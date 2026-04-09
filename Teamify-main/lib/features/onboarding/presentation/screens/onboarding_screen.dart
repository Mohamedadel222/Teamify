import 'package:teamify/core/di/service_locator.dart';
import 'package:teamify/core/storage/token_storage.dart';
import 'package:teamify/core/routing/app_router.dart';
import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int currentIndex = 0;

  // البيانات المحدثة بناءً على الصور الأربع المرفقة
  final List<Map<String, dynamic>> onboardingData = [
    {
      "type": "logo",
      "title": "Teamify",
      "image": "assets/images/logo.png", // استبدله بمسار اللوجو الفعلي
    },
    {
      "type": "content",
      "title": "Work smarter together",
      "subtitle": "Work smarter together with AI-powered task allocation.",
      "image":
          "assets/images/onboarding1.png", // الصورة الأولى (الأشخاص واللابتوب)
    },
    {
      "type": "content",
      "title": "Stay ahead",
      "subtitle": "Stay ahead — AI alerts you when tasks are at risk of delay.",
      "image":
          "assets/images/onboarding2.png", // الصورة الثانية (المصافحة عبر الهاتف)
    },
    {
      "type": "content",
      "title": "Communicate safely",
      "subtitle":
          "Communicate safely with end-to-end encryption and secure data protection.",
      "image":
          "assets/images/onboarding3.png", // الصورة الثالثة (النوافذ والرسائل)
    },
  ];

  void nextPage() async {
    if (currentIndex < onboardingData.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    } else {
      await sl<TokenStorage>().saveOnboardingSeen();
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRouter.chooseRole);
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF3B82F6);
    const Color darkColor = Color(0xFF1E293B);
    const Color skipColor = Color(0xFF475569);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // شريط علوي يحتوي على زر Skip (يختفي في أول شاشة ويظهر في الباقي)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: SizedBox(
                height: 40,
                child:
                    currentIndex > 0 && currentIndex < onboardingData.length - 1
                    ? Align(
                        alignment: Alignment.topRight,
                        child: TextButton(
                          onPressed: () => Navigator.pushReplacementNamed(
                            context,
                            AppRouter.chooseRole,
                          ),
                          child: const Text(
                            "Skip",
                            style: TextStyle(
                              color: skipColor,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ),

            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: onboardingData.length,
                onPageChanged: (index) => setState(() => currentIndex = index),
                itemBuilder: (context, index) {
                  final item = onboardingData[index];

                  // تصميم شاشة اللوجو (أول صورة)
                  if (item["type"] == "logo") {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(item["image"], width: 180, height: 180),
                        const SizedBox(height: 24),
                        Text(
                          item["title"],
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF334155),
                          ),
                        ),
                      ],
                    );
                  }

                  // تصميم الشاشات التعريفية (باقي الصور)
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: 3,
                          child: Center(
                            child: Image.asset(
                              item["image"],
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                        Expanded(
                          flex: 2,
                          child: Column(
                            children: [
                              Text(
                                "“${item["subtitle"]}”",
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 20,
                                  color: Color(0xFF334155),
                                  height: 1.5,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // الجزء السفلي: المؤشرات (Dots) والزر
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // لا تظهر المؤشرات في شاشة اللوجو الأولى
                  if (currentIndex > 0)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        onboardingData.length - 1,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: (currentIndex - 1) == index ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: (currentIndex - 1) == index
                                ? primaryColor
                                : const Color(0xFFE2E8F0),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: ElevatedButton(
                      onPressed: nextPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        currentIndex == 0
                            ? "Start"
                            : (currentIndex == onboardingData.length - 1
                                  ? "Get Started"
                                  : "Next"),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
