import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/auth_provider.dart';
import '../services/mongodb_service.dart';
import '../database/database_helper.dart';
import '../models/user.dart';
import '../utils/theme.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _answerController = TextEditingController();
  final _newPasswordController = TextEditingController();

  int _step = 1; // 1 = Lookup Email, 2 = Verify Answer, 3 = Reset Password
  User? _foundUser;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _answerController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  void _lookupEmail() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) return;

    setState(() => _isLoading = true);

    // Try finding via MongoDB online first
    User? user;
    try {
      final doc = await MongoDbService.instance.findUserByEmail(email);
      if (doc != null) {
        user = User.fromJson(doc);
      }
    } catch (_) {}

    // Fallback to local database
    if (user == null) {
      user = await DatabaseHelper.instance.getUserByEmail(email);
    }

    setState(() {
      _isLoading = false;
      if (user != null) {
        _foundUser = user;
        _step = 2;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No user account found with that email address."), backgroundColor: AppTheme.error),
        );
      }
    });
  }

  void _verifyAnswer() {
    if (_foundUser == null) return;
    final cleanAnswer = _answerController.text.trim().toLowerCase();
    
    if (_foundUser!.securityAnswer == cleanAnswer) {
      setState(() {
        _step = 3;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Incorrect answer. Please try again."), backgroundColor: AppTheme.error),
      );
    }
  }

  void _resetPassword() async {
    if (_newPasswordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password must be at least 6 characters long."), backgroundColor: AppTheme.error),
      );
      return;
    }

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final success = await auth.resetPassword(
      email: _foundUser!.email,
      securityAnswer: _answerController.text,
      newPassword: _newPasswordController.text,
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Password reset successfully! Please sign in."), backgroundColor: AppTheme.accentGreen),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to reset password. Please try again."), backgroundColor: AppTheme.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Password Recovery")),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_step == 1) ...[
                const Text("Find Your Account", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text("Enter the email associated with your shop or customer profile."),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: "Email Address", prefixIcon: Icon(Icons.email_outlined)),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _lookupEmail,
                    child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("Find Account"),
                  ),
                ),
              ] else if (_step == 2) ...[
                const Text("Verify Identity", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text("Answer the security question chosen during setup:"),
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark ? AppTheme.darkSurface : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.black.withOpacity(0.04)),
                  ),
                  child: Text(
                    _foundUser!.securityQuestion,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _answerController,
                  decoration: const InputDecoration(labelText: "Your Answer", prefixIcon: Icon(Icons.question_answer_outlined)),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _verifyAnswer,
                    child: const Text("Verify Answer"),
                  ),
                ),
              ] else if (_step == 3) ...[
                const Text("Create New Password", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text("Please choose a strong and secure password."),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _newPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: "New Password", prefixIcon: Icon(Icons.lock_outline)),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _resetPassword,
                    child: const Text("Reset Password"),
                  ),
                ),
              ]
            ].animate().fade().slideY(begin: 0.1, end: 0),
          ),
        ),
      ),
    );
  }
}
