// ignore: avoid_web_libraries_in_flutter
import 'dart:ui' as ui;

void registerWebViewFactory(String viewType, dynamic Function(int) cb) {
  // ignore: undefined_prefixed_name
  ui.platformViewRegistry.registerViewFactory(viewType, cb);
} 