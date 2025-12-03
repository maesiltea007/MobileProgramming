import 'package:hive_flutter/hive_flutter.dart';
import '../models/design.dart';

class DesignRepository {
  static final _box = Hive.box('designsbox');

  static Box get box => _box;

  static void save(String id, Design design) {
    _box.put(id, design.toMap());
  }

  static Design? get(String id) {
    final data = _box.get(id);
    if (data == null) return null;
    return Design.fromMap(Map<String, dynamic>.from(data));
  }

  static List<String> getAllIds() {
    return _box.keys.map((e) => e.toString()).toList();
  }
}
