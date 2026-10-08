import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../theme/design_a.dart';

class BillingScreen extends StatefulWidget {
  const BillingScreen({super.key});

  @override
  State<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends State<BillingScreen> {
  bool _isLoading = true;
  String? _error;
  List<dynamic> _bills = [];

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
      final bills = await AuthService.getMyBills();
      if (!mounted) return;
      setState(() {
        _bills = bills;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  String _money(dynamic value) {
    final amount = value is num ? value.toDouble() : double.tryParse('$value');
    return amount == null ? 'R$value' : 'R${amount.toStringAsFixed(2)}';
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'partially_paid':
        return 'Partially paid';
      case 'paid':
        return 'Paid';
      default:
        return 'Unpaid';
    }
  }

  (Color, Color) _statusColours(String status) {
    switch (status) {
      case 'paid':
        return (DA.approvedBg, DA.approvedInk);
      case 'partially_paid':
        return (DA.pendingBg, DA.pendingInk);
      default:
        return (DA.rejectedBg, DA.rejectedInk);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DA.ground,
      body: SafeArea(
        child: RefreshIndicator(
          color: DA.rose,
          onRefresh: _load,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: DA.backButton(context),
              ),
              const SizedBox(height: 16),
              Text('Billing', style: DA.heading(30)),
              const SizedBox(height: 6),
              Text(
                'View bills from the practice and their payment status.',
                style: DA.body(15, color: DA.muted),
              ),
              const SizedBox(height: 24),
              _buildBody(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.all(48),
        child: Center(child: CircularProgressIndicator(color: DA.rose)),
      );
    }

    if (_error != null) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: DA.card(),
        child: Column(
          children: [
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: DA.body(15, color: DA.rejectedInk),
            ),
            const SizedBox(height: 14),
            OutlinedButton(
              style: DA.outline(),
              onPressed: _load,
              child: const Text('Try again'),
            ),
          ],
        ),
      );
    }

    if (_bills.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(28),
        decoration: DA.card(),
        child: Text(
          'You do not have any bills yet.',
          textAlign: TextAlign.center,
          style: DA.body(16, color: DA.muted),
        ),
      );
    }

    return Column(
      children: _bills.map((item) {
        final bill = item as Map<String, dynamic>;
        final status = bill['status'] as String? ?? 'unpaid';
        final dueDate = bill['due_date']?.toString();
        final (bg, ink) = _statusColours(status);

        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(20),
          decoration: DA.card(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      bill['description'] as String? ?? 'Practice bill',
                      style: DA.body(17, weight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: bg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _statusLabel(status),
                      style: DA.body(12, color: ink, weight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(_money(bill['amount']), style: DA.heading(24, color: DA.sage)),
              if (dueDate != null && dueDate.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text('Due: $dueDate', style: DA.body(14, color: DA.muted)),
              ],
            ],
          ),
        );
      }).toList(),
    );
  }
}
