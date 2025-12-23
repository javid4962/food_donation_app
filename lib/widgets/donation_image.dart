import 'dart:io';
import 'package:flutter/material.dart';

class DonationImage extends StatelessWidget {
  final String? photoPath;
  final double? width;
  final double? height;
  final BoxFit fit;

  const DonationImage({
    super.key,
    this.photoPath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    if (photoPath == null || photoPath!.isEmpty) {
      return const Icon(Icons.restaurant, color: Color(0xFF4CAF50));
    }

    // Check if it's a URL (starts with http:// or https://)
    if (photoPath!.startsWith('http://') || photoPath!.startsWith('https://')) {
      return Image.network(
        photoPath!,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.restaurant, color: Color(0xFF4CAF50));
        },
      );
    } else {
      // It's a local file path
      final file = File(photoPath!);
      if (file.existsSync()) {
        return Image.file(
          file,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(Icons.restaurant, color: Color(0xFF4CAF50));
          },
        );
      } else {
        return const Icon(Icons.restaurant, color: Color(0xFF4CAF50));
      }
    }
  }
}
