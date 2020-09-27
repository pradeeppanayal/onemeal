import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:onemealapp/appPage.dart';
import 'package:onemealapp/userAccount.dart';
import 'package:onemealapp/utils.dart';
import 'package:url_launcher/url_launcher.dart';
import 'auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OneMeal App',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      routes: <String, WidgetBuilder>{
        '/': (BuildContext context) => MyHomePage(title: 'OneMeal Home Page'),
        '/home': (BuildContext context) => MainPage(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool isUserLoggedIn = false;
  bool loading = false;
  bool loginError = false;
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
                (loading || isUserLoggedIn) && !loginError
                    ? Text("Please wait..")
                    : _signInButton(),
                Visibility(
                  visible: loginError && isUserLoggedIn,
                  child: IconButton(
                      icon: Icon(Icons.refresh), onPressed: () => _trylogin()),
                ),
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
      loginError = false;
    });
    authService
        .tryLogin()
        .then((value) => {
              if (value != null && authService.currentUser != null)
                {Navigator.pushReplacementNamed(context, "/home")}
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
      loginError = true;
    });
  }
}
