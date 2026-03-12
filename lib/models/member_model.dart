class MemberModel {
  final String id;
  final String name;
  final String phone;
  final int points;
  final String memberCode;
  final DateTime createdAt;

  MemberModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.points,
    required this.memberCode,
    required this.createdAt,
  });

  factory MemberModel.fromJson(Map<String, dynamic> json) {
    return MemberModel(
      id: json['id'] ?? '',
      name: json['name'] ?? 'ไม่มีชื่อ',
      phone: json['phone'] ?? '-',
      points: json['total_points'] ?? 0,
      memberCode: json['number_code'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }
}
