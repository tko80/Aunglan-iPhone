import SwiftUI
import WebKit
import UIKit

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
        // Bridge the website's notification button to a native explanation.
        // WKWebView does not support Safari Home Screen Web Push.
        configuration.userContentController.add(context.coordinator, name: "aunglanPWA")

        let webView = WKWebView(frame: .zero, configuration: configuration)
        context.coordinator.webView = webView
        webView.allowsBackForwardNavigationGestures = true
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator

        if let url = URL(string: "https://tko80.github.io/Aunglan-iPhone/") {
            webView.load(URLRequest(url: url))
        }
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {}

    final class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler {
        weak var webView: WKWebView?

        func userContentController(_ userContentController: WKUserContentController,
                                   didReceive message: WKScriptMessage) {
            guard message.name == "aunglanPWA" else { return }
            DispatchQueue.main.async { [weak self] in
                self?.showPwaNotificationHelp()
            }
        }

        private func showPwaNotificationHelp() {
            guard let webView,
                  let controller = webView.window?.rootViewController else { return }

            let alert = UIAlertController(
                title: "Aunglan Notifications",
                message: "ဒီ IPA (WKWebView) ထဲမှာ Safari Web Push ကို တိုက်ရိုက်ဖွင့်လို့ မရသေးပါ။ Admin Announcement Notification ကို အခမဲ့လက်ခံရန် Safari မှ Aunglan ကိုဖွင့်ပြီး Share → Add to Home Screen လုပ်ထားတဲ့ Aunglan ကို အသုံးပြုပါ။",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "နောက်မှ", style: .cancel))
            alert.addAction(UIAlertAction(title: "Safari ဖွင့်မယ်", style: .default) { [weak self] _ in
                guard let url = URL(string: "https://tko80.github.io/Aunglan-iPhone/") else { return }
                self?.openExternally(url)
            })

            var top = controller
            while let presented = top.presentedViewController { top = presented }
            top.present(alert, animated: true)
        }

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
