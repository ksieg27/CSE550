import 'package:flutter/material.dart';
import 'search_medication.dart'; // Import local search widget
// import 'schedule_medication.dart'; // Import local schedule widget

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
  List<String> medications = [];
  // Text controller for direct input
  final TextEditingController _medicationController = TextEditingController();

  // State to track if search panel is visible
  bool _showSearchPanel = false;
  bool _showSchedulePanel = false;

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
  void addMedication(Map<dynamic, dynamic> medication) {
    if (medication.isNotEmpty) {
      setState(() {
        medications.add(
          "${medication['brand_name']} \n(${medication['generic_name']})",
        );
        _updateMedicationCount();
        _medicationController.clear();
        // Hide search panel after adding medication
        _showSearchPanel = false;
      });
    }
  }

  // Toggle search panel visibility
  void _toggleSearchPanel() {
    setState(() {
      _showSearchPanel = !_showSearchPanel;
    });
  }

  void _toggleSchedulePanel() {
    setState(() {
      _showSchedulePanel = !_showSchedulePanel;
    });
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
                            (medication) => Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 4.0,
                              ),

                              child: Row(
                                children: [
                                  Icon(
                                    Icons.medication,
                                    color: AppColors.urgentOrange,
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(child: Text(medication)),
                                ],
                              ),
                            ),
                          ),
                          if (medications.isEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8.0,
                              ),
                              child: Text(
                                'No medications added yet',
                                style: TextStyle(fontStyle: FontStyle.italic),
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
                            backgroundColor: AppColors.getItGreen,
                            foregroundColor: Colors.white,
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
                                _toggleSchedulePanel();
                                if (_showSchedulePanel) {
                                  addMedication(selectedMedication);
                                }
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
                                size: 28.0,
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

                // SCHEDUlE MEDICATION Animated panel
                AnimatedPositioned(
                  duration: Duration(milliseconds: 300), // Animation duration
                  curve: Curves.easeInOut, // Animation curve
                  left: 0,
                  right: 0,
                  bottom: 0,
                  top: _showSchedulePanel ? 0 : 500, // Slide from bottom
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(9.0),
                    ),
                    child: Stack(
                      children: [
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
                                size: 28.0,
                              ),
                              onPressed: _toggleSchedulePanel,
                              tooltip: 'Close schedule',
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
