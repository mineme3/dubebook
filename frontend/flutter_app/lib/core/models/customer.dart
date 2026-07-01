import 'shop.dart';

class Customer {
  final String id; // membershipId
  final String? customerUserId;
  final String shopId;
  final String fullName;
  final String phone;
  final String? address;
  final String? notes;
  final double totalDebt;
  final double totalPaid;
  final double outstandingBalance;
  final double walletBalance;
  final String status; // active | settled | overdue | suspended
  final DateTime createdAt;
  final DateTime updatedAt;
  final Shop? shop;

  const Customer({
    required this.id,
    this.customerUserId,
    required this.shopId,
    required this.fullName,
    required this.phone,
    this.address,
    this.notes,
    required this.totalDebt,
    required this.totalPaid,
    required this.outstandingBalance,
    this.walletBalance = 0.0,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.shop,
  });

  bool get isOverdue => status == 'overdue';
  bool get isSettled => status == 'settled';
  bool get isActive => status == 'active';

  factory Customer.fromJson(Map<String, dynamic> json) => Customer(
        id: (json['id'] ?? json['_id']) as String,
        customerUserId: json['customerId'] as String?,
        shopId: json['shopId'] as String? ?? '',
        fullName: (json['fullName'] ?? json['displayName'] ?? '') as String,
        phone: (json['phone'] ?? '') as String,
        address: json['address'] as String?,
        notes: json['notes'] as String?,
        totalDebt: (json['totalDebt'] as num?)?.toDouble() ?? 0.0,
        totalPaid: (json['totalPaid'] as num?)?.toDouble() ?? 0.0,
        outstandingBalance: (json['outstandingBalance'] as num?)?.toDouble() ?? 0.0,
        walletBalance: (json['walletBalance'] as num?)?.toDouble() ?? 0.0,
        status: json['status'] as String? ?? 'active',
        createdAt: json['joinedAt'] != null
            ? (json['joinedAt'] is String
                ? DateTime.parse(json['joinedAt'] as String)
                : json['joinedAt'] as DateTime)
            : (json['createdAt'] != null
                ? (json['createdAt'] is String
                    ? DateTime.parse(json['createdAt'] as String)
                    : json['createdAt'] as DateTime)
                : DateTime.now()),
        updatedAt: json['updatedAt'] != null
            ? (json['updatedAt'] is String
                ? DateTime.parse(json['updatedAt'] as String)
                : json['updatedAt'] as DateTime)
            : DateTime.now(),
        shop: json['shop'] != null ? Shop.fromJson(json['shop'] as Map<String, dynamic>) : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'customerId': customerUserId,
        'shopId': shopId,
        'fullName': fullName,
        'phone': phone,
        'address': address,
        'notes': notes,
        'totalDebt': totalDebt,
        'totalPaid': totalPaid,
        'outstandingBalance': outstandingBalance,
        'walletBalance': walletBalance,
        'status': status,
        'joinedAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'shop': shop?.toJson(),
      };
}

class CreateCustomerDto {
  final String shopId;
  final String username;

  const CreateCustomerDto({
    required this.shopId,
    required this.username,
  });

  Map<String, dynamic> toJson() => {
        'shopId': shopId,
        'username': username,
      };
}

class UpdateCustomerDto {
  final String? fullName;
  final String? phone;
  final String? address;
  final String? notes;

  const UpdateCustomerDto({
    this.fullName,
    this.phone,
    this.address,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (fullName != null) map['displayName'] = fullName;
    if (phone != null) map['phone'] = phone;
    if (address != null) map['address'] = address;
    if (notes != null) map['notes'] = notes;
    return map;
  }
}
