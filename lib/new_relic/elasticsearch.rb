require 'new_relic/elasticsearch/version'
require 'new_relic/agent/method_tracer'
require 'elasticsearch'

DependencyDetection.defer do
  named :elasticsearch

  depends_on do
    defined?(::Elasticsearch::Transport::Client)
  end

  executes do
    ::NewRelic::Agent.logger.info 'Installing Elasticsearch instrumentation'
    require 'new_relic/elasticsearch/operation_resolver'
  end

  executes do
    NewRelic::Agent::MethodTracer.extend(NewRelic::Agent::MethodTracer)

    ::Elasticsearch::Transport::Client.class_eval do
      def perform_request_with_new_relic(method, path, params={}, body=nil)
        resolver = NewRelic::ElasticsearchOperationResolver.new(method, path)

        callback = proc do |result, metric, elapsed|
          # conditionally require body with notice_statement
          if body && params
            statement = body.merge(params)
          else
            statement = body || params
          end
          statement[:additional_parameters] = resolver.operands

          NewRelic::Agent::Datastores.notice_statement(statement, elapsed) if statement
        end

        NewRelic::Agent::Datastores.wrap('Elasticsearch', resolver.operation_name, resolver.scope_path, callback) do
          perform_request_without_new_relic(method, path, params, body)
        end
      end

      alias_method :perform_request_without_new_relic, :perform_request
      alias_method :perform_request, :perform_request_with_new_relic
    end
  end
end


#$list.lines.each.with_object({}) { |l, memo|
#  matches = /(.*?)(POST|GET|PUT|DELETE|HEAD).*(_.*?)\b/.match(l)
#  if matches
#    if memo.has_key?([matches[2], matches[3]])
#      next if memo[[matches[2], matches[3]]] == matches[1].strip
#      memo[[matches[2],matches[3]]] += (" & " + matches[1].strip)
#    else
#      memo[[matches[2],matches[3]]] = matches[1].strip
#    end
#  else
#    matches = /(.*?)(POST|GET|PUT|DELETE|HEAD)/.match(l)
#    if memo.has_key?([matches[2], nil])
#      next if memo[[matches[2], nil]] == matches[1].strip
#      memo[[matches[2], nil]] += (" & " + matches[1].strip)
#    else
#      memo[[matches[2], nil]] = matches[1].strip
#    end
#  end
#}.sort_by { |k,v| k[1] || '_' }.to_h

# }

# split on slash
# first argument that begins with an underscore is the operation
# first element of things before that is the index
# second element is the type
# third is id
#
# arguments after the underscore are the operands

$list = <<-LIST
AliasesExist HEAD /_alias/{name}
AliasesExist HEAD /{index}/_alias/{name}
Analyze GET /_analyze
Analyze GET /{index}/_analyze
Analyze POST /_analyze
Analyze POST /{index}/_analyze
Bulk POST /_bulk
Bulk POST /{index}/_bulk
Bulk POST /{index}/{type}/_bulk
Bulk PUT /_bulk
Bulk PUT /{index}/_bulk
Bulk PUT /{index}/{type}/_bulk
ClearIndicesCache GET /_cache/clear
ClearIndicesCache GET /{index}/_cache/clear
ClearIndicesCache POST /_cache/clear
ClearIndicesCache POST /{index}/_cache/clear
ClearScroll DELETE /_search/scroll
ClearScroll DELETE /_search/scroll/{scroll_id}
CloseIndex POST /_close
CloseIndex POST /{index}/_close
ClusterGetSettings GET /_cluster/settings
ClusterHealth GET /_cluster/health
ClusterHealth GET /_cluster/health/{index}
ClusterReroute POST /_cluster/reroute
ClusterSearchShards GET /_search_shards
ClusterSearchShards GET /{index}/_search_shards
ClusterSearchShards GET /{index}/{type}/_search_shards
ClusterSearchShards POST /_search_shards
ClusterSearchShards POST /{index}/_search_shards
ClusterSearchShards POST /{index}/{type}/_search_shards
ClusterState GET /_cluster/state
ClusterUpdateSettings PUT /_cluster/settings
Count GET /_count
Count GET /{index}/_count
Count GET /{index}/{type}/_count
Count POST /_count
Count POST /{index}/_count
Count POST /{index}/{type}/_count
Create POST /{index}/{type}/{id}/_create
Create PUT /{index}/{type}/{id}/_create
CreateIndex POST /{index}
CreateIndex PUT /{index}
Delete DELETE /{index}/{type}/{id}
DeleteByQuery DELETE /{index}/_query
DeleteByQuery DELETE /{index}/{type}/_query
DeleteIndex DELETE /
DeleteIndex DELETE /{index}
DeleteIndexTemplate DELETE /_template/{name}
DeleteMapping DELETE /{index}/{type}/_mapping
DeleteWarmer DELETE /{index}/_warmer
DeleteWarmer DELETE /{index}/_warmer/{name}
DeleteWarmer DELETE /{index}/{type}/_warmer/{name}
Explain GET /{index}/{type}/{id}/_explain
Explain POST /{index}/{type}/{id}/_explain
Flush GET /_flush
Flush GET /{index}/_flush
Flush POST /_flush
Flush POST /{index}/_flush
GatewaySnapshot POST /_gateway/snapshot
GatewaySnapshot POST /{index}/_gateway/snapshot
Get GET /{index}/{type}/{id}
GetAliases GET /_alias/{name}
GetAliases GET /{index}/_alias/{name}
GetIndexTemplate GET /_template
GetIndexTemplate GET /_template/{name}
GetIndicesAliases GET /_aliases
GetIndicesAliases GET /{index}/_aliases
GetMapping GET /_mapping
GetMapping GET /{index}/_mapping
GetMapping GET /{index}/{type}/_mapping
GetSettings GET /_settings
GetSettings GET /{index}/_settings
GetSource GET /{index}/{type}/{id}/_source
GetWarmer GET /{index}/_warmer
GetWarmer GET /{index}/_warmer/{name}
GetWarmer GET /{index}/{type}/_warmer/{name}
Head HEAD /{index}/{type}/{id}
HeadIndexTemplate HEAD /_template/{name}
HeadSource HEAD /{index}/{type}/{id}/_source
Index POST /{index}/{type}
Index POST /{index}/{type}/{id}
Index PUT /{index}/{type}/{id}
IndexDeleteAliases DELETE /{index}/_alias/{name}
IndexFilteredStatsCompletion GET /{index}/_stats/completion
IndexFilteredStatsCompletion GET /{index}/_stats/completion/{fields}
IndexFilteredStatsDocs GET /{index}/_stats/docs
IndexFilteredStatsFielddata GET /{index}/_stats/fielddata
IndexFilteredStatsFielddata GET /{index}/_stats/fielddata/{fields}
IndexFilteredStatsFilter_cache GET /{index}/_stats/filter_cache
IndexFilteredStatsFlush GET /{index}/_stats/flush
IndexFilteredStatsGet GET /{index}/_stats/get
IndexFilteredStatsId_cache GET /{index}/_stats/id_cache
IndexFilteredStatsIndexing GET /{index}/_stats/indexing
IndexFilteredStatsIndexing GET /{index}/_stats/indexing/{indexingTypes2}
IndexFilteredStatsMerge GET /{index}/_stats/merge
IndexFilteredStatsPercolate GET /{index}/_stats/percolate
IndexFilteredStatsRefresh GET /{index}/_stats/refresh
IndexFilteredStatsSearch GET /{index}/_stats/search
IndexFilteredStatsSearch GET /{index}/_stats/search/{searchGroupsStats2}
IndexFilteredStatsStore GET /{index}/_stats/store
IndexFilteredStatsWarmer GET /{index}/_stats/warmer
IndexPutAlias PUT /_alias
IndexPutAlias PUT /{index}/_alias
IndexPutAlias PUT /{index}/_alias/{name}
IndexPutAliasByName PUT /_alias/{name}
Indices GET /_cat/indices
Indices GET /_cat/indices/{index}
IndicesAliases POST /_aliases
IndicesExists HEAD /{index}
IndicesSegments GET /_segments
IndicesSegments GET /{index}/_segments
IndicesStatCompletion GET /_stats/completion
IndicesStatCompletion GET /_stats/completion/{fields}
IndicesStatDocs GET /_stats/docs
IndicesStatFielddata GET /_stats/fielddata
IndicesStatFielddata GET /_stats/fielddata/{fields}
IndicesStatFilter_cache GET /_stats/filter_cache
IndicesStatFlush GET /_stats/flush
IndicesStatGet GET /_stats/get
IndicesStatId_cache GET /_stats/id_cache
IndicesStatIndexing GET /_stats/indexing
IndicesStatIndexing GET /_stats/indexing/{indexingTypes1}
IndicesStatMerge GET /_stats/merge
IndicesStatPercolate GET /_stats/percolate
IndicesStatRefresh GET /_stats/refresh
IndicesStatSearch GET /_stats/search
IndicesStatSearch GET /_stats/search/{searchGroupsStats1}
IndicesStatStore GET /_stats/store
IndicesStatWarmer GET /_stats/warmer
IndicesStats GET /_stats
IndicesStats GET /{index}/_stats
IndicesStatus GET /_status
IndicesStatus GET /{index}/_status
Main GET /
Main HEAD /
Master GET /_cat/master
MoreLikeThis GET /{index}/{type}/{id}/_mlt
MoreLikeThis POST /{index}/{type}/{id}/_mlt
MultiGet GET /_mget
MultiGet GET /{index}/_mget
MultiGet GET /{index}/{type}/_mget
MultiGet POST /_mget
MultiGet POST /{index}/_mget
MultiGet POST /{index}/{type}/_mget
MultiPercolate POST /_mpercolate
MultiPercolate POST /{index}/_mpercolate
MultiPercolate POST /{index}/{type}/_mpercolate
MultiSearch GET /_msearch
MultiSearch GET /{index}/_msearch
MultiSearch GET /{index}/{type}/_msearch
MultiSearch POST /_msearch
MultiSearch POST /{index}/_msearch
MultiSearch POST /{index}/{type}/_msearch
MultiTermVectors GET /_mtermvectors
MultiTermVectors GET /{index}/_mtermvectors
MultiTermVectors GET /{index}/{type}/_mtermvectors
MultiTermVectors POST /_mtermvectors
MultiTermVectors POST /{index}/_mtermvectors
MultiTermVectors POST /{index}/{type}/_mtermvectors
NodeInfoHttp GET /_nodes/{nodeId}/http
NodeInfoJvm GET /_nodes/{nodeId}/jvm
NodeInfoNetwork GET /_nodes/{nodeId}/network
NodeInfoOs GET /_nodes/{nodeId}/os
NodeInfoPlugin GET /_nodes/{nodeId}/plugin
NodeInfoProcess GET /_nodes/{nodeId}/process
NodeInfoSettings GET /_nodes/{nodeId}/settings
NodeInfoThread_pool GET /_nodes/{nodeId}/thread_pool
NodeInfoTransport GET /_nodes/{nodeId}/transport
NodeStatsFs GET /_nodes/{nodeId}/stats/fs
NodeStatsHttp GET /_nodes/{nodeId}/stats/http
NodeStatsIndices GET /_nodes/{nodeId}/stats/indices
NodeStatsIndices GET /_nodes/{nodeId}/stats/indices/{flags}
NodeStatsIndices GET /_nodes/{nodeId}/stats/indices/{flags}/{fields}
NodeStatsJvm GET /_nodes/{nodeId}/stats/jvm
NodeStatsNetwork GET /_nodes/{nodeId}/stats/network
NodeStatsOs GET /_nodes/{nodeId}/stats/os
NodeStatsProcess GET /_nodes/{nodeId}/stats/process
NodeStatsThread_pool GET /_nodes/{nodeId}/stats/thread_pool
NodeStatsTransport GET /_nodes/{nodeId}/stats/transport
Nodes GET /_cat/nodes
NodesHotThreads GET /_nodes/hot_threads
NodesHotThreads GET /_nodes/{nodeId}/hot_threads
NodesInfo GET /_nodes
NodesInfo GET /_nodes/{nodeId}
NodesInfoHttp GET /_nodes/http
NodesInfoJvm GET /_nodes/jvm
NodesInfoNetwork GET /_nodes/network
NodesInfoOs GET /_nodes/os
NodesInfoPlugin GET /_nodes/plugin
NodesInfoProcess GET /_nodes/process
NodesInfoSettings GET /_nodes/settings
NodesInfoThread_pool GET /_nodes/thread_pool
NodesInfoTransport GET /_nodes/transport
NodesRestart POST /_cluster/nodes/_restart
NodesRestart POST /_cluster/nodes/{nodeId}/_restart
NodesShutdown POST /_cluster/nodes/{nodeId}/_shutdown
NodesShutdown POST /_shutdown
NodesStats GET /_nodes/stats
NodesStats GET /_nodes/{nodeId}/stats
NodesStatsFs GET /_nodes/stats/fs
NodesStatsHttp GET /_nodes/stats/http
NodesStatsIndices GET /_nodes/stats/indices
NodesStatsIndices GET /_nodes/stats/indices/{flags}
NodesStatsIndices GET /_nodes/stats/indices/{flags}/{fields}
NodesStatsJvm GET /_nodes/stats/jvm
NodesStatsNetwork GET /_nodes/stats/network
NodesStatsOs GET /_nodes/stats/os
NodesStatsProcess GET /_nodes/stats/process
NodesStatsThread_pool GET /_nodes/stats/thread_pool
NodesStatsTransport GET /_nodes/stats/transport
OpenIndex POST /_open
OpenIndex POST /{index}/_open
Optimize GET /_optimize
Optimize GET /{index}/_optimize
Optimize POST /_optimize
Optimize POST /{index}/_optimize
PendingClusterTasks GET /_cluster/pending_tasks
Percolate GET /{index}/{type}/_percolate
Percolate GET /{index}/{type}/{id}/_percolate
Percolate POST /{index}/{type}/_percolate
Percolate POST /{index}/{type}/{id}/_percolate
PercolateCount GET /{index}/{type}/_percolate/count
PercolateCount GET /{index}/{type}/{id}/_percolate/count
PercolateCount POST /{index}/{type}/_percolate/count
PercolateCount POST /{index}/{type}/{id}/_percolate/count
PutIndexTemplate POST /_template/{name}
PutIndexTemplate PUT /_template/{name}
PutMapping POST /{index}/_mapping
PutMapping POST /{index}/{type}/_mapping
PutMapping PUT /{index}/_mapping
PutMapping PUT /{index}/{type}/_mapping
PutWarmer PUT /{index}/_warmer/{name}
PutWarmer PUT /{index}/{type}/_warmer/{name}
Refresh GET /_refresh
Refresh GET /{index}/_refresh
Refresh POST /_refresh
Refresh POST /{index}/_refresh
Search GET /_search
Search GET /{index}/_search
Search GET /{index}/{type}/_search
Search POST /_search
Search POST /{index}/_search
Search POST /{index}/{type}/_search
SearchScroll GET /_search/scroll
SearchScroll GET /_search/scroll/{scroll_id}
SearchScroll POST /_search/scroll
SearchScroll POST /_search/scroll/{scroll_id}
Shards GET /_cat/shards
Suggest GET /_suggest
Suggest GET /{index}/_suggest
Suggest POST /_suggest
Suggest POST /{index}/_suggest
TermVector GET /{index}/{type}/{id}/_termvector
TermVector POST /{index}/{type}/{id}/_termvector
TypesExists HEAD /{index}/{type}
Update POST /{index}/{type}/{id}/_update
UpdateSettings PUT /_settings
UpdateSettings PUT /{index}/_settings
ValidateQuery GET /_validate/query
ValidateQuery GET /{index}/_validate/query
ValidateQuery GET /{index}/{type}/_validate/query
ValidateQuery POST /_validate/query
ValidateQuery POST /{index}/_validate/query
ValidateQuery POST /{index}/{type}/_validate/query
LIST