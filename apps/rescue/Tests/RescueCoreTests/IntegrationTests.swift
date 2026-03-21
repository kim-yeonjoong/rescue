import Testing
import Foundation
import RescueTestSupport
@testable import RescueCore

@Suite
struct IntegrationTests {

    @Test func integrationTest_realLsofOutput() async {
        let shell = ShellExecutor()
        let scanner = PortScanner(shell: shell)
        let entries = await scanner.scan()
        // At minimum, parsing should not crash and all ports should be valid
        #expect(entries.allSatisfy { $0.port > 0 })
    }
}
