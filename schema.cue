package envoy

input: #InputSchema

#InputSchema: {
	hosts: [#VHostName]: #VHost
	targets: #Targets
}

// Virtual Hosts
#VHostName: string
#VHost: {
	routes: [#Route, ...#Route]
}

// Targets
#Targets: [#Target, ...#Target]
#Target: {name: #TargetName, port: >0}
#TargetName: string

// Routes
#Route: #PathRoute | #PrefixRoute | #RegexRoute

#PathRoute: {path: string, target: #ValidTargetName}
#PrefixRoute: {prefix: #Prefix, target: #ValidTargetName}
#RegexRoute: {regex: string, target: #ValidTargetName}

#Prefix: =~"\\^?/[/A-Za-z\\-]*"

#ValidTargetName: or([ for t in input.targets {t.name}])
