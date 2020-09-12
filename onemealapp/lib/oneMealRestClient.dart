import 'dart:convert';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:onemealapp/auth.dart';

/*
 * @author : Pradeep CH
 * @version : 1.0  
 */
class OneMealRestClient {
  final RestClient _client = RestClient();
  final String rootURL = 'https://us-central1-onemealwh.cloudfunctions.net/';
  Future<List> getHungers(LatLng location) async {
    if (location == null) {
      return [];
    }

    var lat = location.latitude;
    var lng = location.longitude;

    String url = rootURL + 'orderservices/api/orders?location=$lat,$lng';
    var items = await _client.doGet(url);
    return items as List;
  }

  addupdateUser(Map<String, dynamic> user) async {
    String url = rootURL + 'userservices/api/users';
    return await _client.doPost(user, url);
  }

  dynamic reportHunger(LatLng hungerLocationToAdd, String description,
      String title, LatLng userLocation) async {
    var reporterLocation =
        userLocation == null ? hungerLocationToAdd : userLocation;
    var order = {
      'description': description,
      'title': title,
      'location': {
        '_longitude': hungerLocationToAdd.longitude,
        '_latitude': hungerLocationToAdd.latitude
      },
      "reporter": authService.currentUser.displayName,
      "reporterLocation": {
        '_longitude': reporterLocation.longitude,
        '_latitude': reporterLocation.latitude
      },
    };

    String url = rootURL + 'orderservices/api/orders';
    return await _client.doPost(order, url);
  }

  Future<dynamic> satisfyHunger(selectedElementId, String comment) async {
    var order = {
      "servedBy": authService.currentUser.displayName,
      "comment": comment
    };
    String url = rootURL + 'orderservices/api/orders/$selectedElementId/serve';
    return await _client.doPut(order, url);
  }

  getUserDetails(String uid) async {
    String url = rootURL + 'userservices/api/users/$uid';
    return await _client.doGet(url);
  }
}

class RestClient {
  Future<dynamic> doPost(Map<String, dynamic> payload, String url) async {
    print("POST ::: $url");
    var client = http.Client();
    var jPayload = jsonEncode(payload);
    try {
      var response = await client.post(url,
          body: jPayload, headers: await _prepareHeader());
      if (response.statusCode == 200) {
        String resp = response.body;
        return jsonDecode(resp);
      }
      _logError(url, response);
      return null;
    } finally {
      client.close();
    }
  }

  Future<dynamic> doPut(Map<String, dynamic> payload, String url) async {
    print("PUT ::: $url");
    var client = http.Client();
    var jPayload = jsonEncode(payload);
    try {
      var response = await client.put(url,
          body: jPayload, headers: await _prepareHeader());
      if (response.statusCode == 200) {
        String resp = response.body;
        return jsonDecode(resp);
      }
      _logError(url, response);
      return null;
    } finally {
      client.close();
    }
  }

  Future<dynamic> doGet(url) async {
    print("GET ::: " + url);
    var client = http.Client();
    try {
      var response = await client.get(url, headers: await _prepareHeader());
      if (response.statusCode == 200) {
        String resp = response.body;
        return jsonDecode(resp);
      }
      _logError(url, response);
      return null;
    } finally {
      client.close();
    }
  }

  Future<Map<String, String>> _prepareHeader() async {
    return {
      'content-type': 'application/json',
      'authorization': 'Bearer ' + await authService.getUserToken()
    };
  }
}

void _logError(String url, http.Response response) {
  var statusCode = response.statusCode;
  var body = response.body;
  print('ERROR $url $statusCode $body');
}

OneMealRestClient oneMealRestClient = OneMealRestClient();
