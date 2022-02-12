import 'dart:convert';
import 'dart:typed_data';

import 'package:hive/hive.dart';
import 'package:moengage_task/model/common/article.dart';
import 'package:moengage_task/util/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

const _encryptionKeyKey = "moengage_key";

final _encryptionKeyIN = RM.injectFuture<Uint8List>(() async {
  /*
  NOT USING SECURED STORAGE BECAUSE IT REQUIRES MIN SDK VERSION 18
  const FlutterSecureStorage secureStorage = FlutterSecureStorage();*/
  final prefs = await SharedPreferences.getInstance();
  var containsEncryptionKey = prefs.containsKey(_encryptionKeyKey);
  if (!containsEncryptionKey) {
    var key = Hive.generateSecureKey();
    await prefs.setString(_encryptionKeyKey, base64UrlEncode(key));
  }

  return base64Url.decode(prefs.getString(_encryptionKeyKey) ?? '');
});

Future<Uint8List> get encryptionKey => _encryptionKeyIN.stateAsync;

Box<Article> get articlesBox => Hive.box<Article>(ARTICLES_BOX_NAME);
