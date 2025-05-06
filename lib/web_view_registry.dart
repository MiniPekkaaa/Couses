import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:universal_html/html.dart' as html;

void registerWebViewFactory(String viewType, dynamic Function(int) factory) {
  if (kIsWeb) {
    registerViewFactory(viewType, factory);
  }
}

html.IFrameElement createKinescopeIframe(String url) {
  return html.IFrameElement()
    ..src = url
    ..style.border = 'none'
    ..allowFullscreen = true
    ..width = '100%'
    ..height = '315';
} 