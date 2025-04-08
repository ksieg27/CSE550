import 'package:flutter/material.dart';
import 'package:medication_management_module/services/notifications_service.dart';
import 'package:medication_management_module/ui/Listing/view/medication_management_view.dart';
import 'package:my_flutter_app/screens/user_profile_screen.dart';
import '/src/theme.dart';

/// Application-wide color scheme moved to src/theme.dart for imports
// class AppColors {
//   static const Color offBlue = Color(0xFFE0F7FA);
//   static const Color deepBlues = Color(0xFF2C3E50);
//   static const Color getItGreen = Color(0xFF76C7C0);
//   static const Color urgentOrange = Color(0xFFF4A261);
//   static const Color white = Color(0xFFFFFFFF);

//   // Private constructor to prevent instantiation
//   AppColors._();
// }

/// Main page of the application
class MedManage extends StatefulWidget {
  final String title;

  const MedManage({super.key, required this.title});

  @override
  State<MedManage> createState() => _MedManageState();
}

/// State for the main page
class _MedManageState extends State<MedManage> {
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
        backgroundColor: AppColors.white,
        title: Text(
          widget.title,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
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
                        "Hi, John, you have $_totalMedications medication(s) scheduled today",
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UserProfileScreen(),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: const BoxDecoration(
                          color: AppColors.deepBlues,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 24.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Medication management module
              MedicationModuleWidget(
                onMedicationCountChanged: _handleMedicationCountChanged,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
