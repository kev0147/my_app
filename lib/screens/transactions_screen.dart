import 'package:flutter/material.dart';
import 'package:my_app/database/database.dart';
import 'package:my_app/model/transaction.dart' as money;

class TransactionScreen extends StatefulWidget {
  TransactionScreen({super.key});

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  final dbHelper = DatabaseHelper();

  List<money.Transaction> _transactions = [];

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    final txs = await dbHelper.getAllTransactions();
    setState(() {
      _transactions = txs;
    });
  }

  Future<void> _deleteTransaction(String id) async {
    await dbHelper.deleteTransaction(id);
    await _loadTransactions();
  }

  int getPoint(List<money.Transaction> list) {
    int point = 0;
    for (var depense in list) {
      point += depense.amount;
    }

    return point;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transactions')),
      body: Column(
        children: [
          Expanded(
            child: _transactions.isEmpty
                ? const Center(child: Text('No transactions yet.'))
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: _transactions.length,
                    itemBuilder: (_, index) {
                      final tx = _transactions[index];
                      return ListTile(
                        title: Text(tx.transactionReason),
                        subtitle: Text(
                            '${tx.transactionTime.toLocal()}'.split('.')[0]),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('${tx.amount}'),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () =>
                                  _deleteTransaction(tx.transactionId),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          Column(
            children: [
              Row(
                children: [
                  Text('the hole money left is ${getPoint(_transactions)}'),
                  getPoint(_transactions) >= 20000
                      ? const Text(
                          'you are going to be broke. very soon. stupid bastard')
                      : const Text('lol'),
                ],
              )
            ],
          )
        ],
      ),
    );
  }
}
