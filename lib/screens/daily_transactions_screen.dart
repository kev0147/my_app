import 'package:flutter/material.dart';
import 'package:my_app/database/database.dart';
import 'package:my_app/model/project.dart';
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

  List<money.Transaction> _transactions = [];
  List<money.Transaction> _allTransactions = [];
  List<Project> _projects = [];

  @override
  void initState() {
    super.initState();
    _loadTransactions();
    _loadProjects();
  }

  Future<void> _loadTransactions() async {
    final txs = await dbHelper.getTransactionsOfTheDay(widget.date);
    final allTxs = await dbHelper.getAllTransactions();
    setState(() {
      _transactions = txs;
      _allTransactions = allTxs;
    });
  }

  Future<void> _loadProjects() async {
    final projects = await dbHelper.getAllProjects();
    setState(() => _projects = projects);
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
          projects: _projects,
        ),
      ),
    );
  }

  _addTransaction(money.Transaction tx) {
    dbHelper.insertTransaction(tx);
    _loadTransactions();
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
      body: 
      Column(
        children: [
                    Column(
            children: [
              Row(
                children: [
                  Text('You have spent ${getPoint(_transactions)}'),
                  getPoint(_transactions) >= 2000
                      ? const Text('its a lot for you. stupid bastard')
                      : const Text('lol'),
                ],
              ),
              Row(
                children: [
                  Text('the hole money left is ${getPoint(_allTransactions)}'),
                  getPoint(_allTransactions) >= 20000
                      ? const Text(
                          'you are going to be broke. very soon. stupid bastard')
                      : const Text('lol'),
                ],
              )
            ],
          ),
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
  final List<Project> projects;
  final DateTime date;
  final bool adding;
  MoneyForm(
      {super.key,
      required this.dbHelper,
      required this.function,
      required this.date,
      required this.adding,
      required this.projects,
      money.Transaction? transaction})
      : transaction = transaction ?? money.Transaction();

  @override
  State<MoneyForm> createState() => _MoneyFormState();
}

class _MoneyFormState extends State<MoneyForm> {
  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  String? selectedValue;
  List<String> options = [];

  @override
  void initState() {
    super.initState();
    if (widget.adding) {
      _reasonController.text = widget.transaction.transactionReason;
      _amountController.text = widget.transaction.amount.toString();
    }

    for (var project in widget.projects) {
      options.add(project.projectName);
    }
  }

  _addTransaction() {
    final reason = _reasonController.text.trim();
    final amountText = _amountController.text.trim();

    if (reason.isEmpty || amountText.isEmpty) return;

    final amount = int.tryParse(amountText);
    if (amount == null) return;

    Project selectedProject = Project(projectId: "default");
    for (var option in options) {
      if (selectedValue == option) {
        selectedProject = widget.projects[options.indexOf(option)];
      }
    }

    final tx = money.Transaction(
        transactionReason: reason,
        amount: amount,
        projectId: selectedProject.projectId);
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

    Project selectedProject = Project(projectId: "default");
    for (var option in options) {
      if (selectedValue == option) {
        selectedProject = widget.projects[options.indexOf(option)];
      }
    }

    final tx = money.Transaction(
      transactionId: widget.transaction.transactionId,
      transactionReason: reason,
      amount: amount,
      projectId: selectedProject.projectId,
    );
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
        DropdownButton<String>(
          hint: const Text('Choose'),
          value: selectedValue,
          onChanged: (newValue) {
            setState(() {
              selectedValue = newValue;
            });
          },
          items: options.map((option) {
            return DropdownMenuItem<String>(
              value: option,
              child: Text(option),
            );
          }).toList(),
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
