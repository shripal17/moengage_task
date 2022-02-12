import 'package:dio/dio.dart';
import 'package:moengage_task/model/common/api_error.dart';
import 'package:moengage_task/model/common/general_response.dart';
import 'package:moengage_task/util/helpers.dart';

mixin BaseApi {
  Future<GeneralResponse<T>> loadResponse<T>(Future<T> Function() executor) async {
    GeneralResponse<T> resp;

    try {
      resp = GeneralResponse(data: await executor(), statusCode: 200);
    } on DioError catch (e) {
      if (e.message.contains('SocketException') || e.type == DioErrorType.receiveTimeout || e.type == DioErrorType.connectTimeout) {
        showSimpleDialog("No Internet");
        resp = GeneralResponse<T>(statusCode: -1, dioError: e, apiError: null, data: null);
      } else {
        ApiError? apiError;
        if (e.response != null && e.response?.data != null && e.response?.data is Map<String, dynamic>) {
          apiError = ApiError.fromJson(e.response!.data);
        }
        resp = GeneralResponse(statusCode: e.response?.statusCode ?? 400, dioError: e, apiError: apiError, data: null);
      }
    }
    return resp;
  }
}
