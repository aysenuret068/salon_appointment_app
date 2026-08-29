import '../models/app_user_model.dart';

class UserSession {
  static AppUserModel? currentUser;

  static bool get isLoggedIn => currentUser != null;

  static void logout() {
    currentUser = null;
  }
}