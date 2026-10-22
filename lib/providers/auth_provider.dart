import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_config.dart';
import '../models/employee_model.dart';

class AuthProvider with ChangeNotifier {
  String? _token;
  String? _userId;
  String? _userRole;
  String? _companyId;
  Employee? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  String? get token => _token;
  String? get userId => _userId;
  String? get userRole => _userRole;
  String? get companyId => _companyId;
  Employee? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _token != null;

  AuthProvider() {
    _loadFromStorage();
  }

  Future<void> _loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(AppConfig.userTokenKey);
    _userId = prefs.getString(AppConfig.userIdKey);
    _userRole = prefs.getString(AppConfig.userRoleKey);
    _companyId = prefs.getString(AppConfig.companyIdKey);
    notifyListeners();
  }

  Future<void> _saveToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    if (_token != null) {
      await prefs.setString(AppConfig.userTokenKey, _token!);
      await prefs.setString(AppConfig.userIdKey, _userId!);
      await prefs.setString(AppConfig.userRoleKey, _userRole!);
      if (_companyId != null) {
        await prefs.setString(AppConfig.companyIdKey, _companyId!);
      }
    } else {
      await prefs.remove(AppConfig.userTokenKey);
      await prefs.remove(AppConfig.userIdKey);
      await prefs.remove(AppConfig.userRoleKey);
      await prefs.remove(AppConfig.companyIdKey);
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));
      
      // In a real app, this would call your authentication API
      // For now, we'll use mock data
      if (email == 'admin@company.com' && password == 'admin123') {
        _token = 'mock_admin_token';
        _userId = 'admin_001';
        _userRole = AppConfig.roleAdmin;
        _companyId = 'company_001';
        _currentUser = Employee(
          id: 'admin_001',
          employeeId: 'ADMIN001',
          firstName: 'Admin',
          lastName: 'User',
          email: email,
          phone: '+1234567890',
          role: AppConfig.roleAdmin,
          department: 'Management',
          position: 'Administrator',
          hireDate: DateTime.now(),
          companyId: 'company_001',
          assignedLocationId: 'location_001',
          checkInTime: AppConfig.defaultCheckInTime,
          checkOutTime: AppConfig.defaultCheckOutTime,
        );
        await _saveToStorage();
        _isLoading = false;
        notifyListeners();
        return true;
      } else if (email == 'employee@company.com' && password == 'employee123') {
        _token = 'mock_employee_token';
        _userId = 'employee_001';
        _userRole = AppConfig.roleEmployee;
        _companyId = 'company_001';
        _currentUser = Employee(
          id: 'employee_001',
          employeeId: 'EMP001',
          firstName: 'John',
          lastName: 'Doe',
          email: email,
          phone: '+1234567891',
          role: AppConfig.roleEmployee,
          department: 'IT',
          position: 'Software Engineer',
          hireDate: DateTime.now(),
          companyId: 'company_001',
          assignedLocationId: 'location_001',
          checkInTime: AppConfig.defaultCheckInTime,
          checkOutTime: AppConfig.defaultCheckOutTime,
        );
        await _saveToStorage();
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Invalid email or password';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Login failed: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _token = null;
    _userId = null;
    _userRole = null;
    _companyId = null;
    _currentUser = null;
    await _saveToStorage();
    notifyListeners();
  }

  Future<bool> register(Employee employee, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 2));
      
      // In a real app, this would call your registration API
      // For now, we'll just simulate success
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Registration failed: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void setUser(Employee user) {
    _currentUser = user;
    _userId = user.id;
    _userRole = user.role;
    _companyId = user.companyId;
    _saveToStorage();
    notifyListeners();
  }
}
