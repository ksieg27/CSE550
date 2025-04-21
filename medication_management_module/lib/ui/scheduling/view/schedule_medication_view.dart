import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/medication_schedule_viewmodel.dart' as view_model;
import '../../../models/medication.dart';
import '../../components/schedule_components.dart' as components;
import '../../components/global_med_components.dart';

class MedicationScheduleWidget extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create:
          (_) => view_model.MedicationScheduleViewModel(
            medicationData: newMedication,
          ),
      child: _MedicationScheduleView(
        onMedicationScheduleConfirmed: onMedicationScheduleConfirmed,
        onClose: onClose,
        currentMedication:
            newMedication != null ? MyMedication.fromMap(newMedication!) : null,
      ),
    );
  }
}

class _MedicationScheduleView extends StatelessWidget {
  final Function(MyMedication)? onMedicationScheduleConfirmed;
  final VoidCallback? onClose;

  // Initialized medication class
  final MyMedication? currentMedication;

  const _MedicationScheduleView({
    this.onMedicationScheduleConfirmed,
    this.onClose,
    this.currentMedication,
  });

  // Format a date for display
  String _formatDate(DateTime date) {
    return "${date.month}/${date.day}/${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<view_model.MedicationScheduleViewModel>(
      context,
    );

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MyAppHeader(
            title: 'Schedule Medications',
            actionIcon: Icons.close,
            onActionPressed: onClose,
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

                      child: Form(
                        key: viewModel.formKey,
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

                            // Profile dropdown replacement
                            viewModel.isLoadingProfiles
                                ? const Center(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      vertical: 8.0,
                                    ),
                                    child: CircularProgressIndicator(),
                                  ),
                                )
                                : DropdownButtonFormField<String>(
                                  decoration: const InputDecoration(
                                    labelText: "Profile",
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.person),
                                  ),
                                  value:
                                      viewModel.profileController.text.isEmpty
                                          ? (viewModel.profiles.isNotEmpty
                                              ? viewModel.profiles[0].email
                                              : 'default@example.com')
                                          : viewModel.profileController.text,
                                  items:
                                      viewModel.profiles.map((profile) {
                                        return DropdownMenuItem<String>(
                                          value: profile.email,
                                          child: Text(profile.email),
                                        );
                                      }).toList(),
                                  onChanged: (newValue) {
                                    if (newValue != null) {
                                      viewModel.profileController.text =
                                          newValue;
                                    }
                                  },
                                  validator:
                                      (value) =>
                                          value == null || value.isEmpty
                                              ? 'Please select a profile'
                                              : null,
                                ),
                            SizedBox(height: 16),

                            // Quantity field - use your custom widget
                            components.MedicationFormField(
                              label: "Quantity",
                              icon: Icons.numbers,
                              controller: viewModel.quantityController,
                              keyboardType: TextInputType.number,
                              validator:
                                  (value) =>
                                      value == null || value.isEmpty
                                          ? 'Please enter a quantity'
                                          : int.tryParse(value) == null
                                          ? 'Please enter a valid number'
                                          : null,
                            ),

                            // Dosage field
                            components.MedicationFormField(
                              label: "Dosage",
                              icon: Icons.numbers,
                              controller: viewModel.dosageController,
                              keyboardType: TextInputType.number,
                              validator:
                                  (value) =>
                                      value == null || value.isEmpty
                                          ? 'Please enter dosage'
                                          : null,
                            ),

                            // The frequency section - keep this as is but add validators where appropriate
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
                                  // Frequency options - keep as is
                                  Wrap(
                                    alignment: WrapAlignment.center,
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: [
                                      components.FrequencyOption(
                                        label: "By Day",
                                        isSelected:
                                            viewModel
                                                .frequencyTakenController
                                                .text ==
                                            "By Day",
                                        onPressed: () {
                                          // Clear other mode's values first
                                          if (viewModel
                                                  .frequencyTakenController
                                                  .text !=
                                              "By Day") {
                                            viewModel
                                                .hourlyFrequencyController
                                                .text = "";
                                            viewModel
                                                .numberOfDosesPerDayController
                                                .text = "";
                                            // Reset this shared controller to a sensible default for "By Day" mode
                                            viewModel
                                                .numberOfDosesController
                                                .text = "1";
                                          }
                                          viewModel
                                              .frequencyTakenController
                                              .text = "By Day";
                                          viewModel.recalculateRefillDate();
                                        },
                                      ),
                                      SizedBox(height: 8),
                                      components.FrequencyOption(
                                        label: "By Hour",
                                        isSelected:
                                            viewModel
                                                .frequencyTakenController
                                                .text ==
                                            "By Hour",
                                        onPressed: () {
                                          if (viewModel
                                                  .frequencyTakenController
                                                  .text !=
                                              "By Hour") {
                                            viewModel
                                                .numberOfDosesController
                                                .text = "";
                                            viewModel
                                                .hourlyFrequencyController
                                                .text = "";
                                            viewModel
                                                .numberOfDosesPerDayController
                                                .text = "";
                                          }
                                          viewModel
                                              .frequencyTakenController
                                              .text = "By Hour";
                                          viewModel.recalculateRefillDate();
                                        },
                                      ),
                                      components.FrequencyOption(
                                        label: "As needed",
                                        isSelected:
                                            viewModel
                                                .frequencyTakenController
                                                .text ==
                                            "As needed",
                                        onPressed: () {
                                          viewModel
                                              .frequencyTakenController
                                              .text = "As needed";
                                          viewModel.recalculateRefillDate();
                                        },
                                      ),
                                    ],
                                  ),

                                  // Daily Frequency
                                  if (viewModel.frequencyTakenController.text ==
                                      "By Day")
                                    Column(
                                      children: [
                                        SizedBox(height: 8),
                                        components.MedicationFormField(
                                          label: "Number of Doses",
                                          icon: Icons.numbers,
                                          controller:
                                              viewModel.numberOfDosesController,
                                          keyboardType: TextInputType.number,
                                          validator:
                                              (value) =>
                                                  value == null || value.isEmpty
                                                      ? 'Required'
                                                      : null,
                                        ),
                                      ],
                                    ),
                                  // Hourly frequency fields - convert all to MedicationFormField
                                  if (viewModel.frequencyTakenController.text ==
                                      "By Hour")
                                    Column(
                                      children: [
                                        SizedBox(height: 8),
                                        components.MedicationFormField(
                                          label: "Number of doses",
                                          icon: Icons.numbers,
                                          controller:
                                              viewModel.numberOfDosesController,
                                          keyboardType: TextInputType.number,
                                          validator:
                                              (value) =>
                                                  value == null || value.isEmpty
                                                      ? 'Required'
                                                      : null,
                                        ),
                                        components.MedicationFormField(
                                          label: "Every X hours",
                                          icon: Icons.numbers,
                                          controller:
                                              viewModel
                                                  .hourlyFrequencyController,
                                          keyboardType: TextInputType.number,
                                          validator:
                                              (value) =>
                                                  value == null || value.isEmpty
                                                      ? 'Required'
                                                      : null,
                                        ),
                                        components.MedicationFormField(
                                          label: "X times a day",
                                          icon: Icons.numbers,
                                          controller:
                                              viewModel
                                                  .numberOfDosesPerDayController,
                                          keyboardType: TextInputType.number,
                                          validator:
                                              (value) =>
                                                  value == null || value.isEmpty
                                                      ? 'Required'
                                                      : null,
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                            SizedBox(height: 16),

                            // Start Date
                            InkWell(
                              onTap: () => viewModel.selectStartDate(context),
                              child: InputDecorator(
                                decoration: InputDecoration(
                                  labelText: "Start Date",
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.calendar_today),
                                ),
                                child: Text(
                                  _formatDate(viewModel.selectedStartDate),
                                ),
                              ),
                            ),
                            SizedBox(height: 16),

                            // Refill Date
                            // Replace the Refill Date InkWell with a non-tappable InputDecorator
                            // If the frequency is "As needed", allow them to select a refill date
                            // If the frequency is "By Day" or "By Hour", calculate the refill date
                            if (viewModel.frequencyTakenController.text ==
                                "As needed")
                              InkWell(
                                onTap:
                                    () => viewModel.selectRefillDate(context),
                                child: InputDecorator(
                                  decoration: InputDecoration(
                                    labelText: "Refill Date",
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.refresh),
                                  ),
                                  child: Text(
                                    viewModel.selectedRefillDate != null
                                        ? _formatDate(
                                          viewModel.selectedRefillDate!,
                                        )
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
                                      viewModel.selectedRefillDate != null
                                          ? _formatDate(
                                            viewModel.selectedRefillDate!,
                                          )
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
                              onTap: () => viewModel.selectTime(context),
                              child: InputDecorator(
                                decoration: InputDecoration(
                                  labelText: "Time",
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.access_time),
                                ),
                                child: Text(
                                  viewModel.selectedTime.format(context),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Confirm Button - Outside scrollview to stay fixed at bottom
          // Update your Confirm Button:
          MyConfirmationButton(
            text: 'Schedule Medication',
            actionIcon: Icons.add,
            actionOnPressed: () {
              // Check and debug the issue
              try {
                viewModel.confirmMedicationSchedule(
                  onMedicationScheduleConfirmed,
                );
              } catch (e) {
                // Show error in UI rather than just console
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            backgroundColor: AppColors.getItGreen,
            textColor: AppColors.white,
          ),
        ],
      ),
    );
  }
}
