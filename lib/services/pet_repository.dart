import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/pet_state.dart';

class PetProfile {
  const PetProfile(this.name, this.history);
  final String name;
  final List<String> history;
}

class PetRepository {
  static const key = 'pet_state_v1';
  static const snapshotKey = 'pet_snapshot_v2';
  Future<Map<String, dynamic>?> _snapshot() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      final raw = prefs.getString(snapshotKey);
      if (raw == null) return null;
      final result = jsonDecode(raw) as Map<String, dynamic>;
      if (result['version'] != 2) return null;
      PetState.fromJson(result['pet'] as Map<String, dynamic>);
      return result;
    } catch (_) {
      return null;
    }
  }

  Future<PetState> load() async {
    final snapshot = await _snapshot();
    if (snapshot != null) {
      return PetState.fromJson(snapshot['pet'] as Map<String, dynamic>);
    }
    final prefs = await SharedPreferences.getInstance();
    try {
      final raw = prefs.getString(key);
      if (raw != null) {
        return PetState.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      }
    } catch (_) {
      // Invalid or old saves recover to a playable pet.
    }
    return PetState.initial(DateTime.now().toUtc());
  }

  Future<PetProfile> loadProfile() async {
    final snapshot = await _snapshot();
    final name = snapshot?['name'];
    final history = snapshot?['history'];
    return PetProfile(
      name is String && name.runes.length <= 12 ? name : '',
      history is List ? history.whereType<String>().take(30).toList() : [],
    );
  }

  Future<void> save(PetState state) async {
    final profile = await loadProfile();
    await saveSnapshot(state, profile);
  }

  Future<void> saveSnapshot(PetState state, PetProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    final success = await prefs.setString(
        snapshotKey,
        jsonEncode({
          'version': 2,
          'pet': state.toJson(),
          'name': profile.name,
          'history': profile.history.take(30).toList(),
        }));
    if (!success) throw StateError('Local save failed');
    // Remove legacy personal data after successful migration or reset.
    await prefs.remove(key);
  }
}
