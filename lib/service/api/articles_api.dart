import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:moengage_task/model/response/articles_response.dart';
import 'package:moengage_task/util/helpers.dart';
import 'package:retrofit/retrofit.dart';

part 'articles_api.g.dart';

@RestApi(baseUrl: '')
abstract class ArticlesApi {
  factory ArticlesApi() => _ArticlesApi(buildDio(loggingEnabled: kDebugMode), baseUrl: "https://candidate-test-data-moengage.s3.amazonaws.com/Android/");

  @GET("news-api-feed/staticResponse.json")
  Future<ArticlesResponse> getArticles();
}
