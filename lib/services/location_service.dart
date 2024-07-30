import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class LocationService {
  static final _location = Location();
  static bool isServiceEnabled = false;
  static PermissionStatus _permissionStatsus = PermissionStatus.denied;
  static LocationData? locationData;

  static Future<void> init() async {
    await checkService();
    await checkPermission();
  }

  static Future<void> checkService() async {
    isServiceEnabled = await _location.serviceEnabled();

    if (!isServiceEnabled) {
      isServiceEnabled = await _location.requestService();

      if (!isServiceEnabled) {
        return;
      }
    }
  }

  static Future<void> checkPermission() async {
    _permissionStatsus = await _location.hasPermission();

    if (_permissionStatsus == PermissionStatus.denied) {
      await _location.requestPermission();
    }
    if (_permissionStatsus == PermissionStatus.granted) {
      return;
    }
  }

  static Future<void> getCurrentLocation() async {
    if (isServiceEnabled && _permissionStatsus == PermissionStatus.granted) {
      locationData = await _location.getLocation();
    }
  }

  static Stream<LocationData> getLiveLocation() async* {
    yield* _location.onLocationChanged;
  }

  static Future<List<LatLng>> fetchPolylinePoints(
    LatLng from,
    LatLng to,
    TravelMode curentTravelMOde,
  ) async {
    final polylinePoints = PolylinePoints();

    final result = await polylinePoints.getRouteBetweenCoordinates(
      googleApiKey: "AIzaSyBEjfX9jrWudgRcWl2scld4R7s0LtlaQmQ",
      request: PolylineRequest(
        origin: PointLatLng(from.latitude, from.longitude),
        destination: PointLatLng(to.latitude, to.longitude),
        mode: curentTravelMOde,
      ),
    );

    if (result.points.isNotEmpty) {
      return result.points.map((point) => LatLng(point.latitude, point.longitude)).toList();
    }

    return [];
  }
}
