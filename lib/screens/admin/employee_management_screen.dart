import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../config/app_config.dart';
import '../../providers/employee_provider.dart';
import '../../widgets/common/loading_overlay.dart';
import '../../widgets/common/app_text_field.dart';
import '../../widgets/common/confirmation_dialog.dart';
import '../../models/employee_model.dart';

class EmployeeManagementScreen extends StatefulWidget {
  const EmployeeManagementScreen({super.key});

  @override
  State<EmployeeManagementScreen> createState() => _EmployeeManagementScreenState();
}

class _EmployeeManagementScreenState extends State<EmployeeManagementScreen> {
  String _searchQuery = '';
  String _filterDepartment = 'All';
  bool _showInactive = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final employeeProvider = Provider.of<EmployeeProvider>(context, listen: false);
    await employeeProvider.initializeWithMockData();
  }

  Future<void> _addEmployee() async {
    final employeeProvider = Provider.of<EmployeeProvider>(context, listen: false);
    
    final result = await showDialog<Employee?>(
      context: context,
      builder: (context) => const AddEditEmployeeDialog(),
    );

    if (result != null) {
      await employeeProvider.addEmployee(result);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Employee added successfully!'),
          backgroundColor: AppConfig.successColor,
        ),
      );
    }
  }

  Future<void> _editEmployee(Employee employee) async {
    final employeeProvider = Provider.of<EmployeeProvider>(context, listen: false);
    
    final result = await showDialog<Employee?>(
      context: context,
      builder: (context) => AddEditEmployeeDialog(employee: employee),
    );

    if (result != null) {
      await employeeProvider.updateEmployee(result);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Employee updated successfully!'),
          backgroundColor: AppConfig.successColor,
        ),
      );
    }
  }

  Future<void> _deleteEmployee(Employee employee) async {
    final result = await showConfirmationDialog(
      context: context,
      title: 'Delete Employee',
      message: 'Are you sure you want to delete ${employee.fullName}? This action cannot be undone.',
      confirmText: 'Delete',
      cancelText: 'Cancel',
      confirmColor: AppConfig.errorColor,
    );

    if (result == true) {
      final employeeProvider = Provider.of<EmployeeProvider>(context, listen: false);
      await employeeProvider.deleteEmployee(employee.id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Employee deleted successfully!'),
          backgroundColor: AppConfig.successColor,
        ),
      );
    }
  }

  Future<void> _toggleEmployeeStatus(Employee employee) async {
    final employeeProvider = Provider.of<EmployeeProvider>(context, listen: false);
    await employeeProvider.toggleEmployeeStatus(employee.id);
    
    final message = employee.isActive 
        ? 'Employee deactivated successfully!' 
        : 'Employee activated successfully!';
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppConfig.successColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final employeeProvider = Provider.of<EmployeeProvider>(context);
    final departments = ['All', ...employeeProvider.allDepartments];

    return LoadingOverlay(
      isLoading: employeeProvider.isLoading,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Employee Management'),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: _addEmployee,
              tooltip: 'Add Employee',
            ),
          ],
        ),
        body: Column(
          children: [
            // Filters
            Card(
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Search
                    AppTextField(
                      labelText: 'Search Employees',
                      hintText: 'Search by name, email, or ID',
                      prefixIcon: Icons.search,
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    
                    // Department Filter
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _filterDepartment,
                            hint: const Text('Department'),
                            items: departments.map((dept) {
                              return DropdownMenuItem<String>(
                                value: dept,
                                child: Text(dept),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _filterDepartment = value ?? 'All';
                              });
                            },
                            decoration: InputDecoration(
                              labelText: 'Department',
                              prefixIcon: const Icon(Icons.business),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        
                        // Show Inactive Toggle
                        FilterChip(
                          label: const Text('Show Inactive'),
                          selected: _showInactive,
                          onSelected: (selected) {
                            setState(() {
                              _showInactive = selected;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            // Employee List
            Expanded(
              child: FutureBuilder(
                future: employeeProvider.initializeWithMockData(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final allEmployees = employeeProvider.employees;
                  
                  // Apply filters
                  List<Employee> filteredEmployees = allEmployees;
                  
                  if (!_showInactive) {
                    filteredEmployees = filteredEmployees.where((e) => e.isActive).toList();
                  }
                  
                  if (_filterDepartment != 'All') {
                    filteredEmployees = filteredEmployees.where((e) => e.department == _filterDepartment).toList();
                  }
                  
                  if (_searchQuery.isNotEmpty) {
                    filteredEmployees = filteredEmployees.where((e) {
                      final query = _searchQuery.toLowerCase();
                      return e.fullName.toLowerCase().contains(query) ||
                             e.email.toLowerCase().contains(query) ||
                             e.employeeId.toLowerCase().contains(query) ||
                             e.department.toLowerCase().contains(query) ||
                             e.position.toLowerCase().contains(query);
                    }).toList();
                  }

                  if (filteredEmployees.isEmpty) {
                    return const Center(
                      child: Text('No employees found'),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredEmployees.length,
                    itemBuilder: (context, index) {
                      final employee = filteredEmployees[index];
                      return _buildEmployeeItem(employee);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmployeeItem(Employee employee) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: AppConfig.primaryColor,
          child: Text(
            employee.firstName.isNotEmpty
                ? employee.firstName[0].toUpperCase()
                : 'E',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        title: Text(
          employee.fullName,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('${employee.employeeId} - ${employee.position}'),
            Text('${employee.department} - ${employee.email}'),
            if (!employee.isActive)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Inactive',
                  style: TextStyle(
                    color: AppConfig.errorColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, size: 20),
              onPressed: () => _editEmployee(employee),
              tooltip: 'Edit',
            ),
            IconButton(
              icon: Icon(
                employee.isActive ? Icons.toggle_off : Icons.toggle_on,
                size: 20,
              ),
              onPressed: () => _toggleEmployeeStatus(employee),
              tooltip: employee.isActive ? 'Deactivate' : 'Activate',
            ),
            IconButton(
              icon: const Icon(Icons.delete, size: 20),
              color: AppConfig.errorColor,
              onPressed: () => _deleteEmployee(employee),
              tooltip: 'Delete',
            ),
          ],
        ),
        onTap: () => context.go('/admin/employees/${employee.id}'),
      ),
    );
  }
}

class AddEditEmployeeDialog extends StatefulWidget {
  final Employee? employee;

  const AddEditEmployeeDialog({super.key, this.employee});

  @override
  State<AddEditEmployeeDialog> createState() => _AddEditEmployeeDialogState();
}

class _AddEditEmployeeDialogState extends State<AddEditEmployeeDialog> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _employeeIdController = TextEditingController();
  
  String? _selectedDepartment;
  String? _selectedPosition;
  TimeOfDay _checkInTime = AppConfig.defaultCheckInTime;
  TimeOfDay _checkOutTime = AppConfig.defaultCheckOutTime;

  @override
  void initState() {
    super.initState();
    if (widget.employee != null) {
      _firstNameController.text = widget.employee!.firstName;
      _lastNameController.text = widget.employee!.lastName;
      _emailController.text = widget.employee!.email;
      _phoneController.text = widget.employee!.phone;
      _employeeIdController.text = widget.employee!.employeeId;
      _selectedDepartment = widget.employee!.department;
      _selectedPosition = widget.employee!.position;
      _checkInTime = widget.employee!.checkInTime;
      _checkOutTime = widget.employee!.checkOutTime;
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _employeeIdController.dispose();
    super.dispose();
  }

  Future<void> _selectTime(BuildContext context, bool isCheckIn) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isCheckIn ? _checkInTime : _checkOutTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppConfig.primaryColor,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isCheckIn) {
          _checkInTime = picked;
        } else {
          _checkOutTime = picked;
        }
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final employeeProvider = Provider.of<EmployeeProvider>(context, listen: false);
    
    final employee = Employee(
      id: widget.employee?.id ?? const Uuid().v4(),
      employeeId: _employeeIdController.text.trim(),
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      role: AppConfig.roleEmployee,
      department: _selectedDepartment ?? 'General',
      position: _selectedPosition ?? 'Employee',
      hireDate: widget.employee?.hireDate ?? DateTime.now(),
      companyId: 'company_001',
      assignedLocationId: 'location_001',
      checkInTime: _checkInTime,
      checkOutTime: _checkOutTime,
      isActive: true,
    );

    Navigator.pop(context, employee);
  }

  @override
  Widget build(BuildContext context) {
    final employeeProvider = Provider.of<EmployeeProvider>(context);
    final departments = employeeProvider.allDepartments;
    final positions = employeeProvider.allPositions;

    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.employee == null ? 'Add Employee' : 'Edit Employee',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      controller: _firstNameController,
                      labelText: 'First Name',
                      hintText: 'Enter first name',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter first name';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppTextField(
                      controller: _lastNameController,
                      labelText: 'Last Name',
                      hintText: 'Enter last name',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter last name';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              AppTextField(
                controller: _employeeIdController,
                labelText: 'Employee ID',
                hintText: 'Enter employee ID',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter employee ID';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              
              AppTextField(
                controller: _emailController,
                labelText: 'Email',
                hintText: 'Enter email',
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter email';
                  }
                  if (!value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              
              AppTextField(
                controller: _phoneController,
                labelText: 'Phone',
                hintText: 'Enter phone number',
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              
              DropdownButtonFormField<String>(
                value: _selectedDepartment,
                hint: const Text('Select Department'),
                items: departments.map((dept) {
                  return DropdownMenuItem<String>(
                    value: dept,
                    child: Text(dept),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedDepartment = value;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Department',
                  prefixIcon: const Icon(Icons.business),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a department';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              
              DropdownButtonFormField<String>(
                value: _selectedPosition,
                hint: const Text('Select Position'),
                items: positions.map((pos) {
                  return DropdownMenuItem<String>(
                    value: pos,
                    child: Text(pos),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedPosition = value;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Position',
                  prefixIcon: const Icon(Icons.work),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a position';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => _selectTime(context, true),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: Colors.grey[50],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.access_time),
                          const SizedBox(width: 8),
                          Text(_checkInTime.format(context)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextButton(
                      onPressed: () => _selectTime(context, false),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: Colors.grey[50],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.access_time),
                          const SizedBox(width: 8),
                          Text(_checkOutTime.format(context)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(widget.employee == null ? 'Add' : 'Save'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
