package main

import (
	"context"
	"fmt"
	"os"

	"google.golang.org/protobuf/types/known/anypb"

	agentv1 "github.com/7k-minato/minato/api/agent/v1/minato/agent/v1"
	"github.com/7k-minato/minato/sdk/agent/server"
)

type ${{ values.gameName | replace("-", "") }}Agent struct {
	name    string
	version string
}

func main() {
	agent := &${{ values.gameName | replace("-", "") }}Agent{
		name:    "minato-${{ values.gameName }}",
		version: "0.1.0",
	}

	_, err := server.Serve(agent, server.Options{})
	if err != nil {
		panic(err)
	}

	select {}
}

func (a *${{ values.gameName | replace("-", "") }}Agent) Info(ctx context.Context, req *agentv1.InfoRequest) (*agentv1.InfoResponse, error) {
	actions := []*agentv1.ActionSchema{
		{Name: "restart", Description: "Restart the server", Params: map[string]*agentv1.ParamSchema{}},
	}

	return &agentv1.InfoResponse{
		Name:    a.name,
		Version: a.version,
		Actions: actions,
		Metrics: []*agentv1.MetricDescriptor{},
	}, nil
}

func (a *${{ values.gameName | replace("-", "") }}Agent) HealthCheck(ctx context.Context, req *agentv1.HealthRequest) (*agentv1.HealthResponse, error) {
	return &agentv1.HealthResponse{Ready: true, Message: "healthy"}, nil
}

func (a *${{ values.gameName | replace("-", "") }}Agent) PrepareShutdown(ctx context.Context, req *agentv1.ShutdownRequest) (*agentv1.ShutdownResponse, error) {
	return &agentv1.ShutdownResponse{Success: true}, nil
}

func (a *${{ values.gameName | replace("-", "") }}Agent) GetPlayers(ctx context.Context, req *agentv1.PlayersRequest) (*agentv1.PlayersResponse, error) {
	return &agentv1.PlayersResponse{Online: 0, Capacity: 32}, nil
}

func (a *${{ values.gameName | replace("-", "") }}Agent) ExecuteAction(ctx context.Context, req *agentv1.ExecuteActionRequest) (*agentv1.ExecuteActionResponse, error) {
	switch req.ActionName {
	case "restart":
		return &agentv1.ExecuteActionResponse{State: agentv1.ActionState_ACTION_STATE_SUCCEEDED}, nil
	default:
		return &agentv1.ExecuteActionResponse{State: agentv1.ActionState_ACTION_STATE_REJECTED, Error: "unknown action"}, nil
	}
}

func (a *${{ values.gameName | replace("-", "") }}Agent) Console(stream agentv1.Agent_ConsoleServer) error {
	for {
		msg, err := stream.Recv()
		if err != nil {
			return err
		}
		_ = stream.Send(&agentv1.ConsoleServerMessage{
			Payload: &agentv1.ConsoleServerMessage_Response{Response: &agentv1.ConsoleResponse{Response: "ok"}},
		})
	}
}
