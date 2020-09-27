import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:onemealapp/beans/storableBean.dart';

/**
 * @author Pradeep CH
 */
class OneMealUser extends StorableBean {
  int createdOn;
  String displayName;
  String email;
  int lastUpdated;
  LatLng location;
  String notificationToken;
  String phtoURL;
  String preferredName;
  String userId;
  String userName;
  int reportCount;
  int serveCount;

  @override
  OneMealUser load(Map<String, dynamic> attributes) {
    this.createdOn = attributes['createdOn'];
    this.displayName = attributes['displayName'];
    this.email = attributes['email'];
    this.lastUpdated = attributes['lastUpdated'];
    this.notificationToken = attributes['notificationToken'];
    this.phtoURL = attributes['phtoURL'];
    this.preferredName = attributes['preferredName'];
    this.userId = attributes['userId'];
    this.userName = attributes['userName'];
    this.location = getAsLocation(attributes['location']);
    this.reportCount = attributes['reportCount'];
    this.serveCount = attributes['serveCount'];

    return this;
  }

  LatLng getAsLocation(dynamic attribut) {
    if (attribut == null) return null;
    if (attribut is GeoPoint)
      return LatLng(attribut.latitude, attribut.longitude);
    return null;
  }

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> attributes = Map();
    if (this.createdOn != null) attributes['createdOn'] = this.createdOn;
    if (this.displayName != null) attributes['displayName'] = this.displayName;
    if (this.email != null) attributes['email'] = this.email;
    if (this.lastUpdated != null) attributes['lastUpdated'] = this.lastUpdated;
    if (this.userName != null) attributes['userName'] = this.userName;
    if (this.notificationToken != null)
      attributes['notificationToken'] = this.notificationToken;
    if (this.phtoURL != null) attributes['phtoUrl'] = this.phtoURL;
    if (this.preferredName != null)
      attributes['preferredName'] = this.preferredName;
    if (this.location != null)
      attributes['location'] = GeoPoint(location.latitude, location.longitude);

    return attributes;
  }
}

class UserAction extends StorableBean {
  String uid;
  String action;
  int date;

  @override
  StorableBean load(Map<String, dynamic> attributes) {
    this.uid = attributes['uid'];
    this.action = attributes['action'];
    this.date = attributes['date'];
    return this;
  }

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> attributes = Map();
    attributes['uid'] = this.uid;
    attributes['action'] = this.action;
    attributes['date'] = this.date;
    return attributes;
  }
}
