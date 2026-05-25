class PaymentRecord {
  final String id;
  final String customerId;
  final String ownerId;
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
    required this.ownerId,
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
        id: json['_id'] as String,
        customerId: json['customerId'] as String,
        ownerId: json['ownerId'] as String,
        amountPaid: (json['amountPaid'] as num).toDouble(),
        balanceBefore: (json['balanceBefore'] as num).toDouble(),
        balanceAfter: (json['balanceAfter'] as num).toDouble(),
        paymentMethod: json['paymentMethod'] as String,
        note: json['note'] as String?,
        paidAt: DateTime.parse(json['paidAt'] as String),
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  Map<String, dynamic> toJson() => {
        '_id': id,
        'customerId': customerId,
        'ownerId': ownerId,
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

  const CreatePaymentDto({
    required this.amountPaid,
    required this.paymentMethod,
    this.note,
  });

  Map<String, dynamic> toJson() => {
        'amountPaid': amountPaid,
        'paymentMethod': paymentMethod,
        'note': note,
      };
}
