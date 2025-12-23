import 'package:uuid/uuid.dart';
import '../models/user.dart';
import 'storage_service.dart';

class AuthService {
  static const _uuid = Uuid();

  static Future<User?> login(String email, String password) async {
    final user = StorageService.getUserByEmail(email);
    if (user != null && user.password == password) {
      await StorageService.setCurrentUserId(user.id);
      return user;
    }
    return null;
  }

  static Future<User?> signup({
    required String email,
    required String password,
    required String fullName,
    required UserRole role,
  }) async {
    // Check if user already exists
    if (StorageService.getUserByEmail(email) != null) {
      return null;
    }

    final user = User(
      id: _uuid.v4(),
      email: email,
      fullName: fullName,
      password: password,
      role: role,
      createdAt: DateTime.now(),
    );

    await StorageService.saveUser(user);
    await StorageService.setCurrentUserId(user.id);
    return user;
  }

  static Future<User?> getCurrentUser() async {
    final userId = await StorageService.getCurrentUserId();
    if (userId != null) {
      return StorageService.getUser(userId);
    }
    return null;
  }

  static Future<void> logout() async {
    await StorageService.logout();
  }

  static Future<User?> updateUser(User user) async {
    await StorageService.saveUser(user);
    return user;
  }
}
