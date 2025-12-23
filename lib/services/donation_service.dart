import 'package:uuid/uuid.dart';
import '../models/donation.dart';
import 'storage_service.dart';

class DonationService {
  static const _uuid = Uuid();

  static Future<Donation> createDonation({
    required String userId,
    required String foodItemName,
    required double quantity,
    String? photoPath,
    String? notes,
  }) async {
    final donation = Donation(
      id: _uuid.v4(),
      userId: userId,
      foodItemName: foodItemName,
      quantity: quantity,
      photoPath: photoPath,
      notes: notes,
      donationDate: DateTime.now(),
    );

    await StorageService.saveDonation(donation);
    return donation;
  }

  static List<Donation> getUserDonations(String userId) {
    return StorageService.getDonationsByUser(userId);
  }

  static List<Donation> getAllDonations() {
    return StorageService.getAllDonations();
  }

  static Map<String, dynamic> getUserStats(String userId) {
    final donations = getUserDonations(userId);
    final totalDonations = donations.length;
    final totalQuantity = donations.fold<double>(
      0.0,
      (sum, donation) => sum + donation.quantity,
    );

    return {'totalDonations': totalDonations, 'totalQuantity': totalQuantity};
  }
}
