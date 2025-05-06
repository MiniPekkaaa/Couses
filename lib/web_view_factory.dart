import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:universal_html/html.dart' as html;
import 'dart:ui' as ui;

void registerKinescopeViewFactory(String viewType, String url) {
  // Регистрируем view factory для web
  if (kIsWeb) {
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
} 