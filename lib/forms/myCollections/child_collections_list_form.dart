import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:pam_app/components/large_heading_widget.dart';
import 'package:pam_app/constants/colours.dart';
import 'package:pam_app/constants/dimensions.dart';
import 'package:pam_app/controllers/item_controller.dart';
import 'package:pam_app/controllers/my_collections_controller.dart';

import 'package:pam_app/helper/DBHelper.dart';
import 'package:pam_app/models/collection_items_server_model.dart';
import 'package:pam_app/models/my_items_server_model.dart';
import 'package:pam_app/screens/addItem/VideoPlayerScreen.dart';
import 'package:pam_app/screens/addItem/item_details_view.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

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

  void _shareItem({
    required String name,
    required String price,
    required String description,
    required String imageUrl,
  }) {
    final message = '''
    Check out this product!

    Name: $name
    Price: $price
    Description: $description
    Image: $imageUrl
    ''';
    Share.share(message);
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
              'Collections Items',
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
              Expanded(
                child: GetBuilder<MyCollectionsController>(
                  builder: (myCollectionController) {
                    if (!myCollectionController.isLoaded) {
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
                          Table(
                            border:
                                TableBorder.all(width: 0.5, color: Colors.grey),
                            columnWidths: const {
                              0: FixedColumnWidth(60), // Image
                              1: FlexColumnWidth(), // Name
                              2: FixedColumnWidth(65), // Value
                              3: FixedColumnWidth(40), // Share
                              4: FixedColumnWidth(40), // Del
                            },
                            children: [
                              TableRow(
                                decoration:
                                    BoxDecoration(color: Colors.grey[200]),
                                children: [
                                  // Preview header (not clickable)
                                  const Padding(
                                    padding: EdgeInsets.all(8),
                                    child: Text('Preview',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                  ),

                                  // Name header clickable
                                  GestureDetector(
                                    onTap: () {},
                                    child: Padding(
                                      padding: const EdgeInsets.all(8),
                                      child: Row(
                                        children: [
                                          const Text('Name',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                    ),
                                  ),

                                  // Value header clickable
                                  GestureDetector(
                                    onTap: () {},
                                    child: Padding(
                                      padding: const EdgeInsets.all(8),
                                      child: Row(
                                        children: [
                                          const Text('Value',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold)),
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
                                  0: FixedColumnWidth(60), // Image
                                  1: FlexColumnWidth(), // Name
                                  2: FixedColumnWidth(65), // Value
                                  3: FixedColumnWidth(40), // Share
                                  4: FixedColumnWidth(40) // Delete
                                },
                                children: [
                                  // Data rows
                                  ..._collectionItems
                                      .asMap()
                                      .entries
                                      .map((entry) {
                                    int index = entry.key;
                                    final item = entry.value;

                                    return TableRow(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: FutureBuilder<ImageProvider?>(
                                            future: _getThumbnailImage(
                                                item.primary_img_url!),
                                            builder: (context, snapshot) {
                                              if (snapshot.connectionState ==
                                                  ConnectionState.waiting) {
                                                return const SizedBox(
                                                  height: 60,
                                                  width: 60,
                                                  child: Center(
                                                    child:
                                                        CircularProgressIndicator(
                                                            strokeWidth: 2),
                                                  ),
                                                );
                                              }

                                              if (snapshot.hasData &&
                                                  snapshot.data != null) {
                                                return Stack(
                                                  alignment: Alignment.center,
                                                  children: [
                                                    ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                      child: Image(
                                                        image: snapshot.data!,
                                                        height: 60,
                                                        width: 60,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                    if (_isVideo(
                                                        item.primary_img_url!))
                                                      GestureDetector(
                                                        onTap: () {
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (_) =>
                                                                  VideoPlayerScreen(
                                                                videoUrl: item
                                                                    .primary_img_url!,
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                        child: const Icon(
                                                            Icons
                                                                .play_circle_fill,
                                                            color:
                                                                Colors.white70,
                                                            size: 24),
                                                      ),
                                                  ],
                                                );
                                              } else {
                                                return const Icon(
                                                    Icons.broken_image,
                                                    size: 60);
                                              }
                                            },
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            MyItemsServerModel arguments =
                                                MyItemsServerModel(
                                              id: _collectionItems[index]
                                                  .myItemId,
                                              name:
                                                  _collectionItems[index].name,
                                              description:
                                                  _collectionItems[index]
                                                      .description,
                                              valueAmount:
                                                  _collectionItems[index]
                                                      .valueAmount,
                                              primary_img_url:
                                                  _collectionItems[index]
                                                      .primary_img_url,
                                              valueType: _collectionItems[index]
                                                  .valueType,
                                              valueUnits:
                                                  _collectionItems[index]
                                                      .valueUnits,
                                              status: _collectionItems[index]
                                                  .status,
                                              condition: _collectionItems[index]
                                                  .condition,
                                              keywords: _collectionItems[index]
                                                  .keywords,
                                            );

                                            Navigator.of(context).pushNamed(
                                                ItemDetailsViewScreen.screenId,
                                                arguments: arguments);
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
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(item.valueAmount ?? ''),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.share,
                                              color: Colors.blue),
                                          onPressed: () {
                                            _shareItem(
                                              name: item.name!,
                                              description:
                                                  item.description ?? 'NA',
                                              price: item.valueAmount!,
                                              imageUrl: item.primary_img_url!,
                                            );
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete,
                                              color: Colors.red),
                                          onPressed: () {
                                            _showDeleteConfirmDialog(
                                                context, index);
                                          },
                                        ),
                                      ],
                                    );
                                  }).toList(),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    );
                  },
                ),
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
              onPressed: () async {
                alert.showLoaderDialog(context);
                createDialog();
              },
              child: Icon(
                Icons.add,
                color: Colors.white,
              ),
            ),
          ),
        )
      ],
    );
  }

  var collectionController = Get.find<MyCollectionsController>();
  var itemController = Get.find<ItemController>();

  List<MyItemsServerModel> _filteredItems = [];

  void _filterList(
      String query, void Function(void Function()) dialogSetState) {
    final allItems = Get.find<ItemController>().myItemsIndexListServer;

    final filltered = allItems.where((item) {
      return item.name?.toLowerCase().contains(query.toLowerCase()) ?? false;
    }).toList();

    dialogSetState(
      () {
        _filteredItems = filltered;
      },
    );
  }

  //My Items list
  createDialog() async {
    await Get.find<ItemController>().getMyItemsListServer();

    _isChecked = List<bool>.filled(
      itemController.myItemsIndexListServer.length,
      false,
    );

    Navigator.pop(context);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, dialogSetState) {
            return AlertDialog(
              title: const Text('Your Items'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    confirmDialog();
                  },
                  child: const Text('Save'),
                ),
              ],
              content: GetBuilder<ItemController>(
                builder: (controller) {
                  if (!controller.isLoaded) {
                    return const SizedBox(
                      height: 200,
                      child: Center(
                        child: Text(
                          "No records found",
                          style: TextStyle(fontSize: 15),
                        ),
                      ),
                    );
                  }

                  if (_filteredItems == null || _filteredItems!.isEmpty) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      dialogSetState(() {
                        _filteredItems =
                            List.from(controller.myItemsIndexListServer);
                      });
                    });
                  }

                  return SizedBox(
                    width: MediaQuery.of(context).size.width * 1.2,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(3.0),
                          child: TextField(
                            decoration: InputDecoration(
                              labelText: "Search by name",
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.search),
                            ),
                            onChanged: ((value) {
                              _filterList(value, dialogSetState);
                            }),
                          ),
                        ),

                        // Fixed Table header
                        Table(
                          border:
                              TableBorder.all(width: 0.5, color: Colors.grey),
                          columnWidths: const {
                            0: FixedColumnWidth(80), // Image
                            1: FlexColumnWidth(), // Name
                            2: FlexColumnWidth(), // Value/Units
                            3: FixedColumnWidth(50), // Checkbox
                          },
                          children: [
                            TableRow(
                              decoration:
                                  BoxDecoration(color: Colors.grey[200]),
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Text('Preview',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Text('Name',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Text('Value',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Text('Select',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          ],
                        ),

                        Expanded(
                            child: SingleChildScrollView(
                                child: Table(
                                    border: TableBorder.all(
                                        width: 0.5, color: Colors.grey),
                                    columnWidths: const {
                                      0: FixedColumnWidth(80),
                                      1: FlexColumnWidth(),
                                      2: FlexColumnWidth(),
                                      3: FixedColumnWidth(50),
                                    },
                                    children: _filteredItems.map((item) {
                                      return TableRow(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(4.0),
                                            child:
                                                FutureBuilder<ImageProvider?>(
                                              future: _getThumbnailImage(
                                                  item.primary_img_url!),
                                              builder: (context, snapshot) {
                                                if (snapshot.connectionState ==
                                                    ConnectionState.waiting) {
                                                  return const SizedBox(
                                                    height: 60,
                                                    width: 60,
                                                    child: Center(
                                                        child:
                                                            CircularProgressIndicator(
                                                                strokeWidth:
                                                                    2)),
                                                  );
                                                }

                                                if (snapshot.hasData &&
                                                    snapshot.data != null) {
                                                  return Stack(
                                                    alignment: Alignment.center,
                                                    children: [
                                                      GestureDetector(
                                                        onTap: () {
                                                          Navigator.of(context)
                                                              .pushNamed(
                                                            ItemDetailsViewScreen
                                                                .screenId,
                                                            arguments: item,
                                                          );
                                                        },
                                                        child: ClipRRect(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(6),
                                                          child: Image(
                                                            image:
                                                                snapshot.data!,
                                                            height: 60,
                                                            width: 60,
                                                            fit: BoxFit.cover,
                                                          ),
                                                        ),
                                                      ),
                                                      if (_isVideo(item
                                                          .primary_img_url!))
                                                        GestureDetector(
                                                          onTap: () {
                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                builder: (_) =>
                                                                    VideoPlayerScreen(
                                                                        videoUrl:
                                                                            item.primary_img_url!),
                                                              ),
                                                            );
                                                          },
                                                          child: const Icon(
                                                              Icons
                                                                  .play_circle_fill,
                                                              color: Colors
                                                                  .white70,
                                                              size: 24),
                                                        ),
                                                    ],
                                                  );
                                                } else {
                                                  return const Icon(
                                                      Icons.broken_image,
                                                      size: 60);
                                                }
                                              },
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              Navigator.of(context).pushNamed(
                                                ItemDetailsViewScreen.screenId,
                                                arguments: item,
                                              );
                                            },
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Text(item.name ?? ''),
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              Navigator.of(context).pushNamed(
                                                ItemDetailsViewScreen.screenId,
                                                arguments: item,
                                              );
                                            },
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Text(
                                                  '${item.valueAmount ?? ''} (${item.valueUnits})'),
                                            ),
                                          ),
                                          StatefulBuilder(builder:
                                              (context, dialogSetState) {
                                            return Checkbox(
                                              value: isCheckedIds
                                                  .contains(item.id),
                                              onChanged: (value) {
                                                dialogSetState(() {
                                                  if (value!) {
                                                    isCheckedIds.add(item.id!);
                                                  } else {
                                                    isCheckedIds
                                                        .remove(item.id);
                                                  }
                                                });
                                              },
                                            );
                                          }),
                                        ],
                                      );
                                    }).toList()))),
                      ],
                    ),
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
  Future<void> confirmDialog() async {
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
                    'Are you sure you want to add this item to collection item?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Yes'),
              onPressed: () async {
                await collectionController
                    .collectionItemCreate(
                  collectionId!,
                  isCheckedIds.join(','),
                  "", "", "", "", "", "", // your other params
                )
                    .then((status) {
                  if (status.isSuccess) {
                    _loadCollectionItems();
                    Navigator.of(context).pop(true);
                  }
                });
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
                collectionController
                    .deleteCollectionItemController(
                        _collectionItems[index].collectionItemId!,
                        widget.collectionId)
                    .then((result) {
                  if (result.isSuccess) {
                    setState(() {
                      _collectionItems.removeAt(index); // ✅ Remove deleted item
                    });

                    Navigator.of(context).pop(true);
                    //Navigator.pop(context, true);
                  } else {
                    alert.showAlertDialog(
                        context, "Delete collection item", result.message);
                  }
                });
                //  _deleteItem(index);
                //   Navigator.of(context).pop(); // Dismiss the dialog
                // Optionally show a snackbar or toast
              },
            ),
          ],
        );
      },
    );
  }

  bool _isVideo(String path) {
    final videoExtensions = ['.mp4', '.mov', '.avi', '.mkv', '.3gp'];
    return videoExtensions.any((ext) => path.toLowerCase().endsWith(ext));
  }

  Future<ImageProvider?> _getThumbnailImage(String url) async {
    if (_isVideo(url)) {
      try {
        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          final tempDir = await getTemporaryDirectory();
          final videoFile = File(
              '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.mp4');
          await videoFile.writeAsBytes(response.bodyBytes);

          final thumbnailData = await VideoThumbnail.thumbnailData(
            video: videoFile.path,
            imageFormat: ImageFormat.PNG,
            maxWidth: 150,
            quality: 75,
          );
          if (thumbnailData != null) return MemoryImage(thumbnailData);
        }
      } catch (e) {
        debugPrint('Error generating video thumbnail: $e');
      }
      return null;
    } else {
      return CachedNetworkImageProvider(url);
    }
  }
}
