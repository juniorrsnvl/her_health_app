import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../theme/design_a.dart';
import 'appointments_screen.dart';
import 'messages_screen.dart';
import 'health_profile_screen.dart';
import 'settings_screen.dart';
import 'reminders_screen.dart';
import 'articles_screen.dart';


class ChatbotScreen extends StatefulWidget {

  const ChatbotScreen({super.key});


  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();

}




class _ChatbotScreenState extends State<ChatbotScreen> {


  final TextEditingController messageController =
      TextEditingController();

  final ScrollController scrollController = ScrollController();

  static const Map<String, String> _welcomeMessage = {
    "sender": "ai",
    "message":
        "Hi 🌸 I am Her Health Assistant.\n\n"
        "I am here to support your wellness journey. "
        "How can I help you today?"
  };

  List<Map<String, String>> messages = [_welcomeMessage];

  bool _isLoadingHistory = true;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  /// Loads whatever conversation the patient already has saved. If they
  /// have no history yet (a brand-new chat), the hardcoded welcome
  /// message stays as the only thing shown -- no error, no empty screen.
  Future<void> _loadHistory() async {
    try {
      final history = await AuthService.getChatHistory();

      if (!mounted) return;

      if (history.isNotEmpty) {
        setState(() {
          messages = history
              .map((m) => {
                    "sender": (m["sender"] as String?) ?? "ai",
                    "message": (m["message"] as String?) ?? "",
                  })
              .toList();
        });
      }
    } catch (e) {
      // A failed history load isn't worth blocking the screen over --
      // the welcome message is still there, and the person can still
      // chat. Fail quietly here.
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingHistory = false;
        });
      }
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!scrollController.hasClients) return;
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> sendMessage() async {
    final text = messageController.text.trim();

    if (text.isEmpty || _isSending) {
      return;
    }

    messageController.clear();

    setState(() {
      _isSending = true;
    });

    try {
      final saved = await AuthService.sendChatMessage(text);

      if (!mounted) return;

      setState(() {
        for (final m in saved) {
          messages.add({
            "sender": (m["sender"] as String?) ?? "ai",
            "message": (m["message"] as String?) ?? "",
          });
        }
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red.shade400),
      );
      // Give the message back so it isn't lost on failure.
      messageController.text = text;
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
      _scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DA.ground,
      drawer: buildDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            // Header: menu, Nia's avatar, name and a clear "not a doctor" note.
            Container(
              padding: const EdgeInsets.fromLTRB(8, 10, 20, 10),
              decoration: const BoxDecoration(
                color: DA.surface,
                border: Border(bottom: BorderSide(color: DA.divider)),
              ),
              child: Row(
                children: [
                  Builder(
                    builder: (context) => IconButton(
                      tooltip: 'Menu',
                      icon: const Icon(Icons.menu_rounded, color: DA.ink),
                      onPressed: () => Scaffold.of(context).openDrawer(),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: DA.blush,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.auto_awesome, color: DA.rose, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Nia', style: DA.heading(18)),
                        Text(
                          'Health assistant, not a doctor',
                          style: DA.body(13, color: DA.quiet),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            DA.emergencyNotice(),

            if (_isLoadingHistory)
              const LinearProgressIndicator(
                minHeight: 2,
                color: DA.rose,
                backgroundColor: DA.blush,
              ),

            // Conversation
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final isUser = messages[index]["sender"] == "user";

                  return Align(
                    alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      constraints: const BoxConstraints(maxWidth: 300),
                      decoration: BoxDecoration(
                        color: isUser ? DA.rose : DA.surface,
                        border: isUser ? null : Border.all(color: DA.divider),
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(20),
                          topRight: const Radius.circular(20),
                          bottomLeft: Radius.circular(isUser ? 20 : 6),
                          bottomRight: Radius.circular(isUser ? 6 : 20),
                        ),
                      ),
                      child: Text(
                        messages[index]["message"] ?? '',
                        style: DA.body(
                          15,
                          color: isUser ? Colors.white : DA.ink,
                          height: 1.5,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Message bar
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              decoration: const BoxDecoration(
                color: DA.surface,
                border: Border(top: BorderSide(color: DA.divider)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: messageController,
                      style: DA.body(15),
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) {
                        if (!_isSending) sendMessage();
                      },
                      decoration: InputDecoration(
                        hintText: 'Message Nia',
                        hintStyle: DA.body(15, color: DA.quiet),
                        filled: true,
                        fillColor: DA.ground,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: const BorderSide(color: DA.border, width: 1.5),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: const BorderSide(color: DA.border, width: 1.5),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: const BorderSide(color: DA.rose, width: 2),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 48,
                    height: 48,
                    child: IconButton(
                      tooltip: 'Send',
                      style: IconButton.styleFrom(
                        backgroundColor: DA.rose,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: DA.rose.withValues(alpha: 0.5),
                      ),
                      onPressed: _isSending ? null : sendMessage,
                      icon: _isSending
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.send_rounded, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Drawer buildDrawer() {
    final name = AuthService.firstName ?? '';

    return Drawer(
      backgroundColor: DA.ground,
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 24),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: DA.blush,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Image.asset('assets/images/logo/logo.png'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Her Health', style: DA.heading(20)),
                        if (name.isNotEmpty)
                          Text('Hi, $name', style: DA.body(14, color: DA.muted)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            _drawerTile(Icons.auto_awesome_outlined, 'AI Assistant', null),
            _drawerTile(Icons.calendar_month_outlined, 'Appointments', const AppointmentsScreen()),
            _drawerTile(Icons.medical_services_outlined, 'Contact Doctor', const MessagesScreen()),
            _drawerTile(Icons.favorite_border_rounded, 'Health Profile', const HealthProfileScreen()),
            _drawerTile(Icons.notifications_none_rounded, 'Reminders', const RemindersScreen()),
            _drawerTile(Icons.article_outlined, 'Health Articles', const ArticlesScreen()),
            _drawerTile(Icons.settings_outlined, 'Settings', const SettingsScreen()),
          ],
        ),
      ),
    );
  }

  /// One drawer row. [screen] null = this screen (Nia): just closes the drawer.
  Widget _drawerTile(IconData icon, String title, Widget? screen) {
    final current = screen == null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        tileColor: current ? DA.blush : null,
        leading: Icon(icon, color: current ? DA.rose : DA.sage),
        title: Text(
          title,
          style: DA.body(16, weight: current ? FontWeight.w700 : FontWeight.w600),
        ),
        onTap: () {
          Navigator.pop(context); // close the drawer first
          if (screen != null) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => screen),
            );
          }
        },
      ),
    );
  }
}
