//import 'package:flutter_app/screens/signup_login/codePin.dart';
import 'package:chatapp/constants/size.dart';

import 'package:flutter/material.dart';
import 'package:chatapp/widgets/newPopup.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:chatapp/constants/colors/main_color.dart';

bool isDark = false;
var alertStyle = AlertStyle(
  backgroundColor: isDark ? blackColor : appBackgroundColor,
  titleStyle: TextStyle(color: isDark ? appBackgroundColor : blackColor),
  descStyle: TextStyle(color: isDark ? appBackgroundColor : blackColor),
);

onAlertLogout(context, bool dark, token) async {
  isDark = dark;
  showDialog(context: context,
                  builder: (BuildContext context){
                  return CustomDialogBox(
                    title: "Déconnexion",
                    descriptions: "Voulez-vous quitter l'application",
                    text: "Oui", img: "assets/images/launcher.png",isLogout: true, textTwo: "Non",isSuccess: false,isBio: false, number: '',
                  );
                  });
  
}
onAlertBio(context, bool dark, token) async {
  isDark = dark;
  showDialog(context: context,
                  builder: (BuildContext context){
                  return CustomDialogBox(
                    title: "Connexion Biométrique",
                    descriptions: "Voulez-vous utiliser votre emprunte pour se connecter à l'application ?",
                    text: "Oui", img: "assets/images/toucher.png",isLogout: true, textTwo: "Non",isSuccess: false,isBio: true, number: '',
                  );
                  });
  
}

onAlertLoan(context, bool dark, token) async {
  isDark = dark;
  
  Alert(
    context: context,
    type: AlertType.warning,
    title: "Prêt",
    desc: "Voulez-vous effectuer ce prêt ?",
    style: alertStyle,
    buttons: [
      DialogButton(
        child: Text(
          "Oui",
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        onPressed: () async {
          Navigator.of(context, rootNavigator: true).pop(true);
        },
        color: Color.fromRGBO(0, 179, 134, 1.0),
      ),
      DialogButton(
          child: Text(
            "Non",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () =>
              {Navigator.of(context, rootNavigator: true).pop(true)})
    ],
  ).show();
}

final spinkit = SpinKitFadingCircle(
  itemBuilder: (BuildContext context, int index) {
    return Container(
      decoration: new BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: borderGreyColor, width: 0.5),
        image: new DecorationImage(
          image: new AssetImage('assets/images/loader.png'),
          fit: BoxFit.cover,
        ),
      ),
    );
  },
);

onAlertErrorButtonPressed(context, title, body, route, bool dark) async {
  isDark = dark;
   showDialog(context: context,
                  builder: (BuildContext context){
                  return CustomDialogBox(
                    title: title,
                    descriptions: body,
                    text: "J'ai compris", img: "assets/images/imojiError.png",isLogout: false, textTwo: "",isSuccess: false,isBio: false, number: '',
                  );
                  });
}

onAlertSuccessButtonPressed(context, title, body, number, bool dark) async {
  isDark = dark;
   showDialog(context: context,
                  builder: (BuildContext context){
                  return CustomDialogBox(
                    title: title,
                    descriptions: body,
                    text: "J'ai compris", img: "assets/images/smile_success.png",isLogout: false, textTwo: "", isSuccess: true,isBio: false, number: number,
                  );
                  });
}

showAlertDialog(BuildContext context) {
  final alert = SpinKitFadingCircle(
    size: 100,
    color: superAppBrown);
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}
