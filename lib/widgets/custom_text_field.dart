import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  String? hintText;
  IconData? prefixIcon;
  TextEditingController? controller;
  String? Function(String?)? validator;




  CustomTextField({
    super.key,
    required this.hintText,
    this.prefixIcon,
    required this.controller,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return  Padding(
      padding:  EdgeInsets.symmetric(vertical: height * 0.01),
      child: TextFormField(
        validator: validator,
        controller: controller,
        decoration: InputDecoration(
          fillColor: Colors.deepPurple.shade50,
          filled: true,
          hintText: hintText,
          prefixIcon: Icon(prefixIcon),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
                color: Colors.deepPurple.shade400,
                width: 4
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
                color: Colors.red,
                width: 4
            ),
          ),
        ),
      ),
    );
  }
}
