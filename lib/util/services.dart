import 'package:moengage_task/service/articles_service.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

final _articlesService = RM.inject(() => ArticlesService());

ArticlesService get articlesService => _articlesService.state;
