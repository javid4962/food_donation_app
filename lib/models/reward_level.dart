class RewardLevel {
  final int level;
  final String name;
  final int requiredDonations;
  final double requiredQuantity; // in kg
  final String reward;

  RewardLevel({
    required this.level,
    required this.name,
    required this.requiredDonations,
    required this.requiredQuantity,
    required this.reward,
  });

  static List<RewardLevel> getAllLevels() {
    return [
      RewardLevel(
        level: 1,
        name: 'Bronze Helper',
        requiredDonations: 5,
        requiredQuantity: 10.0,
        reward: '\$5 Amazon Voucher',
      ),
      RewardLevel(
        level: 2,
        name: 'Silver Supporter',
        requiredDonations: 15,
        requiredQuantity: 30.0,
        reward: '\$10 Gift Card',
      ),
      RewardLevel(
        level: 3,
        name: 'Gold Giver',
        requiredDonations: 30,
        requiredQuantity: 60.0,
        reward: '\$20 Cashback',
      ),
      RewardLevel(
        level: 4,
        name: 'Platinum Partner',
        requiredDonations: 50,
        requiredQuantity: 100.0,
        reward: '\$35 Amazon Voucher',
      ),
      RewardLevel(
        level: 5,
        name: 'Diamond Donor',
        requiredDonations: 100,
        requiredQuantity: 200.0,
        reward: '\$50 Gift Card',
      ),
      RewardLevel(
        level: 6,
        name: 'Elite Champion',
        requiredDonations: 200,
        requiredQuantity: 500.0,
        reward: '\$100 Cashback',
      ),
    ];
  }

  static RewardLevel? getCurrentLevel(
    int totalDonations,
    double totalQuantity,
  ) {
    final levels = getAllLevels();
    for (int i = levels.length - 1; i >= 0; i--) {
      final level = levels[i];
      if (totalDonations >= level.requiredDonations &&
          totalQuantity >= level.requiredQuantity) {
        return level;
      }
    }
    return null;
  }

  static RewardLevel? getNextLevel(int totalDonations, double totalQuantity) {
    final levels = getAllLevels();
    for (final level in levels) {
      if (totalDonations < level.requiredDonations ||
          totalQuantity < level.requiredQuantity) {
        return level;
      }
    }
    return null;
  }
}
