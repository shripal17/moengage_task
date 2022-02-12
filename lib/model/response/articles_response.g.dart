// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'articles_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ArticlesResponse _$ArticlesResponseFromJson(Map<String, dynamic> json) =>
    ArticlesResponse(
      status: $enumDecodeNullable(_$ResponseStatusEnumMap, json['status']) ??
          ResponseStatus.ok,
      articles: (json['articles'] as List<dynamic>?)
          ?.map((e) => Article.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ArticlesResponseToJson(ArticlesResponse instance) =>
    <String, dynamic>{
      'status': _$ResponseStatusEnumMap[instance.status],
      'articles': instance.articles,
    };

const _$ResponseStatusEnumMap = {
  ResponseStatus.ok: 'ok',
  ResponseStatus.error: 'error',
};
