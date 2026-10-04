import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../theme/design_a.dart';
import 'health_profile_screen.dart';
import 'login_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text('You will need to log in again to use Her Health.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text(
              'Log out',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await AuthService.logout();

    if (!context.mounted) return;

    // Clear every screen behind us so the back button can't return to a
    // logged-in screen.
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final name = AuthService.firstName ?? '';

    return Scaffold(
      backgroundColor: DA.ground,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: DA.backButton(context),
            ),
            const SizedBox(height: 16),
            Text('Settings', style: DA.heading(30)),
            if (name.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text('Signed in as $name', style: DA.body(15, color: DA.muted)),
            ],
            const SizedBox(height: 28),

            Container(
              decoration: DA.card(),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                    leading: const Icon(Icons.favorite_border_rounded, color: DA.sage),
                    title: Text('Health profile', style: DA.body(16, weight: FontWeight.w700)),
                    subtitle: Text('Your details, contacts and health info', style: DA.body(14, color: DA.quiet)),
                    trailing: const Icon(Icons.chevron_right_rounded, color: DA.quiet),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const HealthProfileScreen()),
                      );
                    },
                  ),
                  const Divider(height: 1, color: DA.divider),
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                    leading: const Icon(Icons.logout_rounded, color: DA.rose),
                    title: Text(
                      'Log out',
                      style: DA.body(16, color: DA.rose, weight: FontWeight.w700),
                    ),
                    onTap: () => _confirmLogout(context),
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
