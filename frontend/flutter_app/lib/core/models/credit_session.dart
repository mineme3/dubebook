import 'credit_item.dart';

class CreditSession {
  final String id;
  final String accountId; // maps to membershipId
  final String shopId;
  final String createdBy;
  final double totalAmount;
  final double outstandingBalance; // maps to remainingAmount
  final DateTime? deadline;
  final String status; // active | partially_paid | settled | overdue | cancelled
  final bool isPaid;
  final DateTime createdAt;
  final List<CreditItem> items;

  const CreditSession({
    required this.id,
    required this.accountId,
    required this.shopId,
    required this.createdBy,
    required this.totalAmount,
    required this.outstandingBalance,
    this.deadline,
    required this.status,
    required this.isPaid,
    required this.createdAt,
    required this.items,
  });

  factory CreditSession.fromJson(Map<String, dynamic> json) => CreditSession(
        id: json['id'] as String,
        accountId: (json['membershipId'] ?? json['accountId'] ?? '') as String,
        shopId: json['shopId'] as String? ?? '',
        createdBy: (json['createdBy'] ?? json['ownerId'] ?? '') as String,
        totalAmount: (json['totalAmount'] as num).toDouble(),
        outstandingBalance: ((json['remainingAmount'] ?? json['outstandingBalance'] ?? 0.0) as num).toDouble(),
        deadline: json['deadline'] == null ? null : DateTime.parse(json['deadline'] as String),
        status: json['status'] as String? ?? 'active',
        isPaid: json['isPaid'] as bool? ?? (json['status'] == 'settled' || json['status'] == 'paid'),
        createdAt: DateTime.parse(json['createdAt'] as String),
        items: json['items'] != null
            ? (json['items'] as List)
                .map((i) => CreditItem.fromJson(i as Map<String, dynamic>))
                .toList()
            : [],
      );

  bool get isOverdue => status == 'overdue';
}

class CreateCreditSessionDto {
  final List<CreateCreditItemDto> items;
  final DateTime? deadline;
  final Map<String, int>? ethiopianDeadline;

  const CreateCreditSessionDto({
    this.items = const [],
    this.deadline,
    this.ethiopianDeadline,
  });

  Map<String, dynamic> toJson() => {
        'items': items.map((i) => i.toJson()).toList(),
        'deadline': deadline?.toIso8601String(),
        'ethiopianDeadline': ethiopianDeadline,
      };
}
