package envoy

input: {
	hosts: {
		"api.test": {
			routes: [
				{prefix: "/api/v2/users", target: "user-service"},
				{prefix: "/api/v2", target:       "api-service"},
				{prefix: "/", target:             "monolith"},
			]
		}
		"web.test": {
			routes: [
				{prefix: "/users", target: "frontend-users"},
				{prefix: "/", target:      "monolith"},
			]
		}
		"admin.test": {
			routes: [
				{prefix: "/", target: "monolith"},
			]
		}
	}
	targets: [
		{name: "user-service", port:   8080},
		{name: "api-service", port:    8080},
		{name: "frontend-users", port: 8080},
		{name: "monolith", port:       8080},
	]
}
