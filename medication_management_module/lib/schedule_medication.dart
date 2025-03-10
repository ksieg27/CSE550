import 'package:flutter/material.dart';
import 'package:medication_management_module/medication_management_module.dart';

class MyMedication {
  final String profile;
  final String brandName;
  final String genericName;
  final int quantity;
  final int startDate;
  final String? refillDate;
  final int time;
  final String dosage;
  final int? numberOfDoses;

  // Frequency
  final String? frequencyTaken;

  // Daily Frequency
  final int? numberOfDosesPerDay;

  // Hourly Frequency
  final int? hourlyFrequency;

  MyMedication({
    required this.profile,
    required this.brandName,
    required this.genericName,
    required this.quantity,
    required this.startDate,
    this.refillDate,
    required this.time,
    required this.dosage,

    this.numberOfDosesPerDay,
    this.frequencyTaken,

    this.hourlyFrequency,
    this.numberOfDoses,
  });
}

class MedicationScheduleWidget extends StatefulWidget {
  final Map<dynamic, dynamic>? newMedication;
  final Function(MyMedication)? onMedicationScheduleConfirmed;
  final VoidCallback? onClose;

  const MedicationScheduleWidget({
    super.key,
    required this.newMedication,
    this.onMedicationScheduleConfirmed,
    this.onClose,
  });

  @override
  MedicationScheduleWidgetState createState() =>
      MedicationScheduleWidgetState();
}

class MedicationScheduleWidgetState extends State<MedicationScheduleWidget> {
  // Add controllers and state variables for form fields
  late TextEditingController _quantityController;
  late DateTime _selectedStartDate;
  DateTime? _selectedRefillDate;
  late TimeOfDay _selectedTime;
  late TextEditingController _profileController;
  late TextEditingController _dosageController;
  late TextEditingController _numberOfDosesController;

  // Frequency
  late TextEditingController _numberOfDosesPerDayController;
  late TextEditingController _frequencyTakenController;
  late TextEditingController _hourlyFrequencyController;

  MyMedication? currentMedication;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with default values
    _selectedStartDate = DateTime.now();
    _selectedTime = TimeOfDay.now();
    _quantityController = TextEditingController(text: "");
    _quantityController.addListener(_recalculateRefillDate);
    _profileController = TextEditingController(text: "Default Profile");
    _dosageController = TextEditingController(text: "");
    _numberOfDosesController = TextEditingController(text: "");
    _numberOfDosesController.addListener(_recalculateRefillDate);

    // Frequency
    _numberOfDosesPerDayController = TextEditingController(text: "");
    _numberOfDosesPerDayController.addListener(_recalculateRefillDate);

    _frequencyTakenController = TextEditingController(text: "By Day");
    _hourlyFrequencyController = TextEditingController(text: "");

    if (widget.newMedication != null) {
      // Just extract medication names - we'll build the full MyMedication on submit
      currentMedication = MyMedication(
        profile: _profileController.text,
        brandName: widget.newMedication!['brand_name'] ?? 'Unknown Brand',
        genericName: widget.newMedication!['generic_name'] ?? 'Unknown Generic',
        quantity: int.tryParse(_quantityController.text) ?? 1,
        startDate: _selectedStartDate.millisecondsSinceEpoch,
        refillDate: _selectedRefillDate?.toString(),
        time: _selectedTime.hour,
        dosage: _dosageController.text,
        numberOfDoses: int.tryParse(_numberOfDosesController.text),
      );
    }
  }

  @override
  void dispose() {
    _quantityController.removeListener(_recalculateRefillDate);
    _numberOfDosesController.removeListener(_recalculateRefillDate);
    _numberOfDosesPerDayController.removeListener(_recalculateRefillDate);

    _quantityController.dispose();
    _profileController.dispose();
    _dosageController.dispose();
    _numberOfDosesController.dispose();
    _numberOfDosesPerDayController.dispose();
    _frequencyTakenController.dispose();
    _hourlyFrequencyController.dispose();

    super.dispose();
  }

  // Date picker methods
  // Modify _selectStartDate method

  // Create updated medication with all form values
  void confirmMedicationSchedule() {
    if (widget.newMedication != null &&
        widget.onMedicationScheduleConfirmed != null) {
      // Create a fully populated MyMedication object
      final medication = MyMedication(
        profile: _profileController.text,
        brandName: widget.newMedication!['brand_name'] ?? 'Unknown Brand',
        genericName: widget.newMedication!['generic_name'] ?? 'Unknown Generic',
        quantity: int.tryParse(_quantityController.text) ?? 1,
        startDate: _selectedStartDate.millisecondsSinceEpoch,
        refillDate: _selectedRefillDate?.toString(),
        time: _selectedTime.hour * 60 + (_selectedTime.minute),
        dosage: _dosageController.text,
        numberOfDoses: int.tryParse(_numberOfDosesController.text),
        frequencyTaken: _frequencyTakenController.text,
        // Frequency
        numberOfDosesPerDay: int.tryParse(_numberOfDosesPerDayController.text),
        hourlyFrequency: int.tryParse(_hourlyFrequencyController.text),
      );

      widget.onMedicationScheduleConfirmed!(medication);
    }
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedStartDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedStartDate) {
      setState(() {
        _selectedStartDate = picked;
        _recalculateRefillDate(); // Add this line
      });
    }
  }

  Future<void> _selectRefillDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          _selectedRefillDate ?? _selectedStartDate.add(Duration(days: 30)),
      firstDate: _selectedStartDate,
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _selectedRefillDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  // Format a date for display
  String _formatDate(DateTime date) {
    return "${date.month}/${date.day}/${date.year}";
  }

  void _recalculateRefillDate() {
    // Get the quantity as int, default to 1 if parsing fails
    final quantity = int.tryParse(_quantityController.text) ?? 1;

    // Only calculate if not "As needed"
    if (_frequencyTakenController.text == "As needed") {
      setState(() {
        _selectedRefillDate =
            null; // No refill date for "as needed" medications
      });
      return;
    }

    // Calculate based on frequency and quantity
    DateTime calculatedDate;
    switch (_frequencyTakenController.text) {
      case "By Day":
        final dosesPerDay = int.tryParse(_numberOfDosesController.text) ?? 1;
        final days = (quantity / dosesPerDay).ceil();
        calculatedDate = _selectedStartDate.add(Duration(days: days));
        break;

      case "By Hour":
        // For hourly frequency, use the hourly-specific fields
        final dosesPerDay =
            int.tryParse(_numberOfDosesPerDayController.text) ?? 1;
        final amountPerDose = int.tryParse(_numberOfDosesController.text) ?? 1;

        // Total doses consumed per day
        final totalDailyDoses = dosesPerDay * amountPerDose;

        // Days until refill needed (round up to ensure medication doesn't run out)
        final days = (quantity / totalDailyDoses).ceil();
        calculatedDate = _selectedStartDate.add(Duration(days: days));
        break;

      default:
        calculatedDate = _selectedStartDate.add(Duration(days: quantity));
    }

    setState(() {
      _selectedRefillDate = calculatedDate;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MyAppHeader(
            title: 'Schedule Medications',
            actionIcon: Icons.close,
            onActionPressed: widget.onClose,
            actionTooltip: 'Edit Medication List',
          ),
          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 24),

                  // Medication Name Display
                  Card(
                    elevation: 3,
                    color: AppColors.offBlue,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Medication Details",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            "Brand Name: ${currentMedication?.brandName ?? 'Unknown'}",
                            style: TextStyle(fontSize: 16),
                          ),
                          SizedBox(height: 6),
                          Text(
                            "Generic Name: ${currentMedication?.genericName ?? 'Unknown'}",
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 16),

                  // Scheduling Form
                  Card(
                    elevation: 3,
                    margin: EdgeInsets.symmetric(vertical: 8.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "Scheduling Information",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 16),

                          // Profile Name
                          TextField(
                            controller: _profileController,
                            decoration: InputDecoration(
                              labelText: "Profile Name",
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.person),
                            ),
                          ),
                          SizedBox(height: 16),

                          //Quantity
                          TextField(
                            controller: _quantityController,
                            decoration: InputDecoration(
                              labelText: "Quantity",
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.numbers),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                          SizedBox(height: 16),

                          //Dosage
                          TextField(
                            controller: _dosageController,
                            decoration: InputDecoration(
                              labelText: "Dosage",
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.numbers),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                          SizedBox(height: 16),

                          //Frequency
                          InputDecorator(
                            decoration: InputDecoration(
                              labelText: "Frequency",
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.only(
                                top: 25,
                                bottom: 10,
                                left: 15,
                                right: 15,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Wrap(
                                  alignment: WrapAlignment.center,
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    FrequencyOption(
                                      label: "By Day",
                                      isSelected:
                                          _frequencyTakenController.text ==
                                          "By Day",
                                      onPressed: () {
                                        setState(() {
                                          // Clear other mode's values first
                                          if (_frequencyTakenController.text !=
                                              "By Day") {
                                            _hourlyFrequencyController.text =
                                                "N/A";
                                            _numberOfDosesPerDayController
                                                .text = "N/A";
                                            // Reset this shared controller to a sensible default for "By Day" mode
                                            _numberOfDosesController.text = "1";
                                          }
                                          _frequencyTakenController.text =
                                              "By Day";
                                          _recalculateRefillDate();
                                        });
                                      },
                                    ),
                                    FrequencyOption(
                                      label: "By Hour",
                                      isSelected:
                                          _frequencyTakenController.text ==
                                          "By Hour",
                                      onPressed: () {
                                        setState(() {
                                          if (_frequencyTakenController.text !=
                                              "By Hour") {
                                            _numberOfDosesController.text = "";
                                            _hourlyFrequencyController.text =
                                                "";
                                            _numberOfDosesPerDayController
                                                .text = "";
                                          }
                                          _frequencyTakenController.text =
                                              "By Hour";
                                          _recalculateRefillDate();
                                        });
                                      },
                                    ),
                                    FrequencyOption(
                                      label: "As needed",
                                      isSelected:
                                          _frequencyTakenController.text ==
                                          "As needed",
                                      onPressed: () {
                                        setState(() {
                                          _frequencyTakenController.text =
                                              "As needed";
                                          _recalculateRefillDate(); // Add this line
                                        });
                                      },
                                    ),
                                  ],
                                ),

                                // Daily Frequency
                                if (_frequencyTakenController.text == "By Day")
                                  Column(
                                    children: [
                                      SizedBox(height: 8),
                                      TextField(
                                        controller: _numberOfDosesController,
                                        decoration: InputDecoration(
                                          labelText: "Number of Doses",
                                          border: OutlineInputBorder(),
                                          prefixIcon: Icon(Icons.numbers),
                                        ),
                                        keyboardType: TextInputType.number,
                                      ),
                                    ],
                                  ),
                                // Hourly Frequency
                                if (_frequencyTakenController.text == "By Hour")
                                  Column(
                                    children: [
                                      SizedBox(height: 8),
                                      // Frequency
                                      TextField(
                                        controller: _numberOfDosesController,
                                        decoration: InputDecoration(
                                          labelText: "Number of doses",
                                          border: OutlineInputBorder(),
                                          prefixIcon: Icon(Icons.numbers),
                                        ),
                                        keyboardType: TextInputType.number,
                                      ),
                                      SizedBox(height: 8),
                                      TextField(
                                        controller: _hourlyFrequencyController,
                                        decoration: InputDecoration(
                                          labelText: "Every X hours",
                                          border: OutlineInputBorder(),
                                          prefixIcon: Icon(Icons.numbers),
                                        ),
                                        keyboardType: TextInputType.number,
                                      ),
                                      SizedBox(height: 8),
                                      TextField(
                                        controller:
                                            _numberOfDosesPerDayController,
                                        decoration: InputDecoration(
                                          labelText: "X times a day",
                                          border: OutlineInputBorder(),
                                          prefixIcon: Icon(Icons.numbers),
                                        ),
                                        keyboardType: TextInputType.number,
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                          SizedBox(height: 16),

                          // Start Date
                          InkWell(
                            onTap: () => _selectStartDate(context),
                            child: InputDecorator(
                              decoration: InputDecoration(
                                labelText: "Start Date",
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.calendar_today),
                              ),
                              child: Text(_formatDate(_selectedStartDate)),
                            ),
                          ),
                          SizedBox(height: 16),

                          // Refill Date
                          // Replace the Refill Date InkWell with a non-tappable InputDecorator
                          // If the frequency is "As needed", allow them to select a refill date
                          // If the frequency is "By Day" or "By Hour", calculate the refill date
                          if (_frequencyTakenController.text == "As needed")
                            InkWell(
                              onTap: () => _selectRefillDate(context),
                              child: InputDecorator(
                                decoration: InputDecoration(
                                  labelText: "Refill Date",
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.refresh),
                                ),
                                child: Text(
                                  _selectedRefillDate != null
                                      ? _formatDate(_selectedRefillDate!)
                                      : "Not set",
                                ),
                              ),
                            )
                          else
                            InputDecorator(
                              decoration: InputDecoration(
                                labelText: "Calculated Refill Date",
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.refresh),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _selectedRefillDate != null
                                        ? _formatDate(_selectedRefillDate!)
                                        : "Not set",
                                  ),
                                  Icon(
                                    Icons.calculate,
                                    color: Colors.grey,
                                    size: 16,
                                  ),
                                ],
                              ),
                            ),
                          SizedBox(height: 16),

                          InkWell(
                            onTap: () => _selectTime(context),
                            child: InputDecorator(
                              decoration: InputDecoration(
                                labelText: "Time",
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.access_time),
                              ),
                              child: Text("${_selectedTime.format(context)}"),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Confirm Button - Outside scrollview to stay fixed at bottom
          MyConfirmationButton(
            text: 'Schedule Medication',
            actionIcon: Icons.add,
            actionOnPressed: confirmMedicationSchedule,
            backgroundColor: AppColors.getItGreen,
            textColor: AppColors.white,
          ),
        ],
      ),
    );
  }
}

class FrequencyOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onPressed;

  const FrequencyOption({
    required this.label,
    required this.isSelected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? AppColors.getItGreen : null,
        foregroundColor: isSelected ? Colors.white : null,
      ),
      child: Text(label),
    );
  }
}
