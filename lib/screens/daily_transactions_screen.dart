import 'package:flutter/material.dart';
import 'package:my_app/database/database.dart';
import 'package:my_app/model/transaction.dart' as money;
import 'package:my_app/screens/daily_screen.dart';

class TransactionScreen extends StatefulWidget {
  TransactionScreen({super.key, required this.date});

  DateTime date;

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  final dbHelper = DatabaseHelper();
  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  List<money.Transaction> _transactions = [];
  List<money.Transaction> _allTransactions = [];

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    final txs = await dbHelper.getTransactionsOfTheDay(widget.date);
    final allTxs = await dbHelper.getAllTransactions();
    setState(() {
      _transactions = txs;
      _allTransactions = allTxs;
    });
  }

  moneyFormPage(
      BuildContext context, Function(money.Transaction) function, bool adding) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MoneyForm(
          dbHelper: dbHelper,
          function: function,
          date: widget.date,
          adding: adding,
        ),
      ),
    );
  }

  _addTransaction(money.Transaction tx) {
    dbHelper.insertTransaction(tx);
  }

  int getPoint(List<money.Transaction> list) {
    int point = 0;
    for (var depense in list) {
      point += depense.amount;
    }

    return point;
  }

  Future<void> _deleteTransaction(String id) async {
    await dbHelper.deleteTransaction(id);
    await _loadTransactions();
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
                children: [Text('You have spent ${getPoint(_transactions)}'),
              getPoint(_transactions) >= 2000 ? const Text('its a lot for you. stupid bastard'):const Text('lol'),],
              ),
              Row(children: [Text('the hole money left is ${getPoint(_allTransactions)}'),
              getPoint(_allTransactions) >= 20000 ? const Text('you are going to be broke. very soon. stupid bastard'):const Text('lol'),],)
            ],
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => {moneyFormPage(context, _addTransaction, true)},
        child: const Icon(Icons.add),
      ),
    );
  }
}

class MoneyForm extends StatefulWidget {
  final DatabaseHelper dbHelper;
  final Function(money.Transaction) function;
  final money.Transaction transaction;
  final DateTime date;
  final bool adding;
  MoneyForm(
      {super.key,
      required this.dbHelper,
      required this.function,
      required this.date,
      required this.adding,
      money.Transaction? transaction})
      : transaction = transaction ?? money.Transaction();

  @override
  State<MoneyForm> createState() => _MoneyFormState();
}

class _MoneyFormState extends State<MoneyForm> {
  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.adding) {
      _reasonController.text = widget.transaction.transactionReason;
      _amountController.text = widget.transaction.amount.toString();
    }
  }

  _addTransaction() {
    final reason = _reasonController.text.trim();
    final amountText = _amountController.text.trim();

    if (reason.isEmpty || amountText.isEmpty) return;

    final amount = int.tryParse(amountText);
    if (amount == null) return;

    final tx = money.Transaction(transactionReason: reason, amount: amount);
    widget.function(tx);

    _reasonController.clear();
    _amountController.clear();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DailyScreen(date: widget.date),
      ),
    );
  }

  _updateTransaction() {
    final reason = _reasonController.text.trim();
    final amountText = _amountController.text.trim();

    if (reason.isEmpty || amountText.isEmpty) return;

    final amount = int.tryParse(amountText);
    if (amount == null) return;

    final tx = money.Transaction(
        transactionId: widget.transaction.transactionId,
        transactionReason: reason,
        amount: amount);
    widget.function(tx);

    _reasonController.clear();
    _amountController.clear();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DailyScreen(date: widget.date, initialTabIndex: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    DailyScreen(date: widget.date, initialTabIndex: 1),
              ),
            );
          },
        ),
      ),
      body: Column(children: [
        TextField(
          controller: _reasonController,
          decoration: const InputDecoration(labelText: 'Reason'),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _amountController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Amount'),
        ),
      ]),
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        onPressed: widget.adding
            ? () => _addTransaction()
            : () => _updateTransaction(),
        child: Icon(widget.adding ? Icons.add : Icons.update),
      ),
    );
  }
}
