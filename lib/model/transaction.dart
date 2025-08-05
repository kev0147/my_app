import 'package:uuid/uuid.dart';

class Transaction {
  Transaction({
    String? transactionId,
    DateTime? transactionTime,
    this.transactionReason = '',
    this.amount = 0,
  })  : transactionId = transactionId ?? const Uuid().v4(),
        transactionTime = transactionTime ?? DateTime.now();

  String transactionId;
  DateTime transactionTime;
  String transactionReason;
  int amount;

  Map<String, dynamic> toMap() {
    return {
      'transactionId': transactionId,
      'transactionTime': transactionTime.toIso8601String(),
      'transactionReason': transactionReason,
      'amount': amount,
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      transactionId: map['transactionId'],
      transactionTime: DateTime.parse(map['transactionTime']),
      transactionReason: map['transactionReason'],
      amount: map['amount'],
    );
  }
}
