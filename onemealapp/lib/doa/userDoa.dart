import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:onemealapp/beans/user.dart';

/**
 * @author Pradeep CH
 */
class UserDOA {
  final FirebaseFirestore db;
  static const USERS = 'users';
  UserDOA(this.db);

  Future<bool> addupdateUser(OneMealUser user) async {
    if (user.userId == null || user.userId.isEmpty) {
      throw Exception("User id cannot be empty or null");
    }
    var doc = db.collection(USERS).doc(user.userId);
    var userData = await doc.get();
    if (userData.exists) doc.update(user.toMap());
    doc.set(user.toMap());
    return true;
  }

  Future<OneMealUser> getUserDetails(String uid) async {
    if (uid == null || uid.isEmpty) {
      throw Exception("User id cannot be empty or null");
    }
    var doc = db.collection(USERS).doc(uid);
    var userData = await doc.get();
    if (!userData.exists) throw Exception("User does not exist");
    return OneMealUser().load(userData.data());
  }
}

final UserDOA userDOA = UserDOA(FirebaseFirestore.instance);
