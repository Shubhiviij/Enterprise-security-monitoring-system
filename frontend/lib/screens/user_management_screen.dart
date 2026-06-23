import 'package:flutter/material.dart';
import '../services/api_service.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  List<dynamic> _operatorsList = [];
  bool _isProcessing = true;

  final List<String> _availableRoles = ["Administrator", "Analyst", "Viewer"];

  @override
  void initState() {
    super.initState();
    _refreshOperatorsDirectory();
  }

  Future<void> _refreshOperatorsDirectory() async {
    setState(() => _isProcessing = true);
    final data = await ApiService.getUsers();
    setState(() {
      _operatorsList = data;
      _isProcessing = false;
    });
  }

  void _showCreateUserModal() {
    final userController = TextEditingController();
    final passController = TextEditingController();
    String selectedRole = "Analyst";

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
            backgroundColor: const Color(0xFF1E293B),
            title: const Text("Onboard System Operator", style: TextStyle(color: Colors.white)),
            content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                  TextField(
                  controller: userController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(labelText: "Operator ID / Username", labelStyle: TextStyle(color: Colors.white60)),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: passController,
                  obscureText: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(labelText: "Initial Credentials Key", labelStyle: TextStyle(color: Colors.white60)),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                    dropdownColor: const Color(0xFF1E293B),
                    value: selectedRole,
                    items: _availableRoles.map((r) => DropdownMenuItem(value: r, child: Text(r, style: const TextStyle(color: Colors.white)))).toList(),
                    onChanged: (val) if (val != null) setModalState(() => selectedRole = val),
        decoration: const InputDecoration(labelText: "Access Controls Role", labelStyle: TextStyle(color: Colors.white60)),
      ),
      ],
    ),
    ),
    actions: [
    TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel", style: TextStyle(color: Colors.grey))),
    ElevatedButton(
    style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey.shade700),
    onPressed: () async {
    if (userController.text.trim().isEmpty || passController.text.isEmpty) return;
    final status = await ApiService.createNewUser(userController.text.trim(), passController.text, selectedRole);
    if (mounted) {
    Navigator.pop(context);
    _refreshOperatorsDirectory();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(status ? "Operator profile provisioned" : "Onboarding transaction rejected")));
    }
    },
    child: const Text("Provision User", style: TextStyle(color: Colors.white)),
    ),
    ],
    ),
    ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text("Access Management Control"),
        backgroundColor: const Color(0xFF111827),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _refreshOperatorsDirectory),
        ],
      ),
      body: _isProcessing
          ? const Center(child: CircularProgressIndicator())
          : _operatorsList.isEmpty
          ? const Center(child: Text("No operator logs synced from target server schema."))
          : ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _operatorsList.length,
        itemBuilder: (context, index) {
          final op = _operatorsList[index];
          final int userId = op["id"] ?? 0;
          String currentRole = op["role"] ?? "Viewer";

          // Ensure selected value matches the available roles exactly
          if (!_availableRoles.contains(currentRole)) {
            currentRole = "Viewer";
          }

          return Card(
            color: const Color(0xFF1E293B),
            margin: const EdgeInsets.symmetric(vertical: 6),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.blueGrey.withOpacity(0.2),
                    child: const Icon(Icons.person, color: Colors.blueGrey),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          (op["username"] ?? "").toString().toUpperCase(),
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 15),
                        ),
                        const SizedBox(height: 4),
                        Text("System ID: $userId", style: const TextStyle(color: Colors.grey, fontSize: 11)),
                      ],
                    ),
                  ),
                  // ── INLINE ACCESSIBILITY SECURITY ROLE SELECTION DROP-DOWN ──
                  DropdownButton<String>(
                    dropdownColor: const Color(0xFF1E293B),
                    value: currentRole,
                    underline: const SizedBox(),
                    icon: const Icon(Icons.edit_outlined, size: 16, color: Colors.blueGrey),
                    items: _availableRoles.map((r) => DropdownMenuItem(value: r, child: Text(r, style: TextStyle(fontSize: 13, color: r == "Administrator" ? Colors.red.shade300 : Colors.white70)))).toList(),
                    onChanged: (newRole) async {
                      if (newRole != null && newRole != currentRole) {
                        bool updated = await ApiService.changeUserRole(userId, newRole);
                        if (updated) _refreshOperatorsDirectory();
                      }
                    },
                  ),
                  const SizedBox(width: 8),
                  // ── DEPROVISION OPERATOR ACCESS ACTION ──
                  IconButton(
                    icon: const Icon(Icons.delete_sweep_outlined, color: Colors.redAccent, size: 20),
                    onPressed: op["username"] == "admin"
                        ? null // Safe check to protect root accounts
                        : () async {
                      bool deprovisioned = await ApiService.deprovisionUser(userId);
                      if (deprovisioned) {
                        _refreshOperatorsDirectory();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Action rejected: Insufficient credentials")));
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.blueGrey.shade800,
        icon: const Icon(Icons.person_add_alt_1, color: Colors.white),
        label: const Text("Onboard Operator", style: TextStyle(color: Colors.white)),
        onPressed: _showCreateUserModal,
      ),
    );
  }
}