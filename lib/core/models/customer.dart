class Customer {
  final String id;
  final String customerId; // human-readable: CUST-YYYYMMDD-XXXX
  final String ownerId;
  final String fullName;
  final String phone;
  final String telegramUsername;
  final String? telegramChatId;
  final String? address;
  final String? notes;
  final double totalDebt;
  final double totalPaid;
  final double outstandingBalance;
  final String status; // active | settled | overdue
  final DateTime createdAt;
  final DateTime updatedAt;

  const Customer({
    required this.id,
    required this.customerId,
    required this.ownerId,
    required this.fullName,
    required this.phone,
    required this.telegramUsername,
    this.telegramChatId,
    this.address,
    this.notes,
    required this.totalDebt,
    required this.totalPaid,
    required this.outstandingBalance,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isOverdue => status == 'overdue';
  bool get isSettled => status == 'settled';
  bool get isActive => status == 'active';

  factory Customer.fromJson(Map<String, dynamic> json) => Customer(
        id: json['_id'] as String,
        customerId: json['customerId'] as String,
        ownerId: json['ownerId'] as String,
        fullName: json['fullName'] as String,
        phone: json['phone'] as String,
        telegramUsername: json['telegramUsername'] as String? ?? '',
        telegramChatId: json['telegramChatId'] as String?,
        address: json['address'] as String?,
        notes: json['notes'] as String?,
        totalDebt: (json['totalDebt'] as num?)?.toDouble() ?? 0.0,
        totalPaid: (json['totalPaid'] as num?)?.toDouble() ?? 0.0,
        outstandingBalance:
            (json['outstandingBalance'] as num?)?.toDouble() ?? 0.0,
        status: json['status'] as String? ?? 'active',
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );

  Map<String, dynamic> toJson() => {
        '_id': id,
        'customerId': customerId,
        'ownerId': ownerId,
        'fullName': fullName,
        'phone': phone,
        'telegramUsername': telegramUsername,
        'telegramChatId': telegramChatId,
        'address': address,
        'notes': notes,
        'totalDebt': totalDebt,
        'totalPaid': totalPaid,
        'outstandingBalance': outstandingBalance,
        'status': status,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };
}

class CreateCustomerDto {
  final String fullName;
  final String phone;
  final String telegramUsername;
  final String? address;
  final String? notes;

  const CreateCustomerDto({
    required this.fullName,
    required this.phone,
    this.telegramUsername = '',
    this.address,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
        'fullName': fullName,
        'phone': phone,
        'telegramUsername': telegramUsername,
        'address': address ?? '',
        'notes': notes ?? '',
      };
}

class UpdateCustomerDto {
  final String? fullName;
  final String? phone;
  final String? telegramUsername;
  final String? telegramChatId;
  final String? address;
  final String? notes;

  const UpdateCustomerDto({
    this.fullName,
    this.phone,
    this.telegramUsername,
    this.telegramChatId,
    this.address,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (fullName != null) map['fullName'] = fullName;
    if (phone != null) map['phone'] = phone;
    if (telegramUsername != null) map['telegramUsername'] = telegramUsername;
    if (telegramChatId != null) map['telegramChatId'] = telegramChatId;
    if (address != null) map['address'] = address;
    if (notes != null) map['notes'] = notes;
    return map;
  }
}
