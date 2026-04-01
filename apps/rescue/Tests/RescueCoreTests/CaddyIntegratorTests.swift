import Foundation
import Testing
import RescueTestSupport
@testable import RescueCore

@Suite struct CaddyIntegratorTests {

    // MARK: - JSON Parsing

    @Test func parsesReverseProxyRoutes() async {
        let json = """
        {
            "apps": {
                "http": {
                    "servers": {
                        "srv0": {
                            "listen": [":443"],
                            "routes": [
                                {
                                    "match": [{"host": ["app.localhost"]}],
                                    "handle": [
                                        {
                                            "handler": "reverse_proxy",
                                            "upstreams": [{"dial": "localhost:3000"}]
                                        }
                                    ]
                                },
                                {
                                    "match": [{"host": ["api.localhost"]}],
                                    "handle": [
                                        {
                                            "handler": "reverse_proxy",
                                            "upstreams": [{"dial": "localhost:8080"}]
                                        }
                                    ]
                                }
                            ]
                        }
                    }
                }
            }
        }
        """
        let mock = MockShellExecutor()
        let integrator = CaddyIntegrator(shell: mock)
        let routes = await integrator.parseCaddyJSON(Data(json.utf8))
        #expect(routes != nil)
        #expect(routes?.count == 2)
        #expect(routes?[0].hostname == "app.localhost" || routes?[1].hostname == "app.localhost")
    }

    @Test func parsesSubrouteHandlers() async {
        let json = """
        {
            "apps": {
                "http": {
                    "servers": {
                        "srv0": {
                            "listen": [":443"],
                            "routes": [
                                {
                                    "match": [{"host": ["myapp.localhost"]}],
                                    "handle": [
                                        {
                                            "handler": "subroute",
                                            "routes": [
                                                {
                                                    "handle": [
                                                        {
                                                            "handler": "reverse_proxy",
                                                            "upstreams": [{"dial": "localhost:5000"}]
                                                        }
                                                    ]
                                                }
                                            ]
                                        }
                                    ]
                                }
                            ]
                        }
                    }
                }
            }
        }
        """
        let mock = MockShellExecutor()
        let integrator = CaddyIntegrator(shell: mock)
        let routes = await integrator.parseCaddyJSON(Data(json.utf8))
        #expect(routes?.count == 1)
        #expect(routes?.first?.hostname == "myapp.localhost")
        #expect(routes?.first?.upstreamPort == 5000)
    }

    @Test func returnsNilForEmptyConfig() async {
        let json = """
        {"apps": {}}
        """
        let mock = MockShellExecutor()
        let integrator = CaddyIntegrator(shell: mock)
        let routes = await integrator.parseCaddyJSON(Data(json.utf8))
        #expect(routes == nil)
    }

    @Test func returnsNilForInvalidJSON() async {
        let mock = MockShellExecutor()
        let integrator = CaddyIntegrator(shell: mock)
        let routes = await integrator.parseCaddyJSON(Data("not json".utf8))
        #expect(routes == nil)
    }

    @Test func parsesMultipleUpstreams() async {
        let json = """
        {
            "apps": {
                "http": {
                    "servers": {
                        "srv0": {
                            "listen": [":443"],
                            "routes": [
                                {
                                    "match": [{"host": ["lb.localhost"]}],
                                    "handle": [
                                        {
                                            "handler": "reverse_proxy",
                                            "upstreams": [
                                                {"dial": "localhost:3001"},
                                                {"dial": "localhost:3002"}
                                            ]
                                        }
                                    ]
                                }
                            ]
                        }
                    }
                }
            }
        }
        """
        let mock = MockShellExecutor()
        let integrator = CaddyIntegrator(shell: mock)
        let routes = await integrator.parseCaddyJSON(Data(json.utf8))
        #expect(routes?.count == 2)
    }

    // MARK: - Enrichment

    @Test func enrichesPortEntriesWithCaddyURL() async {
        let mock = MockShellExecutor()
        let integrator = CaddyIntegrator(shell: mock)
        let entries = [
            PortEntry(port: 3000, pid: 100, processName: "node"),
            PortEntry(port: 8080, pid: 200, processName: "java"),
        ]
        let routes = [
            CaddyRoute(hostname: "app.localhost", upstreamPort: 3000),
        ]
        let enriched = integrator.enrichEntries(entries, with: routes)
        #expect(enriched[0].caddyURL == "https://app.localhost")
        #expect(enriched[1].caddyURL == nil)
    }

    // MARK: - Availability

    @Test func isCaddyAvailableWhenAdminAPIReachable() async {
        let mock = MockShellExecutor()
        await mock.register(
            command: "curl -s -o /dev/null -w %{http_code} --connect-timeout 1 http://localhost:2019/config/",
            result: ShellResult(exitCode: 0, stdout: "200", stderr: "")
        )
        let integrator = CaddyIntegrator(shell: mock)
        let available = await integrator.isCaddyAvailable()
        #expect(available == true)
    }

    @Test func isCaddyNotAvailableWhenNoBinary() async {
        let mock = MockShellExecutor()
        // curl fails, which not found, no binary at search paths
        let integrator = CaddyIntegrator(shell: mock, binarySearchPaths: [])
        let available = await integrator.isCaddyAvailable()
        #expect(available == false)
    }

    @Test func isCaddyAvailableWhenBinaryFoundButAPINotReachable() async {
        let mock = MockShellExecutor()
        // curl fails (non-200), but `which caddy` resolves successfully
        await mock.register(
            command: "which caddy",
            result: ShellResult(exitCode: 0, stdout: "/usr/local/bin/caddy", stderr: "")
        )
        let integrator = CaddyIntegrator(shell: mock, binarySearchPaths: [])
        let available = await integrator.isCaddyAvailable()
        #expect(available == true)
    }

    // MARK: - Parsing Edge Cases

    @Test func ignoresNonReverseProxyHandlers() async {
        let json = """
        {
            "apps": {
                "http": {
                    "servers": {
                        "srv0": {
                            "listen": [":443"],
                            "routes": [
                                {
                                    "match": [{"host": ["static.localhost"]}],
                                    "handle": [{"handler": "file_server", "root": "/var/www"}]
                                }
                            ]
                        }
                    }
                }
            }
        }
        """
        let mock = MockShellExecutor()
        let integrator = CaddyIntegrator(shell: mock)
        let routes = await integrator.parseCaddyJSON(Data(json.utf8))
        #expect(routes == nil)
    }

    @Test func ignoresRoutesWithoutHostMatch() async {
        let json = """
        {
            "apps": {
                "http": {
                    "servers": {
                        "srv0": {
                            "listen": [":443"],
                            "routes": [
                                {
                                    "handle": [
                                        {
                                            "handler": "reverse_proxy",
                                            "upstreams": [{"dial": "localhost:3000"}]
                                        }
                                    ]
                                }
                            ]
                        }
                    }
                }
            }
        }
        """
        let mock = MockShellExecutor()
        let integrator = CaddyIntegrator(shell: mock)
        let routes = await integrator.parseCaddyJSON(Data(json.utf8))
        #expect(routes == nil)
    }

    @Test func collectsRoutesFromMultipleServers() async {
        let json = """
        {
            "apps": {
                "http": {
                    "servers": {
                        "srv0": {
                            "listen": [":443"],
                            "routes": [
                                {
                                    "match": [{"host": ["a.localhost"]}],
                                    "handle": [{"handler": "reverse_proxy", "upstreams": [{"dial": "localhost:3000"}]}]
                                }
                            ]
                        },
                        "srv1": {
                            "listen": [":8443"],
                            "routes": [
                                {
                                    "match": [{"host": ["b.localhost"]}],
                                    "handle": [{"handler": "reverse_proxy", "upstreams": [{"dial": "localhost:4000"}]}]
                                }
                            ]
                        }
                    }
                }
            }
        }
        """
        let mock = MockShellExecutor()
        let integrator = CaddyIntegrator(shell: mock)
        let routes = await integrator.parseCaddyJSON(Data(json.utf8))
        #expect(routes?.count == 2)
    }

    // MARK: - CaddyRoute Model

    @Test func routeURLAppendsLocalhostForBareName() {
        let route = CaddyRoute(hostname: "myapp", upstreamPort: 3000)
        #expect(route.url == "https://myapp.localhost")
    }

    @Test func routeURLPreservesFullHostname() {
        let route = CaddyRoute(hostname: "myapp.example.com", upstreamPort: 3000)
        #expect(route.url == "https://myapp.example.com")
    }

    @Test func displayHostnameStripsLocaldomainSuffix() {
        let route = CaddyRoute(hostname: "myapp.localhost", upstreamPort: 3000)
        #expect(route.displayHostname == "myapp")
    }

    @Test func displayHostnamePreservesNonLocaldomainHostname() {
        let route = CaddyRoute(hostname: "myapp.example.com", upstreamPort: 3000)
        #expect(route.displayHostname == "myapp.example.com")
    }

    // MARK: - Availability

    // MARK: - Dial Parsing

    @Test func parsesPortOnlyDialString() async {
        let json = """
        {
            "apps": {
                "http": {
                    "servers": {
                        "srv0": {
                            "listen": [":443"],
                            "routes": [
                                {
                                    "match": [{"host": ["app.localhost"]}],
                                    "handle": [
                                        {
                                            "handler": "reverse_proxy",
                                            "upstreams": [{"dial": ":3000"}]
                                        }
                                    ]
                                }
                            ]
                        }
                    }
                }
            }
        }
        """
        let mock = MockShellExecutor()
        let integrator = CaddyIntegrator(shell: mock)
        let routes = await integrator.parseCaddyJSON(Data(json.utf8))
        #expect(routes?.count == 1)
        #expect(routes?.first?.upstreamPort == 3000)
        #expect(routes?.first?.upstreamHost == "localhost")
    }

    @Test func parsesIPv6DialString() async {
        let json = """
        {
            "apps": {
                "http": {
                    "servers": {
                        "srv0": {
                            "listen": [":443"],
                            "routes": [
                                {
                                    "match": [{"host": ["app.localhost"]}],
                                    "handle": [
                                        {
                                            "handler": "reverse_proxy",
                                            "upstreams": [{"dial": "[::1]:3000"}]
                                        }
                                    ]
                                }
                            ]
                        }
                    }
                }
            }
        }
        """
        let mock = MockShellExecutor()
        let integrator = CaddyIntegrator(shell: mock)
        let routes = await integrator.parseCaddyJSON(Data(json.utf8))
        #expect(routes?.count == 1)
        #expect(routes?.first?.upstreamPort == 3000)
        #expect(routes?.first?.upstreamHost == "[::1]")
    }
}
