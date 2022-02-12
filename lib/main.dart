import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:moengage_task/adapter/source_item_adapter.dart';
import 'package:moengage_task/model/common/article.dart';
import 'package:moengage_task/screen/home_screen.dart';
import 'package:moengage_task/util/constants.dart';
import 'package:moengage_task/util/states.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(ArticleAdapter());
  Hive.registerAdapter(SourceItemAdapter());
  final _encryptionKey = await encryptionKey;
  await Hive.openBox<Article>(ARTICLES_BOX_NAME, encryptionCipher: HiveAesCipher(_encryptionKey));

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MoEngage Articles',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomeScreen(),
    );
  }
}
