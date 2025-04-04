import 'medication.dart';
import 'package:flutter/material.dart';

class MedicationFormData {
  // Mutable fields
  String profile;
  String brandName;
  String genericName;
  int quantity;
  String dosage;

  // Natural date/time types
  DateTime startDate;
  DateTime? refillDate;
  TimeOfDay time;

  // Frequency settings
  String frequencyTaken;
  int? numberOfDoses;
  int? numberOfDosesPerDay;
  int? hourlyFrequency;

  // Additional fields
  String? notes;
  DateTime? endDate;

  // Validation errors
  Map<String, String?> errors = {};

  MedicationFormData({
    this.profile = 'Default',
    required this.brandName,
    required this.genericName,
    this.quantity = 1,
    this.dosage = '',
    required this.startDate,
    this.refillDate,
    required this.time,
    this.frequencyTaken = 'As needed',
    this.numberOfDoses,
    this.numberOfDosesPerDay,
    this.hourlyFrequency,
    this.notes,
    this.endDate,
  });

  MyMedication toMedication() {
    return MyMedication(
      profile: profile,
      brandName: brandName,
      genericName: genericName,
      quantity: quantity,
      startDate: startDate.millisecondsSinceEpoch,
      refillDate: refillDate?.toString(),
      time: time.hour * 60 + time.minute,
      dosage: dosage,
      numberOfDoses: numberOfDoses,
      frequencyTaken: frequencyTaken,
      numberOfDosesPerDay: numberOfDosesPerDay,
      hourlyFrequency: hourlyFrequency,
      notes: notes,
      endDate: endDate?.toString(),
    );
  }

  factory MedicationFormData.fromMedication(MyMedication medication) {
    return MedicationFormData(
      profile: medication.profile,
      brandName: medication.brandName,
      genericName: medication.genericName,
      quantity: medication.quantity,
      dosage: medication.dosage,
      startDate: DateTime.fromMillisecondsSinceEpoch(medication.startDate),
      refillDate:
          medication.refillDate != null
              ? DateTime.parse(medication.refillDate!)
              : null,
      time: TimeOfDay(
        hour: medication.time ~/ 60,
        minute: medication.time % 60,
      ),
      frequencyTaken: medication.frequencyTaken ?? 'As needed',
      numberOfDoses: medication.numberOfDoses,
      numberOfDosesPerDay: medication.numberOfDosesPerDay,
      hourlyFrequency: medication.hourlyFrequency,
      notes: medication.notes,
      endDate:
          medication.endDate != null
              ? DateTime.parse(medication.endDate!)
              : null,
    );
  }

  bool validate() {
    errors.clear();

    if (profile.isEmpty) errors['profile'] = 'Profile is required';
    if (quantity <= 0) errors['quantity'] = 'Quantity must be positive';
    if (dosage.isEmpty) errors['dosage'] = 'Dosage is required';

    // Add more validation as needed

    return errors.isEmpty;
  }
}
