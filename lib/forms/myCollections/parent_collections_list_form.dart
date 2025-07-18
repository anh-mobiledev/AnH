import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:pam_app/constants/colours.dart';
import 'package:pam_app/controllers/my_collections_controller.dart';
import 'package:pam_app/helper/DBHelper.dart';
import 'package:pam_app/models/my_collections_server_model.dart';
import 'package:pam_app/screens/myCollections/add_parent_collection_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../common/alert.dart';
import '../../constants/dimensions.dart';
import '../../screens/myCollections/child_collection_list_screen.dart';

class ParentCollectionsListForm extends StatefulWidget {
  const ParentCollectionsListForm({super.key});

  @override
  State<ParentCollectionsListForm> createState() =>
      _ParentCollectionsListFormState();
}

class _ParentCollectionsListFormState extends State<ParentCollectionsListForm> {
  var myCollectionController = Get.find<MyCollectionsController>();

  DBHelper dbHelper = new DBHelper();
  late SharedPreferences sharedPreferences;
  List<CollectionsServerModel> _collections = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadCollections();
  }

  _loadCollections() async {
    await Get.find<MyCollectionsController>().getCollectionsList().then((__) {
      _collections = myCollectionController.myCollectionsIndexList;
    });
  }

  @override
  Widget build(BuildContext context) {
    // myCollectionController.readJson();
    // Get.find<MyCollectionsController>().getParentCollectionList();

    /* Get.find<MyCollectionsController>()
        .getCollectionsList(myCollectionController.getUserToken());*/
    // _loadCollections();

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
                      Navigator.of(context)
                          .pushNamed(AddParentCollectionScreen.screenId);
                    },
                    child: Icon(
                      Icons.add,
                      color: Colors.white,
                    )),
              ),
            ),
          ),
          Container(
            height: 700,
            child: GetBuilder<MyCollectionsController>(
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
                            itemCount:
                                _collections == null ? 0 : _collections.length,
                            // controller.parentCollectionsIndexList.length,
                            shrinkWrap: true,
                            itemBuilder: (BuildContext context, int index) {
                              final myCollections = _collections[index];
                              return Slidable(
                                key: ValueKey(myCollections),
                                endActionPane: ActionPane(
                                  motion: ScrollMotion(),
                                  dismissible: DismissiblePane(
                                    onDismissed: () => _showDeleteConfirmDialog(
                                        context, index),
                                  ),
                                  children: [
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
                                    Navigator.of(context).pushNamed(
                                        ChildCollectionsListScreen.screenId,
                                        arguments: {
                                          'collectionId': controller
                                              .myCollectionsIndexList[index].id,
                                          'name': controller
                                              .myCollectionsIndexList[index]
                                              .name
                                        });
                                  },
                                  child: ListTile(
                                      /* leading: Icon(IconData(
                                          controller.myCollectionsIndexList[index]
                                              .iconId!,
                                          fontFamily: 'MaterialIcons')),*/
                                      leading: Icon(Icons.comment),
                                      title: Text(controller
                                          .myCollectionsIndexList[index].name!),
                                      subtitle: Text(
                                        controller.myCollectionsIndexList[index]
                                            .description!,
                                      )),
                                )),
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

    /*Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              elevation: 0,
              color: Colors.grey.shade100,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListTile(
                  leading: Container(
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.blue, width: 2)),
                    child: CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.transparent,
                      backgroundImage: NetworkImage(myCollectionController
                          .myCollectionsIndexList[position]["image"]),
                    ),
                  ),
                  title: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                        child: Text(
                            myCollectionController
                                .myCollectionsIndexList[position]["name"],
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 18))),
                  ),
                  subtitle: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        SmallText(
                          text: "current vlaue",
                          color: AppColors.paraColor,
                        ),
                        BigText(
                          text:
                              "\$${myCollectionController.myCollectionsIndexList[position]["price"]}",
                        ),
                      ],
                    ),
                  ),
                  trailing: IconButton(
                      onPressed: () {},
                      icon: Icon(
                        Icons.edit,
                      )),
                ),
              ),
            ),
          );*/
    /*return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  leading: SizedBox(
                    width: 100,
                    child: Image.file(
                      File(itemsList[position].item_image!),
                      fit: BoxFit.fill,
                    ),
                  ),
                  title: BigText(text: itemsList[position].item_name!),
                  subtitle: SmallText(
                    text: itemsList[position].item_desc!,
                    color: AppColors.paraColor,
                  ),
                  trailing: SmallText(text: itemsList[position].item_value!),
                  onTap: () async {
                    sharedPreferences = await SharedPreferences.getInstance();
                    await sharedPreferences.setInt(
                        "rowid", itemsList[position].id!);

                    Navigator.of(context)
                        .pushNamed(ItemDetailsViewScreen.screenId);
                  },
                ),
              );)*/
  }

  Dialogs alert = Dialogs();
  Future<void> _showDeleteConfirmDialog(BuildContext context, int index) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap a button
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete this collection?'),
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
                myCollectionController
                    .deleteCollectionController(_collections[index].id!)
                    .then((result) {
                  if (result.isSuccess) {
                    setState(() {
                      _collections.removeAt(index); // ✅ Remove deleted item
                    });

                    Navigator.of(context).pop(true);
                    //Navigator.pop(context, true);
                  } else {
                    alert.showAlertDialog(
                        context, "Delete collection", result.message);
                  }
                });
                // _deleteItem(index);
                //  Navigator.of(context).pop(); // Dismiss the dialog
                // Optionally show a snackbar or toast
              },
            ),
          ],
        );
      },
    );
  }
}
