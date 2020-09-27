import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:onemealapp/beans/user.dart';
import 'package:onemealapp/utils.dart';

/**
 * @author Pradeep CH
 */
class ActionDOA {
  final FirebaseFirestore db;
  ActionDOA(this.db);
  static const String ACTIONS = "actions";

  Future<void> logAction(String uid, String action) async {
    if (uid == null || uid.isEmpty || action == null || action.isEmpty) return;

    UserAction userAction = UserAction();
    userAction.action = action;
    userAction.date = CommonUtil.currentTime();
    userAction.uid = uid;

    var doc = db.collection(ACTIONS).doc(uid).collection(action).doc();
    await doc.set(userAction.toMap());
  }

  Future<Map<String, int>> getActionSummary(String uid) async {
    var doc = db.collection(ACTIONS).doc(uid);
    //print(uid);
    Map<String, int> summary = Map();
    Set<String> actions = {'report', 'serve'};
    for (String key in actions) {
      await doc
          .collection(key)
          .get()
          .then((value) => {summary[key] = value.docs.length});
    }
    return summary;
  }
}

final ActionDOA actionDOA = ActionDOA(FirebaseFirestore.instance);
