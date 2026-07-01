class PaymentRecord {
  final String id;
  final String customerId; // maps to membershipId
  final String shopId;
  final String ownerId; // maps to recordedBy
  final String? sessionId;
  final double amountPaid;
  final double balanceBefore;
  final double balanceAfter;
  final String paymentMethod; // cash | mobile_money | bank_transfer | other
  final String? note;
  final DateTime paidAt;
  final DateTime createdAt;

  const PaymentRecord({
    required this.id,
    required this.customerId,
    required this.shopId,
    required this.ownerId,
    this.sessionId,
    required this.amountPaid,
    required this.balanceBefore,
    required this.balanceAfter,
    required this.paymentMethod,
    this.note,
    required this.paidAt,
    required this.createdAt,
  });

  /// Human-readable payment method label
  String get paymentMethodLabel {
    switch (paymentMethod) {
      case 'cash':
        return 'Cash';
      case 'mobile_money':
        return 'Mobile Money';
      case 'bank_transfer':
        return 'Bank Transfer';
      case 'other':
        return 'Other';
      default:
        return paymentMethod;
    }
  }

  factory PaymentRecord.fromJson(Map<String, dynamic> json) => PaymentRecord(
        id: (json['id'] ?? json['_id'] ?? '') as String,
        customerId: (json['membershipId'] ?? json['customerId'] ?? '') as String,
        shopId: json['shopId'] as String? ?? '',
        ownerId: (json['recordedBy'] ?? json['ownerId'] ?? '') as String,
        sessionId: json['sessionId'] as String?,
        amountPaid: (json['amountPaid'] as num).toDouble(),
        balanceBefore: (json['balanceBefore'] as num).toDouble(),
        balanceAfter: (json['balanceAfter'] as num).toDouble(),
        paymentMethod: json['paymentMethod'] as String? ?? 'cash',
        note: json['note'] as String?,
        paidAt: json['paidAt'] != null
            ? (json['paidAt'] is String
                ? DateTime.parse(json['paidAt'] as String)
                : json['paidAt'] as DateTime)
            : DateTime.now(),
        createdAt: json['createdAt'] != null
            ? (json['createdAt'] is String
                ? DateTime.parse(json['createdAt'] as String)
                : json['createdAt'] as DateTime)
            : DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'membershipId': customerId,
        'shopId': shopId,
        'recordedBy': ownerId,
        'sessionId': sessionId,
        'amountPaid': amountPaid,
        'balanceBefore': balanceBefore,
        'balanceAfter': balanceAfter,
        'paymentMethod': paymentMethod,
        'note': note,
        'paidAt': paidAt.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
      };
}

class CreatePaymentDto {
  final double amountPaid;
  final String paymentMethod;
  final String? note;
  final String? sessionId;

  const CreatePaymentDto({
    required this.amountPaid,
    required this.paymentMethod,
    this.note,
    this.sessionId,
  });

  Map<String, dynamic> toJson() => {
        'amountPaid': amountPaid,
        'paymentMethod': paymentMethod,
        'note': note,
        'sessionId': sessionId,
      };
}
