import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:onemealapp/oneMealRestClient.dart';
import 'package:onemealapp/utils.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

/*
 * @author : Pradeep CH
 * @version : 1.0  
 */
class HungerReportWidget extends StatelessWidget {
  HungerReportWidget(
      {this.panelControllerHungerReport,
      this.hungerLocationToAdd,
      this.callBack,
      this.loadingStatusUpdate,
      this.loading,
      this.userLocation});
  final panelControllerHungerReport;
  final hungerLocationToAdd;
  static final _formKey = GlobalKey<FormState>();
  final _formValueController = TextEditingController();
  final _formValueControllerTitle = TextEditingController();
  final callBack;
  final loadingStatusUpdate;
  final loading;
  final userLocation;

  @override
  Widget build(BuildContext context) {
    return SlidingUpPanel(
      controller: panelControllerHungerReport,
      panel: Stack(children: <Widget>[
        Padding(
            padding: const EdgeInsets.all(15),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  TextFormField(
                    controller: _formValueControllerTitle,
                    decoration: InputDecoration(
                        hintText: "Short note to identify the needy"),
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please enter some text';
                      }
                      return null;
                    },
                    maxLength: 50,
                  ),
                  TextFormField(
                      controller: _formValueController,
                      keyboardType: TextInputType.multiline,
                      decoration: InputDecoration(
                          hintText: "Little more details (optional)"),
                      maxLines: 4,
                      maxLength: 100,
                      enabled: !loading),
                  RaisedButton(
                    color: Colors.blue,
                    textColor: Colors.white,
                    onPressed: loading ? null : _reporthunger,
                    child: Text('Submit'),
                  ),
                ],
              ),
            )),
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

  void _cancelClicked() {
    panelControllerHungerReport.panelPosition = 0.0;
    _formValueController.clear();
    callBack(false);
  }

  void _reporthunger() async {
    if (!_formKey.currentState.validate() || loading) {
      return;
    }
    loadingStatusUpdate(true);
    var description = _formValueController.value.text;
    var title = _formValueControllerTitle.value.text;
    try {
      var resp = await oneMealRestClient.reportHunger(
          hungerLocationToAdd, description, title, userLocation);
      if (resp != null) {
        _formValueController.clear();
        _formValueControllerTitle.clear();
        panelControllerHungerReport.panelPosition = 0.0;
        UserInfoMessageUtil.showMessage(
            "Thank you, hunger reported.", UserInfoMessageMode.SUCCESS);
        loadingStatusUpdate(false);
        callBack(true);
        return;
      } else {
        UserInfoMessageUtil.showMessage(
            "Could not save.", UserInfoMessageMode.ERROR);
      }
    } catch (e) {
      UserInfoMessageUtil.showMessage(
          "Could not save.", UserInfoMessageMode.ERROR);
    }
    loadingStatusUpdate(false);
    callBack(false);
  }
}
