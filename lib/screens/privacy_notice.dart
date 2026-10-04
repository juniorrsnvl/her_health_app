import 'package:flutter/material.dart';
import '../theme/design_a.dart';

/// Shown at registration. PLACEHOLDER WORDING: replace with text approved
/// by the practice and its legal adviser before real patients use the app,
/// and change the version here AND PRIVACY_NOTICE_VERSION in the backend's
/// routers/auth.py at the same time.
const String kPrivacyNoticeVersion = 'draft-2026-10';

const List<(String, String)> _sections = [
  (
    'Who we are',
    'Her Health is provided by [PRACTICE NAME] ("the practice"). '
        'Information Officer: [NAME], [EMAIL / PHONE].',
  ),
  (
    'What we collect',
    'Your name, contact details, date of birth and emergency contact; the '
        'health information you choose to share (blood type, allergies, '
        'conditions, medication and health journey answers); your appointment '
        'requests, messages to the practice, chats with Nia and reminders.',
  ),
  (
    'Why we collect it',
    'To support your care at the practice: managing appointments, answering '
        'your messages and personalising the information you see.',
  ),
  (
    'Who can see it',
    'Authorised practice staff only. [List any service providers that store '
        'or process the information, and where.] [If Nia uses an AI service, '
        'explain it here.]',
  ),
  (
    'How long we keep it',
    '[RETENTION PERIOD, in line with the practice\'s record-keeping duties.]',
  ),
  (
    'Your rights',
    'You can ask for a copy of your information, ask for it to be corrected '
        'or deleted, and object to how it is used. You can also complain to '
        'the Information Regulator.',
  ),
  (
    'Not for emergencies',
    'Nia and practice messages are not monitored for emergencies. In an '
        'emergency call 10177 for an ambulance, 112 from a cellphone, or go to '
        'your nearest emergency unit.',
  ),
];

/// Opens the privacy notice as a scrollable sheet.
Future<void> showPrivacyNotice(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: DA.ground,
    constraints: const BoxConstraints(maxWidth: 640),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      builder: (context, scrollController) => ListView(
        controller: scrollController,
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
        children: [
          Text('Privacy notice', style: DA.heading(24)),
          const SizedBox(height: 6),
          Text('Version: $kPrivacyNoticeVersion', style: DA.body(13, color: DA.quiet)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: DA.pendingBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Draft wording for testing only. It will be replaced with text '
              'approved by the practice before real patients use the app.',
              style: DA.body(13, color: DA.pendingInk, weight: FontWeight.w700),
            ),
          ),
          for (final (title, text) in _sections) ...[
            const SizedBox(height: 18),
            Text(title, style: DA.heading(17, color: DA.sage)),
            const SizedBox(height: 6),
            Text(text, style: DA.body(15, height: 1.55)),
          ],
          const SizedBox(height: 24),
          ElevatedButton(
            style: DA.primary(),
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    ),
  );
}
