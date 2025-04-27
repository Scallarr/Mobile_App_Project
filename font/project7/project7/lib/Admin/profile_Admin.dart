import 'dart:io';
import 'package:flutter/material.dart';

class Profile with ChangeNotifier {
  File? _imageAdmin;

  File? get image => _imageAdmin;

  void updateImage(File? newImage) {
    _imageAdmin = newImage;
    notifyListeners();
  }
}
