class CreditItem {
  final String id;
  final String sessionId;
  final String itemName;
  final String unitType; // kg | liter | piece | pack | box | other
  final double quantity;
  final double unitPrice;
  final double totalPrice;
  final DateTime createdAt;

  const CreditItem({
    required this.id,
    required this.sessionId,
    required this.itemName,
    required this.unitType,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    required this.createdAt,
  });

  bool get isPaid => false;

  /// Human-readable metadata display
  /// e.g. "5 kg × 80 ETB = 400 ETB"
  String get metadataDisplay {
    final unit = unitType == 'piece' ? 'pcs' : unitType;
    final qty =
        quantity % 1 == 0 ? quantity.toInt().toString() : quantity.toString();
    return '$qty $unit × ${unitPrice.toStringAsFixed(0)} ETB = ${totalPrice.toStringAsFixed(0)} ETB';
  }

  factory CreditItem.fromJson(Map<String, dynamic> json) => CreditItem(
        id: (json['id'] ?? json['_id'] ?? '') as String,
        sessionId: (json['sessionId'] ?? json['sessionId'] ?? '') as String,
        itemName: json['itemName'] as String? ?? '',
        unitType: json['unitType'] as String? ?? 'piece',
        quantity: (json['quantity'] as num).toDouble(),
        unitPrice: (json['unitPrice'] as num).toDouble(),
        totalPrice: (json['totalPrice'] as num).toDouble(),
        createdAt: json['createdAt'] != null
            ? (json['createdAt'] is String
                ? DateTime.parse(json['createdAt'] as String)
                : json['createdAt'] as DateTime)
            : DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'sessionId': sessionId,
        'itemName': itemName,
        'unitType': unitType,
        'quantity': quantity,
        'unitPrice': unitPrice,
        'totalPrice': totalPrice,
        'createdAt': createdAt.toIso8601String(),
      };
}

class CreateCreditItemDto {
  final String itemName;
  final String unitType;
  final double quantity;
  final double unitPrice;

  const CreateCreditItemDto({
    required this.itemName,
    required this.unitType,
    required this.quantity,
    required this.unitPrice,
  });

  double get totalPrice => quantity * unitPrice;

  Map<String, dynamic> toJson() => {
        'itemName': itemName,
        'unitType': unitType,
        'quantity': quantity,
        'unitPrice': unitPrice,
      };
}
