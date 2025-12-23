import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/user.dart';
import '../models/donation.dart';
import '../services/auth_service.dart';
import '../services/donation_service.dart';
import '../services/storage_service.dart';
import '../widgets/donation_image.dart';
import 'profile_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  final User user;

  const AdminDashboardScreen({super.key, required this.user});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  late User _currentUser;
  List<Donation> _allDonations = [];
  List<User> _allUsers = [];

  @override
  void initState() {
    super.initState();
    _currentUser = widget.user;
    _loadData();
  }

  Future<void> _loadData() async {
    final donations = DonationService.getAllDonations();
    final users = StorageService.getAllUsers();
    setState(() {
      _allDonations = donations;
      _allUsers = users;
    });
  }

  Future<void> _refreshUser() async {
    final user = await AuthService.getCurrentUser();
    if (user != null) {
      setState(() {
        _currentUser = user;
      });
    }
    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final totalDonations = _allDonations.length;
    final totalQuantity = _allDonations.fold<double>(
      0.0,
      (sum, donation) => sum + donation.quantity,
    );
    final totalUsers = _allUsers.length;
    final totalDonors = _allUsers.where((u) => u.role == UserRole.donor).length;

    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4CAF50),
        elevation: 0,
        title: Row(
          children: [
            const Icon(Icons.favorite, color: Colors.white),
            const SizedBox(width: 8),
            const Text(
              'Food Donation - Admin',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ProfileScreen(user: _currentUser),
                ),
              );
              _refreshUser();
            },
            tooltip: 'Profile',
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await AuthService.logout();
              if (mounted) {
                Navigator.of(context).pushReplacementNamed('/login');
              }
            },
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshUser,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Text(
                'Admin Dashboard',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E7D32),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Manage all donations and users',
                style: TextStyle(fontSize: 16, color: Color(0xFF616161)),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Total Donations',
                      totalDonations.toString(),
                      Icons.inventory_2,
                      const Color(0xFF4CAF50),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      'Total Quantity',
                      '${totalQuantity.toStringAsFixed(1)} kg',
                      Icons.scale,
                      const Color(0xFF2196F3),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Total Users',
                      totalUsers.toString(),
                      Icons.people,
                      const Color(0xFFFF9800),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      'Total Donors',
                      totalDonors.toString(),
                      Icons.person,
                      const Color(0xFF9C27B0),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'All Donations',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E7D32),
                ),
              ),
              const SizedBox(height: 12),
              if (_allDonations.isEmpty)
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text(
                      'No donations yet.',
                      style: TextStyle(fontSize: 16, color: Color(0xFF757575)),
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _allDonations.length,
                  itemBuilder: (context, index) {
                    final donation = _allDonations[index];
                    final donor = _allUsers.firstWhere(
                      (u) => u.id == donation.userId,
                      orElse: () => User(
                        id: 'unknown',
                        email: 'unknown',
                        fullName: 'Unknown User',
                        password: '',
                        role: UserRole.user,
                        createdAt: DateTime.now(),
                      ),
                    );
                    return _buildDonationCard(donation, donor);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(fontSize: 14, color: Color(0xFF757575)),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDonationCard(Donation donation, User donor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: donation.photoPath != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: DonationImage(
                      photoPath: donation.photoPath,
                      fit: BoxFit.cover,
                    ),
                  )
                : const Icon(
                    Icons.recycling,
                    color: Color(0xFF4CAF50),
                    size: 32,
                  ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  donation.foodItemName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF212121),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${donation.quantity} kg • Donated by ${donor.fullName}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF757575),
                  ),
                ),
                if (donation.notes != null && donation.notes!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    donation.notes!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF9E9E9E),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          Text(
            DateFormat('MM/dd/yyyy').format(donation.donationDate),
            style: const TextStyle(fontSize: 14, color: Color(0xFF757575)),
          ),
        ],
      ),
    );
  }
}
