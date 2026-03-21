import SwiftUI
import RescueCore

@MainActor
struct PortActionHandler {
    let actionQueue: ActionResultQueue
    let terminator: ProcessTerminator
    let urlOpener: (URL) -> Void

    func killProcess(entry: PortEntry) async -> Bool {
        let success = await terminator.terminate(pid: entry.pid)
        actionQueue.push(ActionResult(
            message: success ? "Stopped :\(entry.port)" : "Couldn't stop the process",
            isError: !success
        ))
        return success
    }

    func openInBrowser(entry: PortEntry) {
        let urlString = entry.portlessURL ?? "http://localhost:\(entry.port)"
        guard let url = URL(string: urlString),
              url.scheme == "http" || url.scheme == "https" else { return }
        urlOpener(url)
    }

    func copyPort(_ entry: PortEntry) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(String(entry.port), forType: .string)
        actionQueue.push(ActionResult(message: "Port copied", isError: false))
    }

    func copyURL(_ entry: PortEntry) {
        let urlString = entry.portlessURL ?? "http://localhost:\(entry.port)"
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(urlString, forType: .string)
        actionQueue.push(ActionResult(message: "URL copied", isError: false))
    }
}
