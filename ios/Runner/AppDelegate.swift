import UIKit
import Flutter
import WebKit

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    private var webView: WKWebView?
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
        let channel = FlutterMethodChannel(name: "kinescope_player", binaryMessenger: controller.binaryMessenger)
        
        channel.setMethodCallHandler({
            [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            guard let self = self else { return }
            
            if call.method == "initPlayer" {
                if let args = call.arguments as? [String: Any],
                   let videoId = args["videoId"] as? String {
                    self.initKinescopePlayer(videoId: videoId)
                    result(nil)
                } else {
                    result(FlutterError(code: "INVALID_ARGUMENT",
                                      message: "Video ID is required",
                                      details: nil))
                }
            } else {
                result(FlutterMethodNotImplemented)
            }
        })
        
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    private func initKinescopePlayer(videoId: String) {
        DispatchQueue.main.async {
            let webConfiguration = WKWebViewConfiguration()
            self.webView = WKWebView(frame: .zero, configuration: webConfiguration)
            
            guard let webView = self.webView else { return }
            
            if let viewController = self.window?.rootViewController {
                viewController.view.addSubview(webView)
                webView.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    webView.topAnchor.constraint(equalTo: viewController.view.topAnchor),
                    webView.leadingAnchor.constraint(equalTo: viewController.view.leadingAnchor),
                    webView.trailingAnchor.constraint(equalTo: viewController.view.trailingAnchor),
                    webView.bottomAnchor.constraint(equalTo: viewController.view.bottomAnchor)
                ])
                
                let url = URL(string: "https://kinescope.io/embed/\(videoId)")!
                let request = URLRequest(url: url)
                webView.load(request)
            }
        }
    }
} 