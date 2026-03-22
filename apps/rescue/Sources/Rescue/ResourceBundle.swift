import Foundation

extension Bundle {
    /// App-bundle-aware resource bundle accessor.
    ///
    /// SPM's auto-generated `Bundle.module` uses `Bundle.main.bundleURL` which
    /// resolves to the `.app/` directory for macOS app bundles, but the resource
    /// bundle is placed in `Contents/Resources/` by the packaging scripts.
    /// This accessor checks `resourceURL` first (correct for `.app` bundles),
    /// then falls back to `bundleURL` (correct for `swift run`).
    static let rescueResources: Bundle = {
        let bundleName = "Rescue_Rescue"

        // .app bundle: Contents/Resources/Rescue_Rescue.bundle
        if let resourceURL = Bundle.main.resourceURL,
           let bundle = Bundle(url: resourceURL.appendingPathComponent("\(bundleName).bundle")) {
            return bundle
        }

        // swift run / swift test: alongside the executable
        if let bundle = Bundle(
            url: Bundle.main.bundleURL.appendingPathComponent("\(bundleName).bundle")
        ) {
            return bundle
        }

        // Fallback to SPM's generated accessor
        return .module
    }()
}
