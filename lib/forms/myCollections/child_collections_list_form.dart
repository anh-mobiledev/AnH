import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
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

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
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
                    onPressed: () async {
                      alert.showLoaderDialog(context);
                      createDialog();
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
                                          name: child_collections.name!,
                                          description:
                                              child_collections.description! ??
                                                  'NA',
                                          price: child_collections.valueAmount!,
                                          imageUrl: child_collections
                                              .primary_img_url!),
                                      backgroundColor: Colors.blue,
                                      foregroundColor: Colors.white,
                                      icon: Icons.share,
                                      label: 'Share',
                                    ),
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
                                        id: _collectionItems[index].myItemId,
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
                                      leading: FutureBuilder<ImageProvider?>(
                                        future: _getThumbnailImage(
                                            _collectionItems[index]
                                                .primary_img_url!),
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return const SizedBox(
                                              height: 60,
                                              width: 60,
                                              child: Center(
                                                  child:
                                                      CircularProgressIndicator(
                                                          strokeWidth: 2)),
                                            );
                                          }

                                          if (snapshot.hasData &&
                                              snapshot.data != null) {
                                            return Stack(
                                              alignment: Alignment.center,
                                              children: [
                                                ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  child: Image(
                                                    image: snapshot.data!,
                                                    height: 60,
                                                    width: 60,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                                if (_isVideo(
                                                    _collectionItems[index]
                                                        .primary_img_url!))
                                                  GestureDetector(
                                                    onTap: () {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (_) =>
                                                              VideoPlayerScreen(
                                                                  videoUrl: (_collectionItems[
                                                                          index]
                                                                      .primary_img_url!)),
                                                        ),
                                                      );
                                                    },
                                                    child: const Icon(
                                                        Icons.play_circle_fill,
                                                        color: Colors.white70,
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
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(5.0),
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
                        Flexible(
                          child: ListView.builder(
                            itemCount: _filteredItems?.length ?? 0,
                            itemBuilder: (context, index) {
                              final item = _filteredItems[index];
                              return Card(
                                child: InkWell(
                                  onTap: () {
                                    Navigator.of(context).pushNamed(
                                      ItemDetailsViewScreen.screenId,
                                      arguments: item,
                                    );
                                  },
                                  child: ListTile(
                                    leading: FutureBuilder<ImageProvider?>(
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
                                                        strokeWidth: 2)),
                                          );
                                        }

                                        if (snapshot.hasData &&
                                            snapshot.data != null) {
                                          return Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(8),
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
                                                                videoUrl: (item
                                                                    .primary_img_url!)),
                                                      ),
                                                    );
                                                  },
                                                  child: const Icon(
                                                      Icons.play_circle_fill,
                                                      color: Colors.white70,
                                                      size: 24),
                                                ),
                                            ],
                                          );
                                        } else {
                                          return const Icon(Icons.broken_image,
                                              size: 60);
                                        }
                                      },
                                    ),
                                    trailing: Checkbox(
                                      value: isCheckedIds.contains(item.id),
                                      onChanged: (value) {
                                        dialogSetState(() {
                                          if (value!) {
                                            isCheckedIds.add(item.id!);
                                          } else {
                                            isCheckedIds.remove(item.id);
                                          }
                                        });
                                      },
                                    ),
                                    title: Text(item.name ?? ''),
                                    subtitle: Text(item.valueAmount ?? ''),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
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
