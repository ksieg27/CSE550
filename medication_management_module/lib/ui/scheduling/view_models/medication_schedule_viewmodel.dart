import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:medication_management_module/repositories/sqlite_medication_repository.dart';
import 'package:medication_management_module/services/notifications_service.dart';
import '../../../models/medication.dart';
import '../../../repositories/medication_repository.dart';

// View model for the medication scheduling screen
// Handles medication creation, schedule configuration, and form validation
class MedicationScheduleViewModel extends ChangeNotifier {
  // Input data and services
  final Map<dynamic, dynamic>? medicationData;
  final MedicationRepository repository;
  final NotificationService _notificationService = NotificationService();
  final bool isEditing;

  // Form field controllers
  final TextEditingController profileController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController dosageController = TextEditingController();
  final TextEditingController numberOfDosesController = TextEditingController();
  final TextEditingController numberOfDosesPerDayController =
      TextEditingController();
  final TextEditingController frequencyTakenController = TextEditingController(
    text: "As needed",
  );
  final TextEditingController hourlyFrequencyController =
      TextEditingController();

  // Date & time values
  DateTime selectedStartDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  DateTime? selectedRefillDate;

  // Form validation
  final formKey = GlobalKey<FormState>();

  /// Constructor initializes the view model with medication data if editing
  MedicationScheduleViewModel({
    required this.medicationData,
    MedicationRepository? repository,
    this.isEditing = false,
  }) : repository = repository ?? SQLiteMedicationRepository() {
    // Initialize listeners for real-time calculations
    quantityController.addListener(_recalculateRefillDate);
    numberOfDosesController.addListener(_recalculateRefillDate);
    numberOfDosesPerDayController.addListener(_recalculateRefillDate);

    // If editing an existing medication, load its data
    if (isEditing && medicationData != null && medicationData!['id'] != null) {
      _initializeWithExistingData();
    }
  }

  /// Loads existing medication data when editing
  Future<void> _initializeWithExistingData() async {
    try {
      // Find the full medication details by ID
      final int? id = medicationData!['id'];
      if (id != null) {
        final medication = await repository.getMedicationById(id);
        if (medication != null) {
          // Populate text controllers
          profileController.text = medication.profile;
          quantityController.text = medication.quantity.toString();
          dosageController.text = medication.dosage;

          // Set date and time values
          selectedStartDate = DateTime.fromMillisecondsSinceEpoch(
            medication.startDate,
          );

          int minutes = medication.time;
          selectedTime = TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60);

          // Set frequency values
          frequencyTakenController.text =
              medication.frequencyTaken ?? 'As needed';

          if (medication.numberOfDoses != null) {
            numberOfDosesController.text = medication.numberOfDoses.toString();
          }

          if (medication.numberOfDosesPerDay != null) {
            numberOfDosesPerDayController.text =
                medication.numberOfDosesPerDay.toString();
          }

          if (medication.hourlyFrequency != null) {
            hourlyFrequencyController.text =
                medication.hourlyFrequency.toString();
          }

          // Recalculate the refill date
          _recalculateRefillDate();

          // Update UI
          notifyListeners();
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading medication for editing: $e');
      }
    }
  }

  /// Calculates the refill date based on quantity and frequency
  void _recalculateRefillDate() {
    // Get the quantity as int, default to 1 if parsing fails
    final quantity = int.tryParse(quantityController.text) ?? 1;

    // No refill date needed for "as needed" medications
    if (frequencyTakenController.text == "As needed") {
      selectedRefillDate = null;
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

        // Calculate total daily doses and days until refill
        final totalDailyDoses = dosesPerDay * amountPerDose;
        final days = (quantity / totalDailyDoses).ceil();
        calculatedDate = selectedStartDate.add(Duration(days: days));
        break;

      default:
        calculatedDate = selectedStartDate.add(Duration(days: quantity));
    }

    selectedRefillDate = calculatedDate;
    notifyListeners();
  }

  /// Public method to trigger refill date recalculation
  void recalculateRefillDate() {
    _recalculateRefillDate();
  }

  /// Updates the frequency option and resets related fields
  void updateFrequencyOption(String option) {
    frequencyTakenController.text = option;

    if (option == "By Day") {
      // Clear hourly-specific fields
      hourlyFrequencyController.text = "";
      numberOfDosesPerDayController.text = "";

      // Set default for daily dose if empty
      if (numberOfDosesController.text.isEmpty) {
        numberOfDosesController.text = "1";
      }
    } else if (option == "By Hour") {
      // Set defaults for hourly frequency
      if (numberOfDosesPerDayController.text.isEmpty) {
        numberOfDosesPerDayController.text = "1";
      }
      if (hourlyFrequencyController.text.isEmpty) {
        hourlyFrequencyController.text = "6"; // Default: every 6 hours
      }
      if (numberOfDosesController.text.isEmpty) {
        numberOfDosesController.text = "4";
      }
    }

    _recalculateRefillDate();
    notifyListeners();
  }

  /// Updates the start date and recalculates refill date
  void updateStartDate(DateTime date) {
    selectedStartDate = date;
    _recalculateRefillDate();
    notifyListeners();
  }

  /// Updates the time of day and recalculates refill date
  void updateTime(TimeOfDay time) {
    selectedTime = time;
    _recalculateRefillDate();
    notifyListeners();
  }

  /// Shows date picker for selecting start date
  void selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedStartDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) updateStartDate(picked);
  }

  /// Shows date picker for selecting refill date
  void selectRefillDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          selectedRefillDate ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      selectedRefillDate = picked;
      notifyListeners();
    }
  }

  /// Shows time picker for selecting medication time
  void selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (picked != null) updateTime(picked);
  }

  /// Creates a medication object from form values
  MyMedication createMedication() {
    final medicationId = isEditing ? medicationData!['id'] : null;

    return MyMedication(
      id: medicationId,
      profile:
          profileController.text.isEmpty ? 'Default' : profileController.text,
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

  /// Saves medication and schedules notification
  Future<void> confirmMedicationSchedule(
    Function(MyMedication)? onConfirm,
  ) async {
    try {
      final medication = createMedication();

      if (isEditing && medication.id != null) {
        // Update existing medication
        await repository.updateMedication(medication);
      } else {
        // Add new medication
        await repository.addMedication(medication);
      }

      // Schedule notification
      await _notificationService.scheduleMedicationReminder(medication);

      // Notify callback if provided
      if (onConfirm != null) {
        onConfirm(medication);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error scheduling medication: $e');
      }
      rethrow; // Propagate error to UI for handling
    }
  }

  /// Validates the form
  bool validate() {
    return formKey.currentState?.validate() ?? false;
  }

  @override
  void dispose() {
    // Clean up controllers to prevent memory leaks
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
