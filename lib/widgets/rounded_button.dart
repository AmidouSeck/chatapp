import 'package:chatapp/constants/colors/main_color.dart';
import 'package:flutter/material.dart';

class RoundedButton extends StatelessWidget {
  final String text;
  final dynamic press;
  final Color color, textColor;
  const RoundedButton({
    Key? key,
    required this.text,
    this.press,
    this.color = kPrimaryColor,
    this.textColor = Colors.white, TextButton? child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      width: size.width * 0.9,
      height: 50,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: newElevatedButton(),
      ),
    );
  }

  //Used:ElevatedButton as FlatButton is deprecated.
  //Here we have to apply customizations to Button by inheriting the styleFrom

  Widget newElevatedButton() {
    return ElevatedButton(
      child: Text(
        text,
        style: TextStyle(color: textColor),
      ),
      onPressed: press,
      style: ElevatedButton.styleFrom(
          primary: color,
          padding: EdgeInsets.symmetric(horizontal: 40, vertical: 8),
          textStyle: TextStyle(
              color: textColor, fontSize: 18, fontWeight: FontWeight.w500)),
    );
  }
}

class RoundedTwoButton extends StatelessWidget {
  final String text;
  final dynamic press;
  final Color color, textColor;
  const RoundedTwoButton({
    Key? key,
    required this.text,
    this.press,
    this.color = kPrimaryColor,
    this.textColor = Colors.white,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      margin:   EdgeInsets.all(3),
      width:  size.width * 0.33,
      height: size.height / 16,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: newElevatedButton(),
      ),
    );
  }

  //Used:ElevatedButton as FlatButton is deprecated.
  //Here we have to apply customizations to Button by inheriting the styleFrom

  Widget newElevatedButton() {
    return ElevatedButton(
      child: Text(
        text,
        style: TextStyle(color: textColor),
      ),
      onPressed: press,
      style: ElevatedButton.styleFrom(
          primary: color,
          padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
          textStyle: TextStyle(
              color: textColor, fontSize: 18, fontWeight: FontWeight.w500)),
    );
  }
}