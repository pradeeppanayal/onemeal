import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:onemealapp/oneMealRestClient.dart';
import 'package:rxdart/rxdart.dart';

/*
 * @author : Pradeep CH
 * @version : 1.0  
 */
class AuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  FirebaseUser currentUser;
  String userToken;
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  var oneMealCurrentUser;

  PublishSubject loading = PublishSubject();
  Future<String> googleSignIn() async {
    loading.add(true);
    GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null;
    GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final AuthResult authResult =
        await _firebaseAuth.signInWithCredential(credential);
    final FirebaseUser resultUser = authResult.user;
    var token = await resultUser.getIdToken();
    assert(token != null);
    currentUser = await _firebaseAuth.currentUser();
    assert(resultUser.uid == currentUser.uid);
    loading.add(false);
    userToken = token.token;
    return token.token;
  }

  Future<bool> updatePreferredName(String name) async {
    if (name == null) {
      print("No name to update");
      return false;
    }
    var userPayload = {'username': currentUser.uid, 'preferredName': name};
    try {
      var resp = await oneMealRestClient.addupdateUser(userPayload);
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
    var userPayload = {
      'userId': currentUser.uid,
      'displayName': currentUser.displayName,
      'email': currentUser.email,
      'location': {
        '_latitude': location.latitude,
        '_longitude': location.longitude
      },
      'username': currentUser.uid,
      'photoUrl': currentUser.photoUrl,
      'notificationToken': notificationToken,
    };
    try {
      var resp = await oneMealRestClient.addupdateUser(userPayload);
      print("User info updated. Response : $resp");
    } catch (e) {
      print("Could not update the user info");
    }
    await fetchCurrentUserDetails();
  }

  Future<void> fetchCurrentUserDetails() async {
    try {
      oneMealCurrentUser =
          await oneMealRestClient.getUserDetails(currentUser.uid);
    } catch (e) {
      print("Error getting user info");
    }
  }

  Future<String> getUserToken() async {
    if (currentUser == null) return null;
    return (await currentUser.getIdToken()).token;
  }

  Future<String> tryLogin() async {
    await googleSignIn();
    return getUserToken();
  }

  Future<bool> isUserSignedIn() async {
    return await _googleSignIn.isSignedIn();
  }

  signOut() async {
    await _googleSignIn.signOut();
  }
}

final AuthService authService = AuthService();
