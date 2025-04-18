import 'package:cached_query_flutter/cached_query_flutter.dart';
import 'package:client/configs/dio/dio.dart';
import 'package:client/configs/dio/dio_strategy.dart';
import 'package:dio/dio.dart';

Future<dynamic> createMutationFn<T>({
  required T data,
  required String endpoint,
  required String method,
}) async {
  final dio = DioConfig();
  dio.setConfig(PrivateRouteStrategy());

  final dioI = dio.dio;
  try {
    final response = await dioI.request(
      endpoint,
      data: data,
      options: Options(method: method),
    );

    return response.data;
  } on DioException catch (e) {
    return Future.error(e.response?.data['message'] ?? 'Error');
  }
}

Future<void> makeMutation<T>(
  T data,
  Future<T> queryFn,
  Function onSuccess,
  List<String> refetchQueries,
  String key,
  Function onError,
) async {
  final createMutation = Mutation<T, T>(
    queryFn: (data) => queryFn,
    key: key,
    refetchQueries: refetchQueries,
    invalidateQueries: refetchQueries,
    onSuccess: (res, arg) {
      onSuccess();
    },
    onError: (err, arg, fallback) {
      onError();
    },
  );

  createMutation.mutate(data);
}
