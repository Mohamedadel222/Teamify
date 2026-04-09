import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/password_reset_cubit.dart';
import '../../../../core/routing/app_router.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final Color primaryTextColor = const Color(0xFF2E4E6E);
  final Color primaryButtonColor = const Color(0xFF4384B6);
  final Color borderColor = const Color(0xFFD1E1F0);
  final Color hintColor = const Color(0xFFAAB8C2);

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: primaryTextColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Forgot Password',
          style: TextStyle(
            color: primaryTextColor,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              children: [
                _dot(true),
                const SizedBox(width: 4),
                _dot(false),
                const SizedBox(width: 4),
                _dot(false),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: BlocConsumer<PasswordResetCubit, PasswordResetState>(
          listener: (context, state) {
            if (state is OtpSent) {
              Navigator.pushNamed(
                context,
                AppRouter.otpVerification,
                arguments: emailController.text.trim(),
              );
            } else if (state is PasswordResetError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
          builder: (context, state) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 30),
                    // Illustration
                    SizedBox(
                      height: 200,
                      child: Image.asset(
                        'assets/images/onboarding2.png',
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => Icon(
                          Icons.lock_reset,
                          size: 120,
                          color: primaryButtonColor.withAlpha(100),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Forgot Password?',
                      style: TextStyle(
                        color: primaryTextColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 30),
                    // Email Label
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Your Email',
                        style: TextStyle(
                          color: primaryTextColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Email Field
                    TextFormField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Email is required';
                        if (!v.contains('@')) return 'Enter a valid email';
                        return null;
                      },
                      decoration: InputDecoration(
                        hintText: 'example562@gmail.com',
                        hintStyle: TextStyle(color: hintColor, fontSize: 14),
                        prefixIcon: Icon(Icons.mail_outline, color: hintColor),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: borderColor),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: primaryButtonColor),
                        ),
                      ),
                    ),
                    const SizedBox(height: 50),
                    // Got OTP Button
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: state is PasswordResetLoading
                            ? null
                            : () {
                                if (_formKey.currentState!.validate()) {
                                  context.read<PasswordResetCubit>().forgotPassword(
                                    email: emailController.text.trim(),
                                  );
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryButtonColor,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: state is PasswordResetLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Got OTP',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _dot(bool active) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: active ? primaryButtonColor : borderColor,
      ),
    );
  }
}
