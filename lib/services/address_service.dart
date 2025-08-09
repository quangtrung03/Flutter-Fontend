import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/address_model.dart';

class AddressService {
  final String baseUrl = AppConfig.address;

  Future<List<Address>> fetchAddresses(String userId) async {
    final response = await http.get(Uri.parse('$baseUrl/$userId'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true && data['data'] is List) {
        return (data['data'] as List).map((e) => Address.fromJson(e)).toList();
      } else {
        throw Exception('Invalid response format');
      }
    } else {
      throw Exception('Failed to load addresses');
    }
  }

  Future<bool> addAddress(Address address) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(address.toJson()),
    );
    return response.statusCode == 201;
  }

  Future<bool> updateAddress(Address address) async {
    final response = await http.put(
      Uri.parse('$baseUrl/${address.userId}/${address.id}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(address.toJson()),
    );
    return response.statusCode == 200;
  }

  Future<bool> deleteAddress(String userId, String addressId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/$userId/$addressId'),
      headers: {'Content-Type': 'application/json'},
    );
    return response.statusCode == 200;
  }
} 