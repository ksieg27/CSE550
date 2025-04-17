class UserProfile {
  // Add ID field
  final String firstName;
  final String lastName;
  // Have the email be the main ID for tracking medicine for a user.
  // If it is a sub profile, then the email will be the main profile's email + sub profile name
  final String email;

  // Static counter for ID generation
  UserProfile({
    required this.firstName,
    required this.lastName,
    required this.email,
  });

  Map<String, dynamic> toMap() => {
    'email': email,
    'firstName': firstName,
    'lastName': lastName,
  };

  factory UserProfile.fromMap(Map<dynamic, dynamic> map) => UserProfile(
    email: map['eail'],
    firstName: map['firstName'] ?? '',
    lastName: map['lastName'] ?? '',
  );
}
