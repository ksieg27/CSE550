class UserProfile {
  // Add ID field
  final String firstName;
  final String lastName;
  // Have the email be the main ID for tracking medicine for a user.
  // If it is a sub profile, then the email will be the main profile's email + sub profile name
  final String email;
  String doctorName = '';
  String doctorPhone = '';

  UserProfile({
    required this.firstName,
    required this.lastName,
    required this.email,
    this.doctorName = '',
    this.doctorPhone = '',
  });

  Map<String, dynamic> toMap() => {
    'email': email,
    'firstName': firstName,
    'lastName': lastName,
    'doctorName': doctorName,
    'doctorPhone': doctorPhone,
  };

  factory UserProfile.fromMap(Map<dynamic, dynamic> map) => UserProfile(
    email: map['email'],
    firstName: map['firstName'] ?? '',
    lastName: map['lastName'] ?? '',
    doctorName: map['doctorName'] ?? '',
    doctorPhone: map['doctorPhone'] ?? '',
  );
}
