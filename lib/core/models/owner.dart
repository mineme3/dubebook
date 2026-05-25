class Owner {
  final String id;
  final String fullName;
  final String phone;
  final String email;
  final String? telegramChatId;
  final String shopName;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Owner({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.email,
    this.telegramChatId,
    required this.shopName,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Owner.fromJson(Map<String, dynamic> json) => Owner(
        id: json['id'] as String? ?? json['_id'] as String,
        fullName: json['fullName'] as String,
        phone: json['phone'] as String,
        email: json['email'] as String,
        telegramChatId: json['telegramChatId'] as String?,
        shopName: json['shopName'] as String,
        createdAt: json['createdAt'] is String
            ? DateTime.parse(json['createdAt'] as String)
            : json['createdAt'] as DateTime,
        updatedAt: json['updatedAt'] is String
            ? DateTime.parse(json['updatedAt'] as String)
            : json['updatedAt'] as DateTime,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'fullName': fullName,
        'phone': phone,
        'email': email,
        'telegramChatId': telegramChatId,
        'shopName': shopName,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };
}
