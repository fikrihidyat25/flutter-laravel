class Transaction {
  final int? id;
  final String type;
  final String category;
  final double amount;
  final String? note;
  final DateTime date;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Transaction({
    this.id,
    required this.type,
    required this.category,
    required this.amount,
    this.note,
    required this.date,
    this.createdAt,
    this.updatedAt,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      type: json['type'],
      category: json['category'],
      amount: double.parse(json['amount'].toString()),
      note: json['note'],
      date: DateTime.parse(json['date']),
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'category': category,
      'amount': amount,
      'note': note,
      'date': date.toIso8601String().split('T')[0],
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  Transaction copyWith({
    int? id,
    String? type,
    String? category,
    double? amount,
    String? note,
    DateTime? date,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Transaction(
      id: id ?? this.id,
      type: type ?? this.type,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      note: note ?? this.note,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}