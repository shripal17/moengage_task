import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

Dio buildDio({bool loggingEnabled = kDebugMode}) {
  final dio = Dio();
  if (loggingEnabled) {
    dio.interceptors.add(PrettyDioLogger(requestHeader: true, responseHeader: true, error: true, compact: false));
  }
  return dio;
}

Future<bool?> showSimpleDialog(String title, {String? message, Widget? content, List<Widget>? actions}) async => RM.navigate.toDialog<bool>(
      AlertDialog(
        title: Text(title),
        content: content ?? (message == null ? null : Text(message, style: const TextStyle(color: Colors.black54))),
        actionsPadding: const EdgeInsets.only(bottom: 8, right: 8),
        actions: actions ??
            [
              TextButton(
                child: const Text('OK'),
                onPressed: () => RM.navigate.back(true),
              ),
            ],
      ),
      barrierColor: Colors.black54,
    );

void showSnackBar(BuildContext context, {required String content, String? actionLabel, Function()? onActionPress}) => ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(content, style: const TextStyle(fontSize: 14, color: Colors.white54)),
        action: (actionLabel != null && onActionPress != null) ? SnackBarAction(label: actionLabel, onPressed: onActionPress, textColor: Colors.white) : null,
      ),
    );
Widget get centeredProgress => const Align(child: CircularProgressIndicator(), alignment: Alignment.center);
