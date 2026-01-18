// 결제/세션 등록 이력을 관리하는 PaymentLog 데이터 모델을 정의합니다.
class PaymentLog {
  final String id;
  final String relationId; // 어떤 계약 관계에 속한 결제인지
  final DateTime date; // 결제일 or 연동일
  final String type; // 'PT결제', '회원권', 'CRM연동' 등
  final String content; // '10회 등록', '성공' 등
  final String amount; // 금액 (옵션)

  PaymentLog({
    required this.id,
    required this.relationId,
    required this.date,
    required this.type,
    required this.content,
    required this.amount,
  });

  PaymentLog copyWith({
    String? id,
    String? relationId,
    DateTime? date,
    String? type,
    String? content,
    String? amount,
  }) {
    return PaymentLog(
      id: id ?? this.id,
      relationId: relationId ?? this.relationId,
      date: date ?? this.date,
      type: type ?? this.type,
      content: content ?? this.content,
      amount: amount ?? this.amount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'relationId': relationId,
      'date': date.toIso8601String(),
      'type': type,
      'content': content,
      'amount': amount,
    };
  }

  factory PaymentLog.fromJson(Map<String, dynamic> json) {
    return PaymentLog(
      id: json['id'],
      relationId: json['relationId'],
      date: DateTime.parse(json['date']),
      type: json['type'],
      content: json['content'],
      amount: json['amount'],
    );
  }
}
