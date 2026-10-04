import 'package:flutter/material.dart';
import 'create_password_screen.dart';
import 'login_screen.dart';
import '../theme/design_a.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DA.ground,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      width: 72,
                      height: 72,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: DA.blush,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Image.asset(
                  'assets/images/logo/logo.png',
                  height: 48,
                  errorBuilder: (_, __, ___) => Icon(Icons.spa, size: 48, color: DA.rose),
                ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text('Welcome, Dr. Mbokota', style: DA.heading(32)),
                  const SizedBox(height: 12),
                  Text(
                    'Your administrator account has been created successfully. '
                    "Let's complete the setup of your Admin Portal. "
                    'This will only take a minute.',
                    style: DA.body(16, color: DA.muted, height: 1.6),
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    style: DA.primary(),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const CreatePasswordScreen()),
                      );
                    },
                    child: const Text('Continue'),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: DA.rose,
                      minimumSize: const Size.fromHeight(48),
                      textStyle: DA.body(15, weight: FontWeight.w700),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                      );
                    },
                    child: const Text('Already have an account? Log in'),
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
