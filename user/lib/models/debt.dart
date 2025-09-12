class Debt {
  final int? id;
  final String name;
  final double amount;
  final String type; // 'hutang' or 'piutang'
  final String? note;
  final DateTime dueDate;
  final bool isPaid;
  final DateTime? paidAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Debt({
    this.id,
    required this.name,
    required this.amount,
    required this.type,
    this.note,
    required this.dueDate,
    this.isPaid = false,
    this.paidAt,
    this.createdAt,
    this.updatedAt,
  });

  factory Debt.fromJson(Map<String, dynamic> json) {
    return Debt(
      id: json['id'],
      name: json['creditor_name'] ?? json['name'] ?? '',
      amount: double.parse(json['amount'].toString()),
      type: json['type'] ?? 'hutang',
      note: json['note'],
      dueDate: json['due_date'] != null ? DateTime.parse(json['due_date']) : DateTime.now(),
      isPaid: json['status'] == 'paid',
      paidAt: null, // Field ini tidak ada di database
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'type': type,
      'status': isPaid ? 'paid' : 'unpaid',
      'note': note,
      'dueDate': dueDate.toIso8601String().split('T')[0],
    };
  }

  Debt copyWith({
    int? id,
    String? name,
    double? amount,
    String? type,
    String? note,
    DateTime? dueDate,
    bool? isPaid,
    DateTime? paidAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Debt(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      note: note ?? this.note,
      dueDate: dueDate ?? this.dueDate,
      isPaid: isPaid ?? this.isPaid,
      paidAt: paidAt ?? this.paidAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}