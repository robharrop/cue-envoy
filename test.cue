import "list"

#AlwaysStrictDns: {
    clusters: [
        ...{
            type: "strict_dns"
            ...
        }
    ]
    ...
}

#AlwaysCorrectAddress: {
    clusters: [...{
        name: string
        let _n = name
        load_assignment: {
            cluster_name: _n
            endpoints: [
                {
                    lb_endpoints: [
                        {
                            endpoint: address: socket_address: {
                                address: _n
                                port_value: 8080
                            }
                        }
                    ]
                }
            ]
        }
        ...
    }]
    ...
}

#AllClustersArePresent: {
    let _names = ["user-service", "frontend-users", "api-service", "monolith"]
    
    clusters: [for n in _names {name: or(_names), ...}]

    _clusterNames: list.SortStrings([for c in clusters {c.name}])
    _clusterNames: list.SortStrings(_names)
    
    ...
}

static_resources: #AlwaysStrictDns
static_resources: #AlwaysCorrectAddress
static_resources: #AllClustersArePresent