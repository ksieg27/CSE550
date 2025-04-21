import '../models/profile_model.dart';

abstract class ProfileLocalRepository {
  Future<void> addProfile(UserProfile profile);
  Future<List<UserProfile>> fetchProfiles();
  Future<void> updateProfile(UserProfile profile);
  Future<void> deleteProfile(UserProfile profile);
}
