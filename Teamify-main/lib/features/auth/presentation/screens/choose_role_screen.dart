import 'package:flutter/material.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/storage/token_storage.dart';
import '../../../../core/routing/app_router.dart';

class ChooseRoleScreen extends StatefulWidget {
  const ChooseRoleScreen({super.key});

  @override
  State<ChooseRoleScreen> createState() => _ChooseRoleScreenState();
}

class _ChooseRoleScreenState extends State<ChooseRoleScreen> {
  String? selectedRole;

  final List<Map<String, dynamic>> roles = [
    {
      "title": "Freelancer",
      "subtitle": "\"Tell us more about your professional background.\"",
      "icon": Icons.laptop_mac_outlined,
    },
    {
      "title": "Student",
      "subtitle": "\"Help us connect you with the right team.\"",
      "icon": Icons.school_outlined,
    },
    {
      "title": "Guest",
      "subtitle": "\"Just a few details to personalize your experience.\"",
      "icon": Icons.person_search_outlined,
    },
  ];

  void selectRole(String role) {
    setState(() {
      selectedRole = role;
    });
  }

  Future<void> continueFlow() async {
    if (selectedRole == null) return;
    await sl<TokenStorage>().saveUserRole(selectedRole!);
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, AppRouter.register);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            children: [
              const SizedBox(height: 50), // مسافة علوية للوجو
              // Logo Section
              Center(
                child: Container(
                  height: 75,
                  width: 75,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade200),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.asset(
                      'assets/images/logo.png', // تأكد من المسار أو استبدله بـ Icon
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => 
                        const Icon(Icons.apps, size: 40, color: Color(0xFF1A4A7C)),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              // Header Texts
              const Text(
                "Choose Your Role:",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF345A81),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "This helps us personalize your experience",
                style: TextStyle(
                  fontSize: 15,
                  color: Color(0xFF8E99AF),
                ),
              ),
              const SizedBox(height: 40),
              // Role Cards
              Column(
                children: roles.map((role) => _roleCard(
                  role['title'],
                  role['subtitle'],
                  role['icon'],
                )).toList(),
              ),
              // Continue Button
              Padding(
                padding: const EdgeInsets.only(bottom: 40),
                child: SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: selectedRole != null ? continueFlow : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4285B4),
                      disabledBackgroundColor: const Color(0xFF4285B4).withOpacity(0.7),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      "Continue",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, AppRouter.login);
                    },
                    child: RichText(
                    text: const TextSpan(
                      text: "Already have an account? ",
                      style: TextStyle(
                        color: Color(0xFFAAB8C2),
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                      children: [
                        TextSpan(
                          text: "Sign in",
                          style: TextStyle(
                            color: Color(0xFF2E4E6E),
                            fontWeight: FontWeight.w900,
                            decoration: TextDecoration.underline,
                            decorationColor: Color(0xFF2E4E6E),
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
        ),
      ),
    );
  }

  Widget _roleCard(String title, String subtitle, IconData icon) {
    final isSelected = selectedRole == title;
    final Color activeColor = const Color(0xFF4285B4);
    final Color borderColor = isSelected ? activeColor : const Color(0xFFB0C4DE).withOpacity(0.5);

    return GestureDetector(
      onTap: () => selectRole(title),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: borderColor, width: isSelected ? 2 : 1.2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            // Icon Box
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFB0C4DE).withOpacity(0.6)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF1A4A7C),
                size: 26,
              ),
            ),
            const SizedBox(width: 18),
            // Texts
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF4A6889),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}