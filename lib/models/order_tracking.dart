import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

enum OrderStatus {
  processing,
  shipped,
  outForDelivery,
  delivered,
  cancelled
}

class OrderTracking {
  final String id;
  final String orderId;
  final OrderStatus status;
  final DateTime estimatedDelivery;
  final DateTime lastUpdated;
  final LatLng currentLocation;
  final LatLng destinationLocation;
  final List<TrackingUpdate> updates;

  OrderTracking({
    required this.id,
    required this.orderId,
    required this.status,
    required this.estimatedDelivery,
    required this.lastUpdated,
    required this.currentLocation,
    required this.destinationLocation,
    required this.updates,
  });

  factory OrderTracking.fromJson(Map<String, dynamic> json) {
    return OrderTracking(
      id: json['id'],
      orderId: json['order_id'],
      status: _parseStatus(json['status']),
      estimatedDelivery: DateTime.parse(json['estimated_delivery']),
      lastUpdated: DateTime.parse(json['last_updated']),
      currentLocation: LatLng(
        json['current_location']['latitude'],
        json['current_location']['longitude'],
      ),
      destinationLocation: LatLng(
        json['destination_location']['latitude'],
        json['destination_location']['longitude'],
      ),
      updates: (json['updates'] as List)
          .map((update) => TrackingUpdate.fromJson(update))
          .toList(),
    );
  }

  static OrderStatus _parseStatus(String status) {
    switch (status.toLowerCase()) {
      case 'processing':
        return OrderStatus.processing;
      case 'shipped':
        return OrderStatus.shipped;
      case 'out_for_delivery':
        return OrderStatus.outForDelivery;
      case 'delivered':
        return OrderStatus.delivered;
      case 'cancelled':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.processing;
    }
  }

  Color getStatusColor() {
    switch (status) {
      case OrderStatus.processing:
        return Colors.blue;
      case OrderStatus.shipped:
        return Colors.orange;
      case OrderStatus.outForDelivery:
        return Colors.purple;
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
    }
  }

  String getStatusText() {
    switch (status) {
      case OrderStatus.processing:
        return 'Processing';
      case OrderStatus.shipped:
        return 'Shipped';
      case OrderStatus.outForDelivery:
        return 'Out for Delivery';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  IconData getStatusIcon() {
    switch (status) {
      case OrderStatus.processing:
        return Icons.inventory;
      case OrderStatus.shipped:
        return Icons.local_shipping;
      case OrderStatus.outForDelivery:
        return Icons.delivery_dining;
      case OrderStatus.delivered:
        return Icons.check_circle;
      case OrderStatus.cancelled:
        return Icons.cancel;
    }
  }
}

class TrackingUpdate {
  final DateTime timestamp;
  final String status;
  final String description;
  final LatLng? location;

  TrackingUpdate({
    required this.timestamp,
    required this.status,
    required this.description,
    this.location,
  });

  factory TrackingUpdate.fromJson(Map<String, dynamic> json) {
    return TrackingUpdate(
      timestamp: DateTime.parse(json['timestamp']),
      status: json['status'],
      description: json['description'],
      location: json['location'] != null
          ? LatLng(
              json['location']['latitude'],
              json['location']['longitude'],
            )
          : null,
    );
  }
} 