import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:universal_html/html.dart' as html;

class WebKinescopePlayer extends StatelessWidget {
  final String url;
  final String viewType;

  const WebKinescopePlayer({
    required this.url,
    required this.viewType,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // Регистрируем view factory
    registerViewFactory(viewType, (int viewId) {
      final iframe = html.IFrameElement()
        ..src = url
        ..style.border = 'none'
        ..allowFullscreen = true
        ..width = '100%'
        ..height = '315';
      return iframe;
    });

    return SizedBox(
      height: 315,
      child: HtmlElementView(viewType: viewType),
    );
  }
} 