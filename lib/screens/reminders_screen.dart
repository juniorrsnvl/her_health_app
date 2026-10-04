import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../theme/design_a.dart';

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  bool _isLoading = true;
  String? _error;
  List<Map<String, dynamic>> _reminders = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await AuthService.getReminders();
      if (!mounted) return;
      setState(() {
        _reminders = data.cast<Map<String, dynamic>>();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _two(int n) => n.toString().padLeft(2, '0');

  String _format(DateTime dt) =>
      '${_two(dt.day)}/${_two(dt.month)}/${dt.year} at ${_two(dt.hour)}:${_two(dt.minute)}';

  Future<void> _toggle(Map<String, dynamic> reminder, bool isDone) async {
    try {
      await AuthService.setReminderDone(reminder['id'] as int, isDone);
      await _load();
    } catch (e) {
      _showError(e.toString());
    }
  }

  Future<void> _delete(Map<String, dynamic> reminder) async {
    try {
      await AuthService.deleteReminder(reminder['id'] as int);
      await _load();
    } catch (e) {
      _showError(e.toString());
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red.shade400),
    );
  }

  Future<void> _openAddSheet() async {
    final added = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => const _AddReminderSheet(),
    );

    if (added == true) {
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DA.ground,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: DA.rose,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: const StadiumBorder(),
        onPressed: _openAddSheet,
        icon: const Icon(Icons.add),
        label: Text('Add reminder', style: DA.heading(16, color: Colors.white)),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DA.backButton(context),
                  const SizedBox(height: 16),
                  Text('Reminders', style: DA.heading(30)),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                color: DA.rose,
                onRefresh: _load,
                child: _buildBody(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: DA.rose));
    }

    if (_error != null) {
      return ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 60),
          Text(
            _error!,
            textAlign: TextAlign.center,
            style: DA.body(15, color: DA.rejectedInk),
          ),
        ],
      );
    }

    if (_reminders.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 80),
          Text(
            'No reminders yet.\nTap "Add reminder" to create one.',
            textAlign: TextAlign.center,
            style: DA.body(16, color: DA.muted),
          ),
        ],
      );
    }

    final now = DateTime.now();

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
      itemCount: _reminders.length,
      itemBuilder: (context, index) {
        final reminder = _reminders[index];
        final isDone = reminder['is_done'] == true;
        final title = (reminder['title'] as String?) ?? '';
        final notes = reminder['notes'] as String?;
        final when = DateTime.tryParse((reminder['remind_at'] as String?) ?? '');
        final isOverdue = !isDone && when != null && when.isBefore(now);

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.fromLTRB(8, 10, 4, 10),
          decoration: DA.card(color: isDone ? DA.ground : DA.surface),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: isDone,
                activeColor: DA.rose,
                side: const BorderSide(color: Color(0xFFC9BDB8), width: 2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                onChanged: (value) => _toggle(reminder, value ?? false),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: DA.body(
                          16,
                          weight: FontWeight.w700,
                          color: isDone ? DA.quiet : DA.ink,
                        ).copyWith(
                          decoration: isDone ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      if (when != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          isOverdue ? '${_format(when)} · overdue' : _format(when),
                          style: DA.body(
                            14,
                            color: isOverdue ? DA.rejectedInk : DA.muted,
                            weight: isOverdue ? FontWeight.w700 : FontWeight.w400,
                          ),
                        ),
                      ],
                      if (notes != null && notes.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(notes, style: DA.body(14, color: DA.quiet)),
                      ],
                    ],
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Delete',
                icon: const Icon(Icons.delete_outline_rounded, color: DA.quiet),
                onPressed: () => _delete(reminder),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Bottom sheet for creating a reminder. Separate widget so it keeps its
/// own form state while open.
class _AddReminderSheet extends StatefulWidget {
  const _AddReminderSheet();

  @override
  State<_AddReminderSheet> createState() => _AddReminderSheetState();
}

class _AddReminderSheetState extends State<_AddReminderSheet> {
  final titleController = TextEditingController();
  final notesController = TextEditingController();
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  bool _isSubmitting = false;

  String _two(int n) => n.toString().padLeft(2, '0');

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
    );
    if (picked != null) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  Future<void> _submit() async {
    if (titleController.text.trim().isEmpty) {
      _showError('Please give the reminder a title.');
      return;
    }
    if (selectedDate == null || selectedTime == null) {
      _showError('Please choose a date and time.');
      return;
    }

    final remindAt = DateTime(
      selectedDate!.year,
      selectedDate!.month,
      selectedDate!.day,
      selectedTime!.hour,
      selectedTime!.minute,
    );

    setState(() {
      _isSubmitting = true;
    });

    try {
      await AuthService.addReminder(
        title: titleController.text.trim(),
        notes: notesController.text,
        remindAt: remindAt,
      );
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red.shade400),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('New reminder', style: DA.heading(22)),
          const SizedBox(height: 16),
          DA.label('Title'),
          TextField(
            controller: titleController,
            style: DA.body(16),
            decoration: DA.input(hint: 'e.g. Take iron supplement'),
          ),
          const SizedBox(height: 14),
          DA.label('Date'),
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: _pickDate,
            child: InputDecorator(
              decoration: DA.input(
                suffix: const Icon(Icons.calendar_today_outlined, color: DA.sage),
              ),
              child: Text(
                selectedDate == null
                    ? 'Choose a date'
                    : '${_two(selectedDate!.day)}/${_two(selectedDate!.month)}/${selectedDate!.year}',
                style: DA.body(16, color: selectedDate == null ? DA.quiet : DA.ink),
              ),
            ),
          ),
          const SizedBox(height: 14),
          DA.label('Time'),
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: _pickTime,
            child: InputDecorator(
              decoration: DA.input(
                suffix: const Icon(Icons.access_time_rounded, color: DA.sage),
              ),
              child: Text(
                selectedTime == null ? 'Choose a time' : selectedTime!.format(context),
                style: DA.body(16, color: selectedTime == null ? DA.quiet : DA.ink),
              ),
            ),
          ),
          const SizedBox(height: 14),
          DA.label('Notes (optional)'),
          TextField(
            controller: notesController,
            style: DA.body(16),
            decoration: DA.input(),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            style: DA.primary(),
            onPressed: _isSubmitting ? null : _submit,
            child: _isSubmitting ? DA.buttonSpinner : const Text('Save reminder'),
          ),
        ],
      ),
    );
  }
}
