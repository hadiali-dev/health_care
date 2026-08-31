import 'package:flutter/material.dart';
import 'package:healthcare_app/core/services/auth_service.dart';
import 'package:healthcare_app/core/models/user_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  UserModel? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await _authService.getCurrentUserModel();
    setState(() {
      _user = user;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_user == null) {
      return const Center(child: Text('User data not found.'));
    }

    final theme = Theme.of(context);
    final isPatient = _user!.role == 'patient';
    final isUnhealthy = _user!.healthStatus == 'patient';

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const CircleAvatar(
            radius: 50,
            child: Icon(Icons.person, size: 50),
          ),
          const SizedBox(height: 24),
          ListTile(
            leading: const Icon(Icons.badge_outlined),
            title: const Text('Full Name'),
            subtitle: Text(_user!.fullName),
          ),
          ListTile(
            leading: const Icon(Icons.email_outlined),
            title: const Text('Email'),
            subtitle: Text(_user!.email),
          ),
          ListTile(
            leading: const Icon(Icons.admin_panel_settings_outlined),
            title: const Text('Account Type'),
            subtitle: Text(_user!.role == 'medical_staff' ? 'Medical Staff' : 'Patient'),
          ),
          if (isPatient)
            ListTile(
              leading: Icon(
                isUnhealthy ? Icons.sick_outlined : Icons.check_circle_outline,
                color: isUnhealthy ? theme.colorScheme.error : theme.colorScheme.primary,
              ),
              title: const Text('Health Status'),
              subtitle: Text(
                isUnhealthy ? 'Marked as Patient' : 'Healthy',
                style: TextStyle(
                  color: isUnhealthy ? theme.colorScheme.error : theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          const Spacer(),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.errorContainer,
              foregroundColor: theme.colorScheme.onErrorContainer,
            ),
            onPressed: () async {
              await _authService.logout();
              // Router will automatically redirect to Login because of the stream listener!
            },
            icon: const Icon(Icons.logout),
            label: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}