import 'package:http/http.dart' as http; // HTTP client for API requests
import 'dart:convert'; // For JSON parsing

  Future<List<dynamic>> searchMedication(String query) async {
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