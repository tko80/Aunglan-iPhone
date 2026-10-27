
import SwiftUI
import WebKit

struct ContentView: View {
    var body: some View {
        AunglanWebView()
            .ignoresSafeArea()
    }
}

struct AunglanWebView: UIViewRepresentable {
    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true

        let webView = WKWebView(
            frame: .zero,
            configuration: configuration
        )

        webView.allowsBackForwardNavigationGestures = true

        if let url = URL(
            string: "https://tko80.github.io/Aunglan-iPhone/"
        ) {
            webView.load(URLRequest(url: url))
        }

        return webView
    }

    func updateUIView(
        _ webView: WKWebView,
        context: Context
    ) {}
}

@main
struct AunglanApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
