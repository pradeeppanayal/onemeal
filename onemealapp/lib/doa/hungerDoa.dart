import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:onemealapp/auth.dart';
import 'package:onemealapp/beans/constants.dart';
import 'package:onemealapp/beans/hunger.dart';
import 'package:onemealapp/beans/status.dart';
import 'package:onemealapp/beans/user.dart';
import 'package:onemealapp/doa/actionDoa.dart';
import 'package:onemealapp/doa/userDoa.dart';
import 'package:onemealapp/doa/notification.dart';
import 'package:onemealapp/utils.dart';

/**
 * @author Pradeep CH
 */
class HungerDOA {
  final FirebaseFirestore db;
  static const ORDERS = 'orders';
  static const ITEMS = 'items';

  HungerDOA(this.db);

  Future<List<HungerItem>> getHungers(LatLng currentLocation) async {
    List<HungerItem> response = List();
    String formattedDateKey = CommonUtil.getDateAsKey();
    var dateDocs =
        db.collection(ORDERS).doc(formattedDateKey).collection(ITEMS);

    //location
    var locationRange = CommonUtil.getLocationRange(currentLocation, 1.0);
    //console.log(providerlocation);
    //console.log(locationRange);
    await dateDocs //.where("status","==","open")//
        .where("location", isGreaterThan: locationRange['lesserGeopoint'])
        .where("location", isLessThan: locationRange['greaterGeopoint'])
        //.orderBy("status")
        .get()
        .then((snapshot) => {
              snapshot.docs.forEach((element) {
                HungerItem item = HungerItem().load(element.data());
                item.id = element.id;
                response.add(item);
              })
            });
    return response;
  }

  Future<int> getUserReportedHungerCount(DateTime date, String userId) async {
    String formattedDateKey = CommonUtil.getDateAsKey(date: date);
    int count = 0;
    var dateDocs =
        db.collection(ORDERS).doc(formattedDateKey).collection(ITEMS);
    await dateDocs
        .where("reporterId", isEqualTo: userId)
        .get()
        .then((snapshot) => {count = snapshot.docs.length});
    return count;
  }

  Future<bool> satisfyHunger(String id, String comment) async {
    String formattedDateKey = CommonUtil.getDateAsKey();
    var dateDocs =
        db.collection(ORDERS).doc(formattedDateKey).collection(ITEMS).doc(id);
    var data = await dateDocs.get();
    if (!data.exists) throw Exception("Item does not exist");
    HungerItem item = HungerItem().load(data.data());
    item.status = "Served";
    item.servedBy = authService.oneMealCurrentUser == null ||
            authService.oneMealCurrentUser.preferredName == null
        ? authService.currentUser.displayName
        : authService.oneMealCurrentUser.preferredName;
    item.servedById = authService.currentUser.uid;
    item.serveTime = CommonUtil.currentTime();
    item.comment = comment;
    await dateDocs.update(item.toMap());
    //The user report and serve this does not count
    if (item.reporterId == item.servedById) return true;
    actionDOA.logAction(authService.currentUser.uid, "serve");
    _sendHungerServedNotification(item);
    return true;
  }

  Future<bool> reportHunger(HungerItem item) async {
    if ((await getUserReportedHungerCount(null, authService.currentUser.uid)) >=
        OneMealConstants.MAX_REPORT_COUNT) {
      throw Exception("Maximum report count reached.");
    }
    item.reporter = authService.oneMealCurrentUser.preferredName;
    item.reporterId = authService.currentUser.uid;
    item.reportTime = CommonUtil.currentTime();
    item.status = HungerStatus.OPEN;
    String formattedDateKey = CommonUtil.getDateAsKey();
    var doc =
        db.collection(ORDERS).doc(formattedDateKey).collection(ITEMS).doc();
    await doc.set(item.toMap());
    _sendHungerReportNotification(item, doc.id);
    actionDOA.logAction(authService.currentUser.uid, "report");
    return true;
  }

  Future<void> _sendHungerReportNotification(HungerItem item, String id) async {
    if (item == null || item.location == null) return;
    var locationRange = CommonUtil.getLocationRange(item.location, 1);

    var title = "Hunger Reported";
    var body = "A hunger has been reported near by.";
    var data = {"id": id != null ? id : "no id"};
    List<String> userTokens = List();
    var dateDocs = db.collection(UserDOA.USERS);
    await dateDocs
        .where("location",
            isGreaterThanOrEqualTo: locationRange['lesserGeopoint'])
        .where("location",
            isLessThanOrEqualTo: locationRange['greaterGeopoint'])
        .get()
        .then((snapshot) => {
              snapshot.docs.forEach((doc) {
                var val = doc.data();
                if (val['reporterId'] != authService.currentUser.uid &&
                    val['notificationToken'] != null)
                  userTokens.add(val['notificationToken']);
              })
            });
    if (userTokens.length > 0)
      NotificationUtil.sendNotification(title, body, userTokens, data);
  }

  Future<void> _sendHungerServedNotification(HungerItem val) async {
    var reporterId = val.reporterId;
    var servedBy = val.servedBy;
    if (reporterId == null || servedBy == null) return;
    final OneMealUser reporter = await userDOA.getUserDetails(reporterId);
    if (reporter == null || reporter.notificationToken == null) return;

    var title = "Meal Served";
    var body =
        "One of your reported hungers has been served by '" + servedBy + "' ";
    var data = {"id": val.id != null ? val.id : "no id"};
    List<String> userTokens = List();
    userTokens.add(reporter.notificationToken);
    NotificationUtil.sendNotification(title, body, userTokens, data);
  }
}

final HungerDOA hungerDOA = HungerDOA(FirebaseFirestore.instance);
