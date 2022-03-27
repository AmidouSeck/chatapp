import 'package:flutter/services.dart';
import 'package:chatapp/constants/size.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:chatapp/constants/colors/main_color.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chatapp/widgets/AlertAndLoaderCustom.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';

//import '../signup_login/reinitPassWord.dart';

class AccountHome extends StatefulWidget {
  
  
  @override
  AccountHomeState createState() => AccountHomeState();
}

class AccountHomeState extends State<AccountHome>
    with AutomaticKeepAliveClientMixin {
  static bool useBio = false;
  bool status = false;
  bool haveData = false;
  var email = '';
  var token = '';

  var firstName = "";
  var lastName = "";
  var phoneNumber = "";

  bool isSowData = false;
  var textMoney = "XOF";
  final LocalAuthentication auth = LocalAuthentication();
  _SupportState _supportState = _SupportState.unknown;
  bool? _canCheckBiometrics;
  List<BiometricType>? _availableBiometrics;
  String _authorized = 'Not Authorized';
  bool _isAuthenticating = false;
  var assistantNumber = "+221338592200";

  _callNumber() async {
    //set the number here
    bool? res = await FlutterPhoneDirectCaller.callNumber(assistantNumber);
  }

  _saveBio(bool isUseBio) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'isUseBio';
    final value = isUseBio;
    prefs.setBool(key, value);
    print('saved $value');
    _readBio();
  }

  _readNumber() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'phoneNumber';
    var value = prefs.getString(key) ?? "";
    var valueFirstName = prefs.getString("firstname") ?? "";
    var valueLastName = prefs.getString("lastname") ?? "";
    phoneNumber = value;
    firstName = valueFirstName;
    lastName = valueLastName;
  }

  @override
  bool get wantKeepAlive => true;
  _readBio() async {
    useBio = false;
    final prefs = await SharedPreferences.getInstance();
    final key = 'isUseBio';
    bool value = prefs.getBool(key) ?? false;
    useBio = value;
    status = useBio;
  }

  _readToken() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'token';
    final value = prefs.getString(key) ?? '';
    token = value;
  }

  Future<void> _authenticateWithBiometrics() async {
    bool authenticated = false;
    try {
      setState(() {
        _isAuthenticating = true;
        _authorized = 'Authenticating';
      });
      authenticated = await auth.authenticate(
          localizedReason:
              'Scan your fingerprint (or face or whatever) to authenticate',
          useErrorDialogs: true,
          stickyAuth: true,
          biometricOnly: true);
      setState(() {
        if (authenticated) {
          _saveBio(true);
        } else {
          status = false;
        }
        _isAuthenticating = false;
        _authorized = 'Authenticating';
      });
    } on PlatformException catch (e) {
      print(e);
      setState(() {
        _isAuthenticating = false;
        _authorized = "Error - ${e.message}";
      });
      return;
    }
    if (!mounted) return;

    final String message = authenticated ? 'Authorized' : 'Not Authorized';
    setState(() {
      _authorized = message;
    });
  }

  void initState() {
    super.initState();

    auth.isDeviceSupported().then(
          (isSupported) => setState(() => _supportState = isSupported
              ? _SupportState.supported
              : _SupportState.unsupported),
        );
    setState(() {
      _readBio();
      _readToken();
      _readNumber();
    });

    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        haveData = true;
        isSowData = true;
      });
    });
  }

  Widget build(BuildContext context) {
    print("wid ${firstName}");
    return Scaffold(
        appBar: AppBar(
          backgroundColor: kPrimaryColor,
          title: Text("Compte"),
          actions: <Widget>[],
        ),
        backgroundColor: kPrimaryColor,
        body: Stack(children: <Widget>[
          SingleChildScrollView(
            child: Stack(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.only(top: 140),
                  width: mediaWidth(context),
                  height: mediaHeight(context),
                  child: Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.only(
                              left: 7, top: 170, right: 7, bottom: 7),
                          child: Column(
                            children: <Widget>[
                              ListTile(
                                leading: Icon(
                                  Icons.touch_app,
                                  color: appMainColor(),
                                ),
                                title: Text('Face ID/Touch ID'),
                                trailing: Container(
                                  margin: EdgeInsets.fromLTRB(17, 7, 7, 7),
                                  child: CupertinoSwitch(
                                    activeColor: appMainColor(),
                                    value: status,
                                    onChanged: (value) {
                                      setState(() {
                                        // status = value;
                                        if (useBio == false) {
                                          _authenticateWithBiometrics();
                                        } else {
                                          _saveBio(false);
                                        }
                                      });
                                    },
                                  ),
                                ),
                                onTap: () {},
                              ),
                              // ListTile(
                              //   leading: Icon(
                              //     Icons.local_activity,
                              //     color: appMainColor(),
                              //   ),
                              //   title: Text("Trouvez les agents à proximité"),
                              //   trailing: Icon(Icons.keyboard_arrow_right,
                              //       color: appBackgroundColor),
                              //   onTap: () {},
                              // ),
                              ListTile(
                                leading: Icon(
                                  Icons.call,
                                  color: appMainColor(),
                                ),
                                title: Text(
                                    "Inviter un ami à rejoindre ChatApp"),
                                trailing: Icon(Icons.keyboard_arrow_right,
                                    color: appBackgroundColor),
                                onTap: _callNumber,
                              ),
                              ListTile(
                                leading: Icon(
                                  Icons.lock,
                                  color: appMainColor(),
                                ),
                                title: Text("Réinitialiser mon mot de passe"),
                                trailing: Icon(Icons.lock_outline,
                                    color: appBackgroundColor),
                                onTap: () {
                                  // Navigator.of(context, rootNavigator: true)
                                  //       .pushReplacement(MaterialPageRoute(
                                  //           builder: (BuildContext context) =>
                                  //               new ReinitPassWord()));
                                },
                              ),
                              ListTile(
                                leading: Icon(
                                  Icons.logout_outlined,
                                  color: appMainColor(),
                                ),
                                title: Text("Déconnexion"),
                                trailing: Icon(Icons.keyboard_arrow_right,
                                    color: appBackgroundColor),
                                onTap: () {
                                  onAlertLogout(context, false, token);
                                },
                              ),
                            ],
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 50.0),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: 23,
                  top: 80,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: new AssetImage('assets/images/splash.png'),
                        fit: BoxFit.cover,
                      ),
                      border: Border.all(
                        color: appBackgroundColor,
                        width: 2.0,
                      ),
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    isSowData
                        ? Container(
                            margin: EdgeInsets.only(left: 15, top: 210),
                            child: Text(
                              "${firstName} ${lastName}",
                              style: TextStyle(
                                color: kPrimaryColor,
                                fontWeight: FontWeight.normal,
                                fontSize: 25.0,
                              ),
                            ),
                          )
                        : Container(
                            margin: EdgeInsets.only(left: 15, top: 210),
                            width: 200.0,
                            height: 30.0,
                            child: Shimmer.fromColors(
                                baseColor: Colors.grey.shade200,
                                highlightColor: Colors.white,
                                child: Card())),
                    isSowData
                        ? Container(
                            margin: EdgeInsets.only(left: 15, top: 10),
                            child: Text(
                              "${phoneNumber}",
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.normal,
                                fontSize: 20.0,
                              ),
                            ),
                          )
                        : Container(
                            margin: EdgeInsets.only(left: 15, top: 1),
                            width: 200.0,
                            height: 30.0,
                            child: Shimmer.fromColors(
                                baseColor: Colors.grey.shade200,
                                highlightColor: Colors.white,
                                child: Card()))
                  ],
                ),
                Container(
                  margin: EdgeInsets.only(left: 5, right: 5, top: 290),
                  color: Colors.grey.shade100,
                  height: 20,
                ),
              ],
            ),
          ),
        ]));
  }

  Container _buildDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 8.0,
      ),
      width: double.infinity,
      height: 0.5,
      color: borderGreyColor,
    );
  }
}

enum _SupportState {
  unknown,
  supported,
  unsupported,
}
