import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final storage = FlutterSecureStorage();

Future<void> saveToken(String token) async {
  await storage.write(key: 'jwt', value: token);
}

Future<String?> getToken() async {
  return await storage.read(key: 'jwt');
}

Future<void> saveRefreshToken(String refreshToken) async {
  await storage.write(key: 'refreshToken', value: refreshToken);
}

Future<String?> getRefreshToken() async {
  return await storage.read(key: 'refreshToken');
}
