import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/auth_session.dart';
import 'dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  void _triggerLogin() async {
    if (_userController.text.trim().isEmpty || _passController.text.isEmpty) {
      setState(() => _error = "Credentials fields cannot be blank");
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final session = await ApiService.login(
      _userController.text.trim(),
      _passController.text,
    );

    setState(() => _isLoading = false);

    if (session != null && mounted) {
      // ── NEW: INITIALIZE GLOBAL RBAC SESSION ──
      AuthSession().startSession(
        session["username"] ?? _userController.text.trim(),
        session["role"] ?? "Analyst",
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
      );
    } else {
      setState(() => _error = "Access Denied: Invalid Operator Credentials");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.gpp_good, size: 70, color: Colors.blueGrey),
              const SizedBox(height: 12),
              const Text(
                "ENTERPRISE MONITOR",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 1.5),
              ),
              const Text("Security Gateway Access Control", style: TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(height: 30),
              TextField(
                controller: _userController,
                decoration: const InputDecoration(
                  labelText: "Operator Identity",
                  prefixIcon: Icon(Icons.person_outline),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Security Keyphrase",
                  prefixIcon: Icon(Icons.lock_outline),
                  border: OutlineInputBorder(),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 16),
                Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 13, fontWeight: FontWeight.w500)),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: Colors.blueGrey.shade800,
                  ),
                  onPressed: _isLoading ? null : _triggerLogin,
                  child: _isLoading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text("Authenticate Operator", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}