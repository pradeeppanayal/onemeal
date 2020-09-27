import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:onemealapp/auth.dart';
import 'package:onemealapp/main.dart';
import 'package:onemealapp/myProfile.dart';
import 'package:url_launcher/url_launcher.dart';

/**
 * @author Pradeep CH
 */
class SettingsItems extends StatelessWidget {
  final Completer<BuildContext> _context = Completer();

  @override
  Widget build(BuildContext context) {
    _context.complete(context);
    return Container(
        width: MediaQuery.of(context).size.width - 10,
        height: MediaQuery.of(context).size.height * 0.8,
        child: ListView(
          children: [
            Card(
                child: ListTile(
              title: Text("My Profile"),
              subtitle: Text("Manage your profile"),
              leading: Icon(Icons.verified_user, color: Colors.green),
              onTap: () => {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => MyProfile()))
              },
            )),
            Card(
                child: ListTile(
              title: Text("Help"),
              subtitle: Text("Visit us to know more"),
              leading: Icon(Icons.help, color: Colors.blue),
              onTap: () =>
                  {launch("https://sites.google.com/view/onemealinfo")},
            )),
            Card(
                child: ListTile(
              title: Text("Logout"),
              subtitle: Text("Logout from the app"),
              leading: Icon(Icons.exit_to_app, color: Colors.red),
              onTap: () => {_performLogout()},
            )),
          ],
        ));
  }

  _performLogout() async {
    await authService.signOut();
    var context = await _context.future;
    while (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
    Navigator.pushReplacementNamed(context, "/");
  }
}
