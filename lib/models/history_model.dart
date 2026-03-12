class HistoryModel {
  final String description;
  final int points;
  final String actionType;
  final DateTime createdAt;

  HistoryModel({
    required this.description,
    required this.points,
    required this.actionType,
    required this.createdAt,
  });

  factory HistoryModel.fromJson(Map<String, dynamic> json) {
    return HistoryModel(
      description: json['description'] ?? 'ทำรายการ',
      points: json['points'] != null
          ? int.tryParse(json['points'].toString()) ?? 0
          : 0,
      actionType: json['action_type'] ?? 'EARN',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }
}
