import 'package:clearskin_ai/core/config.dart';

class UserService {
  static const String _userKey = 'current_user';
  final _uuid = const Uuid();

  Future<AppUser> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);

    if (userJson != null) {
      try {
        return AppUser.fromJson(json.decode(userJson));
      } catch (e) {
        return _createDefaultUser();
      }
    }
    return _createDefaultUser();
  }

  Future<void> updateUser(AppUser user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, json.encode(user.toJson()));
  }

  AppUser _createDefaultUser() {
    final now = DateTime.now();
    return AppUser(
      id: _uuid.v4(),
      name: 'Guest User',
      email: 'guest@clearskin.ai',
      scanHistory: [],
      createdAt: now,
      updatedAt: now,
    );
  }

  Future<void> addScanToHistory(String scanId) async {
    final user = await getCurrentUser();
    final updatedUser = user.copyWith(
      scanHistory: [...user.scanHistory, scanId],
      updatedAt: DateTime.now(),
    );
    await updateUser(updatedUser);
  }

  Future<void> removeScanFromHistory(String scanId) async {
    final user = await getCurrentUser();
    final updatedHistory = user.scanHistory
        .where((id) => id != scanId)
        .toList();
    final updatedUser = user.copyWith(
      scanHistory: updatedHistory,
      updatedAt: DateTime.now(),
    );
    await updateUser(updatedUser);
  }
}
