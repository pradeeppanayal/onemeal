import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:onemealapp/auth.dart';
import 'package:onemealapp/settings.dart';
import 'package:onemealapp/utils.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

/*
 * @author : Pradeep CH
 * @version : 1.0  
 */
class UserProfileWidget extends StatelessWidget {
  UserProfileWidget(
      {this.panelController,
      this.callback,
      this.loadingStateUpdateCallBack,
      this.loading,
      this.goHome});
  final PanelController panelController;
  final _formValueController = TextEditingController();
  static final double avatarSize = 50.0;
  final loadingStateUpdateCallBack;
  final loading;
  final goHome;
  final callback;
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

  _cancelClicked() {
    panelController.panelPosition = 0.0;
    callback(false);
  }

  @override
  Widget build(BuildContext context) {
    if (authService.oneMealCurrentUser == null ||
        authService.oneMealCurrentUser['preferredName'] == null)
      _formValueController.text = authService.currentUser.displayName;
    else
      _formValueController.text =
          authService.oneMealCurrentUser['preferredName'];

    return SlidingUpPanel(
      controller: panelController,
      panel: Stack(children: <Widget>[
        Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width),
        Container(
          decoration: BoxDecoration(
            gradient: new LinearGradient(
                colors: [Colors.green, Colors.lightGreenAccent],
                begin: const FractionalOffset(0.0, 0.0),
                end: const FractionalOffset(1.0, 0.0),
                stops: [0.6, 1.0],
                tileMode: TileMode.clamp),
          ),
          height: MediaQuery.of(context).size.height * 0.2,
        ),
        Positioned(
          top: MediaQuery.of(context).size.height * 0.2 - avatarSize,
          width: MediaQuery.of(context).size.width,
          child: Center(
              child: Column(children: [
            CircleAvatar(
              backgroundImage: NetworkImage(authService.currentUser.photoUrl),
              backgroundColor: Colors.white,
              minRadius: avatarSize, //avatarSize,
              maxRadius: avatarSize,
            ),
            Text(
              authService.currentUser.displayName,
              style: TextStyle(fontSize: 20),
            )
          ])),
        ),
        Positioned(
            top: MediaQuery.of(context).size.height * 0.2 + avatarSize * 1.5,
            child: SettingsItems()),
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
}
