class Shop {
  final String id;
  final String ownerId;
  final String name;
  final String slug;
  final String businessType;
  final String? phone;
  final String? email;
  final String? address;
  final String? logoUrl;
  final String currency;
  final String timezone;
  final String inviteCode;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Shop({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.slug,
    required this.businessType,
    this.phone,
    this.email,
    this.address,
    this.logoUrl,
    required this.currency,
    required this.timezone,
    required this.inviteCode,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Shop.fromJson(Map<String, dynamic> json) => Shop(
        id: json['id'] as String,
        ownerId: json['ownerId'] as String,
        name: json['name'] as String,
        slug: json['slug'] as String,
        businessType: json['businessType'] as String,
        phone: json['phone'] as String?,
        email: json['email'] as String?,
        address: json['address'] as String?,
        logoUrl: json['logoUrl'] as String?,
        currency: json['currency'] as String? ?? 'ETB',
        timezone: json['timezone'] as String? ?? 'Africa/Addis_Ababa',
        inviteCode: json['inviteCode'] as String,
        isActive: json['isActive'] as bool? ?? true,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'ownerId': ownerId,
        'name': name,
        'slug': slug,
        'businessType': businessType,
        'phone': phone,
        'email': email,
        'address': address,
        'logoUrl': logoUrl,
        'currency': currency,
        'timezone': timezone,
        'inviteCode': inviteCode,
        'isActive': isActive,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };
}
