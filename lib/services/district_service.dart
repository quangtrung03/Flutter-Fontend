import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/district_model.dart';

class DistrictService {
  static Future<List<District>> loadDistricts() async {
    final String jsonString = await rootBundle.loadString('assets/data/hcmc-districts.json');
    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((e) => District.fromJson(e)).toList();
  }
} 