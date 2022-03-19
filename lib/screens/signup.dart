import 'dart:io';
import 'dart:typed_data';

import 'package:adaptive_action_sheet/adaptive_action_sheet.dart';
import 'package:flutter/gestures.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:chatapp/main.dart';
import 'package:chatapp/widgets/address_text.dart';
import 'package:chatapp/widgets/rounded_button.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:chatapp/constants/size.dart';
import 'package:chatapp/services/auth.service.dart';
import 'package:chatapp/widgets/AlertAndLoaderCustom.dart';
import 'package:chatapp/widgets/name_text_field.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:steps_indicator/steps_indicator.dart';
import '../../constants/colors/main_color.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';

enum SingingCharacter { MALE, FEMALE }
enum ImageSourceType { gallery, camera }
ImagePicker picker = ImagePicker();

class Signup extends StatelessWidget {
  Widget build(BuildContext context) {
    return Scaffold(
      body: SignupBody(),
    );
  }
}

class SignupBody extends StatefulWidget {
  const SignupBody({Key? key}) : super(key: key);

  @override
  _SignupBodyState createState() => _SignupBodyState();
}

class _SignupBodyState extends State<SignupBody> {
  final formKey = GlobalKey<FormState>();
  TextEditingController lastnameController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController firstnameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController _confirmPass = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController controllerCNI = TextEditingController();
  var indicator = PhoneNumber();
  bool isFocus = true;
  bool isvalidPrevious = false;
  var dateOfBirth;
  String _chosenValue = 'CNI';
  bool isChecked = false;
  int _currentStep = 0;
  File? _imageCniRecto;
  File? _imageCniVerso;
  File? _imageProfil;
  File? _imagePassport;
  var platformVersion;
  String imeiNo = '';
  int selectedStep = 0;
  int nbSteps = 3;
  var modelName;
  XFile imagePath = XFile('assets/images/orange_money.jpeg');
  StepperType stepperType = StepperType.horizontal;
  List identityType = ["CNI", "PASSPORT"];
  SingingCharacter? _character = SingingCharacter.MALE;
  VoidCallback? _onStepContinue;
  VoidCallback? _onStepCancel;
  String uploadimageCniRectoB64 = "";
  String uploadimageCniVersoB64 = "";
  String dropdownValue = 'Masculin';

  var fToast = FToast();
  Brightness _getBrightness() {
    return Brightness.light;
  }

  _savePhoneNumber(String phoneNumber) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'phoneNumber';
    final value = phoneNumber;
    prefs.setString(key, value);
  }

  String changePhone = "";
  bool isShowChar = true;
  bool isUploadOk = false;
  bool isShowCharConfirm = true;
  _savePassword(String password) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'password';
    final value = password;
    prefs.setString(key, value);
  }

  switchStepsType() {
    setState(() => stepperType == StepperType.vertical
        ? stepperType = StepperType.horizontal
        : stepperType = StepperType.vertical);
  }

  // 2. co
  tapped(int step) {
    setState(() => _currentStep = step);
  }


  _showToast(text, color) {
    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15.0),
        color: Colors.white,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.warning,
            color: Color(color),
          ),
          SizedBox(
            width: 12.0,
          ),
          Text(
            text,
            style: TextStyle(color: kPrimaryColor),
          ),
        ],
      ),
    );

    fToast.showToast(
      child: Card(elevation: 3, child: toast),
      gravity: ToastGravity.CENTER,
      toastDuration: Duration(seconds: 2),
    );
  }

  onStepContinue() {
    if (this.selectedStep < 2) {
      setState(() {
        selectedStep += 1;
      });
    } else {
      return;
    }
  }

  onStepCancel() {
    if (selectedStep == 0) {
      return;
    } else {
      setState(() {
        isvalidPrevious = true;
        selectedStep -= 1;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // create a future delayed function that will change showInagewidget to true after 5 seconds
    Future.delayed(const Duration(seconds: 0), () {
      setState(() {
        //_readCommingPassword();
        fToast = FToast();
        fToast.init(context);
      });
    });
  }

  Widget _createEventControlBuilder(BuildContext context,
      {required VoidCallback onStepContinue,
      required VoidCallback onStepCancel}) {
    _onStepContinue = onStepContinue;
    _onStepCancel = onStepCancel;
    return SizedBox.shrink();
  }

  

  var currentTextPinOne = "";
  Future<void> _handleURLButtonPressVerso(String typeUpload) async {
    final XFile? photo;
    photo = await picker.pickImage(source: ImageSource.camera, imageQuality: 9);
    setState(() {
      _imageCniVerso = File(photo!.path);
    });
  }

  Future<void> _handleURLButtonPressVersoGallery(String typeUpload) async {
    final XFile? photo;
    photo =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 9);
    setState(() {
      _imageCniVerso = File(photo!.path);
    });
  }

  final nameValidator = MultiValidator([
    RequiredValidator(errorText: "Champ obligatoire"),
    MinLengthValidator(2, errorText: "Au moins 2 caractères")
  ]);
  final cniValidator = MultiValidator([
    RequiredValidator(errorText: "Champ obligatoire"),
    MinLengthValidator(12, errorText: "Au moins 12 chiffres")
  ]);

  Widget _iconRectoCNI() {
    return Container(
        decoration: BoxDecoration(
            color: Colors.grey.shade200,
            border: Border.all(
              color: Colors.white,
            ),
            borderRadius: BorderRadius.all(Radius.circular(10))),
        width: 100,
        height: 80,
        child: new Icon(
          Icons.camera_alt_outlined,
          color: brownColor,
          size: 70.0,
        ));
  }

  Widget _imageRectoCNI() {
    return Image.file(
      _imageCniRecto!,
      width: 100.0,
      height: 100.0,
      fit: BoxFit.fitHeight,
    );
  }

  Widget _imageVersoCNI() {
    return Image.file(
      _imageCniVerso!,
      width: 100.0,
      height: 100.0,
      fit: BoxFit.fitHeight,
    );
  }

  Widget _imageProfilFunc() {
    return Image.file(
      _imageProfil!,
      width: 100.0,
      height: 100.0,
      fit: BoxFit.fitHeight,
    );
  }

  Widget _imagePassportFunc() {
    return Image.file(
      _imagePassport!,
      width: 100.0,
      height: 100.0,
      fit: BoxFit.fitHeight,
    );
  }

  Widget _submitForm() {
    return Container(
        width: mediaWidth(context) / 1.2,
        //height: 48,
        child: isChecked
            ? RoundedButton(
                color: kPrimaryColor,
                text: "S'inscrire",
                press: () async {
                  var number = indicator.phoneNumber.toString();
                  final isValid = formKey.currentState!.validate();
                  if (_character.toString() == "SingingCharacter.MALE") {
                    dropdownValue = "MALE";
                  } else {
                    dropdownValue = "FEMALE";
                  }
                  if (isValid || isvalidPrevious) {
                    try {
                      showAlertDialog(context);

                      var result = await AuthService.signup(
                        lastname: lastnameController.text,
                        firstname: firstnameController.text,
                        phoneNumber: number,
                        pinCode: currentTextPinOne,
                        gender: dropdownValue,
                        profilePhoto: _imageCniVerso,
                      );
                      Navigator.pop(context);
                      _savePassword(currentTextPinOne);
                      _savePhoneNumber(number);
                      // Navigator.of(context).push(MaterialPageRoute(
                      //     builder: (BuildContext context) =>
                      //         PinCodeVerificationScreen(number, false, true)));
                      return result;
                    } on SocketException catch (e) {
                      Navigator.pop(context);
                      onAlertErrorButtonPressed(
                          context, "Erreur", "Serveur inaccessible", "", false);
                    } catch (e) {
                      Navigator.pop(context);
                      final Map<String, dynamic> parsed =
                          json.decode(e.toString().substring(11));
                      var status = parsed['status'];
                      if (status == 409 || status == 404) {
                        onAlertErrorButtonPressed(
                            context, "Erreur", parsed['message'], "", false);
                      } else {
                        onAlertErrorButtonPressed(
                            context,
                            "Échoué",
                            "Votre inscription a échoué. Veuillez réessayer plus tard.",
                            "",
                            false);
                      }
                    }
                  }
                }, //isChecked
              )
            : RoundedButton(
                color: softBrown,
                text: "S'inscrire",
                press: () async {
                  await _showToast("Cocher pour s'inscrire", 0xFFFF0000);
                }, //isChecked
              ));
  }

  Route _createRouteToWelcomePage() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => MyApp(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(-1, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInBack;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  Widget _bottomBar() {
    Size size = MediaQuery.of(context).size;
    return Container(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
          (_currentStep < 2)
              ? Container(
                  width: mediaWidth(context) / 1.2,
                  child: RoundedButton(
                    press: () async {
                      final isValid = formKey.currentState!.validate();
                      if (isValid || isvalidPrevious) {
                        if (selectedStep == 0) {
                          setState(() {
                            selectedStep++;
                          });
                        } else if (selectedStep < 2 && selectedStep > 0) {
                          if ((
                                  _imageCniVerso != null ) ) {
                            setState(() {
                              isUploadOk = true;
                              selectedStep += 1;
                            });
                          } else {
                            await _showToast(
                                "La photo de profil est obligatoire", 0xFFFF0000);
                          }
                        } else {}
                      }
                    },
                    text: (selectedStep == 2) ? 'S\'inscrire' : 'Suivant  ',
                  ))
              : _submitForm(),
          (selectedStep == 0)
              ? Container(
                  width: mediaWidth(context) / 1.2,
                  child: RoundedButton(
                    color: appBackgroundColor,
                    textColor: brownColor,
                    press: () => {
                      //Navigator.of(context).pop(),
                      Navigator.of(context, rootNavigator: true)
                          .push(_createRouteToWelcomePage())
                    },
                    text: 'Annuler',
                  ))
              : Container(
                  width: mediaWidth(context) / 1.2,
                  child: RoundedButton(
                    color: appBackgroundColor,
                    textColor: brownColor,
                    press: () => onStepCancel(),
                    text: 'Précédent',
                  )),
        ]));
  }

  void _handleGenderChange(String value) {
    setState(() {
      _chosenValue = value;
    });
  }

  String initialCountry = 'SN';
  PhoneNumber phoneText = PhoneNumber(isoCode: 'SN');
  @override
  Widget build(BuildContext context) {
    return Theme(
        data: ThemeData(
            backgroundColor: generalBackground,
            brightness: _getBrightness(),
            accentColor: brownColor,
            primarySwatch: Colors.blue,
            colorScheme: ColorScheme.light(primary: brownColor)),
        child: Scaffold(
          body: Form(
            key: formKey,
            child: Stack(children: <Widget>[
              Container(
                  margin: EdgeInsets.only(top: 40),
                  child: Column(
                    children: <Widget>[
                      Container(
                          child: StepsIndicator(
                        selectedStep: selectedStep,
                        nbSteps: nbSteps,
                        doneLineColor: kPrimaryColor,
                        doneStepColor: kPrimaryColor,
                        undoneLineColor: appBackgroundColor,
                        lineLength: 40,
                        doneStepWidget: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle, color: kPrimaryColor),
                            child: Center(
                                child: Icon(
                              Icons.check,
                              color: appBackgroundColor,
                            ))),
                        selectedStepWidget: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle, color: kPrimaryColor),
                            child: Center(
                                child: Text(
                              "${selectedStep + 1}",
                              style: TextStyle(color: appBackgroundColor),
                            ))),
                        unselectedStepWidget: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: appBackgroundColor),
                            child: Center(
                                child: Icon(
                              Icons.clear,
                              color: kPrimaryColor,
                            ))),
                        lineLengthCustomStep: [
                          StepsIndicatorCustomLine(nbStep: 4, length: 40)
                        ],
                        enableLineAnimation: true,
                        enableStepAnimation: true,
                      )),
                    ],
                  )),
              (selectedStep == 0)
                  ? ListView.builder(
                      padding: EdgeInsets.only(top: 70, left: 15, right: 15),
                      itemCount: 1,
                      itemBuilder: (BuildContext context, int index) {
                        return Stack(
                          children: <Widget>[
                            Center(
                                child: Column(
                              children: <Widget>[
                                SizedBox(height: 20),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    "Vous êtes :",
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: brownColor,
                                        fontWeight: FontWeight.normal),
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  mainAxisSize: MainAxisSize.max,
                                  children: <Widget>[
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Row(children: [
                                          Radio<SingingCharacter>(
                                            value: SingingCharacter.MALE,
                                            groupValue: _character,
                                            activeColor: brownColor,
                                            onChanged:
                                                (SingingCharacter? value) {
                                              setState(() {
                                                _character = value;
                                              });
                                            },
                                          ),
                                          Text(
                                            "Homme",
                                            style: TextStyle(
                                                fontSize: 16,
                                                color: brownColor,
                                                fontWeight: FontWeight.normal),
                                          ),
                                        ])
                                      ],
                                    ),
                                    Column(
                                      children: [
                                        Row(children: [
                                          Radio<SingingCharacter>(
                                            value: SingingCharacter.FEMALE,
                                            activeColor: brownColor,
                                            groupValue: _character,
                                            onChanged:
                                                (SingingCharacter? value) {
                                              setState(() {
                                                _character = value;
                                              });
                                            },
                                          ),
                                          Text(
                                            "Femme",
                                            style: TextStyle(
                                                fontSize: 16,
                                                color: brownColor,
                                                fontWeight: FontWeight.normal),
                                          ),
                                        ])
                                      ],
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: EdgeInsets.all(7.0),
                                  child: InternationalPhoneNumberInput(
                                    onInputChanged: (PhoneNumber number) {
                                      indicator = number;
                                      changePhone = phoneNumberController.text;
                                    },
                                    onInputValidated: (bool value) {},
                                    selectorConfig: SelectorConfig(
                                      selectorType:
                                          PhoneInputSelectorType.BOTTOM_SHEET,
                                    ),
                                    ignoreBlank: false,
                                    autoValidateMode: AutovalidateMode.disabled,
                                    selectorTextStyle:
                                        TextStyle(color: brownColor),
                                    initialValue: phoneText,
                                    errorMessage:
                                        "Numéro de téléphone invalide",
                                    textFieldController: phoneNumberController,
                                    formatInput: false,
                                    autoFocus: isFocus,
                                    inputDecoration: InputDecoration(
                                        fillColor: Colors.white,
                                        filled: true,
                                        hintText: "Numéro de téléphone",
                                        labelStyle:
                                            TextStyle(color: brownColor),
                                        focusedBorder: OutlineInputBorder(
                                            borderSide:
                                                BorderSide(color: brownColor)),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.white, width: 1.0),
                                        )),
                                    keyboardType:
                                        TextInputType.numberWithOptions(
                                            signed: true, decimal: true),
                                    onSaved: (PhoneNumber number) {},
                                  ),
                                ),
                                Padding(
                                    padding: EdgeInsets.only(
                                        left: 5, right: 5, top: 8, bottom: 8),
                                    child: NameTextField(
                                        "Prénom", firstnameController)),
                                Padding(
                                    padding: EdgeInsets.only(
                                        left: 5, right: 5, top: 8, bottom: 8),
                                    child: NameTextField(
                                        "Nom", lastnameController)),
                                
                                Padding(
                                  padding: EdgeInsets.only(
                                      left: 5, right: 5, top: 42, bottom: 0),
                                  child: _bottomBar(),
                                )
                              ],
                            ))
                          ],
                        );
                      })
                  : (selectedStep == 1)
                      ? ListView.builder(
                          padding:
                              EdgeInsets.only(top: 50, left: 15, right: 15),
                          itemCount: 1,
                          itemBuilder: (BuildContext context, int index) {
                            return Stack(
                              children: <Widget>[
                                Center(
                                    child: Column(children: <Widget>[
                                  SizedBox(height: 40),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Vous souhaitez utiliser votre :",
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: brownColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                  
                                  SizedBox(
                                    height: 60,
                                  ),
                                  
                                       Column(children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: <Widget>[
                                              
                                              Expanded(
                                                child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.end,
                                                    children: [
                                                      Text(
                                                        "Photo de profil",
                                                        style: TextStyle(
                                                            fontSize: 15,
                                                            color: brownColor),
                                                      ),
                                                      SizedBox(height: 14),
                                                      TextButton(
                                                          onPressed: () {
                                                            showAdaptiveActionSheet(
                                                              context: context,
                                                              title: const Text(
                                                                  'Choisir le fichier'),
                                                              actions: <
                                                                  BottomSheetAction>[
                                                                BottomSheetAction(
                                                                    title: const Text(
                                                                        'Galerie'),
                                                                    onPressed:
                                                                        () async {
                                                                      Navigator.pop(
                                                                          context);
                                                                      await _handleURLButtonPressVersoGallery(
                                                                          "gallery");
                                                                    }),
                                                                BottomSheetAction(
                                                                    title: const Text(
                                                                        'Caméra'),
                                                                    onPressed:
                                                                        () async {
                                                                      Navigator.pop(
                                                                          context);
                                                                      await _handleURLButtonPressVerso(
                                                                          "camera");
                                                                    }),
                                                              ],
                                                              cancelAction:
                                                                  CancelAction(
                                                                      title:
                                                                          const Text(
                                                                'Cancel',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .red),
                                                              )), // onPressed parameter is optional by default will dismiss the ActionSheet
                                                            );
                                                          },
                                                          child: (_imageCniVerso !=
                                                                  null)
                                                              ? _imageVersoCNI()
                                                              : _iconRectoCNI()),
                                                    ]),
                                                flex: 6,
                                              ),
                                              
                                            ],
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(
                                                left: 5,
                                                right: 5,
                                                top: 42,
                                                bottom: 0),
                                            child: _bottomBar(),
                                          )
                                        ])
                                      
                                ]))
                              ],
                            );
                          })
                      : ListView.builder(
                          padding:
                              EdgeInsets.only(top: 80, left: 15, right: 15),
                          itemCount: 1,
                          itemBuilder: (BuildContext context, int index) {
                            return Stack(
                              children: <Widget>[
                                Center(
                                  child: Column(
                                    children: <Widget>[
                                      SizedBox(height: 10),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              "Entrez votre code Pin",
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  color: brownColor),
                                            ),
                                            flex: 10,
                                          ),
                                          Expanded(
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
                                            flex: 2,
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 15),
                                      Padding(
                                          padding: EdgeInsets.all(0.0),
                                          child: PinCodeTextField(
                                            appContext: context,
                                            pastedTextStyle: TextStyle(
                                              color: Colors.green.shade600,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            length: 4,
                                            obscureText: isShowChar,
                                            obscuringCharacter: '*',
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
                                              shape: PinCodeFieldShape.box,
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                              fieldHeight: 50,
                                              fieldWidth: 50,
                                              fieldOuterPadding:
                                                  EdgeInsets.all(1),
                                              inactiveColor: appBackgroundColor,
                                              inactiveFillColor:
                                                  appBackgroundColor,
                                              selectedFillColor: appMainColor(),
                                              activeColor: appMainColor(),
                                              activeFillColor: Colors.white,
                                            ),
                                            cursorColor: appMainColor(),
                                            animationDuration:
                                                Duration(milliseconds: 300),
                                            enableActiveFill: true,
                                            keyboardType: TextInputType.number,
                                            boxShadows: [
                                              BoxShadow(
                                                offset: Offset(0, 1),
                                                color: Colors.black12,
                                                blurRadius: 10,
                                              )
                                            ],
                                            onCompleted: (v) {},
                                            onChanged: (value) {
                                              setState(() {
                                                currentTextPinOne = value;
                                              });
                                            },
                                            beforeTextPaste: (text) {
                                              //if you return true then it will show the paste confirmation dialog. Otherwise if false, then nothing will happen.
                                              //but you can show anything you want here, like your pop up saying wrong paste format or etc
                                              return true;
                                            },
                                          )),
                                      SizedBox(height: 20),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              "Confirmez votre code Pin",
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  color: brownColor),
                                            ),
                                            flex: 10,
                                          ),
                                          Expanded(
                                            child: IconButton(
                                              icon: isShowCharConfirm
                                                  ? Icon(Icons.visibility)
                                                  : Icon(Icons.visibility_off),
                                              color: kPrimaryColor,
                                              onPressed: () {
                                                setState(() {
                                                  if (isShowCharConfirm) {
                                                    isShowCharConfirm = false;
                                                  } else {
                                                    isShowCharConfirm = true;
                                                  }
                                                });
                                              },
                                            ),
                                            flex: 2,
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 15),
                                      Padding(
                                          padding: EdgeInsets.all(0.0),
                                          child: PinCodeTextField(
                                            appContext: context,
                                            pastedTextStyle: TextStyle(
                                              color: Colors.green.shade600,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            length: 4,
                                            obscureText: isShowCharConfirm,
                                            obscuringCharacter: '*',
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
                                              shape: PinCodeFieldShape.box,
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                              fieldHeight: 50,
                                              fieldWidth: 50,
                                              fieldOuterPadding:
                                                  EdgeInsets.all(1),
                                              inactiveColor: appBackgroundColor,
                                              inactiveFillColor:
                                                  appBackgroundColor,
                                              selectedFillColor: appMainColor(),
                                              activeColor: appMainColor(),
                                              activeFillColor: Colors.white,
                                            ),
                                            cursorColor: appMainColor(),
                                            animationDuration:
                                                Duration(milliseconds: 300),
                                            enableActiveFill: true,
                                            keyboardType: TextInputType.number,
                                            boxShadows: [
                                              BoxShadow(
                                                offset: Offset(0, 1),
                                                color: Colors.black12,
                                                blurRadius: 10,
                                              )
                                            ],
                                            onCompleted: (v) {},
                                            onChanged: (value) {
                                              setState(() {
                                                currentTextPinOne = value;
                                              });
                                            },
                                            beforeTextPaste: (text) {
                                              //if you return true then it will show the paste confirmation dialog. Otherwise if false, then nothing will happen.
                                              //but you can show anything you want here, like your pop up saying wrong paste format or etc
                                              return true;
                                            },
                                          )),
                                      Padding(
                                          padding: EdgeInsets.all(7.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                child: Checkbox(
                                                  checkColor: Colors.white,
                                                  activeColor: brownColor,
                                                  value: isChecked,
                                                  onChanged: (bool? value) {
                                                    setState(() {
                                                      _currentStep = 2;
                                                      isChecked = value!;
                                                    });
                                                  },
                                                ),
                                                flex: 1,
                                              ),
                                              
                                            ],
                                          )),
                                      Align(
                                        alignment: Alignment.bottomCenter,
                                        child: _bottomBar(),
                                      )
                                    ],
                                  ),
                                )
                              ],
                            );
                          })
            ]),
          ),
          //),
        ));
  }

}
