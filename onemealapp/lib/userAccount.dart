import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:onemealapp/auth.dart';
import 'package:onemealapp/doa/actionDoa.dart';
import 'package:onemealapp/settings.dart';
import 'package:onemealapp/utils.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

/*
 * @author : Pradeep CH
 * @version : 1.0  
 */
class UserAccountPage extends StatefulWidget {
  final PanelController panelController;
  UserAccountPage(this.panelController);
  @override
  _UserAccountPageState createState() => _UserAccountPageState();
}

class _UserAccountPageState extends State<UserAccountPage> {
  //static final double avatarSize = 50.0;
  int report = 0;
  int serve = 0;
  bool loading = false;
  Widget getCancelButton() {
    return Positioned(
      child: IconButton(
        onPressed: _cancelClicked,
        icon: Icon(Icons.close),
      ),
      top: 0,
      right: 0,
    );
  }

  @override
  void didUpdateWidget(UserAccountPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    _fetchSummary();
  }

  _cancelClicked() {
    widget.panelController.panelPosition = 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return SlidingUpPanel(
      controller: widget.panelController,
      panel: Stack(children: <Widget>[
        Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width),
        Positioned(
            top: 30.0,
            child: Container(
                width: MediaQuery.of(context).size.width - 10,
                child: Column(children: [
                  ListTile(
                      title: Text(
                        authService.currentUser.displayName,
                        style: TextStyle(fontSize: 20),
                      ),
                      subtitle:
                          Text("$report hunger reported\n$serve meal served"),
                      /*subtitle: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                          width: MediaQuery.of(context).size.width * 0.5,
                          child: LinearProgressIndicator(
                            backgroundColor: Colors.red,
                            value: serve / (report + serve),
                          ),
                        ),
                            Text("$report hunger reported."),
                            Text("$serve meal served."),
                          ]),*/
                      leading: CircleAvatar(
                        backgroundImage:
                            NetworkImage(authService.currentUser.photoURL),
                        backgroundColor: Colors.white,
                        //minRadius: avatarSize, //avatarSize,
                        //maxRadius: avatarSize,
                      ),
                      onTap: null),
                  _divider(context),
                  SettingsItems()
                ]))),
        Positioned(
          child: IconButton(
            color: Colors.grey,
            onPressed: _cancelClicked,
            icon: Icon(Icons.close),
          ),
          top: 0,
          right: 0,
        ),
      ]),
      isDraggable: false,
      minHeight: 0.0,
      boxShadow: [
        BoxShadow(
          blurRadius: 20.0,
          color: Colors.grey,
        ),
      ],
      borderRadius: CommonUtil.getMarginRadius(),
    );
  }

  void _fetchSummary() async {
    if (loading) return;
    loading = true;
    try {
      Map<String, int> summary =
          await actionDOA.getActionSummary(authService.currentUser.uid);
      setState(() {
        this.report = summary['report'] ?? 0;
        this.serve = summary['serve'] ?? 0;
      });
    } catch (e) {
      print(e);
    }
    loading = false;
  }

  Widget _divider(BuildContext context) {
    return SizedBox(
        width: MediaQuery.of(context).size.width - 100,
        child: Divider(
          thickness: 1.0,
          color: Colors.grey[300],
        ));
  }
}
