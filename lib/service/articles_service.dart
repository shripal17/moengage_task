import 'package:moengage_task/model/common/general_response.dart';
import 'package:moengage_task/model/response/articles_response.dart';

import 'api/articles_api.dart';
import 'api/base_api.dart';

class ArticlesService with BaseApi {
  late ArticlesApi _articlesApi;

  ArticlesService() {
    _articlesApi = ArticlesApi();
  }

  Future<GeneralResponse<ArticlesResponse>> getArticles() => loadResponse(() => _articlesApi.getArticles());
}
