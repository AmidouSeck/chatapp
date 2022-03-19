import 'package:chatapp/constants/colors/main_color.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';

class NameTextField extends StatefulWidget {
  String nameText;
  var controller = TextEditingController();
  NameTextField(this.nameText, this.controller, {Key? key}) : super(key: key);

  @override
  _NameTextFieldState createState() => _NameTextFieldState();
}

class _NameTextFieldState extends State<NameTextField> {
  final nameValidator = MultiValidator([
    RequiredValidator(errorText: "Champ obligatoire"),
    MinLengthValidator(2, errorText: "Au moins 2 caractères")
  ]);
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      validator: nameValidator,
      textInputAction: TextInputAction.next,
      keyboardType: TextInputType.emailAddress,
      autofocus: false,
      controller: widget.controller,
      autofillHints: [AutofillHints.email],
      decoration: InputDecoration(
        fillColor: Colors.white,
        filled: true,
        //prefixIcon: Icon(Icons.person,color: appMainColor()),
        labelText: widget.nameText,
        labelStyle: TextStyle(color: brownColor),  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: brownColor,
                      ),
                      
      ),
      enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white, width: 1.0),
    )));
  }
}
