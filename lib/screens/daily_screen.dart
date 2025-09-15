import 'package:my_app/screens/daily_tasks_screen.dart';
import 'package:my_app/screens/daily_transactions_screen.dart';
import 'package:my_app/screens/daily_notes_screen.dart';
import 'package:my_app/screens/projects_screen.dart';
import 'package:my_app/screens/tasks_screen.dart' as tasks;
import 'package:my_app/screens/transactions_screen.dart' as tx;
import 'package:my_app/screens/notes_screen.dart' as notes;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';

import 'package:my_app/screens/month_screen.dart';

class DailyScreen extends StatefulWidget {
  const DailyScreen({super.key, required this.date, initialTabIndex})
      : initialTabIndex = initialTabIndex ?? 0;

  final DateTime date;
  final int initialTabIndex;

  @override
  State<DailyScreen> createState() => _DailyScreenState();
}

class _DailyScreenState extends State<DailyScreen> {
  late String _formattedTime;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _updateTime(); // Set initial time
    _timer = Timer.periodic(const Duration(seconds: 60), (_) => _updateTime());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _updateTime() {
    final now = DateTime.now();
    setState(() {
      _formattedTime = DateFormat('EEE, MMM d • hh:mm').format(now);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Tabs(
      formattedTime: _formattedTime,
      date: widget.date,
      initialTabIndex: widget.initialTabIndex,
    );
  }
}

class Tabs extends StatelessWidget {
  const Tabs(
      {super.key,
      required String formattedTime,
      required this.date,
      required this.initialTabIndex})
      : _formattedTime = formattedTime;

  final String _formattedTime;
  final DateTime date;
  final int initialTabIndex;

  @override
  Widget build(BuildContext context) {
    //return onePageView(formattedTime: _formattedTime, date: date);
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const CalendarPage(),
              ),
            );
          },
        ),
        title: Column(
          children: [
            Text('today is $_formattedTime'),
            Text(DateFormat('EEE, MMM d').format(date)),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              switch (value) {
                case 'tasks':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const tasks.TaskScreen(),
                    ),
                  );
                  break;

                case 'money':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => tx.TransactionScreen(),
                    ),
                  );
                  break;
                case 'notes':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => notes.NoteScreen(),
                    ),
                  );
                  break;
                                  case 'projects':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>  ProjectScreen(),
                    ),
                  );
                  break;
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'tasks',
                child: Text('Tâches'),
              ),
              const PopupMenuItem<String>(
                value: 'money',
                child: Text('Argent'),
              ),
              const PopupMenuItem<String>(
                value: 'notes',
                child: Text('Notes'),
              ),
              const PopupMenuItem<String>(
                value: 'projects',
                child: Text('Categories'),
              ),
            ],
          ),
        ],
      ),
      body: DefaultTabController(
        initialIndex: initialTabIndex,
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            bottom: const TabBar(tabs: [
              Tab(
                text: 'Tasks',
              ),
              Tab(
                text: 'Depenses',
              ),
              Tab(
                text: 'notes',
              )
            ]),
          ),
          body: TabBarView(
            children: [
              TaskScreen(
                date: date,
              ),
              TransactionScreen(date: date),
              NoteScreen(
                date: date,
              )
            ],
          ),
        ),
      ),
    );
  }
}

/*
returnMenu(BuildContext context) {
  return Column(
    children: [
      SizedBox(
        height: 50,
        child: IconButton(
          icon: const Icon(Icons.list),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const CalendarPage(),
              ),
            );
          },
        ),
      ),
      SizedBox(
        height: 50,
        child: IconButton(
          icon: const Icon(Icons.money),
          onPressed: () {},
        ),
      ),
      SizedBox(
        height: 50,
        child: IconButton(
          icon: const Icon(Icons.book),
          onPressed: () {},
        ),
      ),
    ],
  );
}
*/

//all the tabs in the same page
/*class onePageView extends StatelessWidget {
  const onePageView({
    super.key,
    required String formattedTime,
    required this.date,
  }) : _formattedTime = formattedTime;

  final String _formattedTime;
  final DateTime date;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: BackButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CalendarPage(),
                ),
              );
            },
          ),
          title: Text(_formattedTime),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                  height: MediaQuery.of(context).size.height * 0.5,
                  child: Card(child: TaskScreen(date: date,))),
              Row(
                children: [
                  SizedBox(
                      height: MediaQuery.of(context).size.height * 0.5,
                      width: MediaQuery.of(context).size.width * 0.5,
                      child: Card(child: TransactionScreen(date: date))),
                  SizedBox(
                      height: MediaQuery.of(context).size.height * 0.5,
                      width: MediaQuery.of(context).size.width * 0.5,
                      child: Card(child: NoteScreen(date: date,))),
                ],
              )
            ],
          ),
        ));
  }
}*/
