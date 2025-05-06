// ignore: avoid_web_libraries_in_flutter
import 'dart:ui' as ui;
import 'package:universal_html/html.dart' as html;

void registerKinescopeViewFactory(String viewType, String url) {
  // ignore: undefined_prefixed_name
  ui.platformViewRegistry.registerViewFactory(viewType, (int viewId) {
    final iframe = html.IFrameElement()
      ..src = url
      ..style.border = 'none'
      ..allowFullscreen = true
      ..width = '100%'
      ..height = '315';
    return iframe;
  });
} 