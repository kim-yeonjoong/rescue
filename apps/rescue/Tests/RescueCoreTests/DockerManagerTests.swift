import Testing
@testable import RescueCore

@Suite struct DockerManagerTests {

    @Test func parsesDockerPsOutput() async {
        // Given
        let mock = MockShellExecutor()
        let json = #"{"ID":"abc123","Names":"web-app","Image":"node:18","Status":"Up 2 hours","Ports":"0.0.0.0:3000->3000/tcp, :::3000->3000/tcp"}"#
        await mock.register(
            command: "docker ps -a --format {{json .}}",
            result: ShellResult(exitCode: 0, stdout: json + "\n", stderr: "")
        )
        let manager = DockerManager(shell: mock)

        // When
        let containers = await manager.listContainers()

        // Then
        #expect(containers.count == 1)
        #expect(containers[0].id == "abc123")
        #expect(containers[0].name == "web-app")
        #expect(containers[0].status.isRunning)
    }

    @Test func parsesPortMappings() async {
        // Given
        let mock = MockShellExecutor()
        let json = #"{"ID":"def456","Names":"db","Image":"postgres:15","Status":"Up 5 minutes","Ports":"0.0.0.0:5432->5432/tcp"}"#
        await mock.register(
            command: "docker ps -a --format {{json .}}",
            result: ShellResult(exitCode: 0, stdout: json + "\n", stderr: "")
        )
        let manager = DockerManager(shell: mock)

        // When
        let containers = await manager.listContainers()

        // Then
        #expect(containers.count == 1)
        let ports = containers[0].ports
        #expect(ports.count == 1)
        #expect(ports[0].hostPort == 5432)
        #expect(ports[0].containerPort == 5432)
        #expect(ports[0].proto == "tcp")
    }

    @Test func deduplicatesPorts() {
        // Given: same port exposed on both IPv4 and IPv6
        let portsString = "0.0.0.0:3000->3000/tcp, :::3000->3000/tcp"
        let ports = DockerContainer.parsePorts(portsString)

        // Then: deduplicated to a single mapping
        #expect(ports.count == 1)
        #expect(ports[0].hostPort == 3000)
        #expect(ports[0].containerPort == 3000)
        #expect(ports[0].proto == "tcp")
    }

    @Test func dockerNotAvailable() async {
        // Given
        let mock = MockShellExecutor()
        await mock.register(
            command: "docker ps -q",
            result: ShellResult(exitCode: 1, stdout: "", stderr: "Cannot connect to Docker daemon")
        )
        let manager = DockerManager(shell: mock)

        // When
        let available = await manager.isDockerAvailable()

        // Then
        #expect(!available)
    }

    @Test func emptyContainerList() async {
        // Given
        let mock = MockShellExecutor()
        await mock.register(
            command: "docker ps -a --format {{json .}}",
            result: ShellResult(exitCode: 0, stdout: "", stderr: "")
        )
        let manager = DockerManager(shell: mock)

        // When
        let containers = await manager.listContainers()

        // Then
        #expect(containers.isEmpty)
    }

    @Test func malformedJsonSkipped() async {
        let mock = MockShellExecutor()
        await mock.register(
            command: "docker ps -a --format {{json .}}",
            result: ShellResult(exitCode: 0, stdout: "not json\n", stderr: "")
        )
        let manager = DockerManager(shell: mock)
        let containers = await manager.listContainers()
        #expect(containers.isEmpty)
    }

    @Test func missingFieldsSkipsContainer() async {
        let mock = MockShellExecutor()
        // JSON with missing required "Names" field
        let json = #"{"ID":"abc123","Image":"node:18","Status":"Up 2 hours"}"#
        await mock.register(
            command: "docker ps -a --format {{json .}}",
            result: ShellResult(exitCode: 0, stdout: json + "\n", stderr: "")
        )
        let manager = DockerManager(shell: mock)
        let containers = await manager.listContainers()
        #expect(containers.isEmpty)
    }

    @Test func startContainerFailure() async {
        let mock = MockShellExecutor()
        await mock.register(
            command: "docker start -- abc123",
            result: ShellResult(exitCode: 1, stdout: "", stderr: "Error: No such container")
        )
        let manager = DockerManager(shell: mock)
        let result = await manager.startContainer(id: "abc123")
        #expect(!result)
    }

    @Test func stopContainerFailure() async {
        let mock = MockShellExecutor()
        await mock.register(
            command: "docker stop -- abc123",
            result: ShellResult(exitCode: 1, stdout: "", stderr: "Error: No such container")
        )
        let manager = DockerManager(shell: mock)
        let result = await manager.stopContainer(id: "abc123")
        #expect(!result)
    }

    @Test func rejectsArgumentInjectionInContainerId() async {
        let mock = MockShellExecutor()
        let manager = DockerManager(shell: mock)

        let startResult = await manager.startContainer(id: "--help")
        #expect(!startResult)

        let stopResult = await manager.stopContainer(id: "--rm")
        #expect(!stopResult)

        let restartResult = await manager.restartContainer(id: "-it")
        #expect(!restartResult)
    }

    @Test func parsesMultipleContainers() async {
        let mock = MockShellExecutor()
        let json1 = #"{"ID":"abc","Names":"web","Image":"node:18","Status":"Up 1 hour","Ports":""}"#
        let json2 = #"{"ID":"def","Names":"db","Image":"postgres:15","Status":"Exited (0) 3 hours ago","Ports":""}"#
        await mock.register(
            command: "docker ps -a --format {{json .}}",
            result: ShellResult(exitCode: 0, stdout: json1 + "\n" + json2 + "\n", stderr: "")
        )
        let manager = DockerManager(shell: mock)
        let containers = await manager.listContainers()
        #expect(containers.count == 2)
        #expect(containers[0].status.isRunning)
        #expect(!containers[1].status.isRunning)
    }

    @Test func parsesPausedStatus() async {
        let mock = MockShellExecutor()
        let json = #"{"ID":"ghi","Names":"app","Image":"node:18","Status":"Up 1 hour (Paused)","Ports":""}"#
        await mock.register(
            command: "docker ps -a --format {{json .}}",
            result: ShellResult(exitCode: 0, stdout: json + "\n", stderr: "")
        )
        let manager = DockerManager(shell: mock)
        let containers = await manager.listContainers()
        #expect(containers.count == 1)
        #expect(!containers[0].status.isRunning)
        #expect(containers[0].displayStatus == "Paused")
    }
}
