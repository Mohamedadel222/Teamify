import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:teamify/features/auth/presentation/cubit/login_cubit.dart';
import 'package:teamify/features/auth/presentation/cubit/auth_state.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/storage/token_storage.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool _isPasswordObscured = true;
  bool _rememberMe = false;

  // الألوان الدقيقة من التصميم المرفق
  final Color primaryTextColor = const Color(0xFF2E4E6E); // الكحلي
  final Color primaryButtonColor = const Color(0xFF4384B6); // الأزرق
  final Color borderColor = const Color(0xFFD1E1F0); // حدود فاتحة
  final Color hintColor = const Color(0xFFAAB8C2); // رمادي فاتح

  @override
  void initState() {
    super.initState();
    emailController.clear();
    passwordController.clear();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _resetAppData() async {
    final storage = sl<TokenStorage>();
    await storage.resetFlow();
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("All data cleared!")));
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  void _submitLogin(LoginCubit cubit) {
    if (_formKey.currentState!.validate()) {
      cubit.login(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: BlocConsumer<LoginCubit, AuthState>(
            listener: (context, state) {
              if (state is AuthSuccess) {
                Navigator.pushReplacementNamed(context, '/home');
              } else if (state is AuthError) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(state.message)));
              }
            },
            builder: (context, state) {
              final cubit = context.read<LoginCubit>();
              return Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 50),
                    // شعار التطبيق (T) مطابق للصورة تماماً
                    Center(
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: primaryTextColor,
                                width: 4.5,
                              ),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Text(
                              'T',
                              style: TextStyle(
                                fontSize: 58,
                                fontWeight:
                                    FontWeight.w900, // سُمك الخط مطابق للصورة
                                color: primaryTextColor,
                                height: 1.1,
                              ),
                            ),
                          ),
                          Positioned(
                            top: -6,
                            right: -6,
                            child: Container(
                              width: 15,
                              height: 15,
                              decoration: const BoxDecoration(
                                color: Color(0xFF007BFF), // النقطة الزرقاء
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 55),

                    _buildLabel("Email"),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: emailController,
                      hint: "example562@gmail.com",
                      prefixIcon: Icons.mail_outline,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Email is required';
                        if (!v.contains('@')) return 'Enter a valid email';
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    _buildLabel("Password"),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: passwordController,
                      hint: "********************",
                      isPassword: true,
                      isObscured: _isPasswordObscured,
                      onToggleVisibility: () => setState(
                        () => _isPasswordObscured = !_isPasswordObscured,
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Password is required';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),

                    // خيار التذكر ونسيان كلمة المرور
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              height: 20,
                              width: 20,
                              child: Checkbox(
                                value: _rememberMe,
                                activeColor: primaryButtonColor,
                                side: BorderSide(color: borderColor, width: 2),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                onChanged: (v) =>
                                    setState(() => _rememberMe = v!),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              "Remember me",
                              style: TextStyle(
                                color: hintColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, AppRouter.forgotPassword);
                            },
                            style: TextButton.styleFrom(padding: EdgeInsets.zero),
                            child: Text(
                              "Forget Password?",
                              style: TextStyle(
                                color: primaryButtonColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.underline,
                                decorationColor: primaryButtonColor,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 35),

                    // زر تسجيل الدخول
                    Center(
                      child: SizedBox(
                        width: 190,
                        height: 52,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryButtonColor,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: state is AuthLoading
                              ? null
                              : () => _submitLogin(cubit),
                          child: state is AuthLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  "Sign in",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // الخط الفاصل "Or"
                    Row(
                      children: [
                        Expanded(
                          child: Divider(
                            color: borderColor.withOpacity(0.5),
                            thickness: 1.5,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: Text(
                            "Or",
                            style: TextStyle(
                              color: hintColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            color: borderColor.withOpacity(0.5),
                            thickness: 1.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),

                    // الأيقونات الاجتماعية الأصلية من ملفات الـ Assets
                    // الأيقونات الاجتماعية مربوطة بالـ Cubit
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Google Login
                        _socialIconCard("assets/images/Icons/Google.png", () {
                          context.read<LoginCubit>().loginWithGoogle();
                        }),
                        
                        // Apple Login
                        _socialIconCard("assets/images/Icons/Apple.png", () {
                          context.read<LoginCubit>().loginWithApple();
                        }),
                        
                        // LinkedIn Login
                        _socialIconCard("assets/images/Icons/Linkedin.png", () {
                          context.read<LoginCubit>().loginWithLinkedIn();
                        }),
                        
                        // GitHub Login
                        _socialIconCard("assets/images/Icons/Github.png", () {
                          context.read<LoginCubit>().loginWithGithub();
                        }),
                      ],
                    ),
                    const SizedBox(height: 45),

                    // رابط إنشاء حساب جديد
                    Center(
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, AppRouter.chooseRole);
                          },
                          child: RichText(
                          text: TextSpan(
                            text: "Don't have an account? ",
                            style: TextStyle(
                              color: hintColor,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                            children: [
                              TextSpan(
                                text: "Sign up",
                                style: TextStyle(
                                  color: primaryTextColor,
                                  fontWeight: FontWeight.w900,
                                  decoration: TextDecoration.underline,
                                  decorationColor: primaryTextColor,
                                ),
                              ),
                            ],
                          ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // مكوّنات المساعدة لتنظيف الكود

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 19,
        fontWeight: FontWeight.bold,
        color: primaryTextColor,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    IconData? prefixIcon,
    bool isPassword = false,
    bool isObscured = false,
    VoidCallback? onToggleVisibility,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isObscured,
      validator: validator,
      style: TextStyle(color: primaryTextColor, fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: hintColor.withOpacity(0.7),
          fontWeight: FontWeight.w400,
        ),
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: primaryTextColor, size: 22)
            : null,
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  isObscured
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: primaryTextColor,
                ),
                onPressed: onToggleVisibility,
              )
            : null,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 18,
          horizontal: 16,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderColor, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryButtonColor, width: 2),
        ),
      ),
    );
  }

  Widget _socialIconCard(String assetPath, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10),
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: borderColor, width: 1.2),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Image.asset(assetPath, fit: BoxFit.contain),
          ),
        ),
      ),
    );
  }
}
