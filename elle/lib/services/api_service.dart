import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/cycle_model.dart';

class ApiService {
  static String get baseUrl {
    return 'http://192.168.11.101:8000'; // Physical device and emulator
  }

  static Future<CycleModel> createCycle(CycleCreate cycleCreate) async {
    final response = await http.post(
      Uri.parse('$baseUrl/cycles/'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(cycleCreate.toJson()),
    );

    if (response.statusCode == 200) {
      return CycleModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Échec de la création du cycle: ${response.body}');
    }
  }

  static Future<CycleCalculations> getCycleData(int userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/cycles/$userId'),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return CycleCalculations.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Échec de la récupération des données du cycle: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> toggleIntercourse(
      int userId, IntercourseToggle intercourseToggle) async {
    final response = await http.post(
      Uri.parse('$baseUrl/cycles/$userId/intercourse'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(intercourseToggle.toJson()),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Échec de la mise à jour du rapport: ${response.body}');
    }
  }

  static Future<List<CycleModel>> getAllCycles(int userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/cycles/$userId/all'),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((cycle) => CycleModel.fromJson(cycle)).toList();
    } else {
      throw Exception('Échec de la récupération des cycles: ${response.body}');
    }
  }
}