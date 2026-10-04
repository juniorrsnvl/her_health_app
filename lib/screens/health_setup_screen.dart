import 'package:flutter/material.dart';
import 'package:her_health_app/screens/journey_questions_screen.dart';
import '../services/auth_service.dart';
import '../theme/design_a.dart';

class HealthSetupScreen extends StatefulWidget {
  const HealthSetupScreen({super.key});

  @override
  State<HealthSetupScreen> createState() => _HealthSetupScreenState();
}

class _HealthSetupScreenState extends State<HealthSetupScreen> {
  String? selectedJourney;

  // These exact strings (emoji included) are what the questions screen and
  // its backend mapping expect, so they are passed on unchanged. Only what
  // the patient SEES drops the emoji (see _label).
  final List<String> journeys = [
    "🤰 Pregnancy Care",
    "🌸 Menstrual Health",
    "👶 Postpartum Recovery",
    "💚 General Women's Health",
    "✨ Cosmetic Gynecology",
  ];

  // One line under each option, taken from the questions that journey asks.
  static const Map<String, String> _details = {
    "🤰 Pregnancy Care": "Weeks, check-ups, vitamins",
    "🌸 Menstrual Health": "Cycle, period length, cramps",
    "👶 Postpartum Recovery": "Sleep, mood, check-ups",
    "💚 General Women's Health": "Exercise, water, sleep",
    "✨ Cosmetic Gynecology": "Goals and past procedures",
  };

  /// "🤰 Pregnancy Care" -> "Pregnancy Care"
  String _label(String journey) {
    final space = journey.indexOf(' ');
    return space == -1 ? journey : journey.substring(space + 1);
  }

  void _continue() {
    if (selectedJourney == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select your healthcare journey."),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => JourneyQuestionsScreen(
          journey: selectedJourney!,
        ),
      ),
    );
  }

  Widget _option(String journey) {
    final selected = selectedJourney == journey;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Semantics(
        button: true,
        selected: selected,
        child: Material(
          color: selected ? DA.blush : DA.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: selected ? DA.rose : DA.border, width: 1.5),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              setState(() {
                selectedJourney = journey;
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              child: Row(
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: selected ? DA.rose : const Color(0xFFC9BDB8),
                        width: 2,
                      ),
                    ),
                    child: selected
                        ? Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: DA.rose,
                              shape: BoxShape.circle,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _label(journey),
                          style: DA.body(17, weight: FontWeight.w700),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _details[journey] ?? '',
                          style: DA.body(14, color: selected ? DA.muted : DA.quiet),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final name = AuthService.firstName ?? '';

    return Scaffold(
      backgroundColor: DA.ground,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Image.asset('assets/images/logo/logo.png', height: 28),
                        const SizedBox(width: 8),
                        Text('Her Health', style: DA.heading(15, color: DA.sage)),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Text(
                      name.isEmpty ? 'Welcome' : 'Welcome, $name',
                      style: DA.heading(32),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Which best describes your current healthcare journey?',
                      style: DA.body(17, color: DA.muted, height: 1.5),
                    ),
                    const SizedBox(height: 28),
                    ...journeys.map(_option),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: ElevatedButton(
                style: DA.primary(),
                onPressed: _continue,
                child: const Text('Continue'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
