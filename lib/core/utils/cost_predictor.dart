import 'dart:math' as math;

import '../../data/models/maintenance_record.dart';

/// ============================================================
/// Cost Predictor — Z-Score Filtered Average
/// ============================================================
///
/// Predicts the expected cost for a service task based on
/// historical records. Uses Z-score outlier detection to
/// filter anomalous prices before averaging.
///
/// Algorithm:
///   - N < 3:  Simple average (insufficient data for stats).
///   - N >= 3: Compute mean (μ) and std dev (σ).
///             Filter outliers where |(x - μ) / σ| > 2.0.
///             Average the remaining values.
///
/// Returns null if no historical data exists for the task.
/// ============================================================

/// Calculates the predicted cost for a task based on its history.
///
/// Parameters:
///   [taskKey] — The service task identifier (e.g., "oil_change").
///   [records] — All maintenance records for the vehicle.
///
/// Returns:
///   Predicted cost in SAR, or null if no data exists.
double? calculatePredictedCost(
  String taskKey,
  List<MaintenanceRecord> records,
) {
  // Extract partsCostSar for records containing this taskKey.
  final prices = <double>[];
  for (final record in records) {
    if (record.taskKeys != null && record.taskKeys!.contains(taskKey)) {
      if (record.partsCostSar > 0) {
        prices.add(record.partsCostSar);
      }
    }
  }

  if (prices.isEmpty) return null;

  // Insufficient data for statistical filtering — return simple average.
  if (prices.length < 3) {
    return prices.reduce((a, b) => a + b) / prices.length;
  }

  // Calculate mean (μ).
  final mean = prices.reduce((a, b) => a + b) / prices.length;

  // Calculate standard deviation (σ).
  final variance = prices
          .map((x) => (x - mean) * (x - mean))
          .reduce((a, b) => a + b) /
      prices.length;
  final stdDev = math.sqrt(variance);

  // Guard against zero std dev (all prices identical).
  if (stdDev == 0) return mean;

  // Filter outliers: keep only values within 2σ of mean.
  final filtered =
      prices.where((x) => ((x - mean) / stdDev).abs() <= 2.0).toList();

  // If all values were filtered (extremely unlikely), return the mean.
  if (filtered.isEmpty) return mean;

  return filtered.reduce((a, b) => a + b) / filtered.length;
}
