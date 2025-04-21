import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart'
    hide EmailAuthProvider, PhoneAuthProvider;
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '/src/theme.dart';
import '/app_state.dart';
import 'package:medication_management_module/repositories/sqlite_profile_local_repository.dart'
    as sqlite_user_profile;
import 'package:medication_management_module/models/profile_model.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:medication_management_module/ui/Listing/view/medication_management_view.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final sqlite_user_profile.SQLiteProfileLocalRepository _profileRepository =
      sqlite_user_profile.SQLiteProfileLocalRepository();
  UserProfile? _userProfile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Fetch profiles from the database
      final profiles = await _profileRepository.fetchProfiles();

      if (kDebugMode) {
        print('Found ${profiles.length} profiles in database');
        for (var profile in profiles) {
          print(
            'Profile: ${profile.email}, First Name: "${profile.firstName}", Last Name: "${profile.lastName}", Doctor: "${profile.doctorName}"',
          );
        }
      }

      // Assuming the logged-in user's email is used to identify the profile
      final email = FirebaseAuth.instance.currentUser?.email;
      if (kDebugMode) {
        print('Current user email: $email');
      }

      if (email != null) {
        try {
          _userProfile = profiles.firstWhere(
            (profile) => profile.email == email,
          );

          if (kDebugMode) {
            print('Found matching profile with email: $email');
            print(
              'Profile details: First Name: "${_userProfile!.firstName}", Last Name: "${_userProfile!.lastName}", Doctor: "${_userProfile!.doctorName}"',
            );
          }

          // Initialize controllers with existing data
          _firstNameController.text = _userProfile!.firstName;
          _lastNameController.text = _userProfile!.lastName;
          _doctorController.text = _userProfile!.doctorName;
          _doctorPhoneController.text = _userProfile!.doctorPhone;
        } catch (e) {
          if (kDebugMode) {
            print('No matching profile found for email: $email');
          }
          _userProfile = UserProfile(
            email: email,
            firstName: '',
            lastName: '',
            doctorName: '',
            doctorPhone: '',
          );
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading user profile: $e');
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveUserProfile() async {
    try {
      if (kDebugMode) {
        print('Saving profile...');
      }

      String email = FirebaseAuth.instance.currentUser?.email ?? '';

      // Create/update the profile with form values
      UserProfile updatedProfile = UserProfile(
        email: email,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        doctorName: _doctorController.text.trim(),
        doctorPhone: _doctorPhoneController.text.trim(),
      );

      if (_userProfile != null && _userProfile!.email.isNotEmpty) {
        // Update existing profile
        if (kDebugMode) {
          print('Updating existing profile for: $email');
        }
        await _profileRepository.updateProfile(updatedProfile);
      } else {
        // Add new profile
        if (kDebugMode) {
          print('Adding new profile for: $email');
        }
        await _profileRepository.addProfile(updatedProfile);
      }

      // Update the local _userProfile object with the new values
      setState(() {
        _userProfile = updatedProfile;
      });

      // Show success message
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile saved successfully')),
      );

      // Reload profile from database to confirm changes
      _loadUserProfile();
    } catch (e) {
      if (kDebugMode) {
        print('Error saving profile: $e');
      }
      // Show error message
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error saving profile: $e')));
    }
  }

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _doctorController = TextEditingController();
  final TextEditingController _doctorPhoneController = TextEditingController();

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
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Logout'),
                        content: const Text('Are you sure you want to logout?'),
                        actions: [
                          TextButton(
                            child: const Text('Cancel'),
                            onPressed: () {
                              Navigator.of(context).pop(); // Close the dialog
                            },
                          ),
                          TextButton(
                            child: const Text('Logout'),
                            onPressed: () {
                              FirebaseAuth.instance.signOut();
                              Navigator.of(context).pop(); // Close the dialog
                              context.go('/home');
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
              );
            },
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_userProfile != null &&
                        _userProfile!.firstName.isNotEmpty &&
                        _userProfile!.lastName.isNotEmpty &&
                        _userProfile!.doctorName.isNotEmpty) ...[
                      // Display existing profile information as read-only text
                      const Text(
                        'Profile Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildProfileInfoItem(
                        'First Name',
                        _userProfile!.firstName,
                      ),
                      _buildProfileInfoItem(
                        'Last Name',
                        _userProfile!.lastName,
                      ),
                      _buildProfileInfoItem('Doctor', _userProfile!.doctorName),
                      _buildPhoneNumberItem(
                        'Doctor Phone',
                        _userProfile!.doctorPhone,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          // Allow editing
                          setState(() {
                            _firstNameController.text = _userProfile!.firstName;
                            _lastNameController.text = _userProfile!.lastName;
                            _doctorController.text = _userProfile!.doctorName;
                            _doctorPhoneController.text =
                                _userProfile!.doctorPhone;

                            // Create a "dummy" empty profile to trigger the edit mode
                            _userProfile = UserProfile(
                              email: _userProfile!.email,
                              firstName: '',
                              lastName: '',
                              doctorName: '',
                              doctorPhone: '',
                            );
                          });
                        },
                        child: const Text('Edit Profile'),
                      ),
                    ] else ...[
                      // Show instructions and editable fields
                      if (_userProfile != null) ...[
                        const Text(
                          'Please complete your profile information below:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ] else ...[
                        const Text(
                          'No profile found. Please create one:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _firstNameController,
                        decoration: const InputDecoration(
                          labelText: 'First Name',
                        ),
                      ),
                      TextFormField(
                        controller: _lastNameController,
                        decoration: const InputDecoration(
                          labelText: 'Last Name',
                        ),
                      ),
                      TextFormField(
                        controller: _doctorController,
                        decoration: const InputDecoration(
                          labelText: 'Doctor Name',
                        ),
                      ),
                      TextFormField(
                        controller: _doctorPhoneController,
                        decoration: const InputDecoration(
                          labelText: 'Doctor Phone',
                        ),
                        keyboardType: TextInputType.phone, // Phone keyboard
                      ),

                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _saveUserProfile,
                        child: Text(
                          _userProfile != null && _userProfile!.email.isNotEmpty
                              ? 'Update Profile'
                              : 'Save Profile',
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    MedicationModuleWidget(),
                  ],
                ),
              ),
    );
  }

  // Helper method to display profile info items
  Widget _buildProfileInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const Divider(),
        ],
      ),
    );
  }

  Widget _buildPhoneNumberItem(String label, String phoneNumber) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
          const SizedBox(height: 4),
          InkWell(
            onTap: () => _callDoctor(phoneNumber),
            child: Row(
              children: [
                Text(
                  phoneNumber,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.blue, // Make it look clickable
                    decoration: TextDecoration.underline,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.phone, size: 16, color: Colors.blue),
              ],
            ),
          ),
          const Divider(),
        ],
      ),
    );
  }

  // Method to call the doctor
  void _callDoctor(String phoneNumber) {
    if (phoneNumber.isEmpty) return;

    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Call Doctor'),
          content: Text('Do you want to call your doctor at $phoneNumber?'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Call'),
              onPressed: () {
                Navigator.of(context).pop();
                _launchPhoneCall(phoneNumber);
              },
            ),
          ],
        );
      },
    );
  }

  // Launch phone call
  void _launchPhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    try {
      await launchUrl(phoneUri);
    } catch (e) {
      if (kDebugMode) {
        print('Could not launch phone call: $e');
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch phone call')),
      );
    }
  }
}
// import 'package:flutter/material.dart';