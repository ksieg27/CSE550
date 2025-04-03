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

class MyAppHeader extends StatelessWidget {
  final String title;
  final IconData? actionIcon;
  final VoidCallback? onActionPressed;
  final String? actionTooltip;
  final Color backgroundColor;
  final Color textColor;
  final bool roundedCorners;

  const MyAppHeader({
    Key? key,
    required this.title,
    this.actionIcon,
    this.onActionPressed,
    this.actionTooltip,
    this.backgroundColor = const Color(0xFF2C3E50), // AppColors.deepBlues
    this.textColor = Colors.white,
    this.roundedCorners = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      width: double.infinity,
      height: screenHeight * 0.06,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius:
            roundedCorners
                ? BorderRadius.only(
                  topLeft: Radius.circular(9.0),
                  topRight: Radius.circular(9.0),
                )
                : null,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Title
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: textColor,
              fontSize: screenHeight * 0.03,
            ),
            textAlign: TextAlign.center,
          ),

          // Action button (if provided)
          if (actionIcon != null)
            Positioned(
              right: 10,
              child: Container(
                height: screenHeight * 0.05,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(
                    actionIcon,
                    color: const Color(0xFFF4A261), // AppColors.urgentOrange
                    size: screenHeight * 0.02,
                  ),
                  onPressed: onActionPressed,
                  tooltip: actionTooltip,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class MyConfirmationButton extends StatelessWidget {
  final String text;
  final IconData? actionIcon;
  final VoidCallback? actionOnPressed;
  final String? actionTooltip;
  final Color backgroundColor;
  final Color textColor;

  const MyConfirmationButton({
    Key? key,
    required this.text,
    this.actionIcon,
    this.actionOnPressed,
    this.actionTooltip,
    this.backgroundColor = const Color(0xFF76C7C0), // AppColors.getItGreen
    this.textColor = Colors.white,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.07,
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton.icon(
        onPressed: actionOnPressed,
        icon: Icon(actionIcon),
        label: Text(text, style: TextStyle(fontSize: screenHeight * 0.03)),
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: AppColors.getItGreen,
          padding: EdgeInsets.symmetric(vertical: 12.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(9.0),
          ),
        ),
      ),
    );
  }
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
                        actionIcon: Icons.edit,
                        onActionPressed: () {
                          Navigator.pop(context);
                        },
                        actionTooltip: 'Edit Medication List',
                      ),

                      // Medication List
                      Expanded(
                        child:
                            medications.isEmpty
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
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
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
      ),
    );
  }
}
