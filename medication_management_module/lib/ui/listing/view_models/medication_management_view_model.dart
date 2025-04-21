import 'package:flutter/foundation.dart';
import 'package:medication_management_module/models/medication.dart';
import 'package:medication_management_module/repositories/medication_repository.dart';
import 'package:medication_management_module/repositories/sqlite_medication_repository.dart';
import '../../../services/notifications_service.dart';
import 'package:vibration/vibration.dart';
import 'package:confetti/confetti.dart';

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
  List<MyMedication> _todaysMedications = [];
  List<MyMedication> _medications = [];
  bool _isLoading = true;
  bool _showSearchPanel = false;
  bool _showSchedulePanel = false;
  Map<dynamic, dynamic>? _selectedMedication;

  //Tracking todays doeses for listing medications

  // Getters for state
  List<MyMedication> get medications => _medications;
  List<MyMedication> get todaysMedications => _todaysMedications;
  bool get isLoading => _isLoading;
  bool get showSearchPanel => _showSearchPanel;
  bool get showSchedulePanel => _showSchedulePanel;
  Map<dynamic, dynamic>? get selectedMedication => _selectedMedication;

  final ConfettiController confettiController;

  /// Constructor
  MedicationManagementViewModel({
    MedicationRepository? repository,
    this.onMedicationCountChanged,
    ConfettiController? confettiController,
  }) : repository = repository ?? SQLiteMedicationRepository(),
       confettiController =
           confettiController ??
           ConfettiController(duration: const Duration(seconds: 2)) {
    loadMedications().then((_) {
      fetchTodaysMedications();
    });
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

      final today = DateTime.now();
      List<Future> updateOperations = [];

      for (int i = 0; i < _medications.length; i++) {
        final medicationDate = _medications[i].lastTakenDate;

        // Compare date components instead of DateTime objects directly
        if (medicationDate.year != today.year ||
            medicationDate.month != today.month ||
            medicationDate.day != today.day) {
          // Reset the counters
          _medications[i].takenToday = 0;
          _medications[i].lastTakenDate = today;

          // Create a new medication object with updated values
          final updatedMedication = MyMedication(
            id: _medications[i].id,
            profile: _medications[i].profile,
            brandName: _medications[i].brandName,
            genericName: _medications[i].genericName,
            quantity: _medications[i].quantity,
            startDate: _medications[i].startDate,
            refillDate: _medications[i].refillDate,
            time: _medications[i].time,
            dosage: _medications[i].dosage,
            numberOfDosesPerDay: _medications[i].numberOfDosesPerDay,
            frequencyTaken: _medications[i].frequencyTaken,
            hourlyFrequency: _medications[i].hourlyFrequency,
            numberOfDoses: _medications[i].numberOfDoses,
            takenToday: 0, // Reset to 0
            lastTakenDate: today, // Update to today's date
          );

          // Add update operation to list (don't await here to allow parallel updates)
          updateOperations.add(repository.updateMedication(updatedMedication));

          if (kDebugMode) {
            print(
              'Resetting medication: ${_medications[i].brandName} for new day',
            );
          }
        }
      }

      // Wait for all update operations to complete
      if (updateOperations.isNotEmpty) {
        await Future.wait(updateOperations);
        if (kDebugMode) {
          print(
            'Updated ${updateOperations.length} medications for the new day',
          );
        }
      }

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
      onMedicationCountChanged!(_todaysMedications.length);
    }
  }

  // Need to have a next dose function that will check the time and see what time the next
  // dose time is. It will also show if a medication was not taken and show a past due
  Future<List<MyMedication>> fetchTodaysMedications() async {
    try {
      final todaysMeds =
          _medications.where((medication) {
            return medication.frequencyTaken != "As needed" &&
                medication.quantity > 0 &&
                medication.takenToday <
                    (medication.numberOfDosesPerDay! *
                        medication.numberOfDoses!);
          }).toList();

      // Update the property
      _todaysMedications = todaysMeds;

      // Notify listeners about the change
      notifyListeners();

      // Return the filtered list
      return todaysMeds;
    } catch (e) {
      if (kDebugMode) {
        print('Error filtering today\'s medications: $e');
      }
      // Return empty list on error
      return [];
    }
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

      // Calculate new values
      final newQuantity = medication.quantity - (medication.numberOfDoses ?? 1);
      final newTakenToday =
          medication.takenToday + (medication.numberOfDoses ?? 1);

      print(
        'Medication taken: ${medication.brandName}, New quantity: $newQuantity, Times taken today: $newTakenToday',
      );

      // Create updated medication object with updated values
      final updatedMedication = MyMedication(
        id: medication.id,
        profile: medication.profile,
        brandName: medication.brandName,
        genericName: medication.genericName,
        quantity: newQuantity,
        startDate: medication.startDate,
        refillDate: medication.refillDate,
        time: medication.time,
        dosage: medication.dosage,
        numberOfDosesPerDay: medication.numberOfDosesPerDay,
        frequencyTaken: medication.frequencyTaken,
        hourlyFrequency: medication.hourlyFrequency,
        numberOfDoses: medication.numberOfDoses,
        takenToday: newTakenToday,
        lastTakenDate: DateTime.now(),
      );

      // Update database
      await repository.updateMedication(updatedMedication);

      // Update local list for UI
      final index = _medications.indexWhere((med) => med.id == medication.id);
      if (index != -1) {
        _medications[index] = updatedMedication;
      }

      medication.quantity = newQuantity;
      medication.takenToday = newTakenToday;
      medication.lastTakenDate = DateTime.now();

      // Check if this medication should be removed from today's medications
      bool shouldRemove = false;

      // Remove if quantity is now zero
      if (newQuantity <= 0) {
        shouldRemove = true;
      }
      // Or if all daily doses have been taken
      else if (medication.numberOfDosesPerDay != null &&
          medication.numberOfDoses != null &&
          newTakenToday >=
              (medication.numberOfDosesPerDay! * medication.numberOfDoses!)) {
        shouldRemove = true;
      }

      // Remove from today's list if needed
      if (shouldRemove) {
        _todaysMedications.removeWhere((med) => med.id == medication.id);
        print('Removed medication ${medication.brandName} from today\'s list');
      }

      // Play confetti if medication was taken successfully
      if (medication.quantity >= 0) {
        playConfetti();
      }

      // Check for low quantity and schedule refill reminder
      if (medication.quantity <= 5) {
        await _notificationService.scheduleRefillReminder(medication);
      }

      // Notify UI to update
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

  /// Confetti animation
  void playConfetti() {
    if (confettiController.state == ConfettiControllerState.stopped) {
      confettiController.play();
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
}
