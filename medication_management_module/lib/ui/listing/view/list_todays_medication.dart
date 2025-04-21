import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../searching/view/search_medication_view.dart';
import '../../scheduling/view/schedule_medication_view.dart';
import '../../components/global_med_components.dart';
import 'dart:math' show pi;
import 'package:confetti/confetti.dart';
import '../view_models/medication_management_view_model.dart';
import '../../../models/medication.dart';

//We want to list the medications that are scheduled for today only.
//It should not display a delete medication button
//It should have a + to add a new medication
class ListTodaysMedicationWidget extends StatelessWidget {
  final Function(int)? onMedicationCountChanged;

  const ListTodaysMedicationWidget({super.key, this.onMedicationCountChanged});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create:
          (_) => MedicationManagementViewModel(
            onMedicationCountChanged: onMedicationCountChanged,
          ),
      child: const _ListTodaysMedicationView(),
    );
  }
}

class _ListTodaysMedicationView extends StatelessWidget {
  const _ListTodaysMedicationView();

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<MedicationManagementViewModel>(context);

    // Get screen dimensions for responsive layout
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return SafeArea(
      child: Column(
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.all(10.0),
              height: screenHeight * 0.6,
              width: screenWidth * 0.9,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(9.0),
                color: AppColors.offBlue,
              ),
              child: Stack(
                children: [
                  // Base content (header, medication list, add button)
                  _buildBaseContent(viewModel),

                  // Search panel (slides up from bottom)
                  _buildSearchPanel(viewModel, screenHeight),

                  // Schedule panel (appears when needed)
                  _buildSchedulePanel(viewModel),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the base content including header, medication list, and add button
  Widget _buildBaseContent(MedicationManagementViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header with title and refresh button
        MyAppHeader(
          title: 'Todays Medications',
          actionIcon: Icons.refresh,
          onActionPressed: () async {
            // First load all medications
            await viewModel.loadMedications();
            // Then filter for today's medications
            await viewModel.fetchTodaysMedications();
          },
          actionTooltip: 'Refresh Medications',
        ),

        // Medication list with loading and empty states
        Expanded(
          child:
              viewModel.isLoading
                  ? const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.getItGreen,
                    ),
                  )
                  : viewModel.todaysMedications.isEmpty
                  ? Center(
                    child: Text(
                      "No medications for today",
                      style: TextStyle(
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey[600],
                      ),
                    ),
                  )
                  : _buildMedicationList(viewModel),
        ),
        // Add button (visible only when search panel is hidden)
        if (!viewModel.showSearchPanel)
          MyConfirmationButton(
            text: 'Add Medication',
            actionIcon: Icons.add,
            actionOnPressed: viewModel.toggleSearchPanel,
            actionTooltip: 'Add Medication',
            backgroundColor: AppColors.getItGreen,
            textColor: AppColors.white,
          ),
      ],
    );
  }

  /// Builds the medication list
  Widget _buildMedicationList(MedicationManagementViewModel viewModel) {
    return ListView.builder(
      itemCount: viewModel.todaysMedications.length,
      padding: const EdgeInsets.all(8.0),
      itemBuilder: (context, index) {
        final medication = viewModel.todaysMedications[index];
        return _buildMedicationItem(context, medication, viewModel);
      },
    );
  }

  /// Builds an individual medication list item
  Widget _buildMedicationItem(
    BuildContext context,
    MyMedication medication,
    MedicationManagementViewModel viewModel,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 3, offset: Offset(0, 1)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Medication title, delete button, and take button
            Row(
              children: [
                const Icon(Icons.medication, color: AppColors.urgentOrange),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    medication.brandName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),

                // Take button with confetti
                Stack(
                  alignment: Alignment.center,
                  children: [
                    TextButton.icon(
                      icon: const Icon(
                        Icons.check_circle,
                        color: AppColors.getItGreen,
                      ),
                      label: const Text(
                        'Take',
                        style: TextStyle(color: AppColors.getItGreen),
                      ),
                      onPressed:
                          () => _handleTakeMedication(
                            context,
                            viewModel,
                            medication,
                          ),
                    ),

                    // Confetti widget
                    ConfettiWidget(
                      confettiController: viewModel.confettiController,
                      minimumSize: const Size(3, 2),
                      maximumSize: const Size(5, 3),
                      blastDirection: pi / 2, // Straight down
                      blastDirectionality: BlastDirectionality.explosive,
                      emissionFrequency: 0.01,
                      numberOfParticles: 10,
                      gravity: 0.2,
                      shouldLoop: false,
                      colors: const [
                        AppColors.offBlue,
                        AppColors.getItGreen,
                        AppColors.urgentOrange,
                        AppColors.deepBlues,
                      ],
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 6),

            // Generic name
            Text(
              "Generic: ${medication.genericName}",
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),

            const SizedBox(height: 4),

            // Medication schedule and quantity information
            _buildMedicationScheduleInfo(medication, viewModel),
          ],
        ),
      ),
    );
  }

  /// Builds the medication schedule information section
  Widget _buildMedicationScheduleInfo(
    MyMedication medication,
    MedicationManagementViewModel viewModel,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Dosage frequency based on frequency type
        if (medication.frequencyTaken == "By Day")
          Text(
            "Take ${medication.numberOfDoses} dose(s) once daily.",
            style: const TextStyle(fontSize: 13),
          ),
        if (medication.frequencyTaken == "By Hour")
          Text(
            "Take ${medication.numberOfDoses} doses, ${medication.numberOfDosesPerDay} times per day.",
            style: const TextStyle(fontSize: 13),
          ),
        if (medication.frequencyTaken == "As needed")
          const Text("Take as needed.", style: TextStyle(fontSize: 13)),

        // Next dose time (if applicable)
        if (medication.frequencyTaken != "As needed")
          Text(
            "Next Dose: ${viewModel.formatTime(medication.time)}",
            style: const TextStyle(fontSize: 13),
          ),

        // Quantity (highlighted in orange if low)
        Text(
          "QTY: ${medication.quantity}",
          style: TextStyle(
            fontSize: 13,
            color:
                medication.quantity <= 5
                    ? AppColors.urgentOrange
                    : Colors.black,
          ),
        ),
      ],
    );
  }

  /// Builds the animated search panel
  Widget _buildSearchPanel(
    MedicationManagementViewModel viewModel,
    double screenHeight,
  ) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      left: 0,
      right: 0,
      bottom: 0,
      top: viewModel.showSearchPanel ? 0 : screenHeight * .6,
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
                  onMedicationSelected: viewModel.passMedication,
                ),
              ),
            ),

            // Close Button
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.deepBlues,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.close,
                    color: AppColors.urgentOrange,
                    size: 20.0,
                  ),
                  onPressed: viewModel.toggleSearchPanel,
                  tooltip: 'Close search',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the schedule panel
  Widget _buildSchedulePanel(MedicationManagementViewModel viewModel) {
    return Visibility(
      visible: viewModel.showSchedulePanel,
      maintainState: true,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(9.0),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(9.0),
                child: MedicationScheduleWidget(
                  key: ValueKey(viewModel.selectedMedication),
                  newMedication: viewModel.selectedMedication,
                  onMedicationScheduleConfirmed: (scheduledMedication) {
                    viewModel.loadMedications();
                    viewModel.toggleSchedulePanel();
                  },
                  onClose: viewModel.toggleSchedulePanel,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleTakeMedication(
    BuildContext context,
    MedicationManagementViewModel viewModel,
    MyMedication medication,
  ) {
    // Only take if there are doses left
    if (medication.quantity > 0) {
      viewModel.takeMedication(medication);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Medication taken. ${medication.quantity - 1} doses remaining.',
          ),
          backgroundColor: AppColors.getItGreen,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No doses remaining. Please refill your medication.'),
          backgroundColor: AppColors.urgentOrange,
        ),
      );
    }
  }
}
