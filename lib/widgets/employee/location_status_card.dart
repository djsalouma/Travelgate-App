import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/app_config.dart';
import '../../providers/location_provider.dart';

class LocationStatusCard extends StatelessWidget {
  final LocationProvider locationProvider;

  const LocationStatusCard({super.key, required this.locationProvider});

  @override
  Widget build(BuildContext context) {
    final isWithinRadius = locationProvider.isWithinRadius;
    final distance = locationProvider.distanceFromCompany;
    final companyLocation = locationProvider.companyLocation;

    Color statusColor = isWithinRadius ? AppConfig.successColor : AppConfig.errorColor;
    String statusText = isWithinRadius ? 'Within Radius' : 'Outside Radius';
    IconData statusIcon = isWithinRadius ? Icons.check_circle : Icons.error;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  color: AppConfig.primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Location Status',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            Row(
              children: [
                Icon(
                  statusIcon,
                  color: statusColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            Text(
              'Distance from company: ${distance.toStringAsFixed(0)} meters',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            
            if (companyLocation != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Company: ${companyLocation.name}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            
            if (!isWithinRadius)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  'You need to be within ${AppConfig.geofenceRadius.toInt()} meters of the company location to clock in/out',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppConfig.errorColor,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
