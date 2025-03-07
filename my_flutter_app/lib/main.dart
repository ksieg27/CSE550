import 'package:medication_management_module/medication_management_module.dart'; // Import the module
import 'package:flutter/material.dart';

// Define a library of colors for easy reference
class AppColors {
  static const Color offBlue = Color(0xFFE0F7FA);
  static const Color deepBlues = Color(0xFF2C3E50);
  static const Color getItGreen = Color(0xFF76C7C0);
  static const Color urgentOrange = Color(0xFFF4A261);
  static const Color white = Color(0xFFFFFFFF);
  // Add more colors as needed
}

// Main entry point for the application
// LEARN: Flutter uses a single main() function as the application entry point
void main() {
  runApp(
    const MyApp(),
  ); // runApp inflates the widget tree and attaches it to the screen
}

// Root widget that configures the overall app theme and initial route
// LEARN: StatelessWidget is used for UI components that don't change state internally
class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
  }); // Constructor with const for widget caching optimization

  //
  @override
  Widget build(BuildContext context) {
    // MaterialApp provides the foundation for material design and navigation
    return MaterialApp(
      title: 'Medication Tracker', // App name shown in task switchers
      theme: ThemeData(
        textTheme: TextTheme(
          headlineMedium: TextStyle(
            fontFamily: 'Inter',
            fontSize: 32.0,
            fontWeight: FontWeight.bold,
            color: AppColors.deepBlues,
            decoration: TextDecoration.underline,
            decorationColor: AppColors.deepBlues,
          ),
          bodyMedium: TextStyle(
            fontFamily: 'Inter',
            fontSize: 18.0,
            color: AppColors.deepBlues,
          ),
        ),
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF2C3E50)),
      ),
      home: const MyHomePage(title: 'Medication Tracker'), // Initial route
    );
  }
}

// Primary screen widget that can maintain state
// LEARN: StatefulWidget separates widget configuration from mutable state
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title; // Immutable configuration parameter

  @override
  // Creates the mutable state associated with this widget
  State<MyHomePage> createState() => _MyHomePageState();
}

// Implementation of the MyHomePage widget's state and UI
// LEARN: State objects contain mutable data that can change during widget lifetime
class _MyHomePageState extends State<MyHomePage> {
  int _totalMedications = 0; // Private mutable state variable

  @override
  Widget build(BuildContext context) {
    // Scaffold implements the basic material design layout structure
    return Scaffold(
      // App header with title
      appBar: AppBar(
        // Uses theme colors for consistent appearance
        backgroundColor: AppColors.white,
        title: Text(
          widget.title,
          style: Theme.of(context).textTheme.headlineMedium,
        ), // Accesses parent widget's immutable properties with 'widget.'
      ),

      // Main content area with counter and medication module
      body: Center(
        child: Column(
          // Aligns children at the top of the available space
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: 20), // Optional top padding
            Text(
              "Hi John, You have $_totalMedications medication(s) scheduled today",
            ),
            const SizedBox(height: 20),

            // Integration point for Medication Management Module
            // LEARN: This demonstrates modular architecture with external packages
            // LEARN: The module is a self-contained widget that can be reused in other apps
            MedicationModuleWidget(
              onMedicationCountChanged: (count) {
                setState(() {
                  _totalMedications = count;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
