class AuthSession {
  // Singleton pattern for global access across screens
  static final AuthSession _instance = AuthSession._internal();
  factory AuthSession() => _instance;
  AuthSession._internal();

  String? username;
  String? role;
  bool isAuthenticated = false;

  void startSession(String user, String assignedRole) {
    username = user;
    role = assignedRole;
    isAuthenticated = true;
  }

  void clearSession() {
    username = null;
    role = null;
    isAuthenticated = false;
  }

  bool get isAdmin => role?.toUpperCase() == 'ADMINISTRATOR';
}