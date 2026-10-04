import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../theme/design_a.dart';
import 'login_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final emailController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final List<TextEditingController> codeControllers =
      List.generate(6, (index) => TextEditingController());

  String selectedMethod = 'email';
  bool _codeRequested = false;
  bool _isRequesting = false;
  bool _isResetting = false;
  bool _hidePassword = true;

  String? _phoneForDisplay;
  String? _simulatedCode;

  String get _enteredCode => codeControllers.map((c) => c.text).join();

  Future<void> _handleRequestCode() async {
    final email = emailController.text.trim();
    if (email.isEmpty) {
      _showError('Please enter your email address.');
      return;
    }

    setState(() {
      _isRequesting = true;
    });

    try {
      final result = await AuthService.requestPasswordReset(
        email: email,
        method: selectedMethod,
      );

      if (!mounted) return;
      setState(() {
        _codeRequested = true;
        _simulatedCode = result['reset_code'] as String?;
        _phoneForDisplay = result['phone'] as String?;
      });
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) {
        setState(() {
          _isRequesting = false;
        });
      }
    }
  }

  Future<void> _handleResetPassword() async {
    final code = _enteredCode;

    if (code.length != 6) {
      _showError('Please enter all 6 digits.');
      return;
    }
    if (newPasswordController.text.isEmpty) {
      _showError('Please enter a new password.');
      return;
    }
    if (newPasswordController.text != confirmPasswordController.text) {
      _showError('Passwords do not match.');
      return;
    }

    setState(() {
      _isResetting = true;
    });

    try {
      await AuthService.resetPassword(
        email: emailController.text.trim(),
        code: code,
        newPassword: newPasswordController.text,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password reset successfully. Please log in. 🌸'),
        ),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) {
        setState(() {
          _isResetting = false;
        });
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red.shade400),
    );
  }

  Widget _methodButton(String method, String label) {
    final isSelected = selectedMethod == method;
    return Semantics(
      button: true,
      selected: isSelected,
      child: Material(
        color: isSelected ? DA.rose : Colors.transparent,
        shape: const StadiumBorder(),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: () {
            setState(() {
              selectedMethod = method;
            });
          },
          child: SizedBox(
            height: 44,
            child: Center(
              child: Text(
                label,
                style: DA.body(
                  15,
                  weight: FontWeight.w700,
                  color: isSelected ? Colors.white : DA.muted,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _codeBox(int index) {
    return SizedBox(
      width: 48,
      height: 58,
      child: TextField(
        controller: codeControllers[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: DA.heading(22),
        onChanged: (value) {
          if (value.isNotEmpty && index < 5) {
            FocusScope.of(context).nextFocus();
          }
        },
        decoration: DA.input().copyWith(
          counterText: "",
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DA.ground,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: DA.backButton(context),
                  ),
                  const SizedBox(height: 16),
                  Text('Reset your password', style: DA.heading(30)),
                  const SizedBox(height: 8),
                  Text(
                    _codeRequested
                        ? 'Enter the code, then choose a new password.'
                        : 'Enter the email you signed up with.',
                    style: DA.body(16, color: DA.muted),
                  ),
                  const SizedBox(height: 28),

                  DA.label('Email address'),
                  TextField(
                    controller: emailController,
                    enabled: !_codeRequested,
                    keyboardType: TextInputType.emailAddress,
                    style: DA.body(16, color: _codeRequested ? DA.muted : DA.ink),
                    decoration: DA.input().copyWith(
                      fillColor: _codeRequested ? DA.chip : DA.surface,
                      disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: DA.border, width: 1.5),
                      ),
                    ),
                  ),

                  if (!_codeRequested) ...[
                    const SizedBox(height: 20),
                    DA.label('Send the code by'),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: DA.surface,
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: DA.border, width: 1.5),
                      ),
                      child: Row(
                        children: [
                          Expanded(child: _methodButton('email', 'Email')),
                          Expanded(child: _methodButton('phone', 'Phone')),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    ElevatedButton(
                      style: DA.primary(),
                      onPressed: _isRequesting ? null : _handleRequestCode,
                      child: _isRequesting
                          ? DA.buttonSpinner
                          : const Text('Send reset code'),
                    ),
                  ],

                  if (_codeRequested) ...[
                    const SizedBox(height: 20),

                    // Dev-mode banner: only shown when the backend runs with
                    // DEV_MODE=true and actually returned a code.
                    if (_simulatedCode != null)
                      Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: DA.pendingBg,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Dev mode: no real email or SMS is sent yet.',
                              style: DA.body(13, color: DA.pendingInk, weight: FontWeight.w700),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              selectedMethod == 'email'
                                  ? 'Code: $_simulatedCode'
                                  : 'Code (sent to $_phoneForDisplay): $_simulatedCode',
                              style: DA.body(15, color: DA.pendingInk),
                            ),
                          ],
                        ),
                      ),

                    DA.label('Reset code'),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(6, (i) => _codeBox(i)),
                    ),
                    const SizedBox(height: 20),

                    DA.label('New password'),
                    TextField(
                      controller: newPasswordController,
                      obscureText: _hidePassword,
                      style: DA.body(16),
                      decoration: DA.input(
                        suffix: IconButton(
                          tooltip: _hidePassword ? 'Show password' : 'Hide password',
                          icon: Icon(
                            _hidePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: DA.sage,
                          ),
                          onPressed: () {
                            setState(() {
                              _hidePassword = !_hidePassword;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    DA.label('Confirm new password'),
                    TextField(
                      controller: confirmPasswordController,
                      obscureText: _hidePassword,
                      style: DA.body(16),
                      decoration: DA.input(),
                    ),
                    const SizedBox(height: 28),

                    ElevatedButton(
                      style: DA.primary(),
                      onPressed: _isResetting ? null : _handleResetPassword,
                      child: _isResetting
                          ? DA.buttonSpinner
                          : const Text('Reset password'),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: DA.rose,
                        minimumSize: const Size.fromHeight(48),
                        textStyle: DA.body(15, weight: FontWeight.w700),
                      ),
                      onPressed: () {
                        setState(() {
                          _codeRequested = false;
                        });
                      },
                      child: const Text('Use a different email or method'),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
