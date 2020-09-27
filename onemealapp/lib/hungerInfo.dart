import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:onemealapp/beans/hunger.dart';
import 'package:onemealapp/beans/status.dart';
import 'package:onemealapp/doa/hungerDoa.dart';
import 'package:onemealapp/utils.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

/*
 * @author : Pradeep CH
 * @version : 1.0  
 */
class HungerInfoClass {
  List<Widget> getAsChild(dynamic val) {
    List<Widget> child = <Widget>[];
    if (!(val is Map) || val['id'] == null) {
      return child;
    }
    var item = val as Map;
    var reoprtedby = item['reporter'];
    var dateTime = item['reportTime'];
    DateTime dt = DateTime.fromMicrosecondsSinceEpoch(dateTime * 1000);

    var description =
        item['description'] != null ? item['description'] : " No description";
    var title = item['title'] != null ? item['title'] : " No title provided";
    var status = item['status'];
    child.add(ListTile(
      autofocus: false,
      leading: Icon(
        Icons.flag,
        size: 50.0,
        color: status == HungerStatus.OPEN ? Colors.red : Colors.green,
      ),
      title: Text(title),
      subtitle: Text(
          "Reported by $reoprtedby at ${DateFormat.jm().format(dt)} with a description \"$description\""),
    ));
    return child;
  }
}

HungerInfoClass hungerInfoClass = HungerInfoClass();

class HungerInfo extends StatefulWidget {
  HungerInfo(
      {this.panelController,
      this.currentLocation,
      this.selectedElement,
      this.callback,
      this.loading,
      this.loadingStatusUpdate});
  final HungerItem selectedElement;
  final callback;
  final currentLocation;
  final loadingStatusUpdate;
  final loading;
  final PanelController panelController;
  @override
  _HungerInfoState createState() => _HungerInfoState();
}

class _HungerInfoState extends State<HungerInfo> {
  static final minDistanceToServe = 0.1; //km 100 m
  final TextEditingController _serveFormValueController =
      TextEditingController();
  HungerItem selectedElement;
  bool loading = false;
  Widget getAsError(String msg) {
    return wrappAsSlidUpPanel(Text(msg));
  }

  Widget wrappAsSlidUpPanel(Widget child) {
    return SlidingUpPanel(
      controller: widget.panelController,
      panel: Stack(children: [child, getCancelButton()]),
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

  @override
  Widget build(BuildContext context) {
    selectedElement = widget.selectedElement;
    if (widget.currentLocation == null)
      return getAsError("Your location could not be determined.");
    if (widget.selectedElement == null || widget.selectedElement.id == null)
      return getAsError("There is no item selected.");

    var itemLocation = widget.selectedElement.location;
    var distance = CommonUtil.calculateDistance(
        widget.currentLocation, itemLocation); //in kms
    distance = double.parse(distance.toStringAsFixed(2));
    return wrappAsSlidUpPanel(Padding(
      padding: const EdgeInsets.all(15),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Column(children: hungerInfoClass.getAsChild(widget.selectedElement)),
          _getTheCommentBox(distance),
          _conditionallyGetServeButton(distance),
        ],
      ),
    ));
  }

  void _hungerInfoCancelClicked() {
    widget.panelController.panelPosition = 0.0;
    _serveFormValueController.clear();
    widget.callback(false);
  }

  void _mealServed() async {
    if (selectedElement == null || loading) return;
    var comment = _serveFormValueController.value.text.trim();
    comment = comment.length == 0 ? "No comments." : comment;

    setState(() {
      loading = true;
    });
    try {
      bool resp = await hungerDOA.satisfyHunger(selectedElement.id, comment);
      if (resp != null && resp) {
        widget.panelController.panelPosition = 0.0;
        UserInfoMessageUtil.showMessage(
            "Thank you, It was really kind.", UserInfoMessageMode.SUCCESS);
        _serveFormValueController.clear();
        widget.callback(true);
      } else {
        UserInfoMessageUtil.showMessage(
            "Could not update the status", UserInfoMessageMode.ERROR);
        widget.callback(false);
      }
    } catch (e) {
      UserInfoMessageUtil.showMessage(
          "Could not update the status. ${e.message}",
          UserInfoMessageMode.ERROR);
    }
    setState(() {
      loading = false;
    });
  }

  Widget _conditionallyGetServeButton(double distance) {
    //var cancelButton = getCancelButton();
    var emptyWidget = Text("");
    bool userAtNeedy = (distance < minDistanceToServe) &&
        selectedElement.status == HungerStatus.OPEN;
    return Column(
      children: [
        Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              //cancelButton,
              userAtNeedy
                  ? RaisedButton(
                      color: Colors.blue,
                      textColor: Colors.white,
                      onPressed: loading ? null : _mealServed,
                      child: Text('Served'),
                    )
                  : emptyWidget,
            ]),
        Text(
          "Note : Minimum distance estimated to enable the serve opton is $minDistanceToServe km",
          style: TextStyle(fontSize: 10, fontStyle: FontStyle.italic),
        )
      ],
    );
  }

  Widget getCancelButton() {
    return Positioned(
      child: IconButton(
        color: Colors.grey,
        onPressed: _hungerInfoCancelClicked,
        icon: Icon(Icons.close),
      ),
      top: 0,
      right: 0,
    );
  }

  Widget _getTheCommentBox(double distance) {
    if (distance < minDistanceToServe &&
        selectedElement.status == HungerStatus.OPEN)
      return Form(
          child: TextFormField(
        controller: _serveFormValueController,
        keyboardType: TextInputType.multiline,
        //autofocus: true,
        decoration:
            InputDecoration(hintText: "Provide your commet (Optional)."),
        maxLength: 50,
      ));
    if (selectedElement.status == HungerStatus.OPEN)
      return Text(
          "Please take few more steps towards the needy to serve the food. You are $distance km away.");
    return Text(
        "Served by ${selectedElement.servedBy} with a comment \"${selectedElement.comment}\".");
  }
}
