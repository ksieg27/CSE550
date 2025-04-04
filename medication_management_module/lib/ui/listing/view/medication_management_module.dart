import 'package:flutter/material.dart';
import '../../searching/widgets/search_medication.dart';
import '../../scheduling/view/schedule_medication.dart';
import 'package:medication_management_module/models/medication.dart';
import 'package:medication_management_module/repositories/medication_repository.dart';
import 'package:medication_management_module/repositories/sqlite_medication_repository.dart';
import '../../components/global_med_components.dart';

// Container widget that manages the medication state
// LEARN: Modular architecture separates concerns for better maintainability
class MedicationModuleWidget extends StatefulWidget {
  // Callback to notify parent widget of medication count changes
  final Function(int)? onMedicationCountChanged;

  // Constructor with optional callback
  const MedicationModuleWidget({super.key, this.onMedicationCountChanged});

  @override
  State<MedicationModuleWidget> createState() => _MedicationModuleWidgetState();
}

// State class that manages the list of medications
// LEARN: State is separated from widget for cleaner architecture
class _MedicationModuleWidgetState extends State<MedicationModuleWidget> {
  // List to store selected medications
  List<MyMedication> medications = [];
  final MedicationRepository _repository = SQLiteMedicationRepository();
  // Text controller for direct input
  final TextEditingController _medicationController = TextEditingController();
  // Text controller for direct input

  // State to track if search panel is visible
  bool _showSearchPanel = false;
  bool _showSchedulePanel = false;
  bool _isLoading = true;

  //Variable to store selected medication and pass to scheduling
  Map<dynamic, dynamic>? _selectedMedication;

  @override
  void initState() {
    super.initState();
    // Load medications when widget initializes
    _loadMedications();
  }

  // Method to load medications from repository
  Future<void> _loadMedications() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final loadedMedications = await _repository.fetchMedications();
      setState(() {
        medications = loadedMedications;
        _updateMedicationCount();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Handle error (you could show a snackbar or dialog)
      print('Error loading medications: $e');
    }
    // In your _loadMedications method, add this:
    final loadedMedications = await _repository.fetchMedications();
    print('Loaded ${loadedMedications.length} medications from database');
    for (final med in loadedMedications) {
      print('Loaded: ID=${med.id}, Name=${med.brandName}');
    }
  }

  // Release resources when widget is removed
  @override
  void dispose() {
    _medicationController.dispose();
    super.dispose();
  }

  void _updateMedicationCount() {
    if (widget.onMedicationCountChanged != null) {
      widget.onMedicationCountChanged!(medications.length);
    }
  }

  // Add medication to the list if it's not empty
  // LEARN: State updates should be wrapped in setState() to trigger rebuilds
  void addMedication(MyMedication medication) async {
    if (medication.brandName.isNotEmpty && medication.genericName.isNotEmpty) {
      try {
        // Save to repository
        await _repository.addMedication(medication);
        // Reload medications to get the latest data with IDs
        _loadMedications();

        setState(() {
          _medicationController.clear();
          // Hide search panel after adding medication
          _showSearchPanel = false;
        });
      } catch (e) {
        // Handle error
        print('Error adding medication: $e');
      }
    }
  }

  void passMedication(Map<dynamic, dynamic> newMedication) {
    if (newMedication.isNotEmpty) {
      setState(() {
        _selectedMedication = newMedication;

        _showSearchPanel = false;

        Future.microtask(() {
          setState(() {
            _showSchedulePanel = true;
          });
        });
      });
    }
  }

  // Toggle search panel visibility
  void _toggleSearchPanel() {
    setState(() {
      _showSearchPanel = !_showSearchPanel;
    });
  }

  // Open the search panel and pass the selected medication
  void _toggleSchedulePanel() {
    setState(() {
      _showSchedulePanel = !_showSchedulePanel;
    });
  }

  String _formatTime(int timeValue) {
    // If time is stored as minutes since midnight
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
    }
    // If time is stored as hours (0-23)
    else {
      int hour = timeValue;
      String period = hour >= 12 ? "PM" : "AM";

      // Convert to 12-hour format
      hour = hour > 12 ? hour - 12 : hour;
      hour = hour == 0 ? 12 : hour; // Handle midnight/noon

      return "$hour:00 $period";
    }
  }

  @override
  Widget build(BuildContext context) {
    // Track screen dimensions for layout
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Column for vertical layout
    return SafeArea(
      child: Column(
        children: [
          Center(
            child: Container(
              // Container styling for the medication module
              margin: const EdgeInsets.all(10.0),
              height: screenHeight * 0.6, // Responsive height
              width: screenWidth * 0.9, // Responsive width
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(9.0),
                color: AppColors.offBlue, // Rounded corners
              ),
              child: Stack(
                children: [
                  // Base content (header, medication list, add button)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header
                      MyAppHeader(
                        title: 'My Medications',
                        actionIcon: Icons.refresh,
                        onActionPressed: _loadMedications,
                        actionTooltip: 'Refresh Medications',
                      ),

                      // Medication List
                      Expanded(
                        child:
                            _isLoading
                                ? Center(
                                  child: CircularProgressIndicator(
                                    color: AppColors.getItGreen,
                                  ),
                                )
                                : medications.isEmpty
                                ? Center(
                                  child: Text(
                                    "No medications added yet",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontStyle: FontStyle.italic,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                )
                                : ListView.builder(
                                  itemCount: medications.length,
                                  padding: const EdgeInsets.all(8.0),
                                  itemBuilder: (context, index) {
                                    final medication =
                                        medications[index]; // Get the current medication
                                    return Container(
                                      margin: EdgeInsets.only(bottom: 8.0),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(
                                          8.0,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black12,
                                            blurRadius: 3,
                                            offset: Offset(0, 1),
                                          ),
                                        ],
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // Medication details
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.medication,
                                                  color: AppColors.urgentOrange,
                                                ),
                                                SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(
                                                    medication.brandName,
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                ),
                                                // Delete button
                                                IconButton(
                                                  icon: Icon(
                                                    Icons.delete,
                                                    color:
                                                        AppColors.urgentOrange,
                                                  ),
                                                  onPressed: () async {
                                                    // Make this async
                                                    // Handle delete action
                                                    int id =
                                                        medications[index].id!;
                                                    final scaffoldMessenger =
                                                        ScaffoldMessenger.of(
                                                          context,
                                                        );
                                                    try {
                                                      // Delete from repository first
                                                      await _repository
                                                          .deleteMedication(id);

                                                      // Only update UI after successful database operation
                                                      setState(() {
                                                        // Remove from local list
                                                        medications.removeAt(
                                                          index,
                                                        );
                                                        _updateMedicationCount();
                                                      });

                                                      // Show success message
                                                      scaffoldMessenger.showSnackBar(
                                                        SnackBar(
                                                          content: Text(
                                                            'Medication deleted successfully',
                                                          ),
                                                          backgroundColor:
                                                              AppColors
                                                                  .getItGreen,
                                                        ),
                                                      );
                                                    } catch (e) {
                                                      print(
                                                        'Error deleting medication: $e',
                                                      );
                                                      // Show error message
                                                      scaffoldMessenger
                                                          .showSnackBar(
                                                            SnackBar(
                                                              content: Text(
                                                                'Failed to delete medication',
                                                              ),
                                                              backgroundColor:
                                                                  Colors.red,
                                                            ),
                                                          );
                                                    }
                                                  },
                                                  tooltip: 'Delete Medication',
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 6),
                                            Text(
                                              "Generic: ${medication.genericName}",
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey[700],
                                              ),
                                            ),
                                            SizedBox(height: 4),

                                            // Medication schedule
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                if (medication.frequencyTaken ==
                                                    "By Day")
                                                  Text(
                                                    "Take ${medication.numberOfDoses} dose(s) once daily.",
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                if (medication.frequencyTaken ==
                                                    "By Hour")
                                                  Text(
                                                    "Take ${medication.numberOfDoses} doses, ${medication.numberOfDosesPerDay} times per day.",
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                if (medication.frequencyTaken ==
                                                    "As needed")
                                                  Text(
                                                    "Take as needed.",
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                if (medication.frequencyTaken !=
                                                    "As needed")
                                                  Text(
                                                    "Next Dose: ${_formatTime(medication.time)}",
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                      ),

                      // Add Button (only visible when search panel is hidden)
                      if (!_showSearchPanel)
                        MyConfirmationButton(
                          text: 'Add Medication',
                          actionIcon: Icons.add,
                          actionOnPressed: _toggleSearchPanel,
                          actionTooltip: 'Add Medication',
                          backgroundColor: AppColors.getItGreen,
                          textColor: AppColors.white,
                        ),
                    ],
                  ),

                  // Animated SEARCH PANEL that slides up from bottom
                  AnimatedPositioned(
                    duration: Duration(milliseconds: 300), // Animation duration
                    curve: Curves.easeInOut, // Animation curve
                    left: 0,
                    right: 0,
                    bottom: 0,
                    top:
                        _showSearchPanel
                            ? 0
                            : screenHeight * .6, // Slide from bottom
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(9.0),
                      ),
                      child: Stack(
                        children: [
                          // Search Widget
                          Positioned.fill(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(9.0),
                              child: MedicationSearchWidget(
                                onMedicationSelected: (selectedMedication) {
                                  passMedication(selectedMedication);
                                },
                              ),
                            ),
                          ),
                          // Close Button
                          Positioned(
                            top: 10,
                            right: 10,
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.deepBlues,
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                icon: Icon(
                                  Icons.close,
                                  color: AppColors.urgentOrange,
                                  size: 20.0,
                                ),
                                onPressed: _toggleSearchPanel,
                                tooltip: 'Close search',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // SCHEDUlE MEDICATION VISIBILTY
                  Visibility(
                    visible: _showSchedulePanel,
                    // visible: true, // Visible for testing. Remove for production
                    maintainState: true,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(9.0),
                      ),
                      child: Stack(
                        children: [
                          // Schedule Widget
                          Positioned.fill(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(9.0),
                              child: MedicationScheduleWidget(
                                key: ValueKey(_selectedMedication),
                                newMedication:
                                    _selectedMedication, // Pass the selected medication
                                onMedicationScheduleConfirmed: (
                                  scheduledMedication,
                                ) {
                                  _loadMedications();
                                  _toggleSchedulePanel();
                                },
                                onClose: _toggleSchedulePanel,
                              ),
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
        ],
      ),
    );
  }
}
