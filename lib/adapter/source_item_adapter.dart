import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:moengage_task/model/common/article.dart';

class SourceItemAdapter1 extends TypeAdapter<SourceItem> {
  @override
  int get typeId => 2;

  @override
  SourceItem read(BinaryReader reader) {
    return SourceItem.fromJson(jsonDecode(reader.readString()));
  }

  @override
  void write(BinaryWriter writer, SourceItem obj) {
    writer.write(jsonEncode(obj.toJson()));
  }
}
