import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/search_medication_view_model.dart' as view_model;

class MedicationSearchWidget extends StatelessWidget {
  // Callback function for when medication is selected
  final Function(Map<dynamic, dynamic>)? onMedicationSelected;

  const MedicationSearchWidget({super.key, this.onMedicationSelected});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create:
          (_) => view_model.MedicationSearchViewModel(
            onMedicationSelected: onMedicationSelected,
          ),
      child: _MedicationSearchView(),
    );
  }
}

class _MedicationSearchView extends StatelessWidget {
  // Notifies listeners when selected medication changes
  final ValueNotifier<dynamic> selectedMedicationNotifier =
      ValueNotifier<dynamic>(null);

  // Constructor with no parameters
  _MedicationSearchView();

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<view_model.MedicationSearchViewModel>(
      context,
    );
    // Column layout for search box and results
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: viewModel.searchController,
              decoration: InputDecoration(
                labelText: 'Search Medications',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
                // Conditional clear button
                suffixIcon:
                    viewModel.searchController.text.isNotEmpty
                        ? IconButton(
                          icon: Icon(Icons.clear),
                          onPressed: () {
                            viewModel.searchController.clear();
                            viewModel.searchResults = [];
                          },
                        )
                        : null,
              ),
            ),
          ),

          // Show loading indicator or results list
          // LEARN: Conditional rendering based on state
          viewModel.isLoading
              ? CircularProgressIndicator() // Loading state
              : Expanded(
                // LEARN: ListView.builder creates items only when visible (performance optimization)
                child: ListView.builder(
                  itemCount: viewModel.searchResults.length,
                  itemBuilder: (context, index) {
                    final medicationResults = viewModel.searchResults[index];
                    // Extract data with null safety using ?. operator
                    final brandName =
                        medicationResults['openfda']?['brand_name']?[0] ??
                        'Unknown';

                    final genericName =
                        medicationResults['openfda']?['generic_name']?[0] ??
                        'Unknown';

                    return ListTile(
                      title: Text(brandName),
                      subtitle: Text(genericName),
                      onTap: () {
                        // Handle selection and pass to parent
                        // How do I pass this value to the scheduleing screen?
                        viewModel.selectedMedication(brandName, genericName);
                      },
                    );
                  },
                ),
              ),
        ],
      ),
    );
  }
}
