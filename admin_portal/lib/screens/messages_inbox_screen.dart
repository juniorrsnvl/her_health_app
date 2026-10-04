import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/design_a.dart';
import 'login_screen.dart';
import 'message_thread_screen.dart';

class MessagesInboxScreen extends StatefulWidget {
  const MessagesInboxScreen({super.key});

  @override
  State<MessagesInboxScreen> createState() => _MessagesInboxScreenState();
}

class _MessagesInboxScreenState extends State<MessagesInboxScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  List<dynamic> _threads = [];

  @override
  void initState() {
    super.initState();
    _loadThreads();
  }

  Future<void> _loadThreads() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await ApiService.authorizedGet('/messages/threads');

      if (response.statusCode == 401 || response.statusCode == 403) {
        await _handleSessionExpired();
        return;
      }

      if (response.statusCode != 200) {
        setState(() {
          _errorMessage = 'Failed to load messages (${response.statusCode}).';
          _isLoading = false;
        });
        return;
      }

      final data = jsonDecode(response.body) as List<dynamic>;
      setState(() {
        _threads = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Could not reach the server.';
        _isLoading = false;
      });
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

  Future<void> _openThread(int patientId, String patientName) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MessageThreadScreen(
          patientId: patientId,
          patientName: patientName,
        ),
      ),
    );
    // Refresh the list on return, in case a reply changed the unread count.
    _loadThreads();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DA.ground,
      appBar: DA.adminBar('Messages'),
      body: RefreshIndicator(
        color: DA.rose,
        onRefresh: _loadThreads,
        child: _buildBody(),
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
              onPressed: _loadThreads,
              child: const Text('Try again'),
            ),
          ),
        ],
      );
    }

    final unreadTotal = _threads.fold<int>(
      0,
      (sum, t) => sum + ((t as Map<String, dynamic>)['unread_count'] as int? ?? 0),
    );

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 48),
      children: [
        DA.page(
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Patient messages', style: DA.heading(30)),
              const SizedBox(height: 6),
              Text(
                unreadTotal == 0
                    ? 'You are all caught up.'
                    : '$unreadTotal unread ${unreadTotal == 1 ? 'message' : 'messages'}.',
                style: DA.body(16, color: DA.muted),
              ),
              const SizedBox(height: 20),
              if (_threads.isEmpty)
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: DA.card(),
                  child: Text(
                    'No messages yet.',
                    textAlign: TextAlign.center,
                    style: DA.body(16, color: DA.muted),
                  ),
                ),
              ..._threads.map((t) => _threadRow(t as Map<String, dynamic>)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _threadRow(Map<String, dynamic> thread) {
    final patientId = thread['patient_id'] as int;
    final firstName = thread['first_name'] as String? ?? '';
    final lastName = thread['last_name'] as String? ?? '';
    final lastMessage = thread['last_message'] as String? ?? '';
    final unreadCount = thread['unread_count'] as int? ?? 0;
    final fullName = '$firstName $lastName'.trim();
    final unread = unreadCount > 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: DA.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: unread ? DA.rose : DA.border, width: 1.5),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _openThread(patientId, fullName),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                DA.initials(firstName, lastName),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fullName.isEmpty ? 'Patient #$patientId' : fullName,
                        style: DA.body(16, weight: FontWeight.w700),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        lastMessage,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: DA.body(
                          15,
                          color: unread ? DA.ink : DA.quiet,
                          weight: unread ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                if (unread) ...[
                  const SizedBox(width: 12),
                  Container(
                    constraints: const BoxConstraints(minWidth: 26),
                    height: 26,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: DA.rose,
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Text(
                      '$unreadCount',
                      style: DA.body(12, color: Colors.white, weight: FontWeight.w800),
                    ),
                  ),
                ],
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right_rounded, color: DA.quiet),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
