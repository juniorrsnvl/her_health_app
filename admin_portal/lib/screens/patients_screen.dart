import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/design_a.dart';
import 'login_screen.dart';

class PatientsScreen extends StatefulWidget {
  const PatientsScreen({super.key});

  @override
  State<PatientsScreen> createState() => _PatientsScreenState();
}

class _PatientsScreenState extends State<PatientsScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  List<dynamic> _patients = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadPatients();
  }

  Future<void> _loadPatients() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await ApiService.authorizedGet('/patients/all');

      if (response.statusCode == 401 || response.statusCode == 403) {
        await ApiService.logout();
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
        return;
      }

      if (response.statusCode != 200) {
        setState(() {
          _errorMessage = 'Failed to load patients (${response.statusCode}).';
          _isLoading = false;
        });
        return;
      }

      final data = jsonDecode(response.body) as List<dynamic>;
      setState(() {
        _patients = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Could not reach the server.';
        _isLoading = false;
      });
    }
  }

  List<dynamic> get _filteredPatients {
    if (_searchQuery.isEmpty) return _patients;
    final query = _searchQuery.toLowerCase();
    return _patients.where((p) {
      final patient = p as Map<String, dynamic>;
      final firstName = (patient['first_name'] as String? ?? '').toLowerCase();
      final lastName = (patient['last_name'] as String? ?? '').toLowerCase();
      return firstName.contains(query) || lastName.contains(query);
    }).toList();
  }

  void _showPatientDetails(Map<String, dynamic> patient) {
    showModalBottomSheet(
      context: context,
      backgroundColor: DA.ground,
      constraints: const BoxConstraints(maxWidth: 640),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final firstName = patient['first_name'] as String? ?? '';
        final lastName = patient['last_name'] as String? ?? '';
        final dob = patient['date_of_birth'] as String?;
        final phone = patient['phone'] as String?;
        final emergencyName = patient['emergency_contact_name'] as String?;
        final emergencyPhone = patient['emergency_contact_phone'] as String?;

        return Padding(
          padding: const EdgeInsets.fromLTRB(28, 28, 28, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  DA.initials(firstName, lastName, size: 52),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text('$firstName $lastName'.trim(), style: DA.heading(24)),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: DA.card(),
                child: Column(
                  children: [
                    _detailRow('Date of birth', dob ?? 'Not provided'),
                    _detailRow('Phone', phone ?? 'Not provided'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text('Emergency contact', style: DA.heading(17, color: DA.sage)),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: DA.card(),
                child: Column(
                  children: [
                    _detailRow('Name', emergencyName ?? 'Not provided'),
                    _detailRow('Phone', emergencyPhone ?? 'Not provided'),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(label, style: DA.body(15, color: DA.quiet)),
          ),
          Expanded(
            child: Text(
              value,
              style: DA.body(
                15,
                weight: FontWeight.w600,
                color: value == 'Not provided' ? DA.quiet : DA.ink,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DA.ground,
      appBar: DA.adminBar('Patients'),
      body: RefreshIndicator(
        color: DA.rose,
        onRefresh: _loadPatients,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 48),
          children: [
            DA.page(
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Patients', style: DA.heading(30)),
                  const SizedBox(height: 6),
                  Text(
                    _isLoading
                        ? 'Loading patients...'
                        : '${_patients.length} registered ${_patients.length == 1 ? 'patient' : 'patients'}.',
                    style: DA.body(16, color: DA.muted),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    style: DA.body(16),
                    decoration: DA.input(
                      hint: 'Search by name',
                      prefix: const Icon(Icons.search_rounded, color: DA.sage),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  _buildBody(),
                ],
              ),
            ),
          ],
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

    if (_errorMessage != null) {
      return Column(
        children: [
          const SizedBox(height: 40),
          Text(
            _errorMessage!,
            textAlign: TextAlign.center,
            style: DA.body(15, color: DA.rejectedInk),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            style: DA.outline().copyWith(
              minimumSize: const WidgetStatePropertyAll(Size(140, 48)),
            ),
            onPressed: _loadPatients,
            child: const Text('Try again'),
          ),
        ],
      );
    }

    final patients = _filteredPatients;

    if (patients.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: DA.card(),
        child: Text(
          _searchQuery.isEmpty ? 'No patients yet.' : 'No matches found.',
          textAlign: TextAlign.center,
          style: DA.body(16, color: DA.muted),
        ),
      );
    }

    return Column(
      children: patients.map((p) {
        final patient = p as Map<String, dynamic>;
        final firstName = patient['first_name'] as String? ?? '';
        final lastName = patient['last_name'] as String? ?? '';
        final phone = patient['phone'] as String?;

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Material(
            color: DA.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(color: DA.border, width: 1.5),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => _showPatientDetails(patient),
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
                            '$firstName $lastName'.trim(),
                            style: DA.body(16, weight: FontWeight.w700),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            phone ?? 'No phone on file',
                            style: DA.body(15, color: DA.quiet),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded, color: DA.quiet),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
