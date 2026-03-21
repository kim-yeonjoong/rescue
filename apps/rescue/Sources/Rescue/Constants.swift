import Foundation

enum Constants {
    static let defaultPollingInterval: TimeInterval = 2.5
    static let dockerPollingMultiplier: Double = 2.0
    static let bannerDismissDelay: Duration = .seconds(2)
    static let killConfirmTimeout: Duration = .seconds(3)
    static let feedbackDisplayDuration: Duration = .seconds(2)
    static let searchDebounceDelay: Duration = .milliseconds(200)
}
