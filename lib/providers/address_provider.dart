import 'package:flutter/material.dart';
import '../models/address_model.dart';
import '../services/address_service.dart';

class AddressProvider with ChangeNotifier {
  List<Address> _addresses = [];
  bool _isLoading = false;
  String? _error;

  List<Address> get addresses => _addresses;
  bool get isLoading => _isLoading;
  String? get error => _error;

  final AddressService _addressService = AddressService();

  Future<void> fetchAddresses(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _addresses = await _addressService.fetchAddresses(userId);
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addAddress(Address address) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final result = await _addressService.addAddress(address);
      if (result) {
        await fetchAddresses(address.userId);
      }
      _isLoading = false;
      notifyListeners();
      return result;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateAddress(Address address) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final result = await _addressService.updateAddress(address);
      if (result) {
        await fetchAddresses(address.userId);
      }
      _isLoading = false;
      notifyListeners();
      return result;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteAddress(String userId, String addressId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final result = await _addressService.deleteAddress(userId, addressId);
      if (result) {
        await fetchAddresses(userId);
      }
      _isLoading = false;
      notifyListeners();
      return result;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
} 