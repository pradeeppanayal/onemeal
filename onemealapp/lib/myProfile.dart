import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:onemealapp/auth.dart';
import 'package:onemealapp/utils.dart';

/**
 * @author Pradeep CH
 */
class MyProfile extends StatefulWidget {
  @override
  MyProfileState createState() => MyProfileState();
}

class MyProfileState extends State<MyProfile> {
  bool editEnabled = false;
  bool loading = false;
  TextEditingController pNameController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Profile"),
        backgroundColor: Colors.green,
      ),
      body: Stack(
        children: [
          ListView(
            children: [
              Card(
                child: ListTile(
                  title: Text("Name"),
                  subtitle: Text(authService.currentUser.displayName),
                ),
              ),
              Card(
                child: Column(children: [
                  ListTile(
                    title: Text("Preferred Name"),
                    subtitle: !editEnabled
                        ? Text(_fetchPreferedName())
                        : _getEditText(),
                    trailing: !editEnabled
                        ? IconButton(
                            icon: Icon(Icons.edit), onPressed: _enableEdit)
                        : IconButton(
                            icon: Icon(Icons.save), onPressed: _savePName),
                  ),
                  Text(
                    "Only this name will be shown to others when you \"Report\" or \"Serve\".",
                    style: TextStyle(fontSize: 10, fontStyle: FontStyle.italic),
                  )
                ]),
              ),
            ],
          ),
          Container(width: MediaQuery.of(context).size.width),
          Visibility(
            child: Positioned(
                width: MediaQuery.of(context).size.width,
                child: LinearProgressIndicator(),
                bottom: 0.0),
            visible: loading,
          ),
        ],
      ),
    );
  }

  String _fetchPreferedName() {
    if (authService.oneMealCurrentUser != null &&
        authService.oneMealCurrentUser.preferredName != null)
      return authService.oneMealCurrentUser.preferredName;
    return authService.currentUser.displayName;
  }

  _enableEdit() {
    setState(() {
      this.editEnabled = true;
    });
  }

  void _savePName() async {
    if (loading) return;
    var name = pNameController.value.text; //.trim();
    if (name == null || name.trim().isEmpty) {
      UserInfoMessageUtil.showMessage(
          "Provide a name", UserInfoMessageMode.ERROR);
      return;
    }
    name = name.trim();
    if (name.length > 20) {
      UserInfoMessageUtil.showMessage(
          "Name too big", UserInfoMessageMode.ERROR);
      return;
    }
    setState(() {
      loading = true;
    });
    try {
      await authService.updatePreferredName(name);
      await authService.fetchCurrentUserDetails();
      UserInfoMessageUtil.showMessage(
          "Preferred name updated", UserInfoMessageMode.SUCCESS);
    } catch (e) {
      UserInfoMessageUtil.showMessage(
          "Preferred name not updated", UserInfoMessageMode.ERROR);
    }
    setState(() {
      this.loading = false;
      this.editEnabled = false;
    });
  }

  _getEditText() {
    pNameController.text = _fetchPreferedName();
    return TextField(
      controller: pNameController,
      autofocus: editEnabled,
    );
  }
}
