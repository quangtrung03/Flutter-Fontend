import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/support_request_model.dart';

class SupportRequestService {
  final String baseUrl = AppConfig.supportRequest;

  Future<bool> sendRequest(SupportRequest request) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(request.toJson()),
    );
    return response.statusCode == 201;
  }

  Future<List<SupportRequest>> fetchRequests() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((e) => SupportRequest.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load support requests');
    }
  }
} 