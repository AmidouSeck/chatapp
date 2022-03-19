import 'dart:io';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:chatapp/constants/colors/main_color.dart';
import 'package:chatapp/constants/size.dart';
import 'package:chatapp/screens/homePage.dart';
import 'package:chatapp/screens/login.dart';
import 'package:chatapp/widgets/rounded_button.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomDialogBox extends StatefulWidget {
  final String title, descriptions, text, img, textTwo, number;
  final bool isLogout, isSuccess, isBio;
  const CustomDialogBox({required this.isBio,required this.title, required this.descriptions, required this.text, required this.img,required this.isLogout,required this.textTwo, 
  required this.isSuccess , required this.number });

  @override
  _CustomDialogBoxState createState() => _CustomDialogBoxState();
}

class _CustomDialogBoxState extends State<CustomDialogBox> {

  final LocalAuthentication auth = LocalAuthentication();
  _SupportState _supportState = _SupportState.unknown;
  bool? _canCheckBiometrics;
  List<BiometricType>? _availableBiometrics;
  String _authorized = 'Not Authorized';
  bool _isAuthenticating = false;

  @override
   

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
        if (authenticated) {
          _saveBio(true);
          _saveShowPopup(true);
        
        } 
        _isAuthenticating = false;
        _authorized = 'Authenticating';
    } on PlatformException catch (e) {
      print(e);
      setState(() {
        Navigator.pop(context);
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
  _saveBio(bool isUseBio) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'isUseBio';
    final value = isUseBio;
    prefs.setBool(key, value);
    print('saved $value');
  }
  _saveShowPopup(bool showPopup) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'showPopup';
    final value = showPopup;
    prefs.setBool(key, value);
    print('saved $value');
  }

  void initState() {
    super.initState();

    auth.isDeviceSupported().then(
          (isSupported) => setState(() => _supportState = isSupported
              ? _SupportState.supported
              : _SupportState.unsupported),
        );
  }
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Constants.padding),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: contentBox(context),
    );
  }
  contentBox(context){
    return Stack(
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(left: Constants.padding,top: Constants.avatarRadius
              + Constants.padding, right: Constants.padding,bottom: Constants.padding
          ),
          margin: EdgeInsets.only(top: Constants.avatarRadius),
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            color: Colors.white,
            borderRadius: BorderRadius.circular(Constants.padding),
            boxShadow: [
              BoxShadow(color: Colors.black,offset: Offset(0,10),
              blurRadius: 10
              ),
            ]
          ),
          child: !widget.isLogout ?  Column(
            mainAxisSize: MainAxisSize.min,
               children:    <Widget>[
              Text(widget.title,style: TextStyle(fontSize: 22,fontWeight: FontWeight.w600),),
              SizedBox(height: 15,),
              Text(widget.descriptions,style: TextStyle(fontSize: 14),textAlign: TextAlign.center,),
              SizedBox(height: 22,),
              Align(
                alignment: Alignment.center,
                child: RoundedButton(
                        text: widget.text,
                        color: appMainColor(),
                        
                        textColor: appBackgroundColor,
                        press: () {
                          if(widget.isSuccess){
                            Navigator.of(context).pop();
                            Navigator.of(context,
                                                rootNavigator: true)
                                            .pushReplacement(MaterialPageRoute(
                                                builder: (BuildContext
                                                        context) =>
                                                    new HomePage(
                                                        )));
                          }else{
                           Navigator.of(context).pop();
                          }
                        }),
                   
              ),
             
            ] 
          ) : Column(
            mainAxisSize: MainAxisSize.min,
               children:    <Widget>[
              Text(widget.title,style: TextStyle(fontSize: 22,fontWeight: FontWeight.w600),),
              SizedBox(height: 15,),
              Text(widget.descriptions,style: TextStyle(fontSize: 14),textAlign: TextAlign.center,),
              SizedBox(height: 20,),
              Row(children: [
                Expanded(child: 
              Align(
                alignment: Alignment.bottomRight,
                child: RoundedTwoButton(
                        text: widget.textTwo,
                        color: kPrimaryLightColor,
                        textColor: appBackgroundColor,
                        press: () {
                           if(widget.isBio){
                             _saveShowPopup(true);
                             Navigator.of(context).pop();
                           }else{
                           Navigator.of(context).pop();
                           }
                        }),
                   
              ),
              flex: 6,
                ),
               Expanded(child: 
              Align(
                alignment: Alignment.bottomLeft,
                child: RoundedTwoButton(
                        text: widget.text,
                        color: appMainColor(),
                        textColor: appBackgroundColor,
                        press: ()  {
            if(widget.isBio == false){
                 Navigator.pushAndRemoveUntil(
            context,
              MaterialPageRoute(
                  builder: (BuildContext context) => new Login(haveNumber: false,)),
                  (Route route) => false);
            }else{
                 setState(() {
                   _authenticateWithBiometrics();
                 // Navigator.of(context).pop();
                 });
                  
              
               
            }
         
                  
                        }),
                   
              ),
               flex: 6,
                ),
              ])
            ],),
        ),
        Positioned(
          top: widget.isBio ?  100 : 0,
          left: Constants.padding,
            right: Constants.padding,
            
            child: Container(
                    width: widget.isBio ? 80 : 150,
                    height: widget.isBio ? 80: 150,
                   child:
            CircleAvatar(
              backgroundColor: Colors.transparent,
              radius: Constants.avatarRadius,
              child: ClipRRect(
                 borderRadius:  widget.isBio ? BorderRadius.circular(0) : BorderRadius.circular(140 / 2),
                  child: Image.asset(widget.img)
              ),
            ),
        ),
        )],
    );
  }
}
enum _SupportState {
  unknown,
  supported,
  unsupported,
}