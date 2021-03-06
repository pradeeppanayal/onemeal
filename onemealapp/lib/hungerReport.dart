import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:onemealapp/beans/hunger.dart';
import 'package:onemealapp/doa/hungerDoa.dart';
import 'package:onemealapp/utils.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

/*
 * @author : Pradeep CH
 * @version : 1.0  
 */

class HungerReportWidget extends StatefulWidget {
  final PanelController panelControllerHungerReport;
  final LatLng hungerLocationToAdd;
  final Function callBack;
  final LatLng userLocation;

  HungerReportWidget(this.panelControllerHungerReport, this.hungerLocationToAdd,
      this.callBack, this.userLocation);

  @override
  _HungerReportWidgetState createState() => _HungerReportWidgetState();
}

class _HungerReportWidgetState extends State<HungerReportWidget> {
  bool loading = false;

  static final _formKey = GlobalKey<FormState>();
  final _formValueController = TextEditingController();
  final _formValueControllerTitle = TextEditingController();

  @override
  Widget build(BuildContext context) {
    //print("Build called");
    return SlidingUpPanel(
      controller: widget.panelControllerHungerReport,
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
    widget.panelControllerHungerReport.panelPosition = 0.0;
    _formValueController.clear();
    _formValueControllerTitle.clear();
    widget.callBack(false);
  }

  void _reporthunger() async {
    if (!_formKey.currentState.validate() || loading) {
      return;
    }
    //loadingStatusUpdate(true);
    setState(() {
      loading = true;
    });
    var description = _formValueController.value.text;
    var title = _formValueControllerTitle.value.text;
    try {
      HungerItem item = HungerItem();
      item.description = description;
      item.location = widget.hungerLocationToAdd;
      item.title = title.trim();
      item.reporterLocation = widget.userLocation;
      var resp = await hungerDOA.reportHunger(item);
      if (resp != null && resp) {
        _formValueController.clear();
        _formValueControllerTitle.clear();
        widget.panelControllerHungerReport.panelPosition = 0.0;
        UserInfoMessageUtil.showMessage(
            "Thank you, hunger reported.", UserInfoMessageMode.SUCCESS);
        setState(() {
          loading = false;
        });
        widget.callBack(true);
        return;
      } else {
        UserInfoMessageUtil.showMessage(
            "Could not save.", UserInfoMessageMode.ERROR);
      }
    } catch (e) {
      print(e);
      UserInfoMessageUtil.showMessage(e.message, UserInfoMessageMode.ERROR);
    }
    setState(() {
      loading = false;
    });
    widget.callBack(false);
  }
}
