import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

import '../config/app_config.dart';
import '../models/location_model.dart';

class LocationProvider with ChangeNotifier {
  Position? _currentPosition;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isMonitoring = false;
  CompanyLocation? _companyLocation;
  bool _isWithinRadius = false;
  
  // Mock company location (in real app, this would come from API)
  final CompanyLocation _defaultCompanyLocation = CompanyLocation(
    id: 'location_001',
    name: 'Company HQ',
    address: '123 Business Street, City, Country',
    latitude: 37.7749, // San Francisco coordinates (mock)
    longitude: -122.4194,
    radius: AppConfig.geofenceRadius,
    companyId: 'company_001',
  );

  Position? get currentPosition => _currentPosition;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isMonitoring => _isMonitoring;
  CompanyLocation? get companyLocation => _companyLocation ?? _defaultCompanyLocation;
  bool get isWithinRadius => _isWithinRadius;
  double get distanceFromCompany => _currentPosition != null && companyLocation != null
      ? companyLocation!.distanceFrom(_currentPosition!.latitude, _currentPosition!.longitude)
      : 0.0;

  LocationProvider() {
    _companyLocation = _defaultCompanyLocation;
    _checkPermissionStatus();
  }

  Future<void> _checkPermissionStatus() async {
    final status = await Permission.location.status;
    if (status.isGranted) {
      _startLocationMonitoring();
    }
  }

  Future<bool> requestLocationPermission() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final status = await Permission.location.request();
      if (status.isGranted) {
        _startLocationMonitoring();
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Location permission is required for this app';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Failed to request location permission: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> _startLocationMonitoring() async {
    if (_isMonitoring) return;
    
    _isMonitoring = true;
    notifyListeners();

    // Get current position immediately
    await _getCurrentPosition();

    // Set up periodic location updates
    Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Update every 10 meters
        timeInterval: Duration(seconds: AppConfig.locationCheckInterval),
      ),
    ).listen((Position position) {
      _currentPosition = position;
      _checkWithinRadius();
      notifyListeners();
    }, onError: (e) {
      _errorMessage = 'Location monitoring error: ${e.toString()}';
      notifyListeners();
    });
  }

  Future<void> stopLocationMonitoring() async {
    _isMonitoring = false;
    notifyListeners();
  }

  Future<void> _getCurrentPosition() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      _currentPosition = position;
      _checkWithinRadius();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to get current position: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  void _checkWithinRadius() {
    if (_currentPosition != null && companyLocation != null) {
      _isWithinRadius = companyLocation!.isWithinRadius(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );
    }
  }

  Future<bool> checkLocationAndClockIn() async {
    if (!isMonitoring) {
      await requestLocationPermission();
    }

    if (_currentPosition == null) {
      await _getCurrentPosition();
    }

    _checkWithinRadius();
    return _isWithinRadius;
  }

  Future<bool> checkLocationAndClockOut() async {
    return await checkLocationAndClockIn();
  }

  void setCompanyLocation(CompanyLocation location) {
    _companyLocation = location;
    _checkWithinRadius();
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    stopLocationMonitoring();
    super.dispose();
  }
}
