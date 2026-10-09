import 'package:flutter/widgets.dart';

import '../../core/hand_signs.dart';

/// Mobile / tests: [Image.asset] plays GIF frames.
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
    return Image.asset(
      asset,
      width: size,
      height: size,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
      gaplessPlayback: true,
      errorBuilder: (context, error, stackTrace) {
        return Image.asset(
          kJerusalemDefaultHandAsset,
          width: size,
          height: size,
          fit: BoxFit.contain,
        );
      },
    );
  }
}
