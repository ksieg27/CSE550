import 'package:flutter/foundation.dart';
import 'package:medication_management_module/models/medication.dart';
import 'package:medication_management_module/repositories/medication_repository.dart';
import 'package:medication_management_module/repositories/sqlite_medication_repository.dart';
import '../../../services/notifications_service.dart';
import 'package:vibration/vibration.dart';

/// View model for the medication management screen
///
/// Handles medication list management, UI state, and user interactions
class MedicationManagementViewModel extends ChangeNotifier {
  // Repository for data access
  final MedicationRepository repository;
  final NotificationService _notificationService = NotificationService();

  // Callback for notifying parent widgets about medication count changes
  final Function(int)? onMedicationCountChanged;

  // State variables
  List<MyMedication> _medications = [];
  bool _isLoading = true;
  bool _showSearchPanel = false;
  bool _showSchedulePanel = false;
  Map<dynamic, dynamic>? _selectedMedication;

  // Getters for state
  List<MyMedication> get medications => _medications;
  bool get isLoading => _isLoading;
  bool get showSearchPanel => _showSearchPanel;
  bool get showSchedulePanel => _showSchedulePanel;
  Map<dynamic, dynamic>? get selectedMedication => _selectedMedication;

  /// Constructor
  MedicationManagementViewModel({
    MedicationRepository? repository,
    this.onMedicationCountChanged,
  }) : repository = repository ?? SQLiteMedicationRepository() {
    loadMedications();
  }

  /// Loads medications from the repository
  Future<void> loadMedications() async {
    try {
      _isLoading = true;
      notifyListeners();

      final loadedMedications = await repository.fetchMedications().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          if (kDebugMode) {
            print('Medication loading timed out');
          }
          return []; // Return empty list on timeout
        },
      );

      _medications = loadedMedications;
      _isLoading = false;

      // Use microtask to avoid setState during build
      Future.microtask(() {
        updateMedicationCount();
        notifyListeners();
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error loading medications: $e');
      }
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Updates medication count in parent widgets
  void updateMedicationCount() {
    if (onMedicationCountChanged != null) {
      onMedicationCountChanged!(_medications.length);
    }
  }

  /// Toggles search panel visibility
  void toggleSearchPanel() {
    _showSearchPanel = !_showSearchPanel;
    notifyListeners();
  }

  /// Toggles schedule panel visibility
  void toggleSchedulePanel() {
    _showSchedulePanel = !_showSchedulePanel;
    notifyListeners();
  }

  /// Sets the selected medication for scheduling
  void passMedication(Map<dynamic, dynamic> newMedication) {
    if (newMedication.isNotEmpty) {
      _selectedMedication = newMedication;
      _showSearchPanel = false;
      notifyListeners();

      // Use microtask to avoid setState during build
      Future.microtask(() {
        _showSchedulePanel = true;
        notifyListeners();
      });
    }
  }

  /// "Takes" a medication, reducing its quantity by 1
  Future<void> takeMedication(MyMedication medication) async {
    try {
      // Validate quantity is greater than 0
      if (medication.quantity <= 0) {
        if (kDebugMode) {
          print('Cannot take medication: quantity is 0');
        }
        if (await Vibration.hasVibrator() ?? false) {
          Vibration.vibrate(duration: 100);
        }
        return;
      }

      // Create updated medication object
      final updatedMedication = MyMedication(
        id: medication.id,
        profile: medication.profile,
        brandName: medication.brandName,
        genericName: medication.genericName,
        quantity: medication.quantity - 1, // Reduce by 1
        startDate: medication.startDate,
        refillDate: medication.refillDate,
        time: medication.time,
        dosage: medication.dosage,
        numberOfDosesPerDay: medication.numberOfDosesPerDay,
        frequencyTaken: medication.frequencyTaken,
        hourlyFrequency: medication.hourlyFrequency,
        numberOfDoses: medication.numberOfDoses,
      );

      // Update database
      await repository.updateMedication(updatedMedication);

      // Update local list for UI
      final index = _medications.indexWhere((med) => med.id == medication.id);
      if (index != -1) {
        _medications[index] = updatedMedication;
      }

      // Also update the parameter medication's quantity for UI feedback
      // This is needed because the original object is referenced in the UI
      medication.quantity = medication.quantity - 1;

      // Check for low quantity and schedule refill reminder
      if (medication.quantity <= 5) {
        await _notificationService.scheduleRefillReminder(medication);
      }

      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error taking medication: $e');
      }
    }
  }

  /// Deletes a medication by ID
  Future<bool> deleteMedication(int id) async {
    try {
      // Delete from database
      await repository.deleteMedication(id);

      // Cancel any associated notifications
      await _notificationService.cancelNotification(id);

      // Update local list
      _medications.removeWhere((med) => med.id == id);

      // Notify UI of changes
      notifyListeners();

      // Update parent widget medication count
      updateMedicationCount();

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting medication: $e');
      }
      return false;
    }
  }

  /// Creates a map for editing an existing medication
  void editMedication(MyMedication medication) {
    // Convert medication model to map format expected by Scheduler
    final medicationData = {
      'brand_name': medication.brandName,
      'generic_name': medication.genericName,
      'id': medication.id,
      'quantity': medication.quantity,
      'start_date': medication.startDate,
      'refill_date': medication.refillDate,
      'time': medication.time,
      'dosage': medication.dosage,
      'number_of_doses_per_day': medication.numberOfDosesPerDay,
      'frequency_taken': medication.frequencyTaken,
      'hourly_frequency': medication.hourlyFrequency,
      'number_of_doses': medication.numberOfDoses,
    };

    _selectedMedication = medicationData;
    _showSearchPanel = false;
    notifyListeners();

    Future.microtask(() {
      _showSchedulePanel = true;
      notifyListeners();
    });
  }

  /// Formats time value (stored as minutes since midnight) into readable string
  String formatTime(int? timeValue) {
    if (timeValue == null) {
      return "Not set";
    }

    if (timeValue > 24) {
      int hours = timeValue ~/ 60;
      int minutes = timeValue % 60;
      String period = hours >= 12 ? "PM" : "AM";

      // Convert to 12-hour format
      hours = hours > 12 ? hours - 12 : hours;
      hours = hours == 0 ? 12 : hours; // Handle midnight/noon

      // Format with leading zeros for minutes
      String minutesStr = minutes.toString().padLeft(2, '0');
      return "$hours:$minutesStr $period";
    } else {
      int hour = timeValue;
      String period = hour >= 12 ? "PM" : "AM";

      // Convert to 12-hour format
      hour = hour > 12 ? hour - 12 : hour;
      hour == 0 ? 12 : hour; // Handle midnight/noon

      return "$hour:00 $period";
    }
  }
}
