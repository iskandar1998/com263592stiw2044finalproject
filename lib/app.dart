import 'package:flutter/material.dart';
import 'package:foodgood/admin/pages/add_food_item.dart';
import 'package:foodgood/pages/sigin_page.dart';
import 'package:foodgood/scoped-model/main_model.dart';
import 'package:foodgood/screens/main_screen.dart';
import 'package:scoped_model/scoped_model.dart';

class App extends StatelessWidget {
  final MainModel mainModel = MainModel();

  @override
  Widget build(BuildContext context) {
    return ScopedModel<MainModel>(
      model: mainModel,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "Food Delivery App",
        theme: ThemeData(primaryColor: Colors.blueAccent),
        routes: {
          "/": (BuildContext context) => SignInPage(),
          "/mainscreen": (BuildContext context) => MainScreen(
                model: mainModel,
              ),
        },
      ),
    );
  }
}
