import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class RoleStorage {
  final FlutterSecureStorage storage;

  RoleStorage(this.storage);

  static const _roleKey = "user_role";

  Future<void> saveRole(String role) async {
    await storage.write(key: _roleKey, value: role);
  }

  Future<String?> getRole() async {
    return await storage.read(key: _roleKey);
  }
}