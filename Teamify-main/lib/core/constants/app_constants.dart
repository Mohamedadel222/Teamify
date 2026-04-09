class AppConstants {
  AppConstants._();

  /// Base URL for the Flask backend.
  /// Android emulator → 10.0.2.2 maps to host machine's localhost.
  /// iOS simulator / desktop / web → use localhost directly.
  /// Change this to your production URL when deploying.
  static const String baseUrl = 'http://127.0.0.1:5022/api';

  // Auth
  static const String loginPath = '/auth/login';
  static const String registerPath = '/auth/register';
  static const String refreshPath = '/auth/refresh';
  static const String mePath = '/auth/me';
  static const String forgotPasswordPath = '/auth/forgot-password';
  static const String verifyOtpPath = '/auth/verify-otp';
  static const String resetPasswordPath = '/auth/reset-password';

  // Projects
  static const String projectsPath = '/projects';

  // Tasks
  static const String tasksPath = '/tasks';

  // Users
  static const String profilePath = '/users/profile';

  // Logs
  static const String myLogsPath = '/logs/my';

  // Health
  static const String healthPath = '/health';
}
