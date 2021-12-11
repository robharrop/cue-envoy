package envoy

#_RouteTransform: {
	_route: #Route
	match: {
		if _route["prefix"] != _|_ {
			prefix: _route.prefix
		}
		if _route["regex"] != _|_ {
			safe_regex: {
				google_re2: {}
				regex: _route.regex
			}
		}
		if _route["path"] != _|_ {
			path: _route.path
		}
	}
	route: {
		cluster: _route.target
	}
}

#_VHostTransform: {
	_host: #VHost
	_name: #VHostName

	name: _name
	domains: [_name]
	routes: [ for r in _host.routes {#_RouteTransform & {_route: r}}]
}

#_ListenerTransform: {
	_hosts: [#VHostName]: #VHost

	name: "http"
	address: {
		socket_address: {
			address:    "0.0.0.0"
			port_value: 80
		}
	}
	filter_chains: [{
		filters: [
			{
				name: "envoy.filters.network.http_connection_manager"
				typed_config: {
					"@type":     "type.googleapis.com/envoy.extensions.filters.network.http_connection_manager.v3.HttpConnectionManager"
					stat_prefix: "ingress_http"
					access_log: [{
						name: "envoy.access_loggers.stdout"
						typed_config: {
							"@type": "type.googleapis.com/envoy.extensions.access_loggers.stream.v3.StdoutAccessLog"
						}
					}]
					http_filters: [
						{name: "envoy.filters.http.router"},
					]
					route_config: {
						name: "local_route"
						virtual_hosts: [ for n, h in _hosts {#_VHostTransform & {_host: h, _name: n}}]
					}
				}
			},
		]
	},
	]

}
#TargetTransform: {
	_target: #Target

	name:            _target.name
	connect_timeout: "15s"
	type:            "strict_dns"
	load_assignment: {
		cluster_name: _target.name
		endpoints: [{
			lb_endpoints: [{
				endpoint: {
					address: {
						socket_address: {
							address:    _target.name
							port_value: _target.port
						}
					}
				}
			}]
		}]
	}
}

result: {
	static_resources: {
		listeners: [#_ListenerTransform & {_hosts: input.hosts}]
		clusters: [ for t in input.targets {#TargetTransform & {_target: t}}]
	}
}
