import 'package:flutter/material.dart';
import 'package:medication_management_module/ui/listing/view/list_todays_medication.dart';
import 'package:my_flutter_app/screens/user_profile_screen.dart';
import '/src/theme.dart';

/// Main page of the application
class TodaysMeds extends StatefulWidget {
  final String title;

  const TodaysMeds({super.key, required this.title});

  @override
  State<TodaysMeds> createState() => _TodaysMedsState();
}

/// State for the main page
class _TodaysMedsState extends State<TodaysMeds> {
  int _totalMedications = 0;

  /// Updates the medication count from child widgets
  void _handleMedicationCountChanged(int count) {
    // Use a post-frame callback to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _totalMedications = count;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Remove the back arrow
        backgroundColor: AppColors.white,
        title: Text(
          widget.title,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        actions: [
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UserProfileScreen()),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(8.0),
              margin: const EdgeInsets.only(right: 16.0),
              decoration: const BoxDecoration(
                color: AppColors.deepBlues,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person, color: Colors.white, size: 24.0),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: 20),

              // User greeting and profile
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        "Hi *USER NAME*, you have $_totalMedications medication(s) remaining today.",
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              ListTodaysMedicationWidget(
                onMedicationCountChanged: _handleMedicationCountChanged,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
