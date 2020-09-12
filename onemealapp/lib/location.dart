/*
 * @author : Pradeep CH
 * @version : 1.0  
 */

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class LocationInfoService {
  bool _serviceEnabled;
  LocationData _locationData;

  PermissionStatus _permissionGranted;
  Location location = new Location();

  Future<LatLng> getLocation(Function onLocationUpdate) async {
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return null;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return null;
      }
    }

    _locationData = await location.getLocation().timeout(Duration(seconds: 10));
    if (onLocationUpdate == null)
      return LatLng(_locationData.latitude, _locationData.longitude);
    location.onLocationChanged.listen((LocationData currentLocation) {
      var latLng = LatLng(currentLocation.latitude, currentLocation.longitude);
      onLocationUpdate(latLng);
    });
    return LatLng(_locationData.latitude, _locationData.longitude);
  }
}

LocationInfoService locationInfoService = LocationInfoService();
