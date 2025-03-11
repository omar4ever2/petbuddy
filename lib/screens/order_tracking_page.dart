import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/order_tracking.dart';
import '../services/supabase_service.dart';

class OrderTrackingPage extends StatefulWidget {
  final String orderId;
  final Map<String, dynamic> orderData;

  const OrderTrackingPage({
    Key? key,
    required this.orderId,
    required this.orderData,
  }) : super(key: key);

  @override
  State<OrderTrackingPage> createState() => _OrderTrackingPageState();
}

class _OrderTrackingPageState extends State<OrderTrackingPage> {
  final Completer<GoogleMapController> _controller = Completer();
  OrderTracking? _tracking;
  bool _isLoading = true;
  String? _errorMessage;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  
  @override
  void initState() {
    super.initState();
    _loadTrackingData();
  }
  
  Future<void> _loadTrackingData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final supabaseService = Provider.of<SupabaseService>(context, listen: false);
      final trackingData = await supabaseService.getOrderTracking(widget.orderId);
      
      setState(() {
        _tracking = OrderTracking.fromJson(trackingData);
        _isLoading = false;
        _setupMapData();
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load tracking data: $e';
      });
    }
  }
  
  void _setupMapData() {
    if (_tracking == null) return;
    
    // Create markers
    final markers = <Marker>{};
    
    // Current location marker
    markers.add(
      Marker(
        markerId: const MarkerId('current_location'),
        position: _tracking!.currentLocation,
        infoWindow: InfoWindow(
          title: 'Current Location',
          snippet: 'Your order is here',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      ),
    );
    
    // Destination marker
    markers.add(
      Marker(
        markerId: const MarkerId('destination'),
        position: _tracking!.destinationLocation,
        infoWindow: InfoWindow(
          title: 'Destination',
          snippet: widget.orderData['shipping_address'] ?? 'Your delivery address',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
    );
    
    // Add markers for each update with location
    for (var i = 0; i < _tracking!.updates.length; i++) {
      final update = _tracking!.updates[i];
      if (update.location != null) {
        markers.add(
          Marker(
            markerId: MarkerId('update_$i'),
            position: update.location!,
            infoWindow: InfoWindow(
              title: update.status,
              snippet: update.description,
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          ),
        );
      }
    }
    
    // Create a polyline between all points
    final points = <LatLng>[];
    
    // Add points from updates with locations
    for (final update in _tracking!.updates.where((u) => u.location != null)) {
      points.add(update.location!);
    }
    
    // Add current location if not already included
    if (!points.contains(_tracking!.currentLocation)) {
      points.add(_tracking!.currentLocation);
    }
    
    // Sort points by timestamp (if we had real data)
    // For now, we'll just use the order they appear in the updates list
    
    // Create polyline
    final polylines = <Polyline>{
      Polyline(
        polylineId: const PolylineId('route'),
        points: points,
        color: Colors.blue,
        width: 5,
      ),
    };
    
    setState(() {
      _markers = markers;
      _polylines = polylines;
    });
    
    // Move camera to fit all points
    _fitMapToBounds();
  }
  
  Future<void> _fitMapToBounds() async {
    if (_tracking == null || !_controller.isCompleted) return;
    
    final controller = await _controller.future;
    
    // Create bounds that include all points
    final bounds = LatLngBounds(
      southwest: LatLng(
        _tracking!.updates
            .where((u) => u.location != null)
            .map((u) => u.location!.latitude)
            .followedBy([_tracking!.currentLocation.latitude, _tracking!.destinationLocation.latitude])
            .reduce((min, value) => min < value ? min : value),
        _tracking!.updates
            .where((u) => u.location != null)
            .map((u) => u.location!.longitude)
            .followedBy([_tracking!.currentLocation.longitude, _tracking!.destinationLocation.longitude])
            .reduce((min, value) => min < value ? min : value),
      ),
      northeast: LatLng(
        _tracking!.updates
            .where((u) => u.location != null)
            .map((u) => u.location!.latitude)
            .followedBy([_tracking!.currentLocation.latitude, _tracking!.destinationLocation.latitude])
            .reduce((max, value) => max > value ? max : value),
        _tracking!.updates
            .where((u) => u.location != null)
            .map((u) => u.location!.longitude)
            .followedBy([_tracking!.currentLocation.longitude, _tracking!.destinationLocation.longitude])
            .reduce((max, value) => max > value ? max : value),
      ),
    );
    
    // Animate camera to show all markers
    controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Order Tracking',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTrackingData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 60,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.red,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _loadTrackingData,
                        child: const Text('Try Again'),
                      ),
                    ],
                  ),
                )
              : _buildTrackingContent(),
    );
  }
  
  Widget _buildTrackingContent() {
    if (_tracking == null) {
      return const Center(child: Text('No tracking information available'));
    }
    
    return Column(
      children: [
        _buildStatusBar(),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMapSection(),
                _buildDeliveryInfo(),
                _buildTrackingTimeline(),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildStatusBar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      color: _tracking!.getStatusColor().withOpacity(0.1),
      child: Row(
        children: [
          Icon(
            _tracking!.getStatusIcon(),
            color: _tracking!.getStatusColor(),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Status: ${_tracking!.getStatusText()}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _tracking!.getStatusColor(),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Last updated: ${DateFormat('MMM dd, yyyy hh:mm a').format(_tracking!.lastUpdated)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'Estimated Delivery',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              Text(
                DateFormat('MMM dd, yyyy').format(_tracking!.estimatedDelivery),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildMapSection() {
    return Container(
      height: 300,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: CameraPosition(
          target: _tracking!.currentLocation,
          zoom: 10,
        ),
        markers: _markers,
        polylines: _polylines,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
          _fitMapToBounds();
        },
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        compassEnabled: true,
        zoomControlsEnabled: true,
      ),
    );
  }
  
  Widget _buildDeliveryInfo() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Delivery Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              icon: Icons.numbers,
              title: 'Order ID',
              value: widget.orderId,
            ),
            _buildInfoRow(
              icon: Icons.location_on,
              title: 'Shipping Address',
              value: widget.orderData['shipping_address'] ?? 'N/A',
            ),
            _buildInfoRow(
              icon: Icons.person,
              title: 'Recipient',
              value: widget.orderData['customer_name'] ?? 'N/A',
            ),
            _buildInfoRow(
              icon: Icons.phone,
              title: 'Contact',
              value: widget.orderData['customer_phone'] ?? 'N/A',
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTrackingTimeline() {
    final updates = _tracking!.updates;
    
    return Card(
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tracking History',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: updates.length,
              itemBuilder: (context, index) {
                final update = updates[index];
                final isLast = index == updates.length - 1;
                
                return _buildTimelineItem(
                  update: update,
                  isLast: isLast,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTimelineItem({
    required TrackingUpdate update,
    required bool isLast,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 40, 108, 100),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check,
                color: Colors.white,
                size: 12,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 60,
                color: Colors.grey[300],
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                update.status,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                update.description,
                style: TextStyle(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                DateFormat('MMM dd, yyyy hh:mm a').format(update.timestamp),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
              if (!isLast) const SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
  }
} 