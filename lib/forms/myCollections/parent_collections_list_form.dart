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

  String _searchQuery = '';
  String _sortBy = 'Name';
  String _order = 'A-Z';

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

  void _filterList(String query) {
    final allCollections =
        Get.find<MyCollectionsController>().myCollectionsIndexList;

    if (query.isEmpty) {
      // If search box is empty, show all items

      _collections = List.from(allCollections);
    } else {
      final lowerQuery = query.toLowerCase();
      _collections = allCollections.where((item) {
        return (item.name?.toLowerCase().contains(lowerQuery) ?? false) ||
            (item.description?.toLowerCase().contains(lowerQuery) ?? false);
      }).toList();
    }

    // Sort the filtered items
    _collections.sort((a, b) {
      int cmp;
      switch (_sortBy) {
        case 'Name':
          cmp = (a.name ?? '').compareTo(b.name ?? '');
          break;
        case 'Description':
          cmp = (a.description ?? '').compareTo(b.description ?? '');
          break;

        default:
          cmp = 0;
      }
      return _order == 'A-Z' ? cmp : -cmp;
    });
  }

  @override
  Widget build(BuildContext context) {
    // myCollectionController.readJson();
    // Get.find<MyCollectionsController>().getParentCollectionList();

    /* Get.find<MyCollectionsController>()
        .getCollectionsList(myCollectionController.getUserToken());*/
    // _loadCollections();

    return Stack(
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.all(12),
            color: Colors.white,
            child: Text(
              'My Collections',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryColor,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              const SizedBox(
                height: 40,
              ),
              GetBuilder<MyCollectionsController>(
                builder: (controller) {
                  if (!controller.isLoaded) {
                    return const SizedBox(
                      height: 200,
                      child: Center(
                        child: Text(
                          'No records found',
                          style: TextStyle(fontSize: 15),
                        ),
                      ),
                    );
                  }
                  return SizedBox(
                    width: Dimensions.screenWidth,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(3.0),
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Search by name',
                              prefixIcon: Icon(Icons.search),
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (value) {
                              setState(() {
                                _searchQuery = value;
                              });

                              _filterList(_searchQuery);
                            },
                          ),
                        ),
                        SizedBox(
                          height: Dimensions.height30,
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              'Tab the column header name for sorting',
                              style: TextStyle(color: AppColors.primaryColor),
                            ),
                          ),
                        ),
                        Table(
                          border:
                              TableBorder.all(width: 0.5, color: Colors.grey),
                          columnWidths: const {
                            0: FlexColumnWidth(), // Namee
                            1: FlexColumnWidth(), // Desc

                            2: FixedColumnWidth(40),
                          },
                          children: [
                            TableRow(
                              decoration:
                                  BoxDecoration(color: Colors.grey[200]),
                              children: [
                                // Name header clickable
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      if (_sortBy == 'Name') {
                                        _order =
                                            (_order == 'A-Z') ? 'Z-A' : 'A-Z';
                                      } else {
                                        _sortBy = 'Name';
                                        _order = 'A-Z';
                                      }
                                      _filterList(_searchQuery);
                                    });
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Row(
                                      children: [
                                        const Text('Name',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold)),
                                        if (_sortBy == 'Name')
                                          Icon(
                                              _order == 'A-Z'
                                                  ? Icons.arrow_upward
                                                  : Icons.arrow_downward,
                                              size: 16),
                                      ],
                                    ),
                                  ),
                                ),

                                // Desc header clickable
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      if (_sortBy == 'Description') {
                                        _order =
                                            (_order == 'A-Z') ? 'Z-A' : 'A-Z';
                                      } else {
                                        _sortBy = 'Description';
                                        _order = 'A-Z';
                                      }
                                      _filterList(_searchQuery);
                                    });
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Row(
                                      children: [
                                        const Text('Description',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold)),
                                        if (_sortBy == 'Description')
                                          Icon(
                                              _order == 'A-Z'
                                                  ? Icons.arrow_upward
                                                  : Icons.arrow_downward,
                                              size: 16),
                                      ],
                                    ),
                                  ),
                                ),

                                const Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Text('-',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 500,
                          child: SingleChildScrollView(
                            child: Table(
                              border: TableBorder.all(
                                  width: 0.5, color: Colors.grey),
                              columnWidths: const {
                                0: FlexColumnWidth(),
                                1: FlexColumnWidth(),
                                2: FixedColumnWidth(40),
                              },
                              children:
                                  _collections.asMap().entries.map((entry) {
                                int index = entry.key;
                                var item = entry.value;
                                return TableRow(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.of(context).pushNamed(
                                            ChildCollectionsListScreen.screenId,
                                            arguments: {
                                              'collectionId': item.id,
                                              'name': item.name
                                            });
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          item.name ?? '',
                                          style: TextStyle(
                                            color: Colors
                                                .blue, // Optional: show it's clickable
                                            decoration:
                                                TextDecoration.underline,
                                          ),
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.of(context).pushNamed(
                                            ChildCollectionsListScreen.screenId,
                                            arguments: {
                                              'collectionId': item.id,
                                              'name': item.name
                                            });
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          item.description ?? '',
                                          style: TextStyle(
                                              color: AppColors.paraColor),
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        _showDeleteConfirmDialog(
                                            context, index);
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        )
                      ],
                    ),
                  );
                },
              )
            ],
          ),
        ),
        Positioned(
          bottom: 16,
          right: 16,
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
              ),
            ),
          ),
        ),
      ],
    );
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
