class CreditItem {
  final String id;
  final String customerId;
  final String ownerId;
  final String itemName;
  final String unitType; // kg | liter | piece | pack | box | other
  final double quantity;
  final double unitPrice;
  final double totalPrice;
  final DateTime deadline;
  final bool isPaid;
  final DateTime? notifiedAt;
  final DateTime createdAt; // IMMUTABLE — set once, never updated
  final DateTime updatedAt;

  const CreditItem({
    required this.id,
    required this.customerId,
    required this.ownerId,
    required this.itemName,
    required this.unitType,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    required this.deadline,
    required this.isPaid,
    this.notifiedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Whether the deadline has passed and the item hasn't been paid
  bool get isOverdue =>
      !isPaid && deadline.isBefore(DateTime.now());

  /// Whether the deadline is within 3 days
  bool get isUpcoming =>
      !isPaid &&
      !isOverdue &&
      deadline.difference(DateTime.now()).inDays <= 3;

  /// Human-readable metadata display
  /// e.g. "5 kg × 80 ETB = 400 ETB"
  String get metadataDisplay {
    final unit = unitType == 'piece' ? 'pcs' : unitType;
    final qty =
        quantity % 1 == 0 ? quantity.toInt().toString() : quantity.toString();
    return '$qty $unit × ${unitPrice.toStringAsFixed(0)} ETB = ${totalPrice.toStringAsFixed(0)} ETB';
  }

  factory CreditItem.fromJson(Map<String, dynamic> json) => CreditItem(
        id: json['_id'] as String,
        customerId: json['customerId'] as String,
        ownerId: json['ownerId'] as String,
        itemName: json['itemName'] as String,
        unitType: json['unitType'] as String,
        quantity: (json['quantity'] as num).toDouble(),
        unitPrice: (json['unitPrice'] as num).toDouble(),
        totalPrice: (json['totalPrice'] as num).toDouble(),
        deadline: DateTime.parse(json['deadline'] as String),
        isPaid: json['isPaid'] as bool? ?? false,
        notifiedAt: json['notifiedAt'] != null
            ? DateTime.parse(json['notifiedAt'] as String)
            : null,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );

  Map<String, dynamic> toJson() => {
        '_id': id,
        'customerId': customerId,
        'ownerId': ownerId,
        'itemName': itemName,
        'unitType': unitType,
        'quantity': quantity,
        'unitPrice': unitPrice,
        'totalPrice': totalPrice,
        'deadline': deadline.toIso8601String(),
        'isPaid': isPaid,
        'notifiedAt': notifiedAt?.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };
}

class CreateCreditItemDto {
  final String itemName;
  final String unitType;
  final double quantity;
  final double unitPrice;
  final DateTime deadline;

  const CreateCreditItemDto({
    required this.itemName,
    required this.unitType,
    required this.quantity,
    required this.unitPrice,
    required this.deadline,
  });

  double get totalPrice => quantity * unitPrice;

  Map<String, dynamic> toJson() => {
        'itemName': itemName,
        'unitType': unitType,
        'quantity': quantity,
        'unitPrice': unitPrice,
        'deadline': deadline.toUtc().toIso8601String(),
      };
}
