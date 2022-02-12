import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// This provider serves image caching across all three platforms: android, ios and web
class PlatformCachedNetworkImageProvider extends ImageProvider {
  final String url;
  final Map<String, String>? headers;
  final double scale;
  NetworkImage? networkImage;
  CachedNetworkImageProvider? cachedNetworkImage;

  PlatformCachedNetworkImageProvider(this.url, {this.headers, this.scale = 1}) {
    if (kIsWeb) {
      networkImage = NetworkImage(url, headers: headers, scale: 1);
    } else {
      cachedNetworkImage = CachedNetworkImageProvider(url, headers: headers, scale: 1);
    }
  }

  @override
  ImageStreamCompleter load(Object key, DecoderCallback decode) =>
      kIsWeb ? networkImage!.load(key as NetworkImage, decode) : cachedNetworkImage!.load(key as CachedNetworkImageProvider, decode);

  @override
  Future<Object> obtainKey(ImageConfiguration configuration) => kIsWeb ? networkImage!.obtainKey(configuration) : cachedNetworkImage!.obtainKey(configuration);
}
