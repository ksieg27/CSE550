import 'package:flutter/material.dart';
import 'package:medication_management_module/repositories/sqlite_medication_repository.dart';
import '../../../models/medication.dart';
import '../../../repositories/medication_repository.dart';

class MedicationScheduleViewModel extends ChangeNotifier {
  final Map<dynamic, dynamic>? medicationData;
  final MedicationRepository repository;
  // Initialized medication class
  MyMedication? currentMedication;

  // Add controllers and state variables for form fields
  final TextEditingController profileController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController dosageController = TextEditingController();

  // Dates & Times
  DateTime selectedStartDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  DateTime? selectedRefillDate;

  final formKey = GlobalKey<FormState>();

  // Frequency
  final TextEditingController numberOfDosesController = TextEditingController();
  final TextEditingController numberOfDosesPerDayController =
      TextEditingController();
  final TextEditingController frequencyTakenController = TextEditingController(
    text: "As needed",
  );
  final TextEditingController hourlyFrequencyController =
      TextEditingController();

  MedicationScheduleViewModel({
    required this.medicationData,
    MedicationRepository? repository,
  }) : repository = repository ?? SQLiteMedicationRepository() {
    // Add listeners
    quantityController.addListener(_recalculateRefillDate);
    numberOfDosesController.addListener(_recalculateRefillDate);
    numberOfDosesPerDayController.addListener(_recalculateRefillDate);

    if (medicationData != null) {
      // Initialize viewmodel with medication data
    }
  }

  void _recalculateRefillDate() {
    // Get the quantity as int, default to 1 if parsing fails
    final quantity = int.tryParse(quantityController.text) ?? 1;

    // Only calculate if not "As needed"
    if (frequencyTakenController.text == "As needed") {
      selectedRefillDate = null; // No refill date for "as needed" medications
      notifyListeners();
      return;
    }

    // Calculate based on frequency and quantity
    DateTime calculatedDate;

    switch (frequencyTakenController.text) {
      case "By Day":
        final dosesPerDay = int.tryParse(numberOfDosesController.text) ?? 1;
        final days = (quantity / dosesPerDay).ceil();
        calculatedDate = selectedStartDate.add(Duration(days: days));
        break;

      case "By Hour":
        // For hourly frequency, use the hourly-specific fields
        final dosesPerDay =
            int.tryParse(numberOfDosesPerDayController.text) ?? 1;
        final amountPerDose = int.tryParse(numberOfDosesController.text) ?? 1;

        // Total doses consumed per day
        final totalDailyDoses = dosesPerDay * amountPerDose;

        // Days until refill needed (round up to ensure medication doesn't run out)
        final days = (quantity / totalDailyDoses).ceil();
        calculatedDate = selectedStartDate.add(Duration(days: days));
        break;

      default:
        calculatedDate = selectedStartDate.add(Duration(days: quantity));
    }

    selectedRefillDate = calculatedDate;
    notifyListeners();
  }

  void recalculateRefillDate() {
    _recalculateRefillDate();
  }

  void updateFrequencyOption(String option) {
    if (option == "By Day") {
      hourlyFrequencyController.text = "";
      numberOfDosesPerDayController.text = "";
      if (numberOfDosesController.text.isEmpty) {
        numberOfDosesController.text = "1";
      }
    } else if (option == "By Hour") {
      // Set default for hourly frequency
      if (numberOfDosesController.text.isEmpty) {
        numberOfDosesPerDayController.text = "1";
      }
      if (hourlyFrequencyController.text.isEmpty) {
        hourlyFrequencyController.text = "6"; // Default to every 6 hours
      }
      if (numberOfDosesController.text.isEmpty) {
        numberOfDosesController.text = "4";
      }
    }
    _recalculateRefillDate();
  }

  void updateStartDate(DateTime date) {
    selectedStartDate = date;
    _recalculateRefillDate();
    notifyListeners();
  }

  void updateTime(TimeOfDay time) {
    selectedTime = time;
    _recalculateRefillDate();
    notifyListeners();
  }

  // Add to MedicationScheduleViewModel class
  void selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedStartDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    if (picked != null) updateStartDate(picked);
  }

  void selectRefillDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedRefillDate ?? DateTime.now().add(Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    if (picked != null) selectedRefillDate = picked;
    notifyListeners();
  }

  void selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (picked != null) updateTime(picked);
  }

  MyMedication createMedication() {
    return MyMedication(
      profile: profileController.text,
      brandName: medicationData!['brand_name'] ?? 'Unknown Brand',
      genericName: medicationData!['generic_name'] ?? 'Unknown Generic',
      quantity: int.tryParse(quantityController.text) ?? 1,
      startDate: selectedStartDate.millisecondsSinceEpoch,
      refillDate: selectedRefillDate?.toString(),
      time: selectedTime.hour * 60 + selectedTime.minute,
      dosage: dosageController.text,
      numberOfDosesPerDay: int.tryParse(numberOfDosesPerDayController.text),
      frequencyTaken: frequencyTakenController.text,
      hourlyFrequency: int.tryParse(hourlyFrequencyController.text),
      numberOfDoses: int.tryParse(numberOfDosesController.text),
    );
  }

  void confirmMedicationSchedule(Function(MyMedication)? onConfirm) async {
    try {
      MyMedication medication = createMedication();

      // Save to repository and get the medication with ID
      await repository.addMedication(medication);

      if (onConfirm != null) {
        onConfirm(medication);
      }
    } catch (e) {
      print('Error scheduling medication: $e');
      // You could add error handling here
    }
  }

  bool validate() {
    return formKey.currentState?.validate() ?? false;
  }

  @override
  void dispose() {
    // Clean up controllers
    profileController.dispose();
    quantityController.dispose();
    dosageController.dispose();
    numberOfDosesController.dispose();
    numberOfDosesPerDayController.dispose();
    frequencyTakenController.dispose();
    hourlyFrequencyController.dispose();
    super.dispose();
  }
}
