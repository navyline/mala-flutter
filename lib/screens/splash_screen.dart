import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';
import 'login_screen.dart';

/// [SplashScreen] acts as the initial entry point of the application.
///
/// Responsibilities:
/// 1. Display branding (Logo and App Name).
/// 2. Orchestrate session validation (Check for JWT token).
/// 3. Route the user to the appropriate screen based on authentication state.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApplication();
  }

  /// High-level application initialization sequence.
  Future<void> _initializeApplication() async {
    try {
      // Minimum display time for branding visibility (UX design choice).
      await Future.delayed(const Duration(milliseconds: 1500));

      await _checkLoginStatus();
    } catch (e) {
      // Fallback: If initialization fails, default to LoginScreen for safety.
      debugPrint('INITIALIZATION ERROR: $e');
      _navigateTo(const LoginScreen());
    }
  }

  /// Validates the existence of a stored access token.
  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('access_token');

    if (mounted) {
      if (token != null && token.isNotEmpty) {
        // Authenticated session found.
        _navigateTo(const HomeScreen());
      } else {
        // No valid session; redirect to login.
        _navigateTo(const LoginScreen());
      }
    }
  }

  /// Standardized navigation with replacement to clear the splash from stack.
  void _navigateTo(Widget destination) {
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => destination),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepOrange, // Corporate primary color
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildBrandingLogo(),
            const SizedBox(height: 24),
            _buildAppTitle(),
            const SizedBox(height: 64),
            _buildLoadingIndicator(),
          ],
        ),
      ),
    );
  }

  // --- Specialized UI Components ---

  /// Builds the primary app logo using a stylized icon.
  Widget _buildBrandingLogo() {
    return const Icon(
      Icons.local_fire_department_rounded,
      size: 120, // Increased size for better visual impact
      color: Colors.white,
    );
  }

  /// Displays the official application name.
  Widget _buildAppTitle() {
    return const Text(
      'หมาล่าเชิงดอย',
      style: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w900, // Extra bold for branding
        color: Colors.white,
        letterSpacing: 1.2,
      ),
    );
  }

  /// Standardized loader to indicate background processing.
  Widget _buildLoadingIndicator() {
    return const SizedBox(
      width: 24,
      height: 24,
      child: CircularProgressIndicator(
        color: Colors.white,
        strokeWidth: 2.5, // Thinner stroke for a modern look
      ),
    );
  }
}
