import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import 'home_screen.dart';
import 'register_screen.dart';

/// [LoginScreen] provides a user interface for member authentication.
/// It utilizes phone-based login and manages session tokens.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  /// Initiates the authentication process with the backend.
  ///
  /// 1. Validates user input.
  /// 2. Sends credentials to the server.
  /// 3. Persists the JWT token on success.
  /// 4. Handles errors and provides user feedback.
  Future<void> _login() async {
    // 1. UI Validation: Basic check before network overhead.
    if (_phoneController.text.trim().isEmpty) {
      _showErrorSnackBar('กรุณากรอกเบอร์โทรศัพท์ของคุณ');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 2. Fetch Base URL: Ensure strict environment configuration.
      final String baseUrl = _apiService.baseUrl;

      // 3. API Invocation: Execute POST request for authentication.
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': _phoneController.text.trim()}),
      );

      final data = jsonDecode(response.body);

      // 4. Success Handling: Verify status codes for 200 OK or 201 Created.
      if (response.statusCode == 200 || response.statusCode == 201) {
        final token = data['access_token'];

        if (token != null) {
          // Persist session token for future authorized requests.
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('access_token', token);

          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          }
        }
      } else {
        // 5. Logical Error: Handle unsuccessful login attempts.
        if (mounted) {
          _showErrorSnackBar(data['message'] ?? 'Login failed');
        }
      }
    } catch (e) {
      // 6. Exception Handling: Log system errors and notify user.
      debugPrint('CRITICAL LOGIN ERROR: $e');
      if (mounted) {
        _showErrorSnackBar(
          e.toString().contains('Exception')
              ? 'Configuration error: API URL not found'
              : 'Network error: Cannot reach server',
        );
      }
    } finally {
      // Ensure UI state is reset regardless of outcome.
      setState(() => _isLoading = false);
    }
  }

  /// Utility method to display standardized error messages.
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating, // Improved UX for modern apps
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildHeader(), // Clean Code: Extracting widgets for readability
                const SizedBox(height: 48),
                _buildPhoneInput(),
                const SizedBox(height: 32),
                _buildLoginButton(),
                const SizedBox(height: 16),
                _buildRegisterButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Sub-Widgets to improve Build Method readability ---

  Widget _buildHeader() {
    return Column(
      children: [
        Icon(
          Icons.local_fire_department_rounded,
          size: 100,
          color: Colors.deepOrange.shade500,
        ),
        const SizedBox(height: 24),
        const Text(
          'เข้าสู่ระบบสมาชิก',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        const Text(
          'หมาล่าเชิงดอย ยินดีต้อนรับ',
          style: TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildPhoneInput() {
    return TextField(
      controller: _phoneController,
      keyboardType: TextInputType.phone,
      maxLength: 10,
      decoration: InputDecoration(
        labelText: 'เบอร์โทรศัพท์ (10 หลัก)',
        prefixIcon: const Icon(Icons.phone),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        counterText: "",
      ),
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _login,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepOrange,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
                'เข้าสู่ระบบ',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  Widget _buildRegisterButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const RegisterScreen()),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          side: const BorderSide(
            color: Colors.black26,
          ), // Subtle outline for emphasis
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
                'สมัครสมาชิก',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
      ),
    );
  }
}
