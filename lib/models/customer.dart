class Customer {
  final int? id;
  final String name;
  final String? email;
  final String? phone;
  final String? note;
  final DateTime? deadline;
  final DateTime createdAt;
  final int? shopkeeperId; // SQLite user ID
  final String? remoteId;    // MongoDB ID

  Customer({
    this.id,
    required this.name,
    this.email,
    this.phone,
    this.note,
    this.deadline,
    required this.createdAt,
    this.shopkeeperId,
    this.remoteId,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'note': note,
      'deadline': deadline?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'shopkeeper_id': shopkeeperId,
      'remote_id': remoteId,
    };
  }

  factory Customer.fromMap(Map<String, dynamic> map) {
    return Customer(
      id: map['id'],
      name: map['name'] ?? '',
      email: map['email'],
      phone: map['phone'],
      note: map['note'],
      deadline: map['deadline'] != null ? DateTime.parse(map['deadline']) : null,
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : DateTime.now(),
      shopkeeperId: map['shopkeeper_id'],
      remoteId: map['remote_id'],
    );
  }

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'] is int ? json['id'] : null,
      name: json['name'] ?? '',
      email: json['email'],
      phone: json['phone'],
      note: json['note'],
      deadline: json['deadline'] != null ? DateTime.parse(json['deadline']) : null,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
      shopkeeperId: json['shopkeeper_id'],
      remoteId: json['remote_id'] ?? (json['_id']?.toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return toMap();
  }
}
