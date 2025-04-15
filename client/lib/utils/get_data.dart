import 'package:cached_query_flutter/cached_query_flutter.dart';
import 'package:client/configs/dio/dio.dart';
import 'package:client/configs/dio/dio_strategy.dart';
import 'package:dio/dio.dart';

Query<T> getPublicData<T>({
  required String queryKey,
  required String url,
}) {
  return Query<T>(
    key: queryKey,
    queryFn: () async {
      try {
        final dio = DioConfig();

        final dioI = dio.dio;

        final response = await dioI.get(url);

        return response.data;
      } on DioException catch (e) {
        return Future.error(
            e.response?.data['message'] ?? 'Internal Server Error');
      }
    },
  );
}

Query<T> getPrivateData<T>({
  required String queryKey,
  required String url,
}) {
  return Query<T>(
    key: queryKey,
    queryFn: () async {
      try {
        final dio = DioConfig();

        dio.setConfig(PrivateRouteStrategy());
        final dioI = dio.dio;

        final response = await dioI.get(url);

        return response.data;
      } on DioException catch (e) {
        return Future.error(
            e.response?.data['message'] ?? 'Internal Server Error');
      }
    },
  );
}

Query<T> getAnonumousData<T>({
  required String queryKey,
  required String url,
  required dynamic data,
  String method = 'GET',
}) {
  return Query<T>(
    key: queryKey,
    queryFn: () async {
      try {
        final dio = DioConfig();

        dio.setConfig(PublicRouteStrategy());
        final dioI = dio.dio;

        final response = await dioI.post(url, data: data);

        return response.data;
      } on DioException catch (e) {
        print(e);
        return Future.error(
            e.response?.data['message'] ?? 'Internal Server Error');
      }
    },
  );
}
