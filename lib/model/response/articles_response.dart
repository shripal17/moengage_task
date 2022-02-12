import 'package:json_annotation/json_annotation.dart';
import 'package:moengage_task/model/common/article.dart';

part 'articles_response.g.dart';

// Wrapper Response class as per the given API
@JsonSerializable()
class ArticlesResponse {
  ResponseStatus status;
  List<Article>? articles;

  ArticlesResponse({this.status = ResponseStatus.ok, this.articles});

  factory ArticlesResponse.fromJson(Map<String, dynamic> json) => _$ArticlesResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ArticlesResponseToJson(this);
}

enum ResponseStatus {
  ok,
  error,
}
