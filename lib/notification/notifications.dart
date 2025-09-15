import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:my_app/model/task.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

class Notifications {
  final notificationsPlugin = AndroidFlutterLocalNotificationsPlugin();
  bool isInitialized = false;
  final DateFormat _hm = DateFormat.Hm();

  //Initialize notification settings
  Future<void> init() async {
    if (isInitialized) return;
    tz.initializeTimeZones();
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    await notificationsPlugin.initialize(initializationSettingsAndroid); 
    //await requestNotificationPermission();
    
    isInitialized = true;
  }
  //Notification details setup
  AndroidNotificationDetails notificationDetails() {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'channel_id',
      'channel_name',
      importance: Importance.max,
      priority: Priority.high,
    );
    return androidNotificationDetails;
  }

  //show notification
  

  Future<void> scheduleNotificationForTask( Task task) async {
  await notificationsPlugin.zonedSchedule(
    int.parse(task.taskId.substring(0,4).replaceAll(RegExp(r'[^0-9]'), '')), // notification id
    task.taskName, // notification title
    'start at ${_hm.format(task.startTime)} to  ${_hm.format(task.endTime)}', // notification body
    tz.TZDateTime.from(task.reminder, tz.local).add(const Duration(seconds: 5)),
    const AndroidNotificationDetails(
      'channel_id',
      'channel_name',
      importance: Importance.max,
      priority: Priority.high,
    ),
    scheduleMode: AndroidScheduleMode.inexact,
  );
}

showNotification(String title, String body) async {
    await notificationsPlugin.show(
      1,
      title,
      body,
      notificationDetails: notificationDetails(),
    );
  }

}