import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/design_a.dart';
import 'login_screen.dart';

class MessageThreadScreen extends StatefulWidget {
  final int patientId;
  final String patientName;

  const MessageThreadScreen({
    super.key,
    required this.patientId,
    required this.patientName,
  });

  @override
  State<MessageThreadScreen> createState() => _MessageThreadScreenState();
}

class _MessageThreadScreenState extends State<MessageThreadScreen> {
  final TextEditingController replyController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  bool _isLoading = true;
  bool _isSending = false;
  String? _errorMessage;
  List<dynamic> _messages = [];

  @override
  void initState() {
    super.initState();
    _loadThread();
  }

  Future<void> _loadThread() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await ApiService.authorizedGet(
        '/messages/patient/${widget.patientId}',
      );

      if (response.statusCode == 401 || response.statusCode == 403) {
        await _handleSessionExpired();
        return;
      }

      if (response.statusCode != 200) {
        setState(() {
          _errorMessage = 'Failed to load thread (${response.statusCode}).';
          _isLoading = false;
        });
        return;
      }

      final data = jsonDecode(response.body) as List<dynamic>;
      setState(() {
        _messages = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Could not reach the server.';
        _isLoading = false;
      });
    } finally {
      _scrollToBottom();
    }
  }

  Future<void> _handleSessionExpired() async {
    await ApiService.logout();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
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

  Future<void> _sendReply() async {
    final text = replyController.text.trim();
    if (text.isEmpty || _isSending) {
      return;
    }

    replyController.clear();

    setState(() {
      _isSending = true;
    });

    try {
      final response = await ApiService.authorizedPost(
        '/messages/patient/${widget.patientId}/reply',
        {'message': text},
      );

      if (response.statusCode == 401 || response.statusCode == 403) {
        await _handleSessionExpired();
        return;
      }

      if (response.statusCode != 200) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send (${response.statusCode}).')),
        );
        replyController.text = text;
        return;
      }

      await _loadThread();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not reach the server.')),
      );
      replyController.text = text;
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
    final name = widget.patientName.isEmpty
        ? 'Patient #${widget.patientId}'
        : widget.patientName;

    return Scaffold(
      backgroundColor: DA.ground,
      appBar: DA.adminBar(name),
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              color: DA.rose,
              onRefresh: _loadThread,
              child: _buildBody(),
            ),
          ),
          _buildReplyBar(),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: DA.rose));
    }

    if (_errorMessage != null) {
      return ListView(
        padding: const EdgeInsets.all(32),
        children: [
          const SizedBox(height: 60),
          Text(
            _errorMessage!,
            textAlign: TextAlign.center,
            style: DA.body(15, color: DA.rejectedInk),
          ),
          const SizedBox(height: 16),
          Center(
            child: OutlinedButton(
              style: DA.outline().copyWith(
                minimumSize: const WidgetStatePropertyAll(Size(140, 48)),
              ),
              onPressed: _loadThread,
              child: const Text('Try again'),
            ),
          ),
        ],
      );
    }

    if (_messages.isEmpty) {
      return ListView(
        children: [
          const SizedBox(height: 100),
          Text(
            'No messages yet.',
            textAlign: TextAlign.center,
            style: DA.body(16, color: DA.muted),
          ),
        ],
      );
    }

    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final m = _messages[index] as Map<String, dynamic>;
        final isStaff = m['sender_role'] == 'staff';

        return DA.page(
          maxWidth: 760,
          Align(
            alignment: isStaff ? Alignment.centerRight : Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: isStaff ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 4, left: 4, right: 4),
                  child: Text(
                    isStaff ? 'You (practice)' : widget.patientName,
                    style: DA.body(12, color: DA.quiet, weight: FontWeight.w700),
                  ),
                ),
                Container(
                  constraints: const BoxConstraints(maxWidth: 480),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: isStaff ? DA.rose : DA.surface,
                    border: isStaff ? null : Border.all(color: DA.divider),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: Radius.circular(isStaff ? 20 : 6),
                      bottomRight: Radius.circular(isStaff ? 6 : 20),
                    ),
                  ),
                  child: Text(
                    (m['message'] as String?) ?? '',
                    style: DA.body(15, color: isStaff ? Colors.white : DA.ink, height: 1.5),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildReplyBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
      decoration: const BoxDecoration(
        color: DA.surface,
        border: Border(top: BorderSide(color: DA.divider)),
      ),
      child: DA.page(
        maxWidth: 760,
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: replyController,
                style: DA.body(15),
                textInputAction: TextInputAction.send,
                onSubmitted: (_) {
                  if (!_isSending) _sendReply();
                },
                decoration: DA.input(hint: 'Reply to ${widget.patientName}...').copyWith(
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
                tooltip: 'Send reply',
                style: IconButton.styleFrom(
                  backgroundColor: DA.rose,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: DA.rose.withValues(alpha: 0.5),
                ),
                onPressed: _isSending ? null : _sendReply,
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
    );
  }
}
