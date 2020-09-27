import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:onemealapp/beans/user.dart';
import 'package:onemealapp/doa/userDoa.dart';
import 'package:rxdart/rxdart.dart';

/*
 * @author : Pradeep CH
 * @version : 2.0
 */
class AuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  User currentUser;
  String userToken;
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  OneMealUser oneMealCurrentUser;

  PublishSubject loading = PublishSubject();
  Future<void> googleSignIn() async {
    loading.add(true);
    GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null;
    GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final UserCredential authResult =
        await _firebaseAuth.signInWithCredential(credential);
    //final User resultUser = authResult.user;
    // var token = await resultUser.getIdToken();
    // assert(token != null);
    currentUser = _firebaseAuth.currentUser;
    //assert(resultUser.uid == currentUser.uid);
    loading.add(false);
    //userToken = token;
    //return token;
  }

  Future<bool> updatePreferredName(String name) async {
    if (name == null) {
      print("No name to update");
      return false;
    }
    OneMealUser onemealUser = OneMealUser();
    onemealUser.userName = currentUser.uid;
    onemealUser.userId = currentUser.uid;
    onemealUser.preferredName = name;

    try {
      var resp = await userDOA.addupdateUser(onemealUser);
      print("User info updated. Response : $resp");
    } catch (e) {
      print("Could not update the user info");
      return false;
    }
    return true;
  }

  void updateUserData(LatLng location) async {
    if (currentUser == null) {
      print("No user info");
      return;
    }
    String notificationToken = await _firebaseMessaging.getToken();
    OneMealUser oneMealUser = OneMealUser();
    oneMealUser.userId = currentUser.uid;
    oneMealUser.displayName = currentUser.displayName;
    oneMealUser.email = currentUser.email;
    oneMealUser.location = location;
    oneMealUser.userName = currentUser.uid;
    oneMealUser.phtoURL = currentUser.photoURL;
    oneMealUser.notificationToken = notificationToken;

    try {
      var resp = await userDOA.addupdateUser(oneMealUser);
      print("User info updated. Response : $resp");
    } catch (e) {
      print(e);
      print("Could not update the user info");
    }
    await fetchCurrentUserDetails();
  }

  Future<void> fetchCurrentUserDetails() async {
    oneMealCurrentUser = await userDOA.getUserDetails(currentUser.uid);
  }

  Future<bool> tryLogin() async {
    await googleSignIn();
    await fetchCurrentUserDetails();
    return true;
  }

  Future<bool> isUserSignedIn() async {
    return await _googleSignIn.isSignedIn();
  }

  signOut() async {
    await _googleSignIn.signOut();
  }
}

final AuthService authService = AuthService();
