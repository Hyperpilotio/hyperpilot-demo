package pathfinder

import (
	"time"

	"golang.org/x/net/context"

	"github.com/go-kit/kit/endpoint"

	"github.com/marcusolsson/pathfinder/path"
)

type shortestPathRequest struct {
	From string `json:"from"`
	To   string `json:"to"`
}

type shortestPathResponse struct {
	Paths []path.TransitPath `json:"paths,omitempty"`
	Err   error              `json:"error,omitempty"`
}

func (r shortestPathResponse) error() error { return r.Err }

func makeShortestPathEndpoint(ps PathService, psStat *PathServiceStat) endpoint.Endpoint {
	return func(ctx context.Context, request interface{}) (interface{}, error) {
		defer func(begin time.Time) {
			psStat.requestCount.With("method", "make_shortest_path").Add(1)
			psStat.requestLatency.With("method", "make_shortest_path").Observe(time.Since(begin).Seconds())
		}(time.Now())

		req := request.(shortestPathRequest)
		paths, err := ps.ShortestPath(req.From, req.To)
		return shortestPathResponse{Paths: paths, Err: err}, nil
	}
}
