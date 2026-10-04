import 'package:flutter/material.dart';
import '../theme/design_a.dart';
import 'register_screen.dart';
import 'login_screen.dart';
import 'information_screen.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DA.ground,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Image.asset('assets/images/logo/logo.png', height: 110),
                  const SizedBox(height: 18),
                  Text(
                    'Her Health',
                    textAlign: TextAlign.center,
                    style: DA.heading(36),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your personal health companion',
                    textAlign: TextAlign.center,
                    style: DA.body(18, color: DA.muted),
                  ),
                  const SizedBox(height: 28),

                  buildInfoCard(
                    icon: Icons.auto_awesome,
                    title: 'AI Health Companion',
                    description:
                        'Get trusted health information, receive personalised guidance, and ask questions anytime.',
                  ),
                  buildInfoCard(
                    icon: Icons.favorite_border_rounded,
                    title: 'Track Your Health',
                    description:
                        'Monitor your menstrual cycle, pregnancy, symptoms, and appointments in one place.',
                  ),
                  buildInfoCard(
                    icon: Icons.medical_services_outlined,
                    title: 'Stay Connected',
                    description:
                        'Request appointments, receive reminders, and keep your health journey organised.',
                  ),

                  const SizedBox(height: 24),
                  ElevatedButton(
                    style: DA.primary(),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RegisterScreen(),
                        ),
                      );
                    },
                    child: const Text('Create account'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    style: DA.outline(),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    },
                    child: const Text('Log in'),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: DA.sage,
                      minimumSize: const Size.fromHeight(48),
                      textStyle: DA.body(15, weight: FontWeight.w700),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const InformationScreen(),
                        ),
                      );
                    },
                    child: const Text('Learn more about Her Health'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildInfoCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: DA.card(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: DA.blush,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: DA.rose, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: DA.body(16, weight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(description, style: DA.body(14, color: DA.muted, height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
