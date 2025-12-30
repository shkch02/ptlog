class PaymentLog {
  final String id;
  final String memberId;
  final String date; // 결제일 or 연동일
  final String type; // 'PT결제', '회원권', 'CRM연동' 등
  final String content; // '10회 등록', '성공' 등
  final String amount; // 금액 (옵션)

  PaymentLog({
    required this.id,
    required this.memberId,
    required this.date,
    required this.type,
    required this.content,
    required this.amount,
  });

  PaymentLog copyWith({
    String? id,
    String? memberId,
    String? date,
    String? type,
    String? content,
    String? amount,
  }) {
    return PaymentLog(
      id: id ?? this.id,
      memberId: memberId ?? this.memberId,
      date: date ?? this.date,
      type: type ?? this.type,
      content: content ?? this.content,
      amount: amount ?? this.amount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'memberId': memberId,
      'date': date,
      'type': type,
      'content': content,
      'amount': amount,
    };
  }

  factory PaymentLog.fromJson(Map<String, dynamic> json) {
    return PaymentLog(
      id: json['id'],
      memberId: json['memberId'],
      date: json['date'],
      type: json['type'],
      content: json['content'],
      amount: json['amount'],
    );
  }
}