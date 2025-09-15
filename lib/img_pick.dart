// import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

pickImage(ImageSource source) async{
  // ignore: no_leading_underscores_for_local_identifiers
  final ImagePicker _imagePicker = ImagePicker();
  XFile? file = await _imagePicker.pickImage(source: source);
  if(file != null){
    return await file.readAsBytes();
  }
  // ignore: avoid_print
  print("No Image is selected!!");
}

