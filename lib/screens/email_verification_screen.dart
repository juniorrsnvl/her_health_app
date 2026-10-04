import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../theme/design_a.dart';
import 'login_screen.dart';

class EmailVerificationScreen extends StatefulWidget {
  final String email;
  final String phone;

  /// SIMULATED codes, passed through from registration. No real email/SMS
  /// provider is connected yet -- these are shown on-screen (in a clearly
  /// labelled dev-mode banner) purely so the flow can be tested end to
  /// end. Remove this display, and the fields that carry it, once a real
  /// provider is wired up in the backend.
  // Null unless the backend runs with DEV_MODE=true.
  final String? simulatedEmailCode;
  final String? simulatedPhoneCode;

  const EmailVerificationScreen({
    super.key,
    required this.email,
    required this.phone,
    required this.simulatedEmailCode,
    required this.simulatedPhoneCode,
  });

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final List<TextEditingController> codeControllers =
      List.generate(6, (index) => TextEditingController());

  // User's choice of verification method. Defaults to email.
  String selectedMethod = 'email';

  bool _isVerifying = false;
  bool _isResending = false;
  String? _currentSimulatedEmailCode;
  String? _currentSimulatedPhoneCode;

  @override
  void initState() {
    super.initState();
    _currentSimulatedEmailCode = widget.simulatedEmailCode;
    _currentSimulatedPhoneCode = widget.simulatedPhoneCode;
  }

  String get _enteredCode => codeControllers.map((c) => c.text).join();

  String get _currentSimulatedCode => selectedMethod == 'email'
      ? (_currentSimulatedEmailCode ?? '')
      : (_currentSimulatedPhoneCode ?? '');

  String get _destination =>
      selectedMethod == 'email' ? widget.email : widget.phone;

  void _clearCodeBoxes() {
    for (final controller in codeControllers) {
      controller.clear();
    }
  }

  /// Email / Phone switch. Switching clears the boxes, since each method
  /// has its own code.
  Widget methodToggle() {
    return Container(
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
              _clearCodeBoxes();
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

  Widget codeBox(int index) {
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

  Future<void> _handleVerify() async {
    final code = _enteredCode;

    if (code.length != 6) {
      _showMessage('Please enter all 6 digits.', isError: true);
      return;
    }

    setState(() {
      _isVerifying = true;
    });

    try {
      await AuthService.verify(
        email: widget.email,
        method: selectedMethod,
        code: code,
      );

      if (!mounted) return;
      _showMessage(
        'Account verified successfully via $selectedMethod 🌸 Please log in.',
      );

      // Verification is done: send the user to the login screen and clear
      // the registration/verification screens from the back stack, so the
      // back button can't return to a finished verification.
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      _showMessage(e.toString(), isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isVerifying = false;
        });
      }
    }
  }

  Future<void> _handleResend() async {
    setState(() {
      _isResending = true;
    });

    try {
      final result = await AuthService.resendCodes(email: widget.email);
      if (!mounted) return;
      setState(() {
        _currentSimulatedEmailCode = result['email_code'] as String?;
        _currentSimulatedPhoneCode = result['phone_code'] as String?;
        _clearCodeBoxes();
      });
      _showMessage('New codes generated.');
    } catch (e) {
      _showMessage(e.toString(), isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isResending = false;
        });
      }
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade400 : null,
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
                  Text('Verify your account', style: DA.heading(30)),
                  const SizedBox(height: 8),
                  Text(
                    "Choose how you'd like to get your code.",
                    style: DA.body(16, color: DA.muted),
                  ),
                  const SizedBox(height: 24),

                  methodToggle(),
                  const SizedBox(height: 20),

                  // Dev-mode banner: only shown when the backend runs with
                  // DEV_MODE=true and actually returned a code.
                  if (_currentSimulatedCode.isNotEmpty)
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
                            'Code: $_currentSimulatedCode',
                            style: DA.body(15, color: DA.pendingInk),
                          ),
                        ],
                      ),
                    ),

                  Text(
                    selectedMethod == 'email'
                        ? "Code sent to your email"
                        : "Code sent to your phone",
                    style: DA.body(15, color: DA.muted),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _destination,
                    style: DA.body(17, color: DA.rose, weight: FontWeight.w700),
                  ),
                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(6, (i) => codeBox(i)),
                  ),
                  const SizedBox(height: 32),

                  ElevatedButton(
                    style: DA.primary(),
                    onPressed: _isVerifying ? null : _handleVerify,
                    child: _isVerifying ? DA.buttonSpinner : const Text('Verify'),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: DA.rose,
                      minimumSize: const Size.fromHeight(48),
                      textStyle: DA.body(15, weight: FontWeight.w700),
                    ),
                    onPressed: _isResending ? null : _handleResend,
                    child: Text(_isResending ? 'Sending...' : 'Resend codes'),
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
