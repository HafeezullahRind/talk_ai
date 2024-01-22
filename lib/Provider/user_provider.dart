import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  String name = '';
  String email = '';
  String username = '';
  String? imageUrl = '';

  void setUser({
    required String name,
    required String email,
    required String username,
    String? imageUrl,
  }) {
    this.name = name;
    this.email = email;
    this.username = username;
    this.imageUrl = imageUrl;
    notifyListeners();
  }

  Map<String, dynamic> getUserData() {
    return {
      'name': name,
      'email': email,
      'username': username,
      'imageUrl': imageUrl,
    };
  }

  notifyListeners();
}
