import 'package:flutter/material.dart';
import '../../core/models/user_model.dart';
import '../../core/services/patient_service.dart';

class PatientsListScreen extends StatefulWidget {
  const PatientsListScreen({super.key});

  @override
  State<PatientsListScreen> createState() => _PatientsListScreenState();
}

class _PatientsListScreenState extends State<PatientsListScreen> {
  final PatientService _patientService = PatientService();

  Future<void> _toggleStatus(UserModel patient) async {
    final newStatus = patient.healthStatus == 'healthy' ? 'patient' : 'healthy';
    await _patientService.updateHealthStatus(patient.uid, newStatus);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return StreamBuilder<List<UserModel>>(
      stream: _patientService.streamAllPatients(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Text('Error loading patients.',
                style: TextStyle(color: theme.colorScheme.error)),
          );
        }

        final patients = snapshot.data ?? [];
        if (patients.isEmpty) {
          return const Center(child: Text('No patients registered yet.'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: patients.length,
          itemBuilder: (context, index) {
            final patient = patients[index];
            final isUnhealthy = patient.healthStatus == 'patient';

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              elevation: 0,
              color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: isUnhealthy
                      ? theme.colorScheme.errorContainer
                      : theme.colorScheme.primaryContainer,
                  child: Icon(
                    isUnhealthy ? Icons.sick_outlined : Icons.check_circle_outline,
                    color: isUnhealthy
                        ? theme.colorScheme.onErrorContainer
                        : theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                title: Text(patient.fullName),
                subtitle: Text(patient.email),
                trailing: Switch(
                  value: isUnhealthy,
                  onChanged: (_) => _toggleStatus(patient),
                  activeColor: theme.colorScheme.error,
                ),
              ),
            );
          },
        );
      },
    );
  }
}