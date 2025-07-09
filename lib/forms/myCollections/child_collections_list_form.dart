import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:pam_app/constants/colours.dart';
import 'package:pam_app/constants/dimensions.dart';
import 'package:pam_app/controllers/item_controller.dart';
import 'package:pam_app/controllers/my_collections_controller.dart';
import 'package:pam_app/forms/item_details_view_form.dart';
import 'package:pam_app/forms/myCollections/share_bottom_sheet.dart';
import 'package:pam_app/helper/DBHelper.dart';
import 'package:pam_app/models/collection_items_server_model.dart';
import 'package:pam_app/models/my_items_server_model.dart';
import 'package:pam_app/screens/addItem/item_details_view.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../common/alert.dart';

class ChildCollectionsListForm extends StatefulWidget {
  final String collectionId;
  final String parentName;
  const ChildCollectionsListForm(this.parentName, this.collectionId,
      {super.key});

  @override
  State<ChildCollectionsListForm> createState() =>
      _ChildCollectionsListFormState();
}

class _ChildCollectionsListFormState extends State<ChildCollectionsListForm> {
  var myCollectionController = Get.find<MyCollectionsController>();

  DBHelper dbHelper = new DBHelper();
  late SharedPreferences sharedPreferences;

  String? collectionId;
  String? parent_name;
  List<String> isCheckedIds = [];
  late List<bool> _isChecked;
  List<CollectionItemsModel> _collectionItems = [];
  bool? isCheckedValue = false;

  _loadCollectionItems() async {
    await Get.find<MyCollectionsController>()
        .getCollectionItemsList(collectionId!)
        .then((__) {
      _collectionItems = myCollectionController.myCollectionItemsIndexList;
    });
  }

  @override
  void initState() {
    // TODO: implement initState

    collectionId = widget.collectionId;
    parent_name = widget.parentName;

    print('collectionId :: ${collectionId}');

    _loadCollectionItems();

    super.initState();
    setState(() {});
  }

  void _deleteItem(int index) {
    setState(() {
      _collectionItems.removeAt(index);
      //myCollectionController.myCollectionItemsIndexList.removeAt(index);
    });
  }

  void _shareItem(String item) {
    // Implement your sharing logic

    Share.share('Check out this product!\n ${item}');

    /*showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => ShareBottomSheet(
        shareText: 'Check out this product!',
        shareUrl: 'https://yourapp.com/product?${item}',
      ),
    );*/
  }

  void _moreOptions(String item) {
    // Implement more options logic
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('More options for $item')));
  }

  @override
  Widget build(BuildContext context) {
    // myCollectionController.readJson();

    // Get.find<MyCollectionsController>().getChildCollectionList(parent_id!);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: 150.0,
            height: 50.0,
            child: Align(
              alignment: Alignment.topRight,
              child: SizedBox(
                height: 50,
                width: 50,
                child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: AppColors.secondaryColor,
                      side: BorderSide(
                        color: AppColors.secondaryColor,
                      ),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                          side: BorderSide(color: AppColors.secondaryColor)),
                    ),
                    onPressed: () {
                      createDialog();

                      /* Navigator.of(context).pushNamed(
                        AddChildCollectionScreen.screenId,
                        arguments: {
                          'action': 'add',
                          'collectionId': collectionId,
                          'title': parent_name,
                          'child_name': "",
                          'current_value': ""
                        },
                      );*/
                    },
                    child: Icon(
                      Icons.add,
                      color: Colors.white,
                    )),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(left: Dimensions.width15),
            width: Dimensions.screenWidth,
            child: Text(
              "Swipe from RIGHT to LEFT, to see more options!",
              style: TextStyle(
                  fontSize: Dimensions.font26 / 2,
                  color: AppColors.secondaryColor),
            ),
          ),
          Container(
            height: 700,
            child: GetBuilder<MyCollectionsController>(
              builder: (myCollectionController) {
                return myCollectionController.isLoaded
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
                            itemCount: _collectionItems.length,
                            shrinkWrap: true,
                            itemBuilder: (BuildContext context, int index) {
                              final child_collections = _collectionItems[index];

                              return Slidable(
                                key: ValueKey(child_collections),
                                endActionPane: ActionPane(
                                  motion: ScrollMotion(),
                                  dismissible: DismissiblePane(
                                      onDismissed: () =>
                                          _showDeleteConfirmDialog(
                                              context, index)),
                                  children: [
                                    SlidableAction(
                                      onPressed: (context) => _shareItem(
                                          child_collections.primary_img_url!),
                                      backgroundColor: Colors.blue,
                                      foregroundColor: Colors.white,
                                      icon: Icons.share,
                                      label: 'Share',
                                    ),
                                    /*  SlidableAction(
                                      onPressed: (context) =>
                                          _moreOptions(child_collections.name!),
                                      backgroundColor: Colors.orange,
                                      foregroundColor: Colors.white,
                                      icon: Icons.more_horiz,
                                      label: 'More',
                                    ),*/
                                    SlidableAction(
                                      onPressed: (context) =>
                                          _showDeleteConfirmDialog(
                                              context, index),
                                      backgroundColor: Colors.red,
                                      foregroundColor: Colors.white,
                                      icon: Icons.delete,
                                      label: 'Delete',
                                    ),
                                  ],
                                ),
                                child: Card(
                                  child: InkWell(
                                    onTap: () {
                                      MyItemsServerModel arguments =
                                          MyItemsServerModel(
                                        id: _collectionItems[index].id,
                                        name: _collectionItems[index].name,
                                        description:
                                            _collectionItems[index].description,
                                        valueAmount:
                                            _collectionItems[index].valueAmount,
                                        primary_img_url: _collectionItems[index]
                                            .primary_img_url,
                                        valueType:
                                            _collectionItems[index].valueType,
                                        valueUnits:
                                            _collectionItems[index].valueUnits,
                                        status: _collectionItems[index].status,
                                        condition:
                                            _collectionItems[index].condition,
                                        keywords:
                                            _collectionItems[index].keywords,
                                      );

                                      Navigator.of(context).pushNamed(
                                          ItemDetailsViewScreen.screenId,
                                          arguments: arguments);
                                    },
                                    child: ListTile(
                                      leading: CachedNetworkImage(
                                          imageUrl: _collectionItems[index]
                                              .primary_img_url!,
                                          height: Dimensions.height30 * 2,
                                          width: Dimensions.width30 * 2,
                                          fit: BoxFit.fill,
                                          placeholder: (context, url) =>
                                              CircularProgressIndicator(),
                                          errorWidget: (context, url, error) =>
                                              Icon(Icons.error)),
                                      title:
                                          Text(_collectionItems[index].name!),
                                      subtitle: Text(_collectionItems[index]
                                          .valueAmount!
                                          .toString()),
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

  var collectionController = Get.find<MyCollectionsController>();
  var itemController = Get.find<ItemController>();

  //My Items list
  createDialog() async {
    await Get.find<ItemController>().getMyItemsListServer();

    _isChecked =
        List<bool>.filled(itemController.myItemsIndexListServer.length, false);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Your Items'),
              actions: <Widget>[
                TextButton(
                  onPressed: () async {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    collectionController
                        .collectionItemCreate(
                            collectionId!,
                            isCheckedIds
                                .toString()
                                .replaceAll('[', '')
                                .replaceAll(']', ''),
                            "",
                            "",
                            "",
                            "",
                            "",
                            "")
                        .then((status) {
                      if (status.isSuccess) {
                        _loadCollectionItems();
                        Navigator.pop(context);
                      }
                    });

                    print(isCheckedIds);
                  },
                  child: const Text('Save'),
                ),
              ],
              content: GetBuilder<ItemController>(
                builder: (controller) {
                  return controller.isLoaded
                      ? Container(
                          width: Dimensions.screenWidth,
                          height: Dimensions.screenHeight,
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: controller.myItemsIndexListServer == null
                                ? 0
                                : controller.myItemsIndexListServer.length,
                            itemBuilder: (context, index) {
                              return Card(
                                child: InkWell(
                                  onTap: () {},
                                  child: ListTile(
                                    leading: CachedNetworkImage(
                                        imageUrl: controller
                                            .myItemsIndexListServer[index]
                                            .primary_img_url!,
                                        height: Dimensions.height30 * 2,
                                        width: Dimensions.width30 * 2,
                                        fit: BoxFit.fill,
                                        placeholder: (context, url) =>
                                            CircularProgressIndicator(),
                                        errorWidget: (context, url, error) =>
                                            Icon(Icons.error)),
                                    trailing: Checkbox(
                                      side: MaterialStateBorderSide.resolveWith(
                                          (_) => const BorderSide(
                                              width: 1, color: AppThemeColor)),
                                      fillColor: MaterialStateProperty.all(
                                          AppColors.primaryColor),
                                      value: isCheckedIds.contains(controller
                                              .myItemsIndexListServer[index].id)
                                          ? true
                                          : false,
                                      onChanged: (value) {
                                        if (value!) {
                                          setState(() {
                                            confirmDialog(controller
                                                .myItemsIndexListServer[index]
                                                .id!);
                                            isCheckedIds.add(controller
                                                .myItemsIndexListServer[index]
                                                .id!);
                                          });
                                        } else {
                                          setState(() {
                                            isCheckedIds.remove(controller
                                                .myItemsIndexListServer[index]
                                                .id);
                                          });
                                        }
                                      },
                                    ),
                                    title: Text(controller
                                        .myItemsIndexListServer[index].name!),
                                    subtitle: Text(
                                      controller.myItemsIndexListServer[index]
                                          .valueAmount
                                          .toString(),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        )
                      : CircularProgressIndicator(
                          color: AppColors.primaryColor,
                        );
                },
              ),
            );
          },
        );
      },
    );
  }

  Dialogs alert = Dialogs();
  Future<void> confirmDialog(String id) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Warning!'),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                Text(
                    'Are you sure you want to add this item to collection list?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Yes'),
              onPressed: () async {
                Navigator.of(context).pop(true);
              },
            ),
            TextButton(
              child: const Text('No'),
              onPressed: () async {
                Navigator.of(context).pop(false);
              },
            ),
          ],
        );
      },
    );
  }

//Delete confirmation dialog
  Future<void> _showDeleteConfirmDialog(BuildContext context, int index) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap a button
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete this item?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
              },
            ),
            TextButton(
              child: Text('Delete'),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              onPressed: () {
                // Call your delete function here
                _deleteItem(index);
                Navigator.of(context).pop(); // Dismiss the dialog
                // Optionally show a snackbar or toast
              },
            ),
          ],
        );
      },
    );
  }
}
