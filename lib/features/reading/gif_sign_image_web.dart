import 'package:flutter/widgets.dart';
import 'package:web/web.dart' as web;

/// Chrome / CanvasKit [Image.asset] often shows only the first GIF frame.
/// A real HTML `<img>` plays the loop.
class GifSignImage extends StatelessWidget {
  const GifSignImage({
    super.key,
    required this.asset,
    required this.size,
  });

  final String asset;
  final double size;

  @override
  Widget build(BuildContext context) {
    final src = Uri.base.resolve('assets/$asset').toString();
    return SizedBox(
      width: size,
      height: size,
      child: HtmlElementView.fromTagName(
        tagName: 'img',
        onElementCreated: (element) {
          final img = element as web.HTMLImageElement;
          img.src = src;
          img.alt = '';
          img.style
            ..width = '100%'
            ..height = '100%'
            ..objectFit = 'contain'
            ..border = '0'
            ..pointerEvents = 'none';
        },
      ),
    );
  }
}
