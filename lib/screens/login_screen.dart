import 'package:flutter/material.dart';
import 'health_setup_screen.dart';
import 'register_screen.dart';
import 'email_verification_screen.dart';
import 'chatbot_screen.dart';
import 'forgot_password_screen.dart';
import '../services/auth_service.dart';
import '../theme/design_a.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool hidePassword = true;
  bool _isLoading = false;

  Future<void> _handleLogin() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showError('Please enter your email and password.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await AuthService.login(email: email, password: password);

      if (!mounted) return;

      // If they've already set up a health journey, skip straight past
      // journey selection and land where they actually left off. A
      // brand-new patient (getExistingHealthJourney returns null) still
      // goes through setup as before.
      final existingJourney = await AuthService.getExistingHealthJourney();

      if (!mounted) return;

      // pushReplacement so the back button doesn't return to the login form.
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => existingJourney != null
              ? const ChatbotScreen()
              : const HealthSetupScreen(),
        ),
      );
    } on AuthException catch (e) {
      if (e.isUnverified) {
        await _sendToVerification(email);
      } else {
        _showError(e.message);
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// The account exists but was never verified (e.g. the user closed the
  /// app after registering). Rather than leaving them stuck, generate fresh
  /// codes and take them straight to the verify screen.
  Future<void> _sendToVerification(String email) async {
    try {
      final result = await AuthService.resendCodes(email: email);

      if (!mounted) return;

      _showError('Please verify your account to continue.');

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EmailVerificationScreen(
            email: email,
            phone: (result['phone'] as String?) ?? '',
            // SIMULATED codes -- see auth.py's register_user for details.
            simulatedEmailCode: result['email_code'] as String?,
            simulatedPhoneCode: result['phone_code'] as String?,
          ),
        ),
      );
    } catch (e) {
      _showError(e.toString());
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red.shade400),
    );
  }

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
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      width: 64,
                      height: 64,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: DA.blush,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Image.asset('assets/images/logo/logo.png'),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text('Welcome back', style: DA.heading(32)),
                  const SizedBox(height: 8),
                  Text('Good to see you again', style: DA.body(17, color: DA.muted)),
                  const SizedBox(height: 32),

                  DA.label('Email address'),
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                    style: DA.body(16),
                    decoration: DA.input(hint: 'you@example.com'),
                  ),
                  const SizedBox(height: 18),

                  DA.label('Password'),
                  TextField(
                    controller: passwordController,
                    obscureText: hidePassword,
                    autofillHints: const [AutofillHints.password],
                    style: DA.body(16),
                    onSubmitted: (_) {
                      if (!_isLoading) _handleLogin();
                    },
                    decoration: DA.input(
                      suffix: IconButton(
                        tooltip: hidePassword ? 'Show password' : 'Hide password',
                        icon: Icon(
                          hidePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                          color: DA.sage,
                        ),
                        onPressed: () {
                          setState(() {
                            hidePassword = !hidePassword;
                          });
                        },
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: DA.rose,
                        textStyle: DA.body(14, weight: FontWeight.w700),
                        minimumSize: const Size(44, 44),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ForgotPasswordScreen(),
                          ),
                        );
                      },
                      child: const Text('Forgot password?'),
                    ),
                  ),
                  const SizedBox(height: 8),

                  ElevatedButton(
                    style: DA.primary(),
                    onPressed: _isLoading ? null : _handleLogin,
                    child: _isLoading ? DA.buttonSpinner : const Text('Log in'),
                  ),

                  const SizedBox(height: 48),
                  Text(
                    "Don't have an account?",
                    textAlign: TextAlign.center,
                    style: DA.body(15, color: DA.muted),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    style: DA.outline(),
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
