import 'package:teamify/core/storage/token_storage.dart';

class CheckAuthUseCase {
  final TokenStorage tokenStorage;

  CheckAuthUseCase(this.tokenStorage);

  Future<bool> call() async {
    final token = await tokenStorage.getToken();
    return token != null;
  }
}