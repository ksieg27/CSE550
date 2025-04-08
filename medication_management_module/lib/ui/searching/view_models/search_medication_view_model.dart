import 'package:flutter/cupertino.dart';
import 'dart:async'; // For Timer functionality
import '../../../services/search_openfda_api.dart'
    as search; // Import the API service

class MedicationSearchViewModel extends ChangeNotifier {
  final Function(Map<dynamic, dynamic>)? onMedicationSelected;

  final TextEditingController searchController = TextEditingController();

  Timer? _debounceTimer;
  String debouncedSearch = '';
  List<dynamic> _searchResults = [];
  bool _isLoading = false;

  // Getters
  List<dynamic> get searchResults => _searchResults;
  bool get isLoading => _isLoading;

  // Setter with notification
  set searchResults(List<dynamic> results) {
    _searchResults = results;
    notifyListeners();
  }

  MedicationSearchViewModel({this.onMedicationSelected}) {
    searchController.addListener(_onSearchChanged);
  }

  final ValueNotifier<dynamic> selectedMedicationNotifier =
      ValueNotifier<dynamic>(null);

  void _onSearchChanged() {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();

    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (debouncedSearch != searchController.text) {
        debouncedSearch = searchController.text;
        // Only search if minimum 2 characters entered
        if (searchController.text.length >= 2) {
          searchMedications(searchController.text);
        } else if (searchController.text.isEmpty) {
          searchResults = [];
        }
      }
    });
  }

  void selectedMedication(String brandMedication, String genericMedication) {
    final medication = {
      'brand_name': brandMedication,
      'generic_name': genericMedication,
    };

    selectedMedicationNotifier.value = medication;

    // Call the callback if provided
    if (onMedicationSelected != null) {
      onMedicationSelected!(medication);
    }
  }

  Future<void> searchMedications(String query) async {
    if (query.isEmpty) {
      searchResults = [];
      return;
    }

    _isLoading = true;
    notifyListeners(); // Notify UI to show loading state

    try {
      final results = await search.searchMedications(query);
      _searchResults = results; // Update with API results
    } catch (e) {
      print('Error during medication search: $e');
      _searchResults = []; // Clear results on error
    } finally {
      _isLoading = false; // Hide loading indicator
      notifyListeners(); // Notify UI to update with results
    }
  }

  @override
  void dispose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }
}
