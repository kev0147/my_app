import 'package:flutter/material.dart';
import 'package:my_app/screens/month_screen.dart';
import 'package:my_app/screens/notes_screen.dart';
import 'package:my_app/screens/projects_screen.dart';
import 'package:my_app/screens/tasks_screen.dart';
import 'package:my_app/screens/transactions_screen.dart';

AppBar dayScreenBar (BuildContext context) {
  return AppBar(
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
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              switch (value) {
                case 'tasks':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const TaskScreen(),
                    ),
                  );
                  break;

                case 'money':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TransactionScreen(),
                    ),
                  );
                  break;
                case 'notes':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>  NoteScreen(),
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
      );
}

