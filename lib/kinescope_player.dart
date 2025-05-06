import 'dart:html' as html;
import 'dart:js' as js;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class KinescopePlayer extends StatefulWidget {
  final String videoId;

  const KinescopePlayer({
    Key? key,
    required this.videoId,
  }) : super(key: key);

  @override
  State<KinescopePlayer> createState() => _KinescopePlayerState();
}

class _KinescopePlayerState extends State<KinescopePlayer> {
  static const platform = MethodChannel('kinescope_player');

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    if (html.window.navigator.userAgent.contains('Mobile')) {
      // Для мобильных устройств используем нативный плеер
      await platform.invokeMethod('initPlayer', {'videoId': widget.videoId});
    } else {
      // Для веб используем JavaScript SDK
      final containerId = 'kinescope-player-${widget.videoId}';
      js.context.callMethod('registerKinescopePlayer', [widget.videoId, containerId]);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (html.window.navigator.userAgent.contains('Mobile')) {
      return const SizedBox(
        width: double.infinity,
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      );
    } else {
      return HtmlElementView(
        viewType: 'kinescope-player-${widget.videoId}',
      );
    }
  }
} 