import 'package:flutter/material.dart';
import '../theme/design_a.dart';
import 'onboarding_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DA.ground,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 40, 24, 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Image.asset('assets/images/logo/logo.png', height: 170),
                  const SizedBox(height: 28),
                  Text(
                    'Her Health',
                    textAlign: TextAlign.center,
                    style: DA.heading(42),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Your wellness journey starts here',
                    textAlign: TextAlign.center,
                    style: DA.body(18, color: DA.muted),
                  ),
                  const SizedBox(height: 48),
                  ElevatedButton(
                    style: DA.primary(),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const OnboardingScreen(),
                        ),
                      );
                    },
                    child: const Text('Get started'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
