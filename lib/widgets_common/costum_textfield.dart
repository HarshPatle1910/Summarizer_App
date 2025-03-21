import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';

import '../consts/colors.dart';
import '../consts/styles.dart';

Widget costumTextField({String? title, String? hint, controller, ispass}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      title!.text.color(redColor).fontFamily(semibold).size(16).make(),
      5.heightBox,
      TextFormField(
        controller: controller,
        obscureText: ispass,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(fontFamily: semibold, color: textfieldGrey),
          isDense: true,
          fillColor: lightGrey,
          border: InputBorder.none,
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: redColor),
          ),
        ),
      ),
      SizedBox(height: 10),
    ],
  );
}
