import 'package:flutter/material.dart';
import '../theme/design_a.dart';

class InformationScreen extends StatelessWidget {
  const InformationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DA.ground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: DA.backButton(context),
                  ),
                  const SizedBox(height: 8),
                  Image.asset('assets/images/logo/logo.png', height: 100),
                  const SizedBox(height: 16),
                  Text(
                    'About Her Health',
                    textAlign: TextAlign.center,
                    style: DA.heading(32),
                  ),
                  const SizedBox(height: 28),

                  infoCard(
                    Icons.auto_awesome,
                    'AI Health Companion',
                    'Get trusted health information, receive personalised '
                        'guidance, and ask questions anytime.',
                  ),
                  infoCard(
                    Icons.favorite_border_rounded,
                    'Track Your Health',
                    'Monitor your menstrual cycle, pregnancy journey, '
                        'symptoms and appointments in one place.',
                  ),
                  infoCard(
                    Icons.medical_services_outlined,
                    'Stay Connected',
                    'Request appointments, receive reminders, and keep '
                        'your health journey organised.',
                  ),
                  infoCard(
                    Icons.lock_outline_rounded,
                    'Your Health Matters',
                    'Her Health is designed to support women with '
                        'accessible healthcare information and guidance.',
                  ),

                  const SizedBox(height: 24),
                  OutlinedButton(
                    style: DA.outline(),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Back'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget infoCard(IconData icon, String title, String description) {
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
                Text(title, style: DA.body(17, weight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(description, style: DA.body(15, color: DA.muted, height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
