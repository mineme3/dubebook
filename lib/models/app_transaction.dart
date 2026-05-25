class AppTransaction {
  final int? id;
  final int customerId;
  final String itemName;
  final int quantity;
  final double price;
  final double total;
  final int status; // 0 = UNPAID, 1 = PAID, 2 = PARTIAL_PAID
  final DateTime date;
  final String transactionType; // 'debt' or 'payment'
  final String? remoteId;
  final String? customerRemoteId;

  AppTransaction({
    this.id,
    required this.customerId,
    required this.itemName,
    required this.quantity,
    required this.price,
    required this.total,
    this.status = 0,
    required this.date,
    this.transactionType = 'debt',
    this.remoteId,
    this.customerRemoteId,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'customer_id': customerId,
      'item_name': itemName,
      'quantity': quantity,
      'price': price,
      'total': total,
      'status': status,
      'date': date.toIso8601String(),
      'transaction_type': transactionType,
      'remote_id': remoteId,
      'customer_remote_id': customerRemoteId,
    };
  }

  factory AppTransaction.fromMap(Map<String, dynamic> map) {
    return AppTransaction(
      id: map['id'],
      customerId: map['customer_id'],
      itemName: map['item_name'] ?? '',
      quantity: map['quantity'] ?? 1,
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      total: (map['total'] as num?)?.toDouble() ?? 0.0,
      status: map['status'] ?? 0,
      date: map['date'] != null ? DateTime.parse(map['date']) : DateTime.now(),
      transactionType: map['transaction_type'] ?? 'debt',
      remoteId: map['remote_id'],
      customerRemoteId: map['customer_remote_id'],
    );
  }

  factory AppTransaction.fromJson(Map<String, dynamic> json) {
    return AppTransaction(
      id: json['id'] is int ? json['id'] : null,
      customerId: json['customer_id'] is int ? json['customer_id'] : 0,
      itemName: json['item_name'] ?? '',
      quantity: json['quantity'] ?? 1,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] ?? 0,
      date: json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
      transactionType: json['transaction_type'] ?? 'debt',
      remoteId: json['remote_id'] ?? (json['_id']?.toString()),
      customerRemoteId: json['customer_remote_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return toMap();
  }
}
