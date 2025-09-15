import 'package:my_app/model/project.dart';
import 'package:uuid/uuid.dart';

class Transaction {
  Transaction({
    String? transactionId,
    DateTime? transactionTime,
    this.transactionReason = '',
    this.amount = 0,
    String? projectId,
  })  : transactionId = transactionId ?? const Uuid().v4(),
        transactionTime = transactionTime ?? DateTime.now(),
        projectId = projectId ?? "default";

  String transactionId;
  DateTime transactionTime;
  String transactionReason;
  int amount;
  Project? project;
  String? projectId;

  Map<String, dynamic> toMap() {
    return {
      'transactionId': transactionId,
      'transactionTime': transactionTime.toIso8601String(),
      'transactionReason': transactionReason,
      'amount': amount,
      'projectId': project?.projectId,
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      transactionId: map['transactionId'],
      transactionTime: DateTime.parse(map['transactionTime']),
      transactionReason: map['transactionReason'],
      amount: map['amount'],
      projectId: map['projectId'],
    );
  }
}
