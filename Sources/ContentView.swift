import SwiftUI
import WebKit

struct ContentView: View {
    var body: some View {
        AunglanWebView()
            .ignoresSafeArea()
    }
}

struct AunglanWebView: UIViewRepresentable {
    func makeCoordinator() -> Coordinator { Coordinator() }

    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true

        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.allowsBackForwardNavigationGestures = true
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator

        if let url = URL(string: "https://tko80.github.io/Aunglan-iPhone/") {
            webView.load(URLRequest(url: url))
        }
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {}

    final class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
        private func openExternally(_ url: URL) {
            DispatchQueue.main.async {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }

        func webView(_ webView: WKWebView,
                     decidePolicyFor navigationAction: WKNavigationAction,
                     decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            guard let url = navigationAction.request.url else {
                decisionHandler(.cancel)
                return
            }

            let scheme = (url.scheme ?? "").lowercased()
            let host = (url.host ?? "").lowercased()

            // Keep the Aunglan website inside the app. Send phone calls, KBZPay,
            // Viber, and App Store links to iOS so the matching app can handle them.
            if ["tel", "sms", "mailto", "kbzpay", "viber"].contains(scheme) {
                decisionHandler(.cancel)
                openExternally(url)
                return
            }
            if scheme == "https" && host == "apps.apple.com" {
                decisionHandler(.cancel)
                openExternally(url)
                return
            }
            if scheme == "http" || scheme == "https" {
                decisionHandler(.allow)
                return
            }

            // Avoid silently trying to load unsupported custom schemes in WKWebView.
            decisionHandler(.cancel)
            openExternally(url)
        }

        // JavaScript confirm()/alert() are used by the website's KPay fallback.
        func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String,
                     initiatedByFrame frame: WKFrameInfo,
                     completionHandler: @escaping () -> Void) {
            let alert = UIAlertController(title: "Aunglan", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in completionHandler() })
            present(alert, from: webView)
        }

        func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String,
                     initiatedByFrame frame: WKFrameInfo,
                     completionHandler: @escaping (Bool) -> Void) {
            let alert = UIAlertController(title: "Aunglan", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in completionHandler(false) })
            alert.addAction(UIAlertAction(title: "Continue", style: .default) { _ in completionHandler(true) })
            present(alert, from: webView)
        }

        private func present(_ alert: UIAlertController, from webView: WKWebView) {
            guard let controller = webView.window?.rootViewController else {
                // Complete the JavaScript panel safely if no presenter is available.
                return
            }
            var top = controller
            while let presented = top.presentedViewController { top = presented }
            top.present(alert, animated: true)
        }
    }
}

@main
struct AunglanApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
