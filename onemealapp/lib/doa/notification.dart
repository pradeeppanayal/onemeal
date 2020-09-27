import 'dart:convert';

import 'package:onemealapp/beans/constants.dart';
import 'package:http/http.dart' as http;

/**
 * author : Pradeep CH
 */
class NotificationUtil {
  NotificationUtil(_);
  static final postURL = 'https://fcm.googleapis.com/fcm/send';

  static Future<bool> sendNotification(String title, String body,
      List<String> tokens, dynamic datatoSend) async {
    print("Sending notification to $tokens");
    final data = {
      "registration_ids": tokens,
      "collapse_key": "type_a",
      "notification": {
        "title": title,
        "body": body,
      },
      "data": datatoSend
    };

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': OneMealConstants.KEY_APIFCM // 'key=YOUR_SERVER_KEY'
    };

    final response = await http.post(postURL,
        body: json.encode(data),
        encoding: Encoding.getByName('utf-8'),
        headers: headers);
    print(response.body);
    if (response.statusCode == 200) {
      // on success do sth
      print('CFM Sent');
      return true;
    } else {
      print(' CFM error');
      // on failure do sth
      return false;
    }
  }
}
