import 'dart:io';
import 'package:flutter/material.dart';

class Profile with ChangeNotifier {
  File? _image2;

  File? get image => _image2;

  void updateImage(File? newImage) {
    _image2 = newImage;
    notifyListeners();
  }
}
