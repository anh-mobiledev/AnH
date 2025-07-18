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
    _searchQuery = query;

    print('search query :: ${_searchQuery}');

    final filtered = itemController.myItemsIndexListServer.where((item) {
      final name = item.name?.toLowerCase() ?? '';
      return name.contains(_searchQuery.toLowerCase());
    }).toList();

    print('Sorting by: $_sortBy, Order: $_order');

    if (_sortBy == 'Name') {
      filtered.sort((a, b) {
        final nameA = a.name ?? '';
        final nameB = b.name ?? '';
        return _order == 'A-Z'
            ? nameA.compareTo(nameB)
            : nameB.compareTo(nameA);
      });
    } else if (_sortBy == 'Value') {
      filtered.sort((a, b) {
        final valueA = double.tryParse(a.valueAmount ?? '0') ?? 0;
        final valueB = double.tryParse(b.valueAmount ?? '0') ?? 0;
        return _order == 'A-Z'
            ? valueA.compareTo(valueB)
            : valueB.compareTo(valueA);
      });
    }

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
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search by name',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    _filterList(_searchQuery);

                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                flex: 1,
                child: DropdownButtonFormField<String>(
                  value: _sortBy,
                  items: ['Name', 'Value'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text('$value'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _sortBy = value!;
                    });
                    _filterList(_searchQuery);
                  },
                  decoration: InputDecoration(
                    labelText: 'Filter',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                flex: 1,
                child: DropdownButtonFormField<String>(
                  value: _order,
                  items: ['A-Z', 'Z-A'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _order = value!;
                    });
                    _filterList(_searchQuery);
                  },
                  decoration: InputDecoration(
                    labelText: 'Sort',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 20,
          ),
          GetBuilder<ItemController>(
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
                        child: ListView.builder(
                          padding: const EdgeInsets.all(5.0),
                          itemCount: _filteredItems == null
                              ? 0
                              : _filteredItems.length,
                          itemBuilder: (context, index) {
                            final item = _filteredItems[index];
                            return Slidable(
                              key: ValueKey(item),
                              endActionPane: ActionPane(
                                motion: ScrollMotion(),
                                dismissible: DismissiblePane(
                                    onDismissed: () => _showDeleteConfirmDialog(
                                        context, index)),
                                children: [
                                  SlidableAction(
                                    onPressed: (context) => _shareItem(
                                        name: item.name!,
                                        description: item.description! ?? 'NA',
                                        price: item.valueAmount!,
                                        imageUrl: item.primary_img_url!),
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
                                  onTap: () async {
                                    Navigator.of(context).pushNamed(
                                        ItemDetailsViewScreen.screenId,
                                        arguments: item);
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
                                    title: Text(item.name ?? ''),
                                    subtitle: Text(item.valueAmount ?? ''),
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
          )
        ],
      ),
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
