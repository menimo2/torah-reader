import 'dart:typed_data';

import 'package:flutter/widgets.dart';

import '../../core/hand_signs.dart';
import 'gif_sign_image.dart'
    if (dart.library.js_interop) 'gif_sign_image_web.dart';

/// Pack 3 image. GIF uses a platform player so the loop actually runs.
class SignPackImage extends StatelessWidget {
  const SignPackImage({
    super.key,
    required this.asset,
    required this.size,
    this.memoryBytes,
  });

  final String asset;
  final double size;
  final Uint8List? memoryBytes;

  @override
  Widget build(BuildContext context) {
    if (memoryBytes != null) {
      return Image.memory(
        memoryBytes!,
        width: size,
        height: size,
        fit: BoxFit.contain,
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
    if (asset.toLowerCase().endsWith('.gif')) {
      return GifSignImage(asset: asset, size: size);
    }
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
