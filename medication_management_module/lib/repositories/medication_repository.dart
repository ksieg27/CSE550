import '../models/medication.dart';

abstract class MedicationRepository {
  Future<void> addMedication(MyMedication medication);
  Future<List<MyMedication>> fetchMedications();
  Future<void> updateMedication(MyMedication medication);
  Future<void> deleteMedication(int id);
}
