import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:pam_app/constants/colours.dart';
import 'package:pam_app/constants/dimensions.dart';
import 'package:pam_app/helper/DBHelper.dart';
import 'package:pam_app/models/delete_myitem_failure_response.dart';
import 'package:pam_app/models/item_info_sqllite.dart';
import 'package:pam_app/models/my_items_server_model.dart';
import 'package:pam_app/screens/addItem/add_item_images.dart';
import 'package:pam_app/screens/addItem/item_details_view.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import '../common/alert.dart';
import '../controllers/item_controller.dart';
import '../screens/addItem/VideoPlayerScreen.dart';

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

  String _searchQuery = '';
  String _sortBy = 'Name';
  String _order = 'A-Z';
  Dialogs alert = Dialogs();

  Future<void> getItemsList() async {
    var result = await dbHelper.getItemsList();
    setState(() {
      itemsList = result;
    });
  }

  Future<void> getMyItemsListServer() async {
    await Get.find<ItemController>().getMyItemsListServer().then((__) {
      _isChecked = List<bool>.filled(
          itemController.myItemsIndexListServer.length, false);
      _filteredItems = itemController.myItemsIndexListServer;
    });

    /* setState(() {
      _isLoading = false;
      _filteredItems = itemController.myItemsIndexListServer;
    });*/
  }

  @override
  void initState() {
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
    final allItems = Get.find<ItemController>().myItemsIndexListServer;

    if (query.isEmpty) {
      // If search box is empty, show all items

      _filteredItems = List.from(allItems);
    } else {
      final lowerQuery = query.toLowerCase();
      _filteredItems = allItems.where((item) {
        return (item.name?.toLowerCase().contains(lowerQuery) ?? false) ||
            (item.valueAmount?.toLowerCase().contains(lowerQuery) ?? false) ||
            (item.valueUnits?.toLowerCase().contains(lowerQuery) ?? false);
      }).toList();
    }

    // Sort the filtered items
    _filteredItems.sort((a, b) {
      int cmp;
      switch (_sortBy) {
        case 'Name':
          cmp = (a.name ?? '').compareTo(b.name ?? '');
          break;
        case 'Value':
          cmp = (a.valueAmount ?? '').compareTo(b.valueAmount ?? '');
          break;
        case 'Unit':
          cmp = (a.valueUnits ?? '').compareTo(b.valueUnits ?? '');
          break;
        default:
          cmp = 0;
      }
      return _order == 'A-Z' ? cmp : -cmp;
    });
  }

  @override
  Widget build(BuildContext context) {
    // loadingDialogBox(context, "please wait...");

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
              'My Items',
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
                child: GetBuilder<ItemController>(
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
                              0: FixedColumnWidth(60), // Image
                              1: FlexColumnWidth(), // Name
                              2: FixedColumnWidth(65), // Value
                              3: FixedColumnWidth(55), // Unit
                              4: FixedColumnWidth(40), // Unit
                              5: FixedColumnWidth(40), // Unit
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

                                  // Value header clickable
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        if (_sortBy == 'Value') {
                                          _order =
                                              (_order == 'A-Z') ? 'Z-A' : 'A-Z';
                                        } else {
                                          _sortBy = 'Value';
                                          _order = 'A-Z';
                                        }
                                        _filterList(_searchQuery);
                                      });
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(8),
                                      child: Row(
                                        children: [
                                          const Text('Value',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                          if (_sortBy == 'Value')
                                            Icon(
                                                _order == 'A-Z'
                                                    ? Icons.arrow_upward
                                                    : Icons.arrow_downward,
                                                size: 16),
                                        ],
                                      ),
                                    ),
                                  ),

                                  // Unit header clickable
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        if (_sortBy == 'Unit') {
                                          _order =
                                              (_order == 'A-Z') ? 'Z-A' : 'A-Z';
                                        } else {
                                          _sortBy = 'Unit';
                                          _order = 'A-Z';
                                        }
                                        _filterList(_searchQuery);
                                      });
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(8),
                                      child: Row(
                                        children: [
                                          const Text('Unit',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                          if (_sortBy == 'Unit')
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
                                  0: FixedColumnWidth(60),
                                  1: FlexColumnWidth(),
                                  2: FixedColumnWidth(65),
                                  3: FixedColumnWidth(55),
                                  4: FixedColumnWidth(40),
                                  5: FixedColumnWidth(40),
                                },
                                children:
                                    _filteredItems.asMap().entries.map((entry) {
                                  int index = entry.key;
                                  var item = entry.value;
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
                                                            strokeWidth: 2)),
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
                                                          BorderRadius.circular(
                                                              6),
                                                      child: Image(
                                                        image: snapshot.data!,
                                                        height: 60,
                                                        width: 60,
                                                        fit: BoxFit.cover,
                                                      ),
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
                                                                        .primary_img_url!),
                                                          ),
                                                        );
                                                      },
                                                      child: const Icon(
                                                          Icons
                                                              .play_circle_fill,
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
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.of(context).pushNamed(
                                            ItemDetailsViewScreen.screenId,
                                            arguments: item,
                                          );
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
                                            ItemDetailsViewScreen.screenId,
                                            arguments: item,
                                          );
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            item.valueAmount ?? '',
                                            style: TextStyle(
                                                color: AppColors.paraColor),
                                          ),
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
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            '${item.valueUnits}',
                                            style: TextStyle(
                                                color: AppColors.paraColor),
                                          ),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          _shareItem(
                                              name: item.name!,
                                              price: item.valueAmount!,
                                              description: item.description!,
                                              imageUrl: item.primary_img_url!);
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Icon(
                                            Icons.share,
                                            color: AppColors.secondaryColor,
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
              onPressed: () {
                Navigator.of(context).pushNamed(AddItemImagesScreen.screenId);
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
                itemController
                    .deleteMyitemController(_filteredItems[index].id!)
                    .then((result) {
                  if (result.isSuccess) {
                    setState(() {
                      _filteredItems.removeAt(index); // ✅ Remove deleted item
                    });

                    Navigator.of(context).pop(true);
                    //Navigator.pop(context, true);
                  } else {
                    /* alert.showAlertDialog(
                        context, "Delete Myitem", result.message);*/
                    Navigator.of(context).pop(true);
                    _showCustomListDialog(
                        context, itemController.refCollections);
                  }
                });
                // _deleteItem(index);
                // Dismiss the dialog
                // Optionally show a snackbar or toast
              },
            ),
          ],
        );
      },
    );
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

  Future<void> _showCustomListDialog(
      BuildContext context, List<ReferenceCollections> refCollections) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // close when tapped outside
      builder: (BuildContext context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          child: Container(
            height: 300, // you must give height for ListView
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                    'Item not deleted.  Delete from the following collections first.',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    itemCount: refCollections.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(refCollections[index].collectionName!),
                        onTap: () {
                          // handle item tap
                          print(
                              'Selected: ${refCollections[index].collectionName}');
                          Navigator.pop(context); // close dialog
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
