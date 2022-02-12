import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// This widget is capable of loading images (with caching) across all three platforms: android, ios and web
/// Also supports displaying a circular progress indicator with progress while the image gets loaded
class PlatformCachedNetworkImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final Map<String, String>? headers;
  final Color? color;
  final BlendMode? colorBlendMode;
  final Alignment? alignment;
  final Widget Function(BuildContext context, String error)? errorWidget;
  final Widget? placeholder;

  const PlatformCachedNetworkImage(
    this.imageUrl, {
    Key? key,
    this.width,
    this.height,
    this.fit,
    this.headers,
    this.color,
    this.colorBlendMode,
    this.alignment,
    this.errorWidget,
    this.placeholder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return kIsWeb
        ? Image.network(
            imageUrl,
            fit: fit,
            width: width,
            height: height,
            headers: headers,
            color: color,
            colorBlendMode: colorBlendMode,
            alignment: alignment ?? Alignment.center,
            errorBuilder: (context, e, stack) => errorWidget?.call(context, e.toString()) ?? _CommonErrorWidget(error: e, size: width),
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) {
                return child;
              }
              return Center(
                child: placeholder ??
                    CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes! : null,
                    ),
              );
            },
          )
        : CachedNetworkImage(
            imageUrl: imageUrl,
            fit: fit,
            width: width,
            height: height,
            httpHeaders: headers,
            color: color,
            colorBlendMode: colorBlendMode,
            alignment: alignment ?? Alignment.center,
            errorWidget: (context, url, e) => errorWidget?.call(context, e.toString()) ?? _CommonErrorWidget(error: e, size: width),
            progressIndicatorBuilder:
                placeholder == null ? (context, url, loadingProgress) => Center(child: CircularProgressIndicator(value: loadingProgress.progress)) : null,
            placeholder: placeholder != null ? (_, __) => placeholder! : null,
          );
  }
}

class _CommonErrorWidget extends StatelessWidget {
  final dynamic error;
  final double? size;

  const _CommonErrorWidget({Key? key, this.error, this.size}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(Icons.error, size: size),
        const SizedBox(height: 10),
        Text(error.toString()),
      ],
    );
  }
}
