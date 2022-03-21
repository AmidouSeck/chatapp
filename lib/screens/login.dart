import 'dart:async';
import 'dart:io';

//import 'package:flutter_app/screens/login_signup/codePin.dart';
import 'package:chatapp/screens/signup.dart';
import 'package:flutter/services.dart';
import 'package:chatapp/constants/colors/main_color.dart';
import 'package:chatapp/constants/size.dart';
import 'package:chatapp/screens/homePage.dart';
//import 'package:chatapp/screens/codePin.dart';
//import 'package:flutter_app/screens/welcome/components/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:chatapp/widgets/circle.dart';
import 'package:chatapp/widgets/keyboard.dart';
import 'package:chatapp/widgets/rounded_button.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chatapp/services/auth.service.dart';
import 'package:chatapp/widgets/AlertAndLoaderCustom.dart';
import 'dart:convert';
import 'package:local_auth/local_auth.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class Login extends StatelessWidget {
  Login({Key? key, required this.haveNumber}) : super(key: key);
  final bool haveNumber;
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: LoginBody(
        haveNumber: haveNumber,
      ),
    );
  }
}

class LoginBody extends StatefulWidget {
  LoginBody({Key? key, required this.haveNumber}) : super(key: key);

  late final bool haveNumber;

  @override
  _LoginBodyState createState() => _LoginBodyState();
}

class _LoginBodyState extends State<LoginBody> {
  final formKey = GlobalKey<FormState>();
  var phoneNumber = "";
  var password = "";
  var passwordController = TextEditingController();
  var emailController = TextEditingController();
  var phoneNumberController = TextEditingController();
  final StreamController<bool> _verificationNotifier =
      StreamController<bool>.broadcast();

  // ignore: close_sinks
  StreamController<ErrorAnimationType>? errorController;
  bool hasError = false;
  String currentText = "";
  bool isDoubleAuth = false;
  bool isShowChar = true;

  bool isAuthenticated = false;
  String initialCountry = 'SN';
  final LocalAuthentication auth = LocalAuthentication();
  _SupportState _supportState = _SupportState.unknown;
  bool? _canCheckBiometrics;
  List<BiometricType>? _availableBiometrics;
  String _authorized = 'Not Authorized';
  bool _isAuthenticating = false;
  var imei = "";

  Future<void> _checkBiometrics() async {
    late bool canCheckBiometrics;
    try {
      canCheckBiometrics = await auth.canCheckBiometrics;
    } on PlatformException catch (e) {
      canCheckBiometrics = false;
    }
    if (!mounted) return;

    setState(() {
      _canCheckBiometrics = canCheckBiometrics;
    });
  }

  Future<void> _getAvailableBiometrics() async {
    late List<BiometricType> availableBiometrics;
    try {
      availableBiometrics = await auth.getAvailableBiometrics();
    } on PlatformException catch (e) {
      availableBiometrics = <BiometricType>[];
    }
    if (!mounted) return;

    setState(() {
      _availableBiometrics = availableBiometrics;
    });
  }

  bool haveNumber = false;

  Future<void> _authenticate() async {
    bool authenticated = false;
    try {
      setState(() {
        _isAuthenticating = true;
        _authorized = 'Authenticating';
      });
      authenticated = await auth.authenticate(
          localizedReason: 'Let OS determine authentication method',
          useErrorDialogs: true,
          stickyAuth: true);
      setState(() {
        _isAuthenticating = false;
      });
    } on PlatformException catch (e) {
      setState(() {
        _isAuthenticating = false;
        _authorized = "Error - ${e.message}";
      });
      return;
    }
    if (!mounted) return;

    setState(
        () => _authorized = authenticated ? 'Authorized' : 'Not Authorized');
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
      print("auth $authenticated");
      await _readPassword();

      //setState(()  {
      if (authenticated) {
       // String? deviceId = await _getId();
        print("password $password");
        try {
          showAlertDialog(context);
          var result = await AuthService.login(
              phoneNumber: phoneNumber,
              pinCode: password,
              //imei: deviceId.toString()
              );
          var resultState =
              result.toString().substring(3, result.toString().length);
          final Map<String, dynamic> parsed = json.decode(resultState);
          setState(() {
            _saveUserId(parsed['userId']);
            _saveFirstName(parsed['firstname']);
            _saveLastName(parsed['lastname']);
            _savePhoneNumber(parsed['phoneNumber']);
          });

          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
          );

          return result;
        } on SocketException catch (e) {
          Navigator.pop(context);

          onAlertErrorButtonPressed(context, "Erreur",
              "Veuillez vérifier votre connexion internet", "", _dark);
        } catch (e) {
          Navigator.pop(context);
          if (e.toString().substring(0, 34) ==
              'Exception: {"message":"Ce compte n') {
            // await AuthService.resendCode(
            //     phoneNumber: phoneNumber, imei: deviceId.toString());
            // Navigator.of(context, rootNavigator: true).pushReplacement(
            //     MaterialPageRoute(
            //         builder: (BuildContext context) =>
            //             new PinCodeVerificationScreen(
            //                 "$phoneNumber", false, false)));
          } else {
            onAlertErrorButtonPressed(
                context, "Erreur", "Code incorrect", "", _dark);
          }
        }
      }
      _isAuthenticating = false;
      _authorized = 'Authenticating';
      //});
    } on PlatformException catch (e) {
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

  void _cancelAuthentication() async {
    await auth.stopAuthentication();
    setState(() => _isAuthenticating = false);
  }

  PhoneNumber phoneText = PhoneNumber(isoCode: 'SN');
  var indicator = PhoneNumber();
  var tokenInfos;

  bool isVisible = false;
  static String hour = '';
  String email = "";
  static int hours = 0;
  static bool _dark = false;
  bool useBio = false;

  _saveFirstName(String token) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'firstname';
    final value = token;
    prefs.setString(key, value);
  }

  var storedPasscode = '1234';
  _saveUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'userId';
    final value = userId;
    prefs.setString(key, value);
  }

  _savePhoneNumber(String phoneNumber) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'phoneNumber';
    final value = phoneNumber;
    prefs.setString(key, value);
  }

  _savePassword(String password) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'password';
    final value = password;
    prefs.setString(key, value);
  }

  _saveLastName(String password) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'lastname';
    final value = password;
    prefs.setString(key, value);
  }

  _readBio() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'isUseBio';
    bool value = prefs.getBool(key) ?? false;
    useBio = value;
  }

  // Future<String?> _getId() async {
  //   var deviceInfo = DeviceInfoPlugin();
  //   if (Platform.isIOS) {
  //     // import 'dart:io'
  //     var iosDeviceInfo = await deviceInfo.iosInfo;
  //     return iosDeviceInfo.identifierForVendor; // unique ID on iOS
  //   } else {
  //     var androidDeviceInfo = await deviceInfo.androidInfo;
  //     return androidDeviceInfo.androidId; // unique ID on Android
  //   }
  // }

  bool haveCredit = false;

  _readImei() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'imei';
    var value = prefs.getString(key) ?? "";
    imei = value;
  }

  _readHaveCredit() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'haveCredit';
    bool value = prefs.getBool(key) ?? false;
    haveCredit = value;
  }

  _readNumber() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'phoneNumber';
    var value = prefs.getString(key) ?? "";
    phoneNumber = value;
    if (phoneNumber == "") {
      haveNumber = false;
    } else {
      haveNumber = true;
      if (useBio) {
        _authenticateWithBiometrics();
      }
    }
  }

  _readPassword() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'password';
    var value = prefs.getString(key) ?? "";
    password = value;
  }

  bool opaque = false;
  CircleUIConfig? circleUIConfig;
  KeyboardUIConfig? keyboardUIConfig;
  Widget? cancelButton = Text(
    'Retour',
    style: const TextStyle(fontSize: 16, color: Colors.white),
    semanticsLabel: 'Retour',
  );
  List<String> digits = [
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    'touch',
    '0',
    'clear'
  ];

  _onPasscodeEntered(String enteredPasscode) async {
    print("enteredPasscode $enteredPasscode");
    bool isValid = storedPasscode == enteredPasscode;
    _verificationNotifier.add(isValid);
    if (isValid) {
      await _readPassword();
      await _readPassword();
      //setState(() async {

      //String? deviceId = await _getId();

      try {
        showAlertDialog(context);
        var result = await AuthService.login(
            phoneNumber: phoneNumber,
            pinCode: enteredPasscode
           // imei: deviceId.toString()
           );
        var resultState =
            result.toString().substring(3, result.toString().length);
        final Map<String, dynamic> parsed = json.decode(resultState);
        setState(() {
          _saveUserId(parsed['userId']);
          //_saveToken(parsed['token']);
          _savePhoneNumber(parsed['phoneNumber']);
        });

        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );

        return result;
      } on SocketException catch (e) {
        Navigator.pop(context);

        onAlertErrorButtonPressed(context, "Erreur",
            "Veuillez vérifier votre connexion internet", "", _dark);
      } catch (e) {
        Navigator.pop(context);
        if (e.toString().substring(0, 34) ==
            'Exception: {"message":"Ce compte n') {
          // await AuthService.resendCode(
          //     phoneNumber: phoneNumber, imei: deviceId.toString());
          // Navigator.of(context, rootNavigator: true).pushReplacement(
          //     MaterialPageRoute(
          //         builder: (BuildContext context) =>
          //             new PinCodeVerificationScreen(
          //                 "$phoneNumber", false, false)));
        } else {
          onAlertErrorButtonPressed(
              context, "Erreur", "Numéro ou code pin incorrect", "", _dark);
        }
      }
      //}
      //)
      ;
    }
  }

  _onPasscodeCancelled() {
    Navigator.maybePop(context);
  }

  @override
  void dispose() {
    _verificationNotifier.close();
    super.dispose();
  }

  _buildPasscodeRestoreButton() => Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10.0, top: 20.0),
          child: TextButton(
            child: Text(
              "",
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w300),
            ),
            onPressed: _resetAppPassword,
            // splashColor: Colors.white.withOpacity(0.4),
            // highlightColor: Colors.white.withOpacity(0.2),
            // ),
          ),
        ),
      );

  _resetAppPassword() {
    Navigator.maybePop(context).then((result) {
      if (!result) {
        return;
      }
      _showRestoreDialog(() {
        Navigator.maybePop(context);
        //TODO: Clear your stored passcode here
      });
    });
  }

  Brightness _getBrightness() {
    return _dark ? Brightness.dark : Brightness.light;
  }

  _showRestoreDialog(VoidCallback onAccepted) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Retour",
            style: const TextStyle(color: Colors.black87),
          ),
          content: Text(
            "Passcode reset is a non-secure operation!\n\nConsider removing all user data if this action performed.",
            style: const TextStyle(color: Colors.black87),
          ),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            TextButton(
              child: Text(
                "Retour",
                style: const TextStyle(fontSize: 18),
              ),
              onPressed: () {
                Navigator.maybePop(context);
              },
            ),
            TextButton(
              child: Text(
                "I understand",
                style: const TextStyle(fontSize: 18),
              ),
              onPressed: onAccepted,
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    errorController = StreamController<ErrorAnimationType>();
    setState(() {
      _readImei();
      _readBio();
    });

    @override
    void dispose() {
      super.dispose();
      errorController!.close();
      //controller.dispose();
    }

    _getAvailableBiometrics();
    auth.isDeviceSupported().then(
          (isSupported) => setState(() => _supportState = isSupported
              ? _SupportState.supported
              : _SupportState.unsupported),
        );
    // create a future delayed function that will change showInagewidget to true after 5 seconds
    Future.delayed(const Duration(seconds: 0), () {
      DateTime now = DateTime.now();

      setState(() {
        _readHaveCredit();
        _readNumber();

        hour = now.hour.toString();
        hours = int.parse(hour);
      });
    });
  }

  // Route _createRouteToWelcomePage() {
  //   return PageRouteBuilder(
  //     pageBuilder: (context, animation, secondaryAnimation) => WelcomeScreen(),
  //     transitionsBuilder: (context, animation, secondaryAnimation, child) {
  //       const begin = Offset(-1, 0.0);
  //       const end = Offset.zero;
  //       const curve = Curves.easeInBack;

  //       var tween =
  //           Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

  //       return SlideTransition(
  //         position: animation.drive(tween),
  //         child: child,
  //       );
  //     },
  //   );
  // }

  _login() async {
    if (!haveNumber) {
      final isValid = formKey.currentState!.validate();
      if (isValid) {
        setState(() {
          haveNumber = true;
        });
      }
    } else {
      print("phoneNumber $phoneNumber");
      //String? deviceId = await _getId();
      var number = indicator.phoneNumber.toString();
      // var numberSbstring =
      //     number.substring(1, number.length);
      final isValid = formKey.currentState!.validate();
      if (isValid) {
        try {
          showAlertDialog(context);
          print("phone $phoneNumber");

          var result = await AuthService.login(
              phoneNumber: phoneNumber,
              pinCode: passwordController.text,
              //imei: (deviceId.toString() != "") ? deviceId.toString() : imei
              );

          var state = result.toString().substring(0, 3);
          var resultState =
              result.toString().substring(3, result.toString().length);
          print("stateResult ${state.length}");

          if (state == "200") {
            final Map<String, dynamic> parsed = json.decode(resultState);

            print("state ${parsed['firstname']}");
            print("state $parsed");
            setState(() {
             // _savePassword(passwordController.text);
              //_saveToken(parsed['token']);
              _saveUserId(parsed['userId']);
              _savePhoneNumber(parsed['phoneNumber']);
            });
            Navigator.pop(context);

            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          } else {
            final Map<String, dynamic> parsed = json.decode(resultState);

            setState(() {
              _savePhoneNumber(parsed['phoneNumber']);

              if (parsed["isDeviceVerified"] == true) {
                Navigator.pop(context);

                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                );
              } else {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                );
              }
            });
          }

          return result;
        } on SocketException catch (e) {
          Navigator.pop(context);

          onAlertErrorButtonPressed(context, "Erreur",
              "Veuillez vérifier votre connexion internet", "", _dark);
        } catch (e) {
          Navigator.pop(context);

          if (e.toString().substring(0, 34) ==
              'Exception: {"message":"Ce compte n') {
            // await AuthService.resendCode(
            //     phoneNumber: number,
            //     imei: (deviceId.toString() != "") ? deviceId.toString() : imei);
            // Navigator.of(context, rootNavigator: true).pushReplacement(
            //     MaterialPageRoute(
            //         builder: (BuildContext context) =>
            //             new PinCodeVerificationScreen(
            //                 "$number", false, false)));
          } else if (e.toString().substring(0, 34) ==
              'Exception: {"message":"Nombre de S') {
            onAlertErrorButtonPressed(
                context,
                "Erreur",
                "Nombre de SMS autorisé par jour dépassé. Réessayer plus tard.",
                "",
                _dark);
          } 
          else {
            onAlertErrorButtonPressed(context, "Erreur",
                "Numéro de téléphone ou Code Pin incorrect", "", _dark);
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Theme(
        data: ThemeData(
          brightness: _getBrightness(),
        ),
        child: SingleChildScrollView(
          child: Stack(children: [
            Container(
              margin: EdgeInsets.only(top: 25, left: 15),
              child: IconButton(
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
                  setState(() async {
                    //haveNumber = false;
                    await prefs.clear();
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Login(
                                haveNumber: false,
                              )),
                      (Route<dynamic> route) => false,
                    );
                  });
                },
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: appMainColor(),
                ),
              ),
            ),
            Form(
              key: formKey,
              child: Column(
                children: [
                  SizedBox(height: 80),
                  Container(
                    alignment: Alignment.center, // use aligment
                    child: Image.asset(
                      'assets/images/Groupe_2382.png',
                      height: 200,
                      // width: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(height: 10),
                  // Container(
                  //   alignment: Alignment.center, // use aligment
                  //   child: Image.asset(
                  //     'assets/images/Slogan2.png',
                  //     height: 30,
                  //     fit: BoxFit.cover,
                  //   ),
                  // ),
                  SizedBox(height: 40),
                  Padding(
                    padding: EdgeInsets.only(
                        left: mediaWidth(context) / 16,
                        right: mediaWidth(context) / 16),
                    child: Container(
                      child: Column(
                        children: [
                          (haveNumber)
                              ? Container()
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                      Text(
                                        "Numéro de téléphone",
                                        style: TextStyle(
                                            color: brownColor, fontSize: 16),
                                      ),
                                    ]),
                          SizedBox(height: 10),
                          (haveNumber)
                              ? Container()
                              : IntlPhoneField(
                                  decoration: InputDecoration(
                                    fillColor: superAppSoftGrey,
                                    filled: true,
                                    errorStyle: TextStyle(color: redColor),
                                    alignLabelWithHint: true,
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: brownColor, width: 1.0),
                                    ),
                                    labelStyle: TextStyle(color: brownColor),
                                    focusedBorder: OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: brownColor)),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.white, width: 1.0),
                                    ),
                                  ),
                                  initialCountryCode: 'SN',
                                  invalidNumberMessage: "",
                                  onChanged: (phone) {
                                    // print(phone.completeNumber);
                                    phoneNumber = phone.completeNumber;
                                  },
                                  keyboardType: TextInputType.numberWithOptions(
                                      signed: true, decimal: true),
                                ),
                          (haveNumber)
                              ? Container()
                              : SizedBox(
                                  height: mediaHeight(context) / 90,
                                ),
                          (!haveNumber)
                              ? Container()
                              : Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.only(left: 4),
                                      child: Text(
                                        "Saisissez votre Code Der",
                                        style: TextStyle(
                                            color: brownColor, fontSize: 16),
                                      ),
                                    ),
                                    Container(
                                      child: IconButton(
                                        icon: isShowChar
                                            ? Icon(Icons.visibility)
                                            : Icon(Icons.visibility_off),
                                        color: kPrimaryColor,
                                        onPressed: () {
                                          setState(() {
                                            if (isShowChar) {
                                              isShowChar = false;
                                            } else {
                                              isShowChar = true;
                                            }
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                          SizedBox(
                            height: 10,
                          ),
                          (!haveNumber)
                              ? Container()
                              : Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 2.0, horizontal: 10),
                                  child: PinCodeTextField(
                                    appContext: context,
                                    pastedTextStyle: TextStyle(
                                      color: Colors.green.shade600,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    length: 4,
                                    obscureText: isShowChar,
                                    obscuringCharacter: '*',
                                    //obscuringWidget: Image.asset("assets/images/pin_gif.gif"),
                                    blinkWhenObscuring: true,
                                    animationType: AnimationType.fade,
                                    validator: (v) {
                                      if (v!.length < 3) {
                                        return "";
                                      } else {
                                        return null;
                                      }
                                    },
                                    pinTheme: PinTheme(
                                      shape: PinCodeFieldShape.underline,
                                      borderRadius: BorderRadius.circular(5),
                                      fieldHeight: 50,
                                      fieldWidth: 50,
                                      fieldOuterPadding: EdgeInsets.all(1),
                                      inactiveColor: appMainColor(),
                                      inactiveFillColor: appBackgroundColor,
                                      selectedFillColor: appMainColor(),
                                      activeColor: appMainColor(),
                                      activeFillColor: Colors.white,
                                    ),
                                    cursorColor: appMainColor(),
                                    animationDuration:
                                        Duration(milliseconds: 300),
                                    enableActiveFill: true,
                                    errorAnimationController: errorController,
                                    controller: passwordController,
                                    keyboardType: TextInputType.number,
                                    // boxShadows: [
                                    //   BoxShadow(
                                    //     offset: Offset(0, 1),
                                    //     color: Colors.black12,
                                    //     blurRadius: 10,
                                    //   )
                                    // ],
                                    onCompleted: (v) {
                                      _login();
                                    },
                                    onChanged: (value) {
                                      setState(() {
                                        currentText = value;
                                      });
                                    },
                                    beforeTextPaste: (text) {
                                      //if you return true then it will show the paste confirmation dialog. Otherwise if false, then nothing will happen.
                                      //but you can show anything you want here, like your pop up saying wrong paste format or etc
                                      return true;
                                    },
                                  )),
                          (!haveNumber)
                              ? Container()
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                      TextButton(
                                          onPressed: () {
                                            Navigator.of(context)
                                                .pushNamed("forgot");
                                          },
                                          child: Text(
                                            "Code Der oublié ?",
                                            style: TextStyle(
                                              color: _dark
                                                  ? appBackgroundColor
                                                  : blackColor,
                                            ),
                                          ))
                                    ]),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        top: mediaHeight(context) / 75, left: 5, right: 5),
                    child: Container(
                        child: !haveNumber
                            ? RoundedButton(
                                text: (!haveNumber)
                                    ? "Continuer"
                                    : "Se connecter",
                                press: () async {
                                  _login();
                                })
                            : Container()),
                  ),
                  SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context, rootNavigator: true)
                                        .pushReplacement(MaterialPageRoute(
                                            builder: (BuildContext context) =>
                                                 Signup()));
                        },
                        child: Text("Ouvrir un compte",
                            style: TextStyle(
                                color: superAppBrown,
                                fontStyle: FontStyle.normal,
                                fontWeight: FontWeight.bold)),
                      )
                    ],
                  ),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.center,
                  //   children: [
                  //     TextButton(
                  //       onPressed: () async {

                  //       },
                  //       child: Text("Changer de compte",
                  //           style: TextStyle(
                  //               color: kPrimaryColor,
                  //               fontStyle: FontStyle.normal,
                  //               fontWeight: FontWeight.bold)),
                  //     )
                  //   ],
                  // )
                ],
              ),
            ),
          ]),
        ));
  }

  parseInt(String hour) {}
}

enum _SupportState {
  unknown,
  supported,
  unsupported,
}
