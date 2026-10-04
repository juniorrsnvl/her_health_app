import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../theme/design_a.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  List<Map<String, dynamic>> messages = [];
  bool _isLoading = true;
  bool _isSending = false;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _loadThread();
  }

  Future<void> _loadThread() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });

    try {
      final thread = await AuthService.getMyMessageThread();
      if (!mounted) return;
      setState(() {
        messages = thread.cast<Map<String, dynamic>>();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadError = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
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

  Future<void> _sendMessage() async {
    final text = messageController.text.trim();
    if (text.isEmpty || _isSending) {
      return;
    }

    messageController.clear();

    setState(() {
      _isSending = true;
    });

    try {
      await AuthService.sendDoctorMessage(text);
      // Reload the whole thread rather than optimistically appending --
      // this is a two-person conversation, and a reload is the simplest
      // way to guarantee we're not out of sync with anything the
      // practice might send back later.
      await _loadThread();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red.shade400),
      );
      messageController.text = text;
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DA.ground,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 20, 12),
              decoration: const BoxDecoration(
                color: DA.surface,
                border: Border(bottom: BorderSide(color: DA.divider)),
              ),
              child: Row(
                children: [
                  DA.backButton(context),
                  const SizedBox(width: 12),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE8EDE2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.medical_services_outlined, color: DA.sage, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Contact Doctor', style: DA.heading(18)),
                        Text(
                          'Your practice team replies here',
                          style: DA.body(13, color: DA.quiet),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                color: DA.rose,
                onRefresh: _loadThread,
                child: _buildBody(),
              ),
            ),
            _buildInputBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: DA.rose));
    }

    if (_loadError != null) {
      return ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 60),
          Text(
            _loadError!,
            textAlign: TextAlign.center,
            style: DA.body(15, color: DA.rejectedInk),
          ),
        ],
      );
    }

    if (messages.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(32),
        children: [
          const SizedBox(height: 60),
          Text(
            "No messages yet. Send a message below to reach the practice directly.",
            textAlign: TextAlign.center,
            style: DA.body(16, color: DA.muted),
          ),
        ],
      );
    }

    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final m = messages[index];
        final isPatient = m['sender_role'] == 'patient';

        return Align(
          alignment: isPatient ? Alignment.centerRight : Alignment.centerLeft,
          child: Column(
            crossAxisAlignment: isPatient ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 4, left: 4, right: 4),
                child: Text(
                  isPatient ? 'You' : 'Practice',
                  style: DA.body(12, color: DA.quiet, weight: FontWeight.w700),
                ),
              ),
              Container(
                constraints: const BoxConstraints(maxWidth: 300),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: isPatient ? DA.rose : DA.surface,
                  border: isPatient ? null : Border.all(color: DA.divider),
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(20),
                    topRight: const Radius.circular(20),
                    bottomLeft: Radius.circular(isPatient ? 20 : 6),
                    bottomRight: Radius.circular(isPatient ? 6 : 20),
                  ),
                ),
                child: Text(
                  (m['message'] as String?) ?? '',
                  style: DA.body(15, color: isPatient ? Colors.white : DA.ink, height: 1.5),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInputBar() {
    return Container(
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
                if (!_isSending) _sendMessage();
              },
              decoration: DA.input(hint: 'Message the practice').copyWith(
                fillColor: DA.ground,
                contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
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
              onPressed: _isSending ? null : _sendMessage,
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
    );
  }
}
