import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../models/member_model.dart';
import '../widgets/member_card.dart';
import 'login_screen.dart';
import 'history_screen.dart';

/// [HomeScreen] serves as the primary dashboard for authenticated members.
///
/// It displays the member's digital loyalty card and provides access to
/// point transaction history and session management.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();

  /// Future that holds the member's profile data fetched from the API.
  late Future<MemberModel?> _memberFuture;

  @override
  void initState() {
    super.initState();
    // Initialize data fetching on screen load.
    _memberFuture = _apiService.fetchMemberProfile();
  }

  /// Terminates the current session by clearing the local access token.
  ///
  /// After clearing storage, it redirects the user back to the [LoginScreen].
  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');

    if (mounted) {
      // Use pushReplacement to prevent users from navigating back to the home screen.
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Colors.grey[50], // Light grey background for a clean UI feel.
      appBar: _buildAppBar(),
      body: FutureBuilder<MemberModel?>(
        future: _memberFuture,
        builder: (context, snapshot) {
          // 1. Handling Asynchronous Loading State
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.deepOrange),
            );
          }

          // 2. Handling Error or Empty States
          if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
            return _buildErrorState();
          }

          // 3. Data Successfully Retrieved
          final member = snapshot.data!;

          return _buildContent(member);
        },
      ),
    );
  }

  // --- Modular UI Components (Private Methods) ---

  /// Builds the standard application bar with a logout action.
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        'Mala Choengdoi Membership',
        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
      ),
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.logout, color: Colors.black54),
          tooltip:
              'Logout', // Accessibility: Provides context for screen readers.
          onPressed: _logout,
        ),
      ],
    );
  }

  /// Builds the main content area with the digital member card.
  Widget _buildContent(MemberModel member) {
    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(), // Premium feel on iOS/Android.
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 24),
            MemberCard(
              name: member.name,
              points: member.points,
              phone: member.phone,
              numberCode: member.memberCode,
              createdAt: member.createdAt,
              onHistoryTap: () => _navigateToHistory(member.id),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  /// Redirects to the transaction history screen.
  void _navigateToHistory(String memberId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HistoryScreen(memberId: memberId),
      ),
    );
  }

  /// Reusable widget for displaying data fetch errors.
  Widget _buildErrorState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.grey),
          SizedBox(height: 16),
          Text('ไม่สามารถโหลดข้อมูลได้', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
