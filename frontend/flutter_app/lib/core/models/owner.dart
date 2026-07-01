class Owner {
  final String id;
  final String username;
  final String fullName;
  final String phone;
  final String email;
  final String role;
  final bool isEmailVerified;
  final String? profilePhotoUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Owner({
    required this.id,
    required this.username,
    required this.fullName,
    required this.phone,
    required this.email,
    required this.role,
    required this.isEmailVerified,
    this.profilePhotoUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Owner.fromJson(Map<String, dynamic> json) => Owner(
        id: (json['id'] ?? json['_id']) as String,
        username: json['username'] as String? ?? '',
        fullName: json['fullName'] as String? ?? '',
        phone: json['phone'] as String? ?? '',
        email: json['email'] as String? ?? '',
        role: json['role'] as String? ?? 'SHOP_OWNER',
        isEmailVerified: json['isEmailVerified'] as bool? ?? false,
        profilePhotoUrl: json['profilePhotoUrl'] as String?,
        createdAt: json['createdAt'] == null
            ? DateTime.now()
            : (json['createdAt'] is String
                ? DateTime.parse(json['createdAt'] as String)
                : json['createdAt'] as DateTime),
        updatedAt: json['updatedAt'] == null
            ? DateTime.now()
            : (json['updatedAt'] is String
                ? DateTime.parse(json['updatedAt'] as String)
                : json['updatedAt'] as DateTime),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'fullName': fullName,
        'phone': phone,
        'email': email,
        'role': role,
        'isEmailVerified': isEmailVerified,
        'profilePhotoUrl': profilePhotoUrl,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };
}
