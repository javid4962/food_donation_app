import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/user.dart';
import '../models/donation.dart';
import '../models/reward_level.dart';
import '../services/auth_service.dart';
import '../services/donation_service.dart';
import '../utils/responsive.dart';
import '../widgets/donation_image.dart';
import 'add_donation_screen.dart';
import 'profile_screen.dart';
import 'rewards_screen.dart';

class DonorDashboardScreen extends StatefulWidget {
  final User user;
  final VoidCallback onRefresh;

  const DonorDashboardScreen({
    super.key,
    required this.user,
    required this.onRefresh,
  });

  @override
  State<DonorDashboardScreen> createState() => _DonorDashboardScreenState();
}

class _DonorDashboardScreenState extends State<DonorDashboardScreen> {
  late User _currentUser;
  List<Donation> _donations = [];

  @override
  void initState() {
    super.initState();
    _currentUser = widget.user;
    _loadDonations();
  }

  Future<void> _loadDonations() async {
    final donations = DonationService.getUserDonations(_currentUser.id);
    setState(() {
      _donations = donations;
    });
  }

  Future<void> _refreshUser() async {
    final user = await AuthService.getCurrentUser();
    if (user != null) {
      setState(() {
        _currentUser = user;
      });
      widget.onRefresh();
    }
    await _loadDonations();
  }

  @override
  Widget build(BuildContext context) {
    final stats = DonationService.getUserStats(_currentUser.id);
    final totalDonations = stats['totalDonations'] as int;
    final totalQuantity = stats['totalQuantity'] as double;
    final currentLevel = RewardLevel.getCurrentLevel(
      totalDonations,
      totalQuantity,
    );
    final nextLevel = RewardLevel.getNextLevel(totalDonations, totalQuantity);

    double progress = 0.0;
    if (nextLevel != null && currentLevel != null) {
      final currentLevelIndex = RewardLevel.getAllLevels().indexOf(
        currentLevel,
      );
      final nextLevelIndex = RewardLevel.getAllLevels().indexOf(nextLevel);
      if (nextLevelIndex > currentLevelIndex) {
        final prevLevel = RewardLevel.getAllLevels()[currentLevelIndex];
        final donationProgress =
            (totalDonations - prevLevel.requiredDonations) /
            (nextLevel.requiredDonations - prevLevel.requiredDonations);
        final quantityProgress =
            (totalQuantity - prevLevel.requiredQuantity) /
            (nextLevel.requiredQuantity - prevLevel.requiredQuantity);
        progress = (donationProgress + quantityProgress) / 2;
      }
    } else if (nextLevel != null) {
      final donationProgress = totalDonations / nextLevel.requiredDonations;
      final quantityProgress = totalQuantity / nextLevel.requiredQuantity;
      progress = (donationProgress + quantityProgress) / 2;
    } else {
      progress = 1.0;
    }
    progress = progress.clamp(0.0, 1.0);

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
              'Food Donation',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.card_giftcard, color: Colors.white),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => RewardsScreen(user: _currentUser),
                ),
              );
            },
            tooltip: 'Rewards',
          ),
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
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = Responsive.isMobile(context);
            final padding = Responsive.getResponsivePadding(
              context,
              mobile: const EdgeInsets.all(16.0),
              tablet: const EdgeInsets.all(24.0),
              desktop: const EdgeInsets.all(32.0),
            );

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: padding,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                  maxWidth: Responsive.isDesktop(context)
                      ? 1200
                      : double.infinity,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: isMobile ? 16 : 24),
                    Text(
                      'Welcome back, ${_currentUser.fullName}!',
                      style: TextStyle(
                        fontSize: Responsive.getFontSize(
                          context,
                          mobile: 24,
                          tablet: 28,
                          desktop: 32,
                        ),
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2E7D32),
                      ),
                    ),
                    SizedBox(height: isMobile ? 8 : 12),
                    Text(
                      'Track your impact and earn rewards.',
                      style: TextStyle(
                        fontSize: Responsive.getFontSize(
                          context,
                          mobile: 16,
                          tablet: 18,
                          desktop: 20,
                        ),
                        color: const Color(0xFF616161),
                      ),
                    ),
                    SizedBox(height: isMobile ? 24 : 32),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  AddDonationScreen(user: _currentUser),
                            ),
                          );
                          _refreshUser();
                        },
                        icon: const Icon(Icons.add),
                        label: Text(
                          'Add Donation',
                          style: TextStyle(
                            fontSize: Responsive.getFontSize(
                              context,
                              mobile: 14,
                              tablet: 16,
                            ),
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4CAF50),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            horizontal: isMobile ? 20 : 32,
                            vertical: isMobile ? 12 : 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: isMobile ? 24 : 32),
                    _buildStatsGrid(
                      context,
                      totalDonations,
                      totalQuantity,
                      currentLevel,
                    ),
                    SizedBox(height: isMobile ? 24 : 32),
                    if (nextLevel != null) ...[
                      Text(
                        'Progress to Next Level',
                        style: TextStyle(
                          fontSize: Responsive.getFontSize(
                            context,
                            mobile: 20,
                            tablet: 24,
                            desktop: 28,
                          ),
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2E7D32),
                        ),
                      ),
                      SizedBox(height: isMobile ? 12 : 16),
                      Container(
                        padding: EdgeInsets.all(isMobile ? 16 : 20),
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
                            LinearProgressIndicator(
                              value: progress,
                              backgroundColor: const Color(0xFFE0E0E0),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Color(0xFF4CAF50),
                              ),
                              minHeight: isMobile ? 8 : 10,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            SizedBox(height: isMobile ? 12 : 16),
                            Text(
                              'Next: ${nextLevel.name} - ${nextLevel.reward}',
                              style: TextStyle(
                                fontSize: Responsive.getFontSize(
                                  context,
                                  mobile: 14,
                                  tablet: 16,
                                  desktop: 18,
                                ),
                                color: const Color(0xFF616161),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: isMobile ? 24 : 32),
                    ],
                    Text(
                      'My Donations',
                      style: TextStyle(
                        fontSize: Responsive.getFontSize(
                          context,
                          mobile: 20,
                          tablet: 24,
                          desktop: 28,
                        ),
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2E7D32),
                      ),
                    ),
                    SizedBox(height: isMobile ? 12 : 16),
                    if (_donations.isEmpty)
                      Container(
                        padding: EdgeInsets.all(isMobile ? 32 : 48),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            'No donations yet. Add your first donation!',
                            style: TextStyle(
                              fontSize: Responsive.getFontSize(
                                context,
                                mobile: 16,
                                tablet: 18,
                                desktop: 20,
                              ),
                              color: const Color(0xFF757575),
                            ),
                          ),
                        ),
                      )
                    else
                      _buildDonationsList(context),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatsGrid(
    BuildContext context,
    int totalDonations,
    double totalQuantity,
    RewardLevel? currentLevel,
  ) {
    final isMobile = Responsive.isMobile(context);
    final crossAxisCount = Responsive.getCrossAxisCount(context);

    if (isMobile) {
      // Mobile: Stack cards vertically
      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  'Total Donations',
                  totalDonations.toString(),
                  Icons.inventory_2,
                  const Color(0xFF4CAF50),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  context,
                  'Total Quantity',
                  '${totalQuantity.toStringAsFixed(1)} kg',
                  Icons.scale,
                  const Color(0xFF2196F3),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildStatCard(
            context,
            'Current Level',
            currentLevel?.name ?? 'Getting Started',
            Icons.emoji_events,
            const Color(0xFFFFC107),
          ),
        ],
      );
    } else {
      // Tablet/Desktop: Grid layout
      return GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: isMobile ? 1.5 : 1.8,
        children: [
          _buildStatCard(
            context,
            'Total Donations',
            totalDonations.toString(),
            Icons.inventory_2,
            const Color(0xFF4CAF50),
          ),
          _buildStatCard(
            context,
            'Total Quantity',
            '${totalQuantity.toStringAsFixed(1)} kg',
            Icons.scale,
            const Color(0xFF2196F3),
          ),
          _buildStatCard(
            context,
            'Current Level',
            currentLevel?.name ?? 'Getting Started',
            Icons.emoji_events,
            const Color(0xFFFFC107),
          ),
        ],
      );
    }
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    final isMobile = Responsive.isMobile(context);
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: color,
            size: Responsive.getResponsiveValue(
              context,
              mobile: 32,
              tablet: 36,
              desktop: 40,
            ),
          ),
          SizedBox(height: isMobile ? 12 : 16),
          Text(
            title,
            style: TextStyle(
              fontSize: Responsive.getFontSize(
                context,
                mobile: 14,
                tablet: 16,
                desktop: 18,
              ),
              color: const Color(0xFF757575),
            ),
          ),
          SizedBox(height: isMobile ? 4 : 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                fontSize: Responsive.getFontSize(
                  context,
                  mobile: 24,
                  tablet: 28,
                  desktop: 32,
                ),
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDonationsList(BuildContext context) {
    if (Responsive.isDesktop(context)) {
      // Desktop: Grid layout
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 3.5,
        ),
        itemCount: _donations.length,
        itemBuilder: (context, index) {
          return _buildDonationCard(_donations[index], context);
        },
      );
    } else {
      // Mobile/Tablet: List layout
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _donations.length,
        itemBuilder: (context, index) {
          return _buildDonationCard(_donations[index], context);
        },
      );
    }
  }

  Widget _buildDonationCard(Donation donation, BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final imageSize = Responsive.getResponsiveValue(
      context,
      mobile: 60.0,
      tablet: 70.0,
      desktop: 80.0,
    );

    return Container(
      margin: EdgeInsets.only(bottom: isMobile ? 12 : 16),
      padding: EdgeInsets.all(isMobile ? 16 : 20),
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
            width: imageSize,
            height: imageSize,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: donation.photoPath != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: DonationImage(
                      photoPath: donation.photoPath,
                      width: imageSize,
                      height: imageSize,
                      fit: BoxFit.cover,
                    ),
                  )
                : Icon(
                    Icons.recycling,
                    color: const Color(0xFF4CAF50),
                    size: imageSize * 0.5,
                  ),
          ),
          SizedBox(width: isMobile ? 16 : 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  donation.foodItemName,
                  style: TextStyle(
                    fontSize: Responsive.getFontSize(
                      context,
                      mobile: 16,
                      tablet: 18,
                      desktop: 20,
                    ),
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF212121),
                  ),
                ),
                SizedBox(height: isMobile ? 4 : 6),
                Text(
                  '${donation.quantity} kg',
                  style: TextStyle(
                    fontSize: Responsive.getFontSize(
                      context,
                      mobile: 14,
                      tablet: 16,
                      desktop: 18,
                    ),
                    color: const Color(0xFF757575),
                  ),
                ),
              ],
            ),
          ),
          Text(
            DateFormat('MM/dd/yyyy').format(donation.donationDate),
            style: TextStyle(
              fontSize: Responsive.getFontSize(
                context,
                mobile: 14,
                tablet: 16,
                desktop: 18,
              ),
              color: const Color(0xFF757575),
            ),
          ),
        ],
      ),
    );
  }
}
