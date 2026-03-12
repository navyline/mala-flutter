import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/history_model.dart';
import '../widgets/history_tile.dart';

/// [HistoryScreen] displays a chronological list of point transactions.
///
/// It requires a [memberId] to fetch specific data from the backend.
class HistoryScreen extends StatefulWidget {
  /// Unique identifier of the member used for API requests.
  final String memberId;

  const HistoryScreen({super.key, required this.memberId});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final ApiService _apiService = ApiService();

  /// Asynchronous future that retrieves the list of transaction history.
  late Future<List<HistoryModel>> _historyFuture;

  @override
  void initState() {
    super.initState();
    // Initialize the data stream for the specific member.
    _historyFuture = _apiService.fetchHistory(widget.memberId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: FutureBuilder<List<HistoryModel>>(
        future: _historyFuture,
        builder: (context, snapshot) {
          // 1. Handling the 'In-Progress' state.
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.deepOrange),
            );
          }

          // 2. Handling 'Empty' or 'No Data' states.
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState();
          }

          // 3. Handling 'Success' state.
          final historyList = snapshot.data!;
          return _buildHistoryList(historyList);
        },
      ),
    );
  }

  // --- Private UI Helper Methods ---

  /// Builds the standard app bar with a back navigation button.
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1,
      leading: IconButton(
        icon: const Icon(Icons.chevron_left, color: Colors.black, size: 32),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'ประวัติคะแนน',
        style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
      ),
      centerTitle: false,
    );
  }

  /// Builds the scrollable list of history items.
  Widget _buildHistoryList(List<HistoryModel> historyList) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          _buildSummaryCard(historyList.length),
          // Mapping data objects to UI Widgets (HistoryTiles).
          ...historyList.map((item) => _buildTransactionItem(item)),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  /// Builds the top summary card displaying the total transaction count.
  Widget _buildSummaryCard(int count) {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.orange.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          _buildTrophyIcon(),
          const SizedBox(width: 16),
          _buildSummaryText(count),
        ],
      ),
    );
  }

  /// Displays the Trophy icon within a styled container.
  Widget _buildTrophyIcon() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(
        Icons.emoji_events_rounded,
        color: Colors.orange.shade600,
        size: 32,
      ),
    );
  }

  /// Displays the total count labels.
  Widget _buildSummaryText(int count) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'รายการทั้งหมด',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              '$count',
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
            ),
            const SizedBox(width: 4),
            const Text('รายการ', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ],
    );
  }

  /// Converts a [HistoryModel] into a [HistoryTile] with formatted date/time.
  Widget _buildTransactionItem(HistoryModel item) {
    // Standardizing Date Formatting (DD-MM-YYYY).
    final dateStr =
        "${item.createdAt.day.toString().padLeft(2, '0')}-"
        "${item.createdAt.month.toString().padLeft(2, '0')}-"
        "${item.createdAt.year}";

    final timeStr =
        "${item.createdAt.hour.toString().padLeft(2, '0')}:"
        "${item.createdAt.minute.toString().padLeft(2, '0')}";

    return HistoryTile(
      title: item.description,
      points: item.points,
      type: item.actionType,
      date: '$dateStr • $timeStr น.',
    );
  }

  /// Reusable UI for when no transactions are found.
  Widget _buildEmptyState() {
    return const Center(
      child: Text(
        'ไม่มีประวัติการใช้งาน',
        style: TextStyle(color: Colors.grey),
      ),
    );
  }
}
