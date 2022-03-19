import 'package:chatapp/constants/colors/main_color.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';

class AddressTextField extends StatefulWidget {
  String nameText;
  var controller = TextEditingController();
  AddressTextField(this.nameText, this.controller, {Key? key}) : super(key: key);

  @override
  _NameTextFieldState createState() => _NameTextFieldState();
}

class _NameTextFieldState extends State<AddressTextField> {
  final nameValidator = MultiValidator([
    RequiredValidator(errorText: "Champ obligatoire"),
    MinLengthValidator(4, errorText: "Au moins 4 caractères")
  ]);
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      validator: nameValidator,
      textInputAction: TextInputAction.next,
      keyboardType: TextInputType.streetAddress,
      autofocus: true,
      controller: widget.controller,
      autofillHints: [AutofillHints.addressCity],
      decoration: InputDecoration(
        fillColor: Colors.white,
        filled: true,
        labelText: widget.nameText,
        labelStyle: TextStyle(color: brownColor),  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: brownColor),
      ),
      enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white, width: 1.0),
    )
    ));
  }
}
