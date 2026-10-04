import 'package:flutter/material.dart';
import 'chatbot_screen.dart';
import '../services/auth_service.dart';
import '../theme/design_a.dart';

class JourneyQuestionsScreen extends StatefulWidget {
  final String journey;

  const JourneyQuestionsScreen({
    super.key,
    required this.journey,
  });

  @override
  State<JourneyQuestionsScreen> createState() =>
      _JourneyQuestionsScreenState();
}

class _JourneyQuestionsScreenState
    extends State<JourneyQuestionsScreen> {

  // --------------------------------------------------
  // Backend wiring: maps the display string in widget.journey to the
  // journey_type slug the backend's CHECK constraint and ANSWER_MODELS
  // dict expect.
  // --------------------------------------------------

  static const Map<String, String> _journeyTypeSlugs = {
    "🤰 Pregnancy Care": "pregnancy_care",
    "🌸 Menstrual Health": "menstrual_health",
    "👶 Postpartum Recovery": "postpartum_recovery",
    "💚 General Women's Health": "general_health",
    "✨ Cosmetic Gynecology": "cosmetic_gynecology",
  };

  bool _isSaving = false;

  /// Reads whichever controllers are actually shown for widget.journey and
  /// builds the JSON the backend expects for that journey type. Field
  /// names here must match models/health_journey.py exactly.
  Map<String, dynamic> _buildAnswers() {
    switch (widget.journey) {
      case "🤰 Pregnancy Care":
        return {
          'weeks_pregnant': pregnancyWeeksController.text,
          'first_pregnancy': firstPregnancyController.text,
          'had_antenatal_visit': antenatalController.text,
          'complications': complicationsController.text,
          'taking_vitamins': vitaminsController.text,
          'due_date': dueDateController.text,
        };
      case "🌸 Menstrual Health":
        return {
          'last_period': lastPeriodController.text,
          'cycle_length': cycleLengthController.text,
          'period_length': periodLengthController.text,
          'cramps': crampsController.text,
          'regular_periods': regularController.text,
          'birth_control': birthControlController.text,
        };
      case "👶 Postpartum Recovery":
        return {
          'weeks_postpartum': postpartumWeeksController.text,
          'breastfeeding': breastfeedingController.text,
          'sleep_quality': sleepController.text,
          'mood': moodController.text,
          'postpartum_checkup': postpartumCheckController.text,
          'concerns': postpartumConcernController.text,
        };
      case "💚 General Women's Health":
        return {
          'height': heightController.text,
          'weight': weightController.text,
          'exercise': exerciseController.text,
          'water_intake': waterController.text,
          'sleep_hours': sleepHoursController.text,
          'health_concerns': healthConcernController.text,
        };
      case "✨ Cosmetic Gynecology":
        return {
          'improvement_goal': cosmeticGoalController.text,
          'previous_procedures': previousProcedureController.text,
          'consulted_specialist': specialistController.text,
          'expected_outcome': expectedOutcomeController.text,
        };
      default:
        return {};
    }
  }

  Future<void> _handleContinue() async {
    final journeyType = _journeyTypeSlugs[widget.journey];
    if (journeyType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unrecognised journey type.')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await AuthService.saveHealthJourney(
        journeyType: journeyType,
        answers: _buildAnswers(),
      );

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ChatbotScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red.shade400),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  // --------------------------------------------------
  // Pregnancy Care
  // --------------------------------------------------

  DateTime? dueDate;

  String? pregnancyTrimester;

  String? pregnancyRisk;

  final TextEditingController doctorController =
      TextEditingController();

  final TextEditingController pregnancyNotesController =
      TextEditingController();

  // --------------------------------------------------
  // Menstrual Health
  // --------------------------------------------------

  DateTime? lastPeriod;

  int cycleLength = 28;

  int periodLength = 5;

  bool irregularPeriods = false;

  bool severePain = false;

  // --------------------------------------------------
  // Postpartum Recovery
  // --------------------------------------------------

  DateTime? babyBirthDate;

  String? deliveryType;

  bool breastfeeding = false;

  final TextEditingController postpartumNotesController =
      TextEditingController();

  // --------------------------------------------------
  // General Women's Health
  // --------------------------------------------------

  bool yearlyCheckup = false;

  bool papSmear = false;

  bool breastExam = false;

  final TextEditingController healthGoalsController =
      TextEditingController();

  // --------------------------------------------------
  // Cosmetic Gynecology
  // --------------------------------------------------

  String? cosmeticInterest;

  final TextEditingController cosmeticQuestionsController =
      TextEditingController();

  // ===========================
  // Pregnancy Care
  // ===========================

  final TextEditingController weeksPregnantController =
      TextEditingController();

  final TextEditingController dueDateController =
      TextEditingController();

  final TextEditingController pregnancySymptomsController =
      TextEditingController();

  final TextEditingController pregnancyConcernsController =
      TextEditingController();

  // ===========================
  // Menstrual Health
  // ===========================

  final TextEditingController cycleLengthController =
      TextEditingController();

  final TextEditingController lastPeriodController =
      TextEditingController();

  final TextEditingController periodSymptomsController =
      TextEditingController();

  final TextEditingController flowController =
      TextEditingController();

  // ===========================
  // Postpartum Recovery
  // ===========================

  final TextEditingController babyAgeController =
      TextEditingController();

  final TextEditingController deliveryTypeController =
      TextEditingController();

  final TextEditingController breastfeedingController =
      TextEditingController();

  final TextEditingController recoveryConcernsController =
      TextEditingController();

  // ===========================
  // General Women's Health
  // ===========================

  final TextEditingController heightController =
      TextEditingController();

  final TextEditingController weightController =
      TextEditingController();

  final TextEditingController exerciseController =
      TextEditingController();

  final TextEditingController waterController =
      TextEditingController();

  final TextEditingController sleepHoursController =
      TextEditingController();

  final TextEditingController healthConcernController =
      TextEditingController();

  // ===========================
  // Cosmetic Gynecology
  // ===========================

  final TextEditingController cosmeticGoalController =
      TextEditingController();

  final TextEditingController previousProcedureController =
      TextEditingController();

  final TextEditingController specialistController =
      TextEditingController();

  final TextEditingController expectedOutcomeController =
      TextEditingController();

  // ===========================
  // Selected answers
  // ===========================

  String? selectedPainLevel;
  String? selectedMood;

  // ===========================
  // Missing controllers (added to fix compile errors --
  // these were referenced in buildQuestion() calls below
  // but never declared)
  // ===========================

  final TextEditingController pregnancyWeeksController =
      TextEditingController();

  final TextEditingController firstPregnancyController =
      TextEditingController();

  final TextEditingController antenatalController =
      TextEditingController();

  final TextEditingController complicationsController =
      TextEditingController();

  final TextEditingController vitaminsController =
      TextEditingController();

  final TextEditingController periodLengthController =
      TextEditingController();

  final TextEditingController crampsController =
      TextEditingController();

  final TextEditingController regularController =
      TextEditingController();

  final TextEditingController birthControlController =
      TextEditingController();

  final TextEditingController postpartumWeeksController =
      TextEditingController();

  final TextEditingController sleepController =
      TextEditingController();

  final TextEditingController moodController =
      TextEditingController();

  final TextEditingController postpartumCheckController =
      TextEditingController();

  final TextEditingController postpartumConcernController =
      TextEditingController();

  // --------------------------------------------------
  // Helper Methods
  // --------------------------------------------------

  Future<void> pickDate(
      BuildContext context,
      Function(DateTime) onSelected,
      ) async {

    DateTime initial = DateTime.now();

    final DateTime? picked =
    await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        onSelected(picked);
      });
    }
  }

  /// "🤰 How many weeks pregnant are you?" -> "How many weeks pregnant are you?"
  /// Display only: answers are read from the controllers, never the labels.
  String _plain(String label) {
    final space = label.indexOf(' ');
    if (space > 0 && !RegExp(r'^[A-Za-z0-9]').hasMatch(label)) {
      return label.substring(space + 1);
    }
    return label;
  }

  Widget buildQuestion(
    String label,
    TextEditingController controller,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DA.label(_plain(label)),
          TextField(
            controller: controller,
            style: DA.body(16),
            decoration: DA.input(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DA.ground,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 560),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: DA.backButton(context),
                        ),
                        const SizedBox(height: 16),
                        Text(_plain(widget.journey), style: DA.heading(30)),
                        const SizedBox(height: 10),
                        Text(
                          "Let's get to know you better so Nia can give you personalised support.",
                          style: DA.body(16, color: DA.muted, height: 1.5),
                        ),
                        const SizedBox(height: 28),

                    if (widget.journey ==
                        "🤰 Pregnancy Care") ...[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          buildQuestion(
                            "🤰 How many weeks pregnant are you?",
                            pregnancyWeeksController,
                          ),

                          const SizedBox(height: 15),

                          buildQuestion(
                            "👩 Is this your first pregnancy?",
                            firstPregnancyController,
                          ),

                          const SizedBox(height: 15),

                          buildQuestion(
                            "🏥 Have you had your first antenatal visit?",
                            antenatalController,
                          ),

                          const SizedBox(height: 15),

                          buildQuestion(
                            "🩸 Do you have any pregnancy complications?",
                            complicationsController,
                          ),

                          const SizedBox(height: 15),

                          buildQuestion(
                            "💊 Are you taking prenatal vitamins?",
                            vitaminsController,
                          ),

                          const SizedBox(height: 15),

                          buildQuestion(
                            "📅 Estimated Due Date",
                            dueDateController,
                          ),

                        ],
                      ),
                    ],

                    // ===========================
                    // MENSTRUAL HEALTH QUESTIONS
                    // ===========================

                    if (widget.journey == "🌸 Menstrual Health") ...[

                      

                      buildQuestion(
                        "📅 First day of your last period",
                        lastPeriodController,
                      ),

                      buildQuestion(
                        "🔄 Average cycle length (days)",
                        cycleLengthController,
                      ),

                      buildQuestion(
                        "🩸 Average period length (days)",
                        periodLengthController,
                      ),

                      buildQuestion(
                        "😖 Do you experience painful cramps?",
                        crampsController,
                      ),

                      buildQuestion(
                        "😊 Are your periods regular?",
                        regularController,
                      ),

                      buildQuestion(
                        "💊 Are you using any birth control?",
                        birthControlController,
                      ),
                    ],

                    // ===========================
                    // POSTPARTUM RECOVERY QUESTIONS
                    // ===========================

                    if (widget.journey == "👶 Postpartum Recovery") ...[

                      

                      buildQuestion(
                        "🍼 How many weeks postpartum are you?",
                        postpartumWeeksController,
                      ),

                      buildQuestion(
                        "🤱 Are you breastfeeding?",
                        breastfeedingController,
                      ),

                      buildQuestion(
                        "😴 How is your sleep quality?",
                        sleepController,
                      ),

                      buildQuestion(
                        "😊 How has your mood been recently?",
                        moodController,
                      ),

                      buildQuestion(
                        "🩺 Have you attended your postpartum check-up?",
                        postpartumCheckController,
                      ),

                      buildQuestion(
                        "❤️ Do you have any concerns you'd like support with?",
                        postpartumConcernController,
                      ),
                    ],

                    // ===========================
                    // GENERAL WOMEN'S HEALTH QUESTIONS
                    // ===========================

                    if (widget.journey == "💚 General Women's Health") ...[

                      

                      buildQuestion(
                        "📏 Height (cm)",
                        heightController,
                      ),

                      buildQuestion(
                        "⚖️ Weight (kg)",
                        weightController,
                      ),

                      buildQuestion(
                        "🏃 Do you exercise regularly?",
                        exerciseController,
                      ),

                      buildQuestion(
                        "💧 How much water do you drink daily?",
                        waterController,
                      ),

                      buildQuestion(
                        "😴 Average hours of sleep per night",
                        sleepHoursController,
                      ),

                      buildQuestion(
                        "🩺 Any current health concerns?",
                        healthConcernController,
                      ),
                    ],

                    // ===========================
                    // COSMETIC GYNECOLOGY QUESTIONS
                    // ===========================

                    if (widget.journey == "✨ Cosmetic Gynecology") ...[

                      

                      buildQuestion(
                        "💬 What would you like to improve?",
                        cosmeticGoalController,
                      ),

                      buildQuestion(
                        "📅 Have you had any previous procedures?",
                        previousProcedureController,
                      ),

                      buildQuestion(
                        "👩‍⚕️ Have you consulted a specialist before?",
                        specialistController,
                      ),

                      buildQuestion(
                        "⭐ What outcome are you hoping for?",
                        expectedOutcomeController,
                      ),
                    ],


                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: ElevatedButton(
                  style: DA.primary(),
                  onPressed: _isSaving ? null : _handleContinue,
                  child: _isSaving ? DA.buttonSpinner : const Text('Continue to Nia'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
