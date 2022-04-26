import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'app/app_module.dart';
import 'app/app_widget.dart';

void main() async {
  runApp(ModularApp(module: AppModule(), child: AppWidget()));


}
