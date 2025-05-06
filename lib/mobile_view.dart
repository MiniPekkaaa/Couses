import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class MobileKinescopePlayer extends StatelessWidget {
  final String url;
  const MobileKinescopePlayer({required this.url, super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 315,
      child: WebViewWidget(
        controller: WebViewController()
          ..loadRequest(Uri.parse(url))
          ..setJavaScriptMode(JavaScriptMode.unrestricted),
      ),
    );
  }
} 