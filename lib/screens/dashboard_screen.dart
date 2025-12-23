import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import 'admin_dashboard_screen.dart';
import 'user_dashboard_screen.dart';
import 'donor_dashboard_screen.dart';

class DashboardScreen extends StatefulWidget {
  final User user;

  const DashboardScreen({super.key, required this.user});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late User _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = widget.user;
    _refreshUser();
  }

  Future<void> _refreshUser() async {
    final user = await AuthService.getCurrentUser();
    if (user != null) {
      setState(() {
        _currentUser = user;
      });
    }
  }

  Widget _buildRoleBasedDashboard() {
    switch (_currentUser.role) {
      case UserRole.admin:
        return AdminDashboardScreen(user: _currentUser);
      case UserRole.donor:
        return DonorDashboardScreen(
          user: _currentUser,
          onRefresh: _refreshUser,
        );
      case UserRole.user:
        return UserDashboardScreen(user: _currentUser, onRefresh: _refreshUser);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _buildRoleBasedDashboard());
  }
}
