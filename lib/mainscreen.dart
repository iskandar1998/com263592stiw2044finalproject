import 'dart:convert';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ndialog/ndialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'cartpage.dart';
import 'config.dart';

class MainScreen extends StatefulWidget {
  MainScreen({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  String _titlecenter = "Loading...";
  List _productList = [];
  double screenHeight, screenWidth;
  SharedPreferences prefs;
  String email = "";
  int cartitem = 0;
  TextEditingController _srcController = new TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _testasync();
    });
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text('RESTAURANTIS'),
          actions: [
            TextButton.icon(
                onPressed: () => {_goToCart()},
                icon: Icon(
                  Icons.shopping_cart,
                  color: Colors.white,
                ),
                label: Text(
                  cartitem.toString(),
                  style: TextStyle(color: Colors.white),
                )),
          ],
        ),
        body: Center(
          child: Column(
            children: [
              Container(
                  padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Container(
                        height: 50,
                        width: screenWidth / 1.5,
                        child: TextFormField(
                          style: TextStyle(fontSize: 14),
                          controller: _srcController,
                          decoration: InputDecoration(
                            hintText: "Search product",
                            suffixIcon: IconButton(
                              onPressed: () =>
                                  _loadProduct(_srcController.text),
                              icon: Icon(Icons.search),
                            ),
                            border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10.0)),
                                borderSide: BorderSide(color: Colors.white24)),
                          ),
                        ),
                      ),
                    ],
                  )),
              if (_productList.isEmpty)
                Flexible(child: Center(child: Text(_titlecenter)))
              else
                Flexible(
                    child: OrientationBuilder(builder: (context, orientation) {
                  return StaggeredGridView.countBuilder(
                      padding: EdgeInsets.all(10),
                      crossAxisCount:
                          orientation == Orientation.portrait ? 2 : 4,
                      itemCount: _productList.length,
                      staggeredTileBuilder: (int index) =>
                          new StaggeredTile.fit(1),
                      mainAxisSpacing: 4.0,
                      crossAxisSpacing: 4.0,
                      itemBuilder: (BuildContext ctxt, int index) {
                        return Column(
                          children: [
                            Container(
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                elevation: 10,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        height:
                                            orientation == Orientation.portrait
                                                ? 100
                                                : 150,
                                        width:
                                            orientation == Orientation.portrait
                                                ? 100
                                                : 150,
                                        child: Image.network(CONFIG.SERVER +
                                            _productList[index]['picture']),
                                      ),
                                      Text(
                                        titleSub(
                                            _productList[index]['productName']),
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(_productList[index]['productType'][0]
                                              .toUpperCase() +
                                          _productList[index]['productType']
                                              .substring(1)),
                                      Text("Qty:" +
                                          _productList[index]['quantity']),
                                      Text("RM " +
                                          double.parse(
                                                  _productList[index]['price'])
                                              .toStringAsFixed(2)),
                                      Container(
                                        child: ElevatedButton(
                                          onPressed: () => {_addtocart(index)},
                                          child: Text("Add to Cart"),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      });
                }))
            ],
          ),
        ),
      ),
    );
  }

  String titleSub(String title) {
    if (title.length > 15) {
      return title.substring(0, 15) + "...";
    } else {
      return title;
    }
  }

  Future<void> _loadPref() async {
    prefs = await SharedPreferences.getInstance();
  }

  _loadProduct(String prname) {
    http.post(Uri.parse(CONFIG.SERVER + "/foodgood/mobile/loadproducts.php"),
        body: {"prname": prname}).then((response) {
      if (response.body == "nodata") {
        _titlecenter = "No product";
        _productList = [];
        return;
      } else {
        var jsondata = json.decode(response.body);
        print(jsondata);
        _productList = jsondata["products"];
        _titlecenter = "";
      }
      setState(() {});
    });
  }

  _addtocart(int index) async {
    ProgressDialog progressDialog = ProgressDialog(context,
        message: Text("Add to cart"), title: Text("Progress..."));
    progressDialog.show();
    await Future.delayed(Duration(seconds: 1));
    String prid = _productList[index]['productId'];
    http.post(Uri.parse(CONFIG.SERVER + "/foodgood/mobile/insertcart.php"),
        body: {"email": email, "prid": prid}).then((response) {
      print(response.body);
      if (response.body == "failed") {
        Fluttertoast.showToast(
            msg: "Failed",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      } else {
        Fluttertoast.showToast(
            msg: "Success",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
        _loadCart();
      }
    });
    progressDialog.dismiss();
  }

  _goToCart() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CartPage(email: email),
      ),
    );
    _loadProduct("all");
  }

  void _loadCart() {
    print(email);
    http.post(Uri.parse(CONFIG.SERVER + "/foodgood/mobile/loadcartitem.php"),
        body: {"email": email}).then((response) {
      setState(() {
        cartitem = int.parse(response.body);
        print(cartitem);
      });
    });
  }

  Future<void> _testasync() async {
    await _loadPref();
    _loadProduct("all");
    _loadCart();
  }
}
