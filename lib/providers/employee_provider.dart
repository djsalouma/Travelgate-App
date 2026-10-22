import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../config/app_config.dart';
import '../models/employee_model.dart';

class EmployeeProvider with ChangeNotifier {
  List<Employee> _employees = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Hive box name
  static const String _boxName = 'employees';

  List<Employee> get employees => _employees;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  EmployeeProvider() {
    _loadFromStorage();
  }

  Future<void> _loadFromStorage() async {
    try {
      final box = await Hive.openBox<Employee>(_boxName);
      _employees = box.values.toList();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load employees: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> _saveToStorage() async {
    try {
      final box = await Hive.openBox<Employee>(_boxName);
      await box.clear();
      for (final employee in _employees) {
        await box.add(employee);
      }
    } catch (e) {
      _errorMessage = 'Failed to save employees: ${e.toString()}';
      notifyListeners();
    }
  }

  // Initialize with some mock data for demo
  Future<void> initializeWithMockData() async {
    if (_employees.isNotEmpty) return;

    _isLoading = true;
    notifyListeners();

    try {
      final mockEmployees = [
        Employee(
          id: const Uuid().v4(),
          employeeId: 'EMP001',
          firstName: 'John',
          lastName: 'Doe',
          email: 'john.doe@company.com',
          phone: '+1234567891',
          role: AppConfig.roleEmployee,
          department: 'IT',
          position: 'Software Engineer',
          hireDate: DateTime(2020, 1, 15),
          companyId: 'company_001',
          assignedLocationId: 'location_001',
          checkInTime: AppConfig.defaultCheckInTime,
          checkOutTime: AppConfig.defaultCheckOutTime,
        ),
        Employee(
          id: const Uuid().v4(),
          employeeId: 'EMP002',
          firstName: 'Jane',
          lastName: 'Smith',
          email: 'jane.smith@company.com',
          phone: '+1234567892',
          role: AppConfig.roleEmployee,
          department: 'HR',
          position: 'HR Manager',
          hireDate: DateTime(2019, 5, 20),
          companyId: 'company_001',
          assignedLocationId: 'location_001',
          checkInTime: AppConfig.defaultCheckInTime,
          checkOutTime: AppConfig.defaultCheckOutTime,
        ),
        Employee(
          id: const Uuid().v4(),
          employeeId: 'EMP003',
          firstName: 'Michael',
          lastName: 'Johnson',
          email: 'michael.johnson@company.com',
          phone: '+1234567893',
          role: AppConfig.roleManager,
          department: 'Operations',
          position: 'Operations Manager',
          hireDate: DateTime(2018, 11, 10),
          companyId: 'company_001',
          assignedLocationId: 'location_001',
          checkInTime: AppConfig.defaultCheckInTime,
          checkOutTime: AppConfig.defaultCheckOutTime,
        ),
        Employee(
          id: const Uuid().v4(),
          employeeId: 'EMP004',
          firstName: 'Sarah',
          lastName: 'Williams',
          email: 'sarah.williams@company.com',
          phone: '+1234567894',
          role: AppConfig.roleEmployee,
          department: 'Finance',
          position: 'Accountant',
          hireDate: DateTime(2021, 3, 1),
          companyId: 'company_001',
          assignedLocationId: 'location_001',
          checkInTime: AppConfig.defaultCheckInTime,
          checkOutTime: AppConfig.defaultCheckOutTime,
        ),
        Employee(
          id: const Uuid().v4(),
          employeeId: 'EMP005',
          firstName: 'David',
          lastName: 'Brown',
          email: 'david.brown@company.com',
          phone: '+1234567895',
          role: AppConfig.roleEmployee,
          department: 'Marketing',
          position: 'Marketing Specialist',
          hireDate: DateTime(2022, 7, 15),
          companyId: 'company_001',
          assignedLocationId: 'location_001',
          checkInTime: AppConfig.defaultCheckInTime,
          checkOutTime: AppConfig.defaultCheckOutTime,
        ),
      ];

      _employees = mockEmployees;
      await _saveToStorage();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to initialize mock data: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Employee?> getEmployeeById(String employeeId) async {
    try {
      return _employees.firstWhere((e) => e.id == employeeId);
    } catch (e) {
      return null;
    }
  }

  Future<Employee?> getEmployeeByEmail(String email) async {
    try {
      return _employees.firstWhere((e) => e.email == email);
    } catch (e) {
      return null;
    }
  }

  Future<List<Employee>> getEmployeesByDepartment(String department) async {
    return _employees.where((e) => e.department == department).toList();
  }

  Future<List<Employee>> getActiveEmployees() async {
    return _employees.where((e) => e.isActive).toList();
  }

  Future<void> addEmployee(Employee employee) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _employees.add(employee);
      await _saveToStorage();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to add employee: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateEmployee(Employee employee) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final index = _employees.indexWhere((e) => e.id == employee.id);
      if (index != -1) {
        _employees[index] = employee;
        await _saveToStorage();
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to update employee: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteEmployee(String employeeId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _employees.removeWhere((e) => e.id == employeeId);
      await _saveToStorage();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to delete employee: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleEmployeeStatus(String employeeId) async {
    try {
      final index = _employees.indexWhere((e) => e.id == employeeId);
      if (index != -1) {
        final updatedEmployee = _employees[index].copyWith(
          isActive: !_employees[index].isActive,
        );
        _employees[index] = updatedEmployee;
        await _saveToStorage();
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Failed to toggle employee status: ${e.toString()}';
      notifyListeners();
    }
  }

  List<String> get allDepartments {
    final departments = _employees.map((e) => e.department).toSet();
    return departments.toList()..sort();
  }

  List<String> get allPositions {
    final positions = _employees.map((e) => e.position).toSet();
    return positions.toList()..sort();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Search employees
  List<Employee> searchEmployees(String query) {
    if (query.isEmpty) {
      return List.from(_employees);
    }
    
    return _employees.where((employee) {
      final fullName = employee.fullName.toLowerCase();
      final email = employee.email.toLowerCase();
      final department = employee.department.toLowerCase();
      final position = employee.position.toLowerCase();
      final employeeId = employee.employeeId.toLowerCase();
      
      return fullName.contains(query.toLowerCase()) ||
             email.contains(query.toLowerCase()) ||
             department.contains(query.toLowerCase()) ||
             position.contains(query.toLowerCase()) ||
             employeeId.contains(query.toLowerCase());
    }).toList();
  }
}
