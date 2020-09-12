import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:onemealapp/appPage.dart';
import 'package:onemealapp/utils.dart';
import 'package:url_launcher/url_launcher.dart';
import 'auth.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OneMeal App',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'OneMeal Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool isUserLoggedIn = false;
  bool loading = false;
  void initState() {
    super.initState();
    loading = true;
    authService.isUserSignedIn().then((value) => {_loginStateUpdated(value)});
  }

  _loginStateUpdated(v) {
    setState(() {
      isUserLoggedIn = v;
      loading = false;
    });
    if (isUserLoggedIn) _trylogin();
  }

  @override
  Widget build(BuildContext context) {
    var linkStyle = TextStyle(
        color: Colors.blue,
        fontStyle: FontStyle.italic,
        decoration: TextDecoration.underline);
    var normalTextStyle = TextStyle(
      color: Colors.black,
      fontStyle: FontStyle.italic,
    );
    return Scaffold(
      body: Stack(
        //color: Colors.white,
        children: [
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image(
                  image: AssetImage("assets/images/onemeal.png"),
                  width: 150,
                  height: 150,
                  fit: BoxFit.fill,
                ),
                SizedBox(height: 50),
                loading || isUserLoggedIn
                    ? Text("Please wait..")
                    : _signInButton(),
                SizedBox(height: 100),
              ],
            ),
          ),
          Positioned(
              left: 10,
              right: 10,
              bottom: 50,
              child: RichText(
                  text: TextSpan(style: normalTextStyle, children: [
                TextSpan(
                  text: "By signing up, you agree to our ",
                ),
                TextSpan(
                    style: linkStyle,
                    text: "Terms of Use",
                    recognizer: TapGestureRecognizer()
                      ..onTap = () async {
                        await launchUrl(
                            'https://sites.google.com/view/onemealinfo/usage-policy');
                      }),
                TextSpan(
                  text: " and ",
                ),
                TextSpan(
                    text: "Privacy Policy.",
                    style: linkStyle,
                    recognizer: TapGestureRecognizer()
                      ..onTap = () async {
                        await launchUrl(
                            'https://sites.google.com/view/onemealinfo/privacy-policy');
                      }),
              ]))),
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

  launchUrl(url) async {
    if (await canLaunch(url)) {
      await launch(url, forceSafariVC: false);
    }
  }

  Widget _signInButton() {
    return OutlineButton(
      splashColor: Colors.grey,
      onPressed: _trylogin,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
      highlightElevation: 0,
      borderSide: BorderSide(color: Colors.grey),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image(
                image: AssetImage("assets/images/google_logo.png"),
                height: 35.0),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text(
                'Sign in with Google',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.grey,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  _trylogin() {
    if (loading) return;
    setState(() {
      loading = true;
    });
    authService
        .tryLogin()
        .then((value) => {
              if (value != null && authService.getUserToken() != null)
                {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => MainPage()))
                }
            })
        .then((value) => setState(() {
              loading = false;
            }))
        .catchError((error) => showLoginfailedError());
  }

  showLoginfailedError() {
    UserInfoMessageUtil.showMessage("Login failed.", UserInfoMessageMode.ERROR);
    setState(() {
      loading = false;
    });
  }
}
