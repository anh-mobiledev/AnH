import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:pam_app/constants/colours.dart';
import 'package:pam_app/constants/dimensions.dart';
import 'package:pam_app/helper/DBHelper.dart';
import 'package:pam_app/models/item_info_sqllite.dart';
import 'package:pam_app/models/my_items_server_model.dart';
import 'package:pam_app/screens/addItem/item_details_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../common/alert.dart';
import '../controllers/item_controller.dart';

class ItemsListForm extends StatefulWidget {
  const ItemsListForm({super.key});

  @override
  State<ItemsListForm> createState() => _ItemsListFormState();
}

class _ItemsListFormState extends State<ItemsListForm> {
  var itemController = Get.find<ItemController>();
  late List<ItemInfoSQLLite> itemsList;
  DBHelper dbHelper = new DBHelper();
  late SharedPreferences sharedPreferences;

  late List<bool> _isChecked;
  List<String> isCheckedIds = [];

  bool _isConnected = false;
  late final InternetConnectionCheckerPlus _connectionChecker;
  bool _isLoading = true;

  Future<void> getItemsList() async {
    var result = await dbHelper.getItemsList();
    setState(() {
      itemsList = result;
    });
  }

  Future<void> getMyItemsListServer() async {
    await Get.find<ItemController>().getMyItemsListServer();

    _isChecked =
        List<bool>.filled(itemController.myItemsIndexListServer.length, false);

    setState(() {
      _isLoading = false;
      _filteredItems = itemController.myItemsIndexListServer;
    });
  }

  @override
  void initState() {
    /*itemsList = [];
    getItemsList();*/

    // TODO: implement initState
    super.initState();
    _connectionChecker = InternetConnectionCheckerPlus();
    _checkConnection();
    _startMonitoring();

    getMyItemsListServer();
  }

  Future<void> _checkConnection() async {
    final isConnected = await _connectionChecker.hasConnection;
    setState(() {
      _isConnected = isConnected;
    });
  }

  void _startMonitoring() {
    _connectionChecker.onStatusChange.listen((status) {
      setState(() {
        _isConnected = status == InternetConnectionStatus.connected;
      });
    });
  }

  List<MyItemsServerModel> _filteredItems = [];

  void _filterList(String query) {
    final filtered = itemController.myItemsIndexListServer.where((item) {
      final name = item.name.toString().toLowerCase();
      return name.contains(query.toLowerCase());
    }).toList();

    setState(() {
      _filteredItems = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    // loadingDialogBox(context, "please wait...");

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: "Search by name",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: _filterList,
            ),
          ),
          Container(
            height: Dimensions.screenHeight,
            child: GetBuilder<ItemController>(
              builder: (controller) {
                return controller.isLoaded
                    ? SingleChildScrollView(
                        child: Container(
                          constraints: BoxConstraints(
                              minHeight: 100, minWidth: 100, maxHeight: 600),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius:
                                BorderRadius.circular(Dimensions.radius30),
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 10,
                                spreadRadius: 7,
                                offset: Offset(1, 1),
                                color: Colors.grey.withOpacity(0.2),
                              )
                            ],
                          ),
                          margin: EdgeInsets.only(
                              left: Dimensions.width10,
                              right: Dimensions.width10,
                              top: Dimensions.height20),
                          child: ListView.builder(
                            padding: const EdgeInsets.all(10.0),
                            itemCount: _filteredItems == null
                                ? 0
                                : _filteredItems.length,
                            itemBuilder: (context, index) {
                              final item = _filteredItems[index];
                              return Card(
                                child: InkWell(
                                  onTap: () async {
                                    Navigator.of(context).pushNamed(
                                        ItemDetailsViewScreen.screenId,
                                        arguments: item);
                                  },
                                  child: ListTile(
                                    leading: CachedNetworkImage(
                                      imageUrl: item.primary_img_url!,
                                      height: Dimensions.height30 * 2,
                                      width: Dimensions.width30 * 2,
                                      fit: BoxFit.fill,
                                      placeholder: (context, url) =>
                                          CircularProgressIndicator(),
                                      errorWidget: (context, url, error) =>
                                          Icon(Icons.error),
                                    ),
                                    title: Text(item.name!),
                                    subtitle: Text(
                                      item.valueAmount!,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      )
                    : const Padding(
                        padding: EdgeInsets.only(top: 200),
                        child: Center(
                          child: Text(
                            "No records found, please click + to add.",
                            style: TextStyle(fontSize: 15),
                          ),
                        ),
                      );
              },
            ),
          )
        ],
      ),
    );
  }
}
