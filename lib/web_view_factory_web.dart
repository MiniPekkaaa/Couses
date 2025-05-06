// ignore: avoid_web_libraries_in_flutter
import 'dart:ui' as ui;
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:universal_html/html.dart' as html;

void registerKinescopeViewFactory(String viewType, String url) {
  // ignore: undefined_prefixed_name
  registerViewFactory(viewType, (int viewId) {
    final iframe = html.IFrameElement()
      ..src = url
      ..style.border = 'none'
      ..allowFullscreen = true
      ..width = '100%'
      ..height = '315';
    return iframe;
  });
} 