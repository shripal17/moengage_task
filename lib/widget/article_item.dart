import 'package:flutter/material.dart';
import 'package:moengage_task/model/common/article.dart';
import 'package:moengage_task/util/extensions.dart';
import 'package:moengage_task/widget/platform_cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';

class ArticleItem extends StatelessWidget {
  final Article article;
  final bool isOffline;
  final Function(bool newOffline)? onOfflineActionPress;

  const ArticleItem({Key? key, required this.article, this.isOffline = false, this.onOfflineActionPress}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: InkWell(
          onTap: () => launch(article.url),
          child: Ink(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                PlatformCachedNetworkImage(article.urlToImage, height: 180, fit: BoxFit.fitWidth),
                const SizedBox(height: 16),
                if (article.source != null) ...{
                  Text("${article.source!.name}${article.author != null ? " (by ${article.author})" : ""}", style: const TextStyle(color: Colors.black45, fontSize: 12)),
                  const SizedBox(height: 8),
                },
                Text(article.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                if (article.description != null) ...{
                  const SizedBox(height: 8),
                  Text(article.description!, style: const TextStyle(color: Colors.black54, fontSize: 14)),
                },
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(article.publishedAt!.humanReadableTime, style: const TextStyle(color: Colors.black45, fontSize: 12)),
                    const Spacer(),
                    IconButton(
                      icon: Icon(isOffline ? Icons.delete : Icons.bookmark),
                      onPressed: () {
                        onOfflineActionPress?.call(!isOffline);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
