import 'package:flutter/material.dart';
import 'search_medication.dart'; // Import local search widget
import 'schedule_medication.dart'; // Import local schedule widget

// Define a library of colors for easy reference
class AppColors {
  static const Color offBlue = Color(0xFFE0F7FA);
  static const Color deepBlues = Color(0xFF2C3E50);
  static const Color getItGreen = Color(0xFF76C7C0);
  static const Color urgentOrange = Color(0xFFF4A261);
  static const Color white = Color(0xFFFFFFFF);
  // Add more colors as needed
}

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
  // Text controller for direct input
  final TextEditingController _medicationController = TextEditingController();

  // State to track if search panel is visible
  bool _showSearchPanel = false;
  bool _showSchedulePanel = false;

  //Variable to store selected medication and pass to scheduling
  Map<dynamic, dynamic>? _selectedMedication;

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
  void addMedication(MyMedication medication) {
    if (medication.brandName.isNotEmpty & medication.genericName.isNotEmpty) {
      setState(() {
        medications.add(medication);
        _updateMedicationCount();
        _medicationController.clear();
        // Hide search panel after adding medication
        _showSearchPanel = false;
      });
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

  // Format date to a human-readable string
  String _formatDate(DateTime date) {
    return "${date.month}/${date.day}/${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    // Column for vertical layout
    return Column(
      children: [
        Center(
          child: Container(
            // Container styling for the medication module
            margin: const EdgeInsets.all(10.0),
            height: 500,
            width: MediaQuery.of(context).size.width * 0.9, // Responsive width
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
                    Container(
                      constraints: BoxConstraints(minHeight: 48.0),
                      width: double.infinity, // Full width
                      padding: const EdgeInsets.all(10.0), // Padding for text
                      decoration: BoxDecoration(
                        color: AppColors.deepBlues, // Background color
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(9.0),
                          topRight: Radius.circular(9.0),
                        ),
                      ),
                      child: Text(
                        'My Medications',
                        style: Theme.of(
                          context,
                        ).textTheme.headlineSmall?.copyWith(
                          color: AppColors.white, // Text color
                        ),
                        textAlign: TextAlign.center, // Center text
                      ),
                    ),

                    // Medication List
                    Container(
                      height: 400,
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ...medications.map(
                            (medication) => Container(
                              margin: EdgeInsets.only(bottom: 8.0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8.0),
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
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
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
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
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "Quantity: ${medication.quantity}",
                                          style: TextStyle(fontSize: 13),
                                        ),
                                        Text(
                                          "Start: ${_formatDate(DateTime.fromMillisecondsSinceEpoch(medication.startDate))}",
                                          style: TextStyle(fontSize: 13),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Add Button (only visible when search panel is hidden)
                    if (!_showSearchPanel)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton.icon(
                          onPressed: _toggleSearchPanel,
                          icon: Icon(Icons.add),
                          label: Text('Add Medication'),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: AppColors.getItGreen,
                            padding: EdgeInsets.symmetric(vertical: 12.0),
                          ),
                        ),
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
                  top: _showSearchPanel ? 0 : 500, // Slide from bottom
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
                                addMedication(scheduledMedication);
                                _toggleSchedulePanel();
                                _updateMedicationCount();
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
    );
  }
}
