import 'package:firebase_auth/firebase_auth.dart'
    hide EmailAuthProvider, PhoneAuthProvider;
import 'package:flutter/material.dart';
import 'package:medication_management_module/ui/Listing/view/medication_management_view.dart';
import 'package:my_flutter_app/screens/user_profile_screen.dart';
import 'package:provider/provider.dart';
import '/src/theme.dart';
import '/app_state.dart';

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
        automaticallyImplyLeading: false, // Remove the back arrow
        backgroundColor: AppColors.white,
        title: Text(
          widget.title,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        actions: [
          Consumer<ApplicationState>(
            builder: (context, appState, _) {
              if (appState.loggedIn) {
                return IconButton(
                  icon: const Icon(Icons.logout),
                  tooltip: 'Logout',
                  onPressed: () {
                    FirebaseAuth.instance.signOut();
                    Navigator.pushReplacementNamed(context, '/');
                  },
                );
              }
              return const SizedBox.shrink(); // No button if not logged in
            },
          )
        ]
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
