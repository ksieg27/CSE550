import 'package:flutter/material.dart';

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
  final int quantity;
  final int startDate;
  final String? refillDate;
  final int time;

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

  MyMedication? currentMedication;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with default values
    _selectedStartDate = DateTime.now();
    _selectedTime = TimeOfDay.now();
    _quantityController = TextEditingController(text: "1");
    _profileController = TextEditingController(text: "Default Profile");

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
      );
    }
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _profileController.dispose();
    super.dispose();
  }

  // Date picker methods
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
        time:
            _selectedTime.hour * 60 +
            (_selectedTime.minute), // Store as minutes since midnight
      );

      widget.onMedicationScheduleConfirmed!(medication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(0),
      child: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 12.0),
            decoration: BoxDecoration(
              color: AppColors.deepBlues,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(9.0),
                topRight: Radius.circular(9.0),
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  "Schedule Medication",
                  style: Theme.of(
                    context,
                  ).textTheme.headlineSmall?.copyWith(color: AppColors.white),
                  textAlign: TextAlign.center,
                ),
                Positioned(
                  right: 30,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.close,
                        color: AppColors.urgentOrange,
                        size: 20.0,
                      ),
                      onPressed: widget.onClose,
                      tooltip: 'Close Medication Schedule',
                    ),
                  ),
                ),
              ],
            ),
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Scheduling Information",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 16),

                          TextField(
                            controller: _profileController,
                            decoration: InputDecoration(
                              labelText: "Profile Name",
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.person),
                            ),
                          ),
                          SizedBox(height: 16),

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

                          InkWell(
                            onTap: () => _selectRefillDate(context),
                            child: InputDecorator(
                              decoration: InputDecoration(
                                labelText: "Refill Date (Optional)",
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.refresh),
                              ),
                              child: Text(
                                _selectedRefillDate != null
                                    ? _formatDate(_selectedRefillDate!)
                                    : "Not set",
                              ),
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
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: confirmMedicationSchedule,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.getItGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: Text(
                  "Schedule Medication",
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
