import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'
    hide EmailAuthProvider, PhoneAuthProvider;
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '/src/theme.dart';
import '/app_state.dart';
import 'package:medication_management_module/ui/listing/view/medication_management_view.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
        backgroundColor: AppColors.white,
        actions: [
          Consumer<ApplicationState>(
            builder: (context, appState, _) {
                return IconButton(
                  icon: const Icon(Icons.logout),
                  tooltip: 'Logout',
                  onPressed: () {
                    FirebaseAuth.instance.signOut();
                    context.go(
                      '/home',
                    ); // Navigate to the home page using GoRouter
                  },
                );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(decoration: InputDecoration(labelText: 'First Name')),
            TextFormField(decoration: InputDecoration(labelText: 'Last Name')),
            TextFormField(decoration: InputDecoration(labelText: 'Doctor')),
            SizedBox(height: 16),
            MedicationModuleWidget(),
          ],
        ),
      ),
    );
  }
}

class Button extends StatelessWidget {
  const Button({super.key});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: () {
        print('Profile submitted!');
      },
      child: Text('Submit'),
    );
  }
}
