
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medication_management_module/models/medication_form_data.dart';

void main(){
  test('MedicationFormData intialization with required fields', () {
    final medicationData = MedicationFormData(
      brandName: 'BrandX',
      genericName: 'GenericY',
      startDate: DateTime.now(),
      time: TimeOfDay.now(),
    );

    expect(medicationData.brandName, 'BrandX');
    expect(medicationData.genericName, 'GenericY');
    expect(medicationData.startDate, isA<DateTime>());
    expect(medicationData.time, isA<TimeOfDay>());
    expect(medicationData.profile, 'Default');
    expect(medicationData.quantity, 1);
  });

  test('MedicationFormData validation detects missing required fields', () {
    final medicationData = MedicationFormData(
      brandName: 'BrandX',
      genericName: 'GenericY',
      startDate: DateTime.now(),
      time: TimeOfDay.now(),
    );
  
    // Validate with missing profile and dosage
    medicationData.profile = '';
    medicationData.dosage = '';

    final isValid = medicationData.validate();

    expect(isValid, false);
    expect(medicationData.errors['profile'], 'Profile is required');
    expect(medicationData.errors['dosage'], 'Dosage is required');
  });
}