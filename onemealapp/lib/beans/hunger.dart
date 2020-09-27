import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:onemealapp/beans/storableBean.dart';
import 'package:onemealapp/utils.dart';

/**
 * @author Pradeep CH
 */
class HungerItem extends StorableBean {
  String comment;
  String description;
  String title;
  LatLng location;
  int reportTime;
  String reporter;
  String reporterId;
  LatLng reporterLocation;
  int serveTime;
  String servedBy;
  String servedById;
  String status;
  String id;

  @override
  HungerItem load(Map<String, dynamic> attributes) {
    this.id = attributes['id'];
    this.comment = attributes['comment'];
    this.description = attributes['description'];
    this.location = CommonUtil.getAsLocation(attributes['location']);
    this.reportTime = attributes['reportTime'];
    this.reporter = attributes['reporter'];
    this.reporterId = attributes['reporterId'];
    this.reporterLocation =
        CommonUtil.getAsLocation(attributes['reporterLocation']);
    this.serveTime = attributes['serveTime'];
    this.servedBy = attributes['servedBy'];
    this.servedById = attributes['servedById'];
    this.status = attributes['status'];
    this.title = attributes['title'];
    return this;
  }

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> attributes = Map();
    if (this.comment != null) attributes['comment'] = this.comment;
    if (this.description != null) attributes['description'] = this.description;
    if (this.location != null)
      attributes['location'] = GeoPoint(location.latitude, location.longitude);
    if (this.reportTime != null) attributes['reportTime'] = this.reportTime;
    if (this.reporter != null) attributes['reporter'] = this.reporter;
    if (this.reporterId != null) attributes['reporterId'] = this.reporterId;
    if (this.reporterLocation != null)
      attributes['reporterLocation'] =
          GeoPoint(reporterLocation.latitude, reporterLocation.longitude);
    if (this.serveTime != null) attributes['serveTime'] = this.serveTime;
    if (this.servedBy != null) attributes['servedBy'] = this.servedBy;
    if (this.servedById != null) attributes['servedById'] = this.servedById;
    if (this.status != null) attributes['status'] = this.status;
    if (this.title != null) attributes['title'] = this.title;
    return attributes;
  }

  @override
  String toString() {
    return toMap().toString();
  }
}
