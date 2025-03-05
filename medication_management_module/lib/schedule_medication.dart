import 'dart:ffi';
import 'package:flutter/material.dart';
// import 'search_medication.dart';

class AppColors {
  static const Color offBlue = Color(0xFFE0F7FA);
  static const Color deepBlues = Color(0xFF2C3E50);
  static const Color getItGreen = Color(0xFF76C7C0);
  static const Color urgentOrange = Color(0xFFF4A261);
  static const Color white = Color(0xFFFFFFFF);
  // Add more colors as needed
}

class MyMedication {
  final String profile;
  final String brandName;
  final String genericName;
  final Int quantity;
  final Int startDate;
  final String? refillDate;
  final Int time;

  MyMedication({
    required this.profile,
    required this.brandName,
    required this.genericName,
    required this.quantity,
    required this.startDate,
    this.refillDate,
    required this.time,
  });
}

class MedicationScheduleWidget extends StatefulWidget {
  final Function(Map<dynamic, dynamic>)? onMedicationSelected;

  const MedicationScheduleWidget({super.key, this.onMedicationSelected});

  @override
  _MedicationScheduleWidgetState createState() =>
      _MedicationScheduleWidgetState();
}

class _MedicationScheduleWidgetState extends State<MedicationScheduleWidget> {
  final ValueNotifier<dynamic> selectedMedicationNotifier =
      ValueNotifier<dynamic>(null);

  @override
  Widget build(BuildContext context) {
    return Column();
  }
}
