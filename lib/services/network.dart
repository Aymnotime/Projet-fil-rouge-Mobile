import 'package:dio/dio.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

final Dio dio = Dio();
late PersistCookieJar cookieJar;

Future<void> setupDio() async {
  final appDocDir = await getApplicationDocumentsDirectory();
  final cookiePath = '${appDocDir.path}/.cookies/';
  final cookieDir = Directory(cookiePath);
  if (!await cookieDir.exists()) {
    await cookieDir.create(recursive: true);
  }
  cookieJar = PersistCookieJar(
    storage: FileStorage(cookiePath),
    persistSession: true,
  );
  dio.interceptors.clear();
  dio.interceptors.add(CookieManager(cookieJar));
  dio.options.followRedirects = false;
  dio.options.validateStatus = (status) => status != null && status < 500;
}

Future<void> initializeNetwork() async {
  await setupDio();
}
