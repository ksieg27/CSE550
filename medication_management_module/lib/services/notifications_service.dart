import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../models/medication.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  Future<void> init() async {
    // Initialize time zones
    tz.initializeTimeZones();
    final String currentTimeZone =
        await FlutterNativeTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(currentTimeZone));

    // Configure for Android
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // Configure for iOS
    final DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
          onDidReceiveLocalNotification: (
            int id,
            String? title,
            String? body,
            String? payload,
          ) async {
            // Handle iOS foreground notification
          },
        );

    final InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );
    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        print('Notification tapped: ${response.payload}');
      },
    );
  }

  Future<void> requestPermissions() async {
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  Future<void> scheduleMedicationReminder(MyMedication medication) async {
    if (medication.id != null) {
      await cancelNotification(medication.id!);
    }

    final int numberOfDosesPerDay = medication.numberOfDosesPerDay ?? 1;
    final int baseID = medication.id ?? 0;

    // First dose time variables
    final int baseHour = medication.time ~/ 60;
    final int baseMinute = medication.time % 60;

    // Loop through the number of doses per day
    for (int i = 0; i < numberOfDosesPerDay; i++) {
      // Use default value of 6 hours if hourlyFrequency is null
      int doseHour = baseHour + (i * (medication.hourlyFrequency ?? 0));
      int doseMinute = baseMinute;

      int notificationID = baseID + (i * 1000);

      final now = DateTime.now();
      final scheduledDate = DateTime(
        now.year,
        now.month,
        now.day,
        doseHour,
        doseMinute,
      );

      final tz.TZDateTime scheduledTZDate = tz.TZDateTime.from(
        scheduledDate.isBefore(now)
            ? scheduledDate.add(Duration(days: 1))
            : scheduledDate,
        tz.local,
      );

      await _flutterLocalNotificationsPlugin.zonedSchedule(
        notificationID,
        'It\'s time to take ${medication.brandName} (${medication.genericName})',
        'Dose ${i + 1} of ${medication.brandName}',
        scheduledTZDate,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'medication_channel',
            'Medication Reminders',
            channelDescription: 'Channel for medication reminders',
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
            enableVibration: true,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: '${medication.id}_doese${i + 1}',
      );
      print(
        'Scheduled dose ${i + 1} notification for ${medication.brandName} at $doseHour:$doseMinute}',
      );
    }
  }

  Future<void> scheduleRefillReminder(MyMedication medication) async {
    if (medication.id != null) {
      await cancelNotification(medication.id!);
    }

    final int hours = medication.time ~/ 60;
    final int minutes = medication.time % 60;

    final now = DateTime.now();
    final scheduledDate = DateTime(
      now.year,
      now.month,
      now.day,
      hours,
      minutes,
    );

    final tz.TZDateTime scheduledTZDate = tz.TZDateTime.from(
      scheduledDate.isBefore(now)
          ? scheduledDate.add(Duration(days: 1))
          : scheduledDate,
      tz.local,
    );

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      medication.id ?? 0,
      'Do you need a refill?',
      'You have ${medication.quantity} doses left of ${medication.brandName} (${medication.genericName})',
      scheduledTZDate,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'medication_channel',
          'Medication Reminders',
          channelDescription: 'Channel for medication reminders',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: medication.id.toString(),
    );

    print(
      'Scheduled notification for ${medication.brandName} at $hours:$minutes',
    );
  }

  Future<void> cancelNotification(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
  }

  Future<void> cancelAllMedicationNotifications(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);

    for (int i = 0; i < 10; i++) {
      int notificationId = id + (i * 1000);
      await _flutterLocalNotificationsPlugin.cancel(notificationId);
    }
  }
}
