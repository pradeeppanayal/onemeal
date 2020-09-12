import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:onemealapp/auth.dart';
import 'package:onemealapp/hungerInfo.dart';
import 'package:onemealapp/hungerReport.dart';
import 'package:onemealapp/location.dart';
import 'package:onemealapp/main.dart';
import 'package:onemealapp/oneMealRestClient.dart';
import 'package:onemealapp/userprofile.dart';
import 'package:onemealapp/utils.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

/*
 * @author : Pradeep CH
 * @version : 1.0  
 */
class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with WidgetsBindingObserver {
  static final String locationRequiredErrorMessage =
      "Your current location is not available.";
  final Completer<GoogleMapController> _controller = Completer();
  PanelController panelController = new PanelController();
  PanelController panelControllerHungerReport = new PanelController();
  PanelController panelControllerUser = new PanelController();
  static LatLng currentLocation = Maputil.getDefaultLocation();
  LatLng _hungerLocationToAdd;
  bool loading = true;
  bool hasUserLocation = false;
  dynamic _selectedElement = {};
  Set<Marker> _markers = Set();

  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _getlocation();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _controller.future.then((value) => value.setMapStyle("[]"));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
          children: [
            hasUserLocation
                ? _googleMap(context)
                : _getLocationAccessRequired(),
            HungerInfo(
                panelController: panelController,
                selectedElement: _selectedElement,
                currentLocation: currentLocation,
                callback: _hunegrInfoUpdate,
                loadingStatusUpdate: loadingStatusUpdate,
                loading: loading),
            HungerReportWidget(
                hungerLocationToAdd: _hungerLocationToAdd,
                userLocation: currentLocation,
                panelControllerHungerReport: panelControllerHungerReport,
                callBack: _hungerReoprted,
                loadingStatusUpdate: loadingStatusUpdate,
                loading: loading),
            UserProfileWidget(
              panelController: panelControllerUser,
              callback: userInfoUpdated,
              loadingStateUpdateCallBack: loadingStatusUpdate,
              loading: loading,
              goHome: goHome,
            ),
            Visibility(
              child: Positioned(
                  width: MediaQuery.of(context).size.width,
                  child: LinearProgressIndicator(),
                  bottom: 0.0),
              visible: loading,
            )
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
              _menuTaped(index);
            });
          },
          items: [
            BottomNavigationBarItem(
                icon: Icon(Icons.search), title: Text("Search Hunger")),
            BottomNavigationBarItem(
                icon: Icon(Icons.add), title: Text("Report Hunger")),
            BottomNavigationBarItem(
                icon: Icon(Icons.supervised_user_circle),
                title: Text("My Account")),
          ],
        ));
  }

  void _menuTaped(int index) {
    panelControllerHungerReport.panelPosition = 0.0;
    panelController.panelPosition = 0.0;
    panelControllerUser.panelPosition = 0.0;

    switch (index) {
      case 0:
        fetchHunger();
        break;
      case 1:
        _markers.clear(); //delete all markers
        reportHunger(currentLocation);
        break;
      case 2:
        showProfile();
        break;
    }
  }

  Widget _googleMap(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition:
            CameraPosition(target: currentLocation, zoom: 12),
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
          MarkerUtil.loadCustomMarkers(context);
          fetchHunger();
        },
        markers: _markers,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        onLongPress: _userPickedHungerLocation,
        padding: EdgeInsets.only(top: 40),
      ),
    );
  }

  Widget _getLocationAccessRequired() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: loading
            ? [Text("Loading..")]
            : <Widget>[
                IconButton(
                  icon: Icon(Icons.location_disabled),
                  onPressed: () => {requestForLocationAccess()},
                  iconSize: 100.00,
                  color: Colors.red[400],
                ),
                Text("Location access is required"),
                FlatButton(
                    child: Icon(Icons.refresh),
                    onPressed: () => {requestForLocationAccess()}),
                SizedBox(height: 100),
              ],
      ),
    );
  }

  void requestForLocationAccess() {
    loadingStatusUpdate(true);
    _getlocation();
  }

  void fetchHunger() {
    if (loading) return;
    if (!hasUserLocation) {
      UserInfoMessageUtil.showMessage(
          locationRequiredErrorMessage, UserInfoMessageMode.INFO);
      return;
    }
    _markers.clear();
    loadingStatusUpdate(true);
    oneMealRestClient
        .getHungers(currentLocation)
        .then((value) => {
              setState(() {
                var reportCount = value == null ? 0 : value.length;
                if (reportCount == 0) {
                  UserInfoMessageUtil.showMessage(
                      "Thank God. No hunger reported near you.",
                      UserInfoMessageMode.SUCCESS);
                  loadingStatusUpdate(false);
                  return;
                }

                UserInfoMessageUtil.showMessage(
                    "$reportCount hunger reported near you.",
                    UserInfoMessageMode.WARN);
                value.forEach((element) {
                  _markers.add(Marker(
                      icon: MarkerUtil.getIcon(element['status']),
                      markerId: MarkerId(element['id']),
                      position: LatLng(element["location"]["_latitude"],
                          element["location"]["_longitude"]),
                      onTap: () {
                        _showDetails(element);
                      },
                      infoWindow: InfoWindow(
                          title: element['title'] == null
                              ? "No title"
                              : element['title'])));
                });
                loadingStatusUpdate(false);
              })
            })
        .catchError((e) {
      loadingStatusUpdate(false);
      print(e);
    });
  }

  void reportHunger(point) {
    if (loading) return;
    if (!hasUserLocation) {
      UserInfoMessageUtil.showMessage(
          locationRequiredErrorMessage, UserInfoMessageMode.INFO);
      return;
    }

    setState(() {
      _markers.clear();
      _markers.add(Marker(
          markerId: MarkerId("hunger"),
          draggable: true,
          position: point == null ? currentLocation : point,
          icon: MarkerUtil.getAddIcon(),
          //onTap: () => {_userPickedALocation(point)},
          onDragEnd: (value) => {_userPickedALocation(value)}));
    });
    UserInfoMessageUtil.showMessage(
        "Drag the marker to the exact location.", UserInfoMessageMode.INFO);
  }

  void showProfile() {
    _markers.clear();
    _moveCameraToCurrentlocation();
    panelControllerUser.panelPosition = 1.0;
  }

  _showDetails(element) {
    setState(() {
      _selectedElement = element;
    });

    panelController.panelPosition = 0.5;
  }

  void _currentLocationUpdated(LatLng val) {
    currentLocation = val == null ? currentLocation : val;
  }

  void _moveCameraToCurrentlocation() async {
    if (currentLocation == null) return;
    GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: currentLocation, zoom: 14.00)));
  }

  void _getlocation() async {
    loading = true;
    var location;
    try {
      location = await locationInfoService.getLocation(_currentLocationUpdated);
    } catch (e) {
      UserInfoMessageUtil.showMessage(
          "Could not get your current location", UserInfoMessageMode.ERROR);
    }
    if (location == null) {
      loadingStatusUpdate(false);
      return;
    }
    print("Initial location recived $location");
    authService.updateUserData(location);
    setState(() {
      currentLocation = location;
      hasUserLocation = true;
    });
    setState(() {
      loading = false;
    });
    _moveCameraToCurrentlocation();
  }

  void _userPickedHungerLocation(LatLng location) {
    if (currentLocation == null) return;

    if (!hasUserLocation) {
      UserInfoMessageUtil.showMessage(
          locationRequiredErrorMessage, UserInfoMessageMode.INFO);
      return;
    }

    setState(() {
      _markers.clear();
      _markers.add(Marker(
        markerId: MarkerId("hunger"),
        draggable: true,
        position: location,
        onDragEnd: _userPickedALocation,
        icon: MarkerUtil.getAddIcon(),
      ));
    });
    _userPickedALocation(location);
  }

  void _userPickedALocation(LatLng argument) {
    print("Location picked :$argument");
    setState(() {
      _hungerLocationToAdd = argument;
    });
    panelControllerHungerReport.panelPosition = 0.5;
  }

  void _hunegrInfoUpdate(bool val) {
    FocusScope.of(context).unfocus();
    if (val) {
      setState(() {
        _markers.clear();
        _selectedElement = {};
      });
      fetchHunger();
    }
  }

  void userInfoUpdated(val) {
    FocusScope.of(context).unfocus();
  }

  void _hungerReoprted(bool val) {
    FocusScope.of(context).unfocus();
    if (val) {
      setState(() {
        _markers.clear();
        _hungerLocationToAdd = null;
      });
      if (val) fetchHunger();
    }
  }

  void loadingStatusUpdate(val) {
    FocusScope.of(context).unfocus();
    setState(() {
      loading = val;
    });
  }

  void goHome() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => MyHomePage()));
  }
}
