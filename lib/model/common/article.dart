import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'article.g.dart';

// The main Article Data Class
@JsonSerializable()
@HiveType(typeId: 1)
class Article extends HiveObject {
  @HiveField(0)
  SourceItem? source;
  @HiveField(1)
  String? author;
  @HiveField(2)
  String title;
  @HiveField(3)
  String? description;
  @HiveField(4)
  String url;
  @HiveField(5)
  String urlToImage;
  @HiveField(6)
  DateTime? publishedAt;
  @HiveField(7)
  String? content;

  Article({this.source, this.author, this.title = "", this.description = "", this.url = "", this.urlToImage = "", this.publishedAt, this.content});

  factory Article.fromJson(Map<String, dynamic> json) => _$ArticleFromJson(json);

  Map<String, dynamic> toJson() => _$ArticleToJson(this);
}

@JsonSerializable()
@HiveType(typeId: 2)
class SourceItem {
  @HiveField(0)
  String? id;
  @HiveField(1)
  String name;

  SourceItem({this.id, this.name = ""});

  factory SourceItem.fromJson(Map<String, dynamic> json) => _$SourceItemFromJson(json);

  Map<String, dynamic> toJson() => _$SourceItemToJson(this);
}
