import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:moengage_task/util/constants.dart';
import 'package:moengage_task/util/helpers.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import 'api_error.dart';

class GeneralResponse<T> {
  T? data;
  DioError? dioError;
  ApiError? apiError;
  int statusCode;

  GeneralResponse({this.data, this.dioError, this.apiError, required this.statusCode});

  bool get success => statusCode <= 299 && statusCode >= 200;

  Future<bool?> showErrorDialog() async {
    if (statusCode == 401) {
      if (dioError != null && !dioError!.requestOptions.uri.toString().endsWith("login")) return false;
    } else if (statusCode == 500) {
      return RM.navigate.toDialog(
        AlertDialog(
          title: const Text("Something went wrong"),
          actionsPadding: const EdgeInsets.only(bottom: 8, right: 8),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text("We are working on fixing it!", style: TextStyles.title, textAlign: TextAlign.center),
              const SizedBox(height: 15),
              Text("$errorTitle\n$errorMessage", style: TextStyles.helper, textAlign: TextAlign.center),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () => RM.navigate.back(true),
            ),
          ],
        ),
        barrierColor: Colors.black54,
      );
    }
    return showSimpleDialog(errorTitle, message: errorMessage);
  }

  String get errorTitle {
    if (apiError != null && apiError?.error != null) {
      return apiError!.error.toString();
    } else if (dioError != null && dioError?.error != null) {
      return dioError!.error!.toString();
    }
    return "Error";
  }

  String get errorMessage {
    if (apiError != null && apiError?.message != null) {
      return apiError!.message!;
    } else if (dioError != null) {
      return dioError!.message;
    }
    return "Something went wrong";
  }
}
