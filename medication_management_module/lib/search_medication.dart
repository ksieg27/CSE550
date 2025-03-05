import 'package:http/http.dart' as http; // HTTP client for API requests
import 'package:flutter/material.dart';
import 'dart:convert'; // For JSON parsing
import 'dart:async'; // For Timer functionality

// Stateful widget for medication search UI
// LEARN: Custom widgets should focus on a single responsibility
class MedicationSearchWidget extends StatefulWidget {
  // Callback function for when medication is selected
  // LEARN: Function parameters allow parent widgets to respond to child events
  final Function(Map<dynamic, dynamic>)? onMedicationSelected;

  const MedicationSearchWidget({super.key, this.onMedicationSelected});

  @override
  _MedicationSearchWidgetState createState() => _MedicationSearchWidgetState();
}

// API function to search for medications
// LEARN: Async functions return Future objects for non-blocking operations
Future<List<dynamic>> searchMedications(String query) async {
  if (query.isEmpty) return [];

  try {
    // URL-encode the query parameter
    final encodedQuery = Uri.encodeComponent(query);
    final url = Uri.parse(
      // FDA API endpoint with wildcard search
      'https://api.fda.gov/drug/drugsfda.json?search=openfda.brand_name:"$encodedQuery*"&limit=10',
    );

    final response = await http.get(url); // Non-blocking API call

    if (response.statusCode == 200) {
      final data = json.decode(response.body); // Parse JSON response
      return data['results'] ?? []; // Return results or empty list
    } else {
      print('Error: ${response.statusCode}');
      return [];
    }
  } catch (e) {
    print('Exception during API call: $e'); // Error handling
    return [];
  }
}

class _MedicationSearchWidgetState extends State<MedicationSearchWidget> {
  // Controller for the text input field
  final TextEditingController _searchController = TextEditingController();
  // Notifies listeners when selected medication changes
  final ValueNotifier<dynamic> selectedMedicationNotifier =
      ValueNotifier<dynamic>(null);

  Timer? _debounceTimer; // Controls API call frequency
  String _debouncedSearch = ''; // Stores the search text after debounce
  List<dynamic> _searchResults = []; // Stores API results
  bool _isLoading = false; // Tracks loading state for UI feedback

  @override
  void initState() {
    super.initState();
    // LEARN: Listeners should be attached in initState and detached in dispose
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    // Clean up resources to prevent memory leaks
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  // Debounce mechanism to prevent excessive API calls while typing
  // LEARN: Debouncing is important for performance with search-as-you-type
  void _onSearchChanged() {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();

    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (_debouncedSearch != _searchController.text) {
        setState(() {
          _debouncedSearch = _searchController.text;
          // Only search if minimum 3 characters entered
          if (_searchController.text.length >= 3) {
            _performSearch();
          } else {
            _searchResults = [];
          }
        });
      }
    });
  }

  // Handler for when user selects a medication
  // LEARN: Callback pattern for child-to-parent communication
  void selectedMedication(String brandMedication, String genericMedication) {
    final medication = {
      'brand_name': brandMedication,
      'generic_name': genericMedication,
    };

    selectedMedicationNotifier.value = medication;

    // Call the callback if provided
    if (widget.onMedicationSelected != null) {
      widget.onMedicationSelected!(medication);
    }
  }

  // Executes the API search and updates state
  // LEARN: Async/await with setState for UI updates after API calls
  Future<void> _performSearch() async {
    if (_debouncedSearch.isEmpty) {
      setState(() {
        _searchResults = [];
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true; // Show loading indicator
    });

    final results = await searchMedications(_debouncedSearch);

    setState(() {
      _searchResults = results; // Update with API results
      _isLoading = false; // Hide loading indicator
    });
  }

  @override
  Widget build(BuildContext context) {
    // Column layout for search box and results
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'Search Medications',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
              filled: true,
              fillColor: Colors.white,
              // Conditional clear button
              suffixIcon:
                  _searchController.text.isNotEmpty
                      ? IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchResults = [];
                          });
                        },
                      )
                      : null,
            ),
          ),
        ),

        // Show loading indicator or results list
        // LEARN: Conditional rendering based on state
        _isLoading
            ? CircularProgressIndicator() // Loading state
            : Expanded(
              // LEARN: ListView.builder creates items only when visible (performance optimization)
              child: ListView.builder(
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  final medication = _searchResults[index];
                  // Extract data with null safety using ?. operator
                  final brandName =
                      medication['openfda']?['brand_name']?[0] ?? 'Unknown';
                  final genericName =
                      medication['openfda']?['generic_name']?[0] ?? 'Unknown';

                  return ListTile(
                    title: Text(brandName),
                    subtitle: Text(genericName),
                    onTap: () {
                      // Handle selection and pass to parent
                      selectedMedication(brandName, genericName);
                    },
                  );
                },
              ),
            ),
      ],
    );
  }
}
