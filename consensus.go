package ipfscluster

import (
	"context"
	"errors"
	"strings"
	"sync"
	"time"

	consensus "github.com/libp2p/go-libp2p-consensus"
	host "github.com/libp2p/go-libp2p-host"
	peer "github.com/libp2p/go-libp2p-peer"
	libp2praft "github.com/libp2p/go-libp2p-raft"

	cid "github.com/ipfs/go-cid"
)

const (
	maxSnapshots   = 5
	raftSingleMode = true
)

// Type of pin operation
const (
	LogOpPin = iota + 1
	LogOpUnpin
)

type clusterLogOpType int

// FirstSyncDelay specifies what is the maximum delay
// before the we trigger a Sync operation after starting
// Raft. This is because Raft will need time to sync the global
// state. If not all the ops have been applied after this
// delay, at least the pin tracker will have a partial valid state.
var FirstSyncDelay = 10 * time.Second

// clusterLogOp represents an operation for the OpLogConsensus system.
// It implements the consensus.Op interface.
type clusterLogOp struct {
	Cid   string
	Type  clusterLogOpType
	ctx   context.Context
	rpcCh chan RPC
}

// ApplyTo applies the operation to the State
func (op *clusterLogOp) ApplyTo(cstate consensus.State) (consensus.State, error) {
	state, ok := cstate.(State)
	var err error
	if !ok {
		// Should never be here
		panic("received unexpected state type")
	}

	c, err := cid.Decode(op.Cid)
	if err != nil {
		// Should never be here
		panic("could not decode a CID we ourselves encoded")
	}

	ctx, cancel := context.WithCancel(op.ctx)
	defer cancel()

	switch op.Type {
	case LogOpPin:
		err := state.AddPin(c)
		if err != nil {
			goto ROLLBACK
		}
		// Async, we let the PinTracker take care of any problems
		MakeRPC(ctx, op.rpcCh, NewRPC(TrackRPC, c), false)
	case LogOpUnpin:
		err := state.RmPin(c)
		if err != nil {
			goto ROLLBACK
		}
		// Async, we let the PinTracker take care of any problems
		MakeRPC(ctx, op.rpcCh, NewRPC(UntrackRPC, c), false)
	default:
		logger.Error("unknown clusterLogOp type. Ignoring")
	}
	return state, nil

ROLLBACK:
	// We failed to apply the operation to the state
	// and therefore we need to request a rollback to the
	// cluster to the previous state. This operation can only be performed
	// by the cluster leader.
	rllbckRPC := NewRPC(RollbackRPC, state)
	leadrRPC := NewRPC(LeaderRPC, rllbckRPC)
	MakeRPC(ctx, op.rpcCh, leadrRPC, false)
	logger.Errorf("an error ocurred when applying Op to state: %s", err)
	logger.Error("a rollback was requested")
	// Make sure the consensus algorithm nows this update did not work
	return nil, errors.New("a rollback was requested. Reason: " + err.Error())
}

// Consensus handles the work of keeping a shared-state between
// the members of an IPFS Cluster, as well as modifying that state and
// applying any updates in a thread-safe manner.
type Consensus struct {
	ctx context.Context

	consensus consensus.OpLogConsensus
	actor     consensus.Actor
	baseOp    *clusterLogOp
	rpcCh     chan RPC

	p2pRaft *libp2pRaftWrap

	shutdownLock sync.Mutex
	shutdown     bool
	shutdownCh   chan struct{}
	wg           sync.WaitGroup
}

// NewConsensus builds a new ClusterConsensus component. The state
// is used to initialize the Consensus system, so any information in it
// is discarded.
func NewConsensus(cfg *Config, host host.Host, state State) (*Consensus, error) {
	logger.Info("starting Consensus component")
	ctx := context.Background()
	rpcCh := make(chan RPC, RPCMaxQueue)
	op := &clusterLogOp{
		ctx:   context.Background(),
		rpcCh: rpcCh,
	}
	con, actor, wrapper, err := makeLibp2pRaft(cfg, host, state, op)
	if err != nil {
		return nil, err
	}

	con.SetActor(actor)

	cc := &Consensus{
		ctx:        ctx,
		consensus:  con,
		baseOp:     op,
		actor:      actor,
		rpcCh:      rpcCh,
		p2pRaft:    wrapper,
		shutdownCh: make(chan struct{}),
	}

	cc.run()
	return cc, nil
}

func (cc *Consensus) run() {
	cc.wg.Add(1)
	go func() {
		defer cc.wg.Done()
		ctx, cancel := context.WithCancel(context.Background())
		defer cancel()
		cc.ctx = ctx
		cc.baseOp.ctx = ctx

		upToDate := make(chan struct{})
		go func() {
			logger.Info("consensus state is catching up")
			time.Sleep(time.Second)
			for {
				lai := cc.p2pRaft.raft.AppliedIndex()
				li := cc.p2pRaft.raft.LastIndex()
				logger.Infof("current Raft index: %d/%d", lai, li)
				if lai == li {
					upToDate <- struct{}{}
					break
				}
				time.Sleep(500 * time.Millisecond)
			}
		}()

		logger.Info("consensus state is catching up")
		timer := time.NewTimer(FirstSyncDelay)
		quitLoop := false
		for !quitLoop {
			select {
			case <-timer.C: // Make a first sync
				MakeRPC(ctx, cc.rpcCh, NewRPC(LocalSyncRPC, nil), false)
			case <-upToDate:
				MakeRPC(ctx, cc.rpcCh, NewRPC(LocalSyncRPC, nil), false)
				quitLoop = true
			}
		}

		<-cc.shutdownCh
	}()
}

// Shutdown stops the component so it will not process any
// more updates. The underlying consensus is permanently
// shutdown, along with the libp2p transport.
func (cc *Consensus) Shutdown() error {
	cc.shutdownLock.Lock()
	defer cc.shutdownLock.Unlock()

	if cc.shutdown {
		logger.Debug("already shutdown")
		return nil
	}

	logger.Info("stopping Consensus component")

	// Cancel any outstanding makeRPCs
	cc.shutdownCh <- struct{}{}

	// Raft shutdown
	errMsgs := ""

	f := cc.p2pRaft.raft.Snapshot()
	err := f.Error()
	if err != nil && !strings.Contains(err.Error(), "Nothing new to snapshot") {
		errMsgs += "could not take snapshot: " + err.Error() + ".\n"
	}
	f = cc.p2pRaft.raft.Shutdown()
	err = f.Error()
	if err != nil {
		errMsgs += "could not shutdown raft: " + err.Error() + ".\n"
	}
	err = cc.p2pRaft.transport.Close()
	if err != nil {
		errMsgs += "could not close libp2p transport: " + err.Error() + ".\n"
	}
	err = cc.p2pRaft.boltdb.Close() // important!
	if err != nil {
		errMsgs += "could not close boltdb: " + err.Error() + ".\n"
	}

	if errMsgs != "" {
		errMsgs += "Consensus shutdown unsucessful"
		logger.Error(errMsgs)
		return errors.New(errMsgs)
	}
	cc.wg.Wait()
	cc.shutdown = true
	return nil
}

// RpcChan can be used by Cluster to read any
// requests from this component
func (cc *Consensus) RpcChan() <-chan RPC {
	return cc.rpcCh
}

func (cc *Consensus) op(c *cid.Cid, t clusterLogOpType) *clusterLogOp {
	return &clusterLogOp{
		Cid:  c.String(),
		Type: t,
	}
}

// LogPin submits a Cid to the shared state of the cluster.
func (cc *Consensus) LogPin(c *cid.Cid) error {
	// Create pin operation for the log
	op := cc.op(c, LogOpPin)
	_, err := cc.consensus.CommitOp(op)
	if err != nil {
		// This means the op did not make it to the log
		return err
	}
	logger.Infof("pin commited to global state: %s", c)
	return nil
}

// LogUnpin removes a Cid from the shared state of the cluster.
func (cc *Consensus) LogUnpin(c *cid.Cid) error {
	// Create  unpin operation for the log
	op := cc.op(c, LogOpUnpin)
	_, err := cc.consensus.CommitOp(op)
	if err != nil {
		return err
	}
	logger.Infof("unpin commited to global state: %s", c)
	return nil
}

func (cc *Consensus) State() (State, error) {
	st, err := cc.consensus.GetLogHead()
	if err != nil {
		return nil, err
	}
	state, ok := st.(State)
	if !ok {
		return nil, errors.New("wrong state type")
	}
	return state, nil
}

// Leader() returns the peerID of the Leader of the
// cluster.
func (cc *Consensus) Leader() (peer.ID, error) {
	// FIXME: Hashicorp Raft specific
	raftactor := cc.actor.(*libp2praft.Actor)
	return raftactor.Leader()
}

// TODO
func (cc *Consensus) Rollback(state State) error {
	return cc.consensus.Rollback(state)
}
