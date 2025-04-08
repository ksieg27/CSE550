class MyMedication {
  // Add ID field
  final int? id;
  final String profile;
  final String brandName;
  final String genericName;
  int quantity;
  final int startDate;
  final String? refillDate;
  int time;
  final String dosage;
  final int? numberOfDoses;

  //Add a notes field when creating a medication
  final String? notes;
  final String? endDate;

  // Frequency
  final String? frequencyTaken;

  // Daily Frequency
  final int? numberOfDosesPerDay;

  // Hourly Frequency
  final int? hourlyFrequency;

  // Static counter for ID generation
  MyMedication({
    this.id,
    required this.profile,
    required this.brandName,
    required this.genericName,
    required this.quantity,
    required this.startDate,
    this.refillDate,
    required this.time,
    required this.dosage,
    this.numberOfDosesPerDay,
    this.frequencyTaken,
    this.hourlyFrequency,
    this.numberOfDoses,
    this.notes,
    this.endDate,
  });

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'profile': profile,
    'brandName': brandName,
    'genericName': genericName,
    'quantity': quantity,
    'startDate': startDate,
    'refillDate': refillDate,
    'time': time,
    'dosage': dosage,
    'numberOfDosesPerDay': numberOfDosesPerDay,
    'frequencyTaken': frequencyTaken,
    'hourlyFrequency': hourlyFrequency,
    'numberOfDoses': numberOfDoses,
    'notes': notes,
    'endDate': endDate,
  };

  factory MyMedication.fromMap(Map<dynamic, dynamic> map) => MyMedication(
    id: map['id'],
    profile: map['profile'] ?? '',
    brandName: map['brandName'] ?? map['brand_name'] ?? 'Unknown Brand',
    genericName: map['genericName'] ?? map['generic_name'] ?? 'Unknown Generic',
    quantity: map['quantity'] ?? 0,
    startDate: map['startDate'] ?? DateTime.now().millisecondsSinceEpoch,
    refillDate: map['refillDate'],
    time:
        map['time'] is String
            ? _parseTimeString(map['time'])
            : (map['time'] as int? ?? 0),
    dosage: map['dosage'] ?? '',

    // Add default values to these nullable fields:
    numberOfDosesPerDay: map['numberOfDosesPerDay'] as int? ?? 1,
    frequencyTaken: map['frequencyTaken'] as String? ?? 'Not Set',
    hourlyFrequency: map['hourlyFrequency'] as int? ?? 6,
    numberOfDoses: map['numberOfDoses'] as int? ?? 1,
    notes: map['notes'] as String? ?? '',
    endDate: map['endDate'] as String? ?? '',
  );

  // Existing helper method
  static int _parseTimeString(String? timeStr) {
    if (timeStr == null) return 0;
    try {
      final parts = timeStr.split(':');
      return int.parse(parts[0]) * 60 + int.parse(parts[1]);
    } catch (e) {
      return 0;
    }
  }
}
