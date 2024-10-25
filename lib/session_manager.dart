import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static final SessionManager _instance = SessionManager._internal();

  String? sessionCookie;
  String? csrfCookie;
  String? role;
  String? username;

  // Private constructor
  SessionManager._internal();

  // Factory constructor to return the singleton instance
  factory SessionManager() {
    return _instance;
  }

  // Method to save session data
  void saveSession(String session, String csrf, String role, String username) {
    sessionCookie = session;
    csrfCookie = csrf;
    this.role = role;
    this.username = username;
  }

  // Method to clear session data (useful for logout)
  void clearSession() {
    sessionCookie = null;
    csrfCookie = null;
    role = null;
    username = null;
  }
}

class UserSession {
  static final UserSession _instance = UserSession._internal();

  String? userRole;
  String? userId;

  factory UserSession() {
    return _instance;
  }

  UserSession._internal();
}



// class SessionManager {
//   // Save data
//   static Future<void> saveSessionData(String session, String csrf, String role) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.setString('session', session);
//     await prefs.setString('csrf', csrf);
//     await prefs.setString('role', role);
//   }
//
//   // Retrieve data
//   static Future<Map<String, String?>> getSessionData() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     return {
//       'session': prefs.getString('session'),
//       'csrf': prefs.getString('csrf'),
//       'role': prefs.getString('role'),
//     };
//   }
//
//   // Clear data
//   static Future<void> clearSession() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.clear();
//   }
// }
