import 'package:flutter/material.dart';
import 'web_view_factory.dart';

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
    registerKinescopeViewFactory(viewType, url);

    return SizedBox(
      height: 315,
      child: HtmlElementView(viewType: viewType),
    );
  }
} 