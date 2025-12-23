import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/user.dart';
import '../models/donation.dart';

class StorageService {
  static const String _boxNameUsers = 'users';
  static const String _boxNameDonations = 'donations';
  static const String _keyCurrentUserId = 'current_user_id';
  static const String _keyIsLoggedIn = 'is_logged_in';

  static Box<Map>? _usersBox;
  static Box<Map>? _donationsBox;

  static Future<void> init() async {
    await Hive.initFlutter();

    if (!Hive.isAdapterRegistered(0)) {
      // Register adapters if needed
    }

    _usersBox = await Hive.openBox<Map>(_boxNameUsers);
    _donationsBox = await Hive.openBox<Map>(_boxNameDonations);
  }

  // User storage methods
  static Future<void> saveUser(User user) async {
    await _usersBox?.put(user.id, user.toJson());
  }

  static User? getUser(String userId) {
    final userData = _usersBox?.get(userId);
    if (userData != null) {
      return User.fromJson(Map<String, dynamic>.from(userData));
    }
    return null;
  }

  static List<User> getAllUsers() {
    final users = <User>[];
    _usersBox?.values.forEach((userData) {
      users.add(User.fromJson(Map<String, dynamic>.from(userData)));
    });
    return users;
  }

  static User? getUserByEmail(String email) {
    final users = getAllUsers();
    try {
      return users.firstWhere((user) => user.email == email);
    } catch (e) {
      return null;
    }
  }

  // Donation storage methods
  static Future<void> saveDonation(Donation donation) async {
    await _donationsBox?.put(donation.id, donation.toJson());
  }

  static Donation? getDonation(String donationId) {
    final donationData = _donationsBox?.get(donationId);
    if (donationData != null) {
      return Donation.fromJson(Map<String, dynamic>.from(donationData));
    }
    return null;
  }

  static List<Donation> getAllDonations() {
    final donations = <Donation>[];
    _donationsBox?.values.forEach((donationData) {
      donations.add(Donation.fromJson(Map<String, dynamic>.from(donationData)));
    });
    return donations;
  }

  static List<Donation> getDonationsByUser(String userId) {
    final allDonations = getAllDonations();
    return allDonations.where((d) => d.userId == userId).toList()
      ..sort((a, b) => b.donationDate.compareTo(a.donationDate));
  }

  // Auth state methods
  static Future<void> setCurrentUserId(String? userId) async {
    final prefs = await SharedPreferences.getInstance();
    if (userId != null) {
      await prefs.setString(_keyCurrentUserId, userId);
      await prefs.setBool(_keyIsLoggedIn, true);
    } else {
      await prefs.remove(_keyCurrentUserId);
      await prefs.setBool(_keyIsLoggedIn, false);
    }
  }

  static Future<String?> getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyCurrentUserId);
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  static Future<void> logout() async {
    await setCurrentUserId(null);
  }
}
