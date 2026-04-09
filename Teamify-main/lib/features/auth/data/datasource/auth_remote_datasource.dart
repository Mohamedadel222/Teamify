import '../models/user_model.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/api_client.dart';

/// Response wrapper holding user + tokens from backend.
class AuthResponse {
  final UserModel user;
  final String accessToken;
  final String refreshToken;

  AuthResponse({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
  });
}

abstract class AuthRemoteDataSource {
  Future<AuthResponse> login({
    required String email,
    required String password,
  });

  Future<AuthResponse> register({
    required String displayName,
    required String email,
    required String password,
    required String role,
    String? fullName,
    String? userType,
  });

  Future<UserModel> getMe();

  /// Request a password-reset OTP for the given email.
  Future<String> forgotPassword({required String email});

  /// Verify the OTP code. Returns a reset_token on success.
  Future<String> verifyOtp({required String email, required String otp});

  /// Reset the password using the reset token.
  Future<void> resetPassword({required String resetToken, required String newPassword});
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSourceImpl(this.apiClient);

  @override
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    final response = await apiClient.post(
      AppConstants.loginPath,
      data: {
        'email': email,
        'password': password,
      },
    );

    final data = response.data;
    return AuthResponse(
      user: UserModel.fromJson(data['user']),
      accessToken: data['access_token'],
      refreshToken: data['refresh_token'],
    );
  }

  @override
  Future<AuthResponse> register({
    required String displayName,
    required String email,
    required String password,
    required String role,
    String? fullName,
    String? userType,
  }) async {
    final body = <String, dynamic>{
      'display_name': displayName,
      'email': email,
      'password': password,
      'role': role,
    };
    if (fullName != null && fullName.isNotEmpty) body['full_name'] = fullName;
    if (userType != null && userType.isNotEmpty) body['user_type'] = userType;

    final response = await apiClient.post(
      AppConstants.registerPath,
      data: body,
    );

    final data = response.data;
    return AuthResponse(
      user: UserModel.fromJson(data['user']),
      accessToken: data['access_token'],
      refreshToken: data['refresh_token'],
    );
  }

  @override
  Future<UserModel> getMe() async {
    final response = await apiClient.get(AppConstants.mePath);
    return UserModel.fromJson(response.data['user']);
  }

  @override
  Future<String> forgotPassword({required String email}) async {
    final response = await apiClient.post(
      AppConstants.forgotPasswordPath,
      data: {'email': email},
    );
    return response.data['message'] as String;
  }

  @override
  Future<String> verifyOtp({required String email, required String otp}) async {
    final response = await apiClient.post(
      AppConstants.verifyOtpPath,
      data: {'email': email, 'otp': otp},
    );
    return response.data['reset_token'] as String;
  }

  @override
  Future<void> resetPassword({required String resetToken, required String newPassword}) async {
    await apiClient.post(
      AppConstants.resetPasswordPath,
      data: {'reset_token': resetToken, 'new_password': newPassword},
    );
  }
}