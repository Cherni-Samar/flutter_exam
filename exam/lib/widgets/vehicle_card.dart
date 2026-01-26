import 'package:flutter/material.dart';
import '../models/vehicle.dart';
import '../utils/constants.dart';

class VehicleCard extends StatelessWidget {
  final Vehicle vehicle;

  const VehicleCard({
    super.key,
    required this.vehicle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Brand and Model
            Text(
              '${vehicle.brand} ${vehicle.model}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            
            // Mileage
            Text(
              '${FormatUtils.formatNumber(vehicle.mileage)} KM',
              style: const TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 20),
            
            // Vehicle silhouette (icon as placeholder)
            Icon(
              Icons.directions_car,
              size: 120,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }
}
