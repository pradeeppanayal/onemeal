import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

/*
 * @author : Pradeep CH
 * @version : 1.0  
 */
class Maputil {
  Maputil._();
  static final LatLng defaultLocation = LatLng(12.97, 77.56); //Banglore
  static LatLng getDefaultLocation() {
    return defaultLocation;
  }

  static Future<void> openMap(double latitude, double longitude) async {
    String googleUrl =
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    if (await canLaunch(googleUrl)) {
      await launch(googleUrl);
    } else {
      throw 'Could not open the map.';
    }
  }
}

class UserInfoMessageUtil {
  UserInfoMessageUtil._();
  static void showMessage(String msg, UserInfoMessageMode mode) {
    Color bg;
    switch (mode) {
      case UserInfoMessageMode.ERROR:
        bg = Colors.red;
        break;
      case UserInfoMessageMode.INFO:
      case UserInfoMessageMode.WARN:
        bg = Colors.blue;
        break;
      case UserInfoMessageMode.SUCCESS:
        bg = Colors.green;
        break;
    }
    Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 1,
        backgroundColor: bg,
        textColor: Colors.white,
        fontSize: 16.0);
  }
}

class MarkerUtil {
  MarkerUtil._();
  static final ImageConfiguration imageConfiguration = ImageConfiguration();

  static BitmapDescriptor addIconBitmapDescriptor;
  static BitmapDescriptor hungerIconBitmapDescriptor;
  static BitmapDescriptor servedIconBitmapDescriptor;

  static getIcon(String status) {
    if (status == 'Open') {
      if (hungerIconBitmapDescriptor != null)
        return hungerIconBitmapDescriptor;
      else
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
    } else {
      if (servedIconBitmapDescriptor != null)
        return servedIconBitmapDescriptor;
      else
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
    }
  }

  static String _getAssetMarkerDirecotry(
      BuildContext context, String rootDirectory) {
    MediaQueryData data = MediaQuery.of(context);
    double pixelRatio = data.devicePixelRatio;
    bool isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    print("========================================$pixelRatio$isIOS");

    String directory = '/70';
    if (!isIOS) {
      if (pixelRatio >= 3.5) {
        directory = '/210';
      } else if (pixelRatio >= 2.5) {
        directory = '/140';
      } else if (pixelRatio >= 1.5) {
        directory = '/70';
      } else {
        directory = '/35';
      }
    }
    return '$rootDirectory$directory';
  }

  static Future<void> loadCustomMarkers(BuildContext context) async {
    String iconDirectory = _getAssetMarkerDirecotry(context, 'assets/images');
    print(iconDirectory);
    addIconBitmapDescriptor = await BitmapDescriptor.fromAssetImage(
      imageConfiguration,
      "$iconDirectory/add.png",
    );
    hungerIconBitmapDescriptor = await BitmapDescriptor.fromAssetImage(
        imageConfiguration, "$iconDirectory/hunger.png");
    servedIconBitmapDescriptor = await BitmapDescriptor.fromAssetImage(
        imageConfiguration, "$iconDirectory/served.png");
  }

  static getAddIcon() {
    if (addIconBitmapDescriptor != null) return addIconBitmapDescriptor;
    return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
  }
}

class CommonUtil {
  CommonUtil._();
  static getMarginRadius() {
    return BorderRadius.only(
      topLeft: Radius.circular(24.0),
      topRight: Radius.circular(24.0),
    );
  }

  static LatLng getAsLocation(dynamic attribut) {
    if (attribut == null) return null;
    if (attribut is GeoPoint)
      return LatLng(attribut.latitude, attribut.longitude);
    return null;
  }

  static String getDateAsKey({DateTime date}) {
    if (date == null) date = DateTime.now();
    String month =
        date.month < 10 ? "0" + date.month.toString() : date.month.toString();
    String day =
        date.day < 10 ? "0" + date.day.toString() : date.day.toString();
    return date.year.toString() + month + day;
  }

  static double calculateDistance(LatLng l1, LatLng l2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((l2.latitude - l1.latitude) * p) / 2 +
        c(l1.latitude * p) *
            c(l2.latitude * p) *
            (1 - c((l2.longitude - l1.longitude) * p)) /
            2;
    return 12742 * asin(sqrt(a));
  }

  static getLocationRange(LatLng providerlocation, double distance) {
    // ~1 mile of lat and lon in degrees
    const lat = 0.0144927536231884;
    const lon = 0.0181818181818182;
    var lowerLat = providerlocation.latitude - (lat * distance);
    var lowerLon = providerlocation.longitude - (lon * distance);

    var greaterLat = providerlocation.latitude + (lat * distance);
    var greaterLon = providerlocation.longitude + (lon * distance);

    return {
      'lesserGeopoint': new GeoPoint(lowerLat, lowerLon),
      'greaterGeopoint': new GeoPoint(greaterLat, greaterLon)
    };
  }

  static int currentTime() {
    return DateTime.now().millisecondsSinceEpoch;
  }
}

enum UserInfoMessageMode { INFO, WARN, SUCCESS, ERROR }
