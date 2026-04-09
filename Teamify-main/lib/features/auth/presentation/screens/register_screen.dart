import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/storage/token_storage.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import '../../../../core/routing/app_router.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _isPasswordObscured = true;

  String? role;

  // Freelancer fields
  String? professionalField;
  String? experienceLevel;
  String? availability;
  List<String> primarySkills = [];

  // Student fields
  String? currentLevel;
  String? major;
  List<String> studentSkills = [];
  String? lookingForTeam;

  // Guest fields
  String? reasonForJoining;

  final Color primaryTextColor = const Color(0xFF2E4E6E);
  final Color primaryButtonColor = const Color(0xFF4384B6);
  final Color borderColor = const Color(0xFFD1E1F0);
  final Color hintColor = const Color(0xFFAAB8C2);

  final List<String> allSkills = [
    'UI Design', 'UX Design', 'Flutter', 'React', 'Node.js',
    'Python', 'Java', 'Search', 'Communication', 'Marketing',
    'Data Analysis', 'Project Management', 'Content Creation',
  ];

  final List<String> levelOptions = [
    'First year', 'Second year', 'Third year', 'Fourth year', 'Graduate',
  ];

  final List<String> majorOptions = [
    'Computer Science', 'Information Technology', 'Software Engineering',
    'Data Science', 'Cyber Security', 'Business', 'Design', 'Other',
  ];

  @override
  void initState() {
    super.initState();
    loadRole();
  }

  Future<void> loadRole() async {
    final savedRole = await sl<TokenStorage>().getUserRole();
    setState(() => role = savedRole);
  }

  String _mapRoleToBackend(String uiRole) {
    switch (uiRole.toLowerCase()) {
      case 'guest':
        return 'guest';
      default:
        return 'member';
    }
  }

  String? _mapRoleToUserType(String uiRole) {
    switch (uiRole.toLowerCase()) {
      case 'freelancer':
        return 'freelancer';
      case 'student':
        return 'student';
      default:
        return null;
    }
  }

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
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
          icon: Icon(Icons.arrow_back_ios_new, color: primaryTextColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          role ?? 'Register',
          style: TextStyle(
            color: primaryTextColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: role == null
            ? const Center(child: CircularProgressIndicator())
            : BlocConsumer<AuthCubit, AuthState>(
                listener: (context, state) {
                  if (state is AuthSuccess) {
                    Navigator.pushReplacementNamed(context, AppRouter.home);
                  }
                  if (state is AuthError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(state.message)),
                    );
                  }
                },
                builder: (context, state) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (role!.toLowerCase() == 'guest') ...[
                            const SizedBox(height: 20),
                            Center(child: _buildLogo()),
                            const SizedBox(height: 20),
                          ] else
                            const SizedBox(height: 20),

                          _buildLabel('Full Name'),
                          const SizedBox(height: 8),
                          _buildInputField(
                            controller: fullNameController,
                            hint: 'example',
                          ),
                          const SizedBox(height: 18),

                          _buildLabel('Email'),
                          const SizedBox(height: 8),
                          _buildInputField(
                            controller: emailController,
                            hint: 'example562@gmail.com',
                            suffix: Icon(Icons.mail_outline, color: hintColor, size: 20),
                          ),
                          const SizedBox(height: 18),

                          _buildLabel('Password'),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: passwordController,
                            obscureText: _isPasswordObscured,
                            style: TextStyle(color: primaryTextColor, fontWeight: FontWeight.w600),
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Password is required';
                              if (v.length < 8) return 'At least 8 characters';
                              if (!v.contains(RegExp(r'[A-Z]'))) return 'At least one uppercase letter';
                              if (!v.contains(RegExp(r'[0-9]'))) return 'At least one digit';
                              return null;
                            },
                            decoration: InputDecoration(
                              hintText: '********************',
                              hintStyle: TextStyle(color: hintColor.withValues(alpha: 0.7), fontWeight: FontWeight.w400),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isPasswordObscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                  color: primaryTextColor,
                                ),
                                onPressed: () => setState(() => _isPasswordObscured = !_isPasswordObscured),
                              ),
                              contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: borderColor, width: 1.5),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: primaryButtonColor, width: 2),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Colors.red, width: 1.5),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Colors.red, width: 2),
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),

                          if (role!.toLowerCase() == 'freelancer')
                            _buildFreelancerFields()
                          else if (role!.toLowerCase() == 'student')
                            _buildStudentFields()
                          else if (role!.toLowerCase() == 'guest')
                            _buildGuestFields(),

                          const SizedBox(height: 30),

                          SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: ElevatedButton(
                              onPressed: state is AuthLoading
                                  ? null
                                  : () {
                                      if (_formKey.currentState!.validate()) {
                                        context.read<AuthCubit>().register(
                                          displayName: fullNameController.text.trim(),
                                          email: emailController.text.trim(),
                                          password: passwordController.text.trim(),
                                          role: _mapRoleToBackend(role!),
                                          fullName: fullNameController.text.trim(),
                                          userType: _mapRoleToUserType(role!),
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
                              child: state is AuthLoading
                                  ? const SizedBox(
                                      width: 24, height: 24,
                                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                    )
                                  : const Text(
                                      'Continue',
                                      style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  // ─── Freelancer ──────────────────────────────────────────────────────

  Widget _buildFreelancerFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('Professional Field'),
        const SizedBox(height: 8),
        _buildRadioGroup(
          options: ['Designer', 'Developer', 'Marketer', 'Project Manager', 'Content Creator', 'Other'],
          value: professionalField,
          onChanged: (v) => setState(() => professionalField = v),
        ),
        const SizedBox(height: 18),
        _buildLabel('Experience Level'),
        const SizedBox(height: 8),
        _buildRadioGroup(
          options: ['Beginner', 'Intermediate', 'Expert'],
          value: experienceLevel,
          onChanged: (v) => setState(() => experienceLevel = v),
        ),
        const SizedBox(height: 18),
        _buildLabel('Availability'),
        const SizedBox(height: 8),
        _buildRadioGroup(
          options: ['Full Time', 'Part Time', 'Freelancer'],
          value: availability,
          onChanged: (v) => setState(() => availability = v),
        ),
        const SizedBox(height: 18),
        _buildLabel('Primary Skills'),
        const SizedBox(height: 8),
        _buildChipSelector(
          selected: primarySkills,
          options: allSkills,
          onChanged: (list) => setState(() => primarySkills = list),
        ),
      ],
    );
  }

  // ─── Student ─────────────────────────────────────────────────────────

  Widget _buildStudentFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('Current Level'),
        const SizedBox(height: 8),
        _buildDropdown(value: currentLevel, options: levelOptions, onChanged: (v) => setState(() => currentLevel = v)),
        const SizedBox(height: 18),
        _buildLabel('Major'),
        const SizedBox(height: 8),
        _buildDropdown(value: major, options: majorOptions, onChanged: (v) => setState(() => major = v)),
        const SizedBox(height: 18),
        _buildLabel('Primary Skills'),
        const SizedBox(height: 8),
        _buildChipSelector(selected: studentSkills, options: allSkills, onChanged: (list) => setState(() => studentSkills = list)),
        const SizedBox(height: 18),
        _buildLabel('Looking for a team?'),
        const SizedBox(height: 8),
        _buildRadioGroup(options: ['Yes', 'NO'], value: lookingForTeam, onChanged: (v) => setState(() => lookingForTeam = v)),
      ],
    );
  }

  // ─── Guest ───────────────────────────────────────────────────────────

  Widget _buildGuestFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('Reason for Joining'),
        const SizedBox(height: 8),
        _buildRadioGroup(
          options: ['Reviewing project', 'Viewer', 'Client', 'Mentor'],
          value: reasonForJoining,
          onChanged: (v) => setState(() => reasonForJoining = v),
        ),
      ],
    );
  }

  // ─── Shared Widgets ──────────────────────────────────────────────────

  Widget _buildLogo() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
          decoration: BoxDecoration(
            border: Border.all(color: primaryTextColor, width: 3.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text('T', style: TextStyle(fontSize: 42, fontWeight: FontWeight.w900, color: primaryTextColor, height: 1.1)),
        ),
        Positioned(
          top: -5, right: -5,
          child: Container(width: 12, height: 12, decoration: const BoxDecoration(color: Color(0xFF007BFF), shape: BoxShape.circle)),
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Text(text, style: TextStyle(color: primaryTextColor, fontSize: 16, fontWeight: FontWeight.w700));
  }

  Widget _buildInputField({required TextEditingController controller, required String hint, Widget? suffix}) {
    return TextFormField(
      controller: controller,
      validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
      decoration: InputDecoration(
        hintText: hint, hintStyle: TextStyle(color: hintColor, fontSize: 14), suffixIcon: suffix,
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: borderColor)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: primaryButtonColor)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.red)),
        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.red)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
    );
  }

  Widget _buildRadioGroup({required List<String> options, required String? value, required ValueChanged<String?> onChanged}) {
    return Column(
      children: options.map((option) {
        return GestureDetector(
          onTap: () => onChanged(option),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(children: [
              Container(
                width: 18, height: 18,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: value == option ? primaryButtonColor : borderColor, width: 2),
                ),
                child: value == option
                    ? Center(child: Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: primaryButtonColor)))
                    : null,
              ),
              const SizedBox(width: 10),
              Text(option, style: TextStyle(color: primaryTextColor, fontSize: 14)),
            ]),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDropdown({required String? value, required List<String> options, required ValueChanged<String?> onChanged}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), border: Border.all(color: borderColor)),
      child: Wrap(spacing: 8, runSpacing: 4, children: [
        if (value != null)
          Chip(
            label: Text(value, style: const TextStyle(color: Colors.white, fontSize: 13)),
            backgroundColor: primaryButtonColor, deleteIconColor: Colors.white,
            onDeleted: () => onChanged(null),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
        PopupMenuButton<String>(
          icon: Icon(Icons.keyboard_arrow_down, color: primaryTextColor),
          onSelected: onChanged,
          itemBuilder: (_) => options.map((o) => PopupMenuItem(value: o, child: Text(o))).toList(),
        ),
      ]),
    );
  }

  Widget _buildChipSelector({required List<String> selected, required List<String> options, required ValueChanged<List<String>> onChanged}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), border: Border.all(color: borderColor)),
      child: Wrap(spacing: 8, runSpacing: 4, children: [
        ...selected.map((s) => Chip(
              label: Text(s, style: const TextStyle(color: Colors.white, fontSize: 13)),
              backgroundColor: primaryButtonColor, deleteIconColor: Colors.white,
              onDeleted: () => onChanged(List<String>.from(selected)..remove(s)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            )),
        PopupMenuButton<String>(
          icon: Icon(Icons.keyboard_arrow_down, color: primaryTextColor),
          onSelected: (v) { if (!selected.contains(v)) onChanged([...selected, v]); },
          itemBuilder: (_) => options.where((o) => !selected.contains(o)).map((o) => PopupMenuItem(value: o, child: Text(o))).toList(),
        ),
      ]),
    );
  }
}