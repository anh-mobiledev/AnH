import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:mime/mime.dart';
import 'package:pam_app/models/attachments_list.dart';
import 'package:pam_app/models/my_items_by_id_server_model.dart';
import 'package:pam_app/screens/addItem/items_list.dart';
import 'package:pam_app/services/auth.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_compress/video_compress.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import '../common/alert.dart';
import '../constants/colours.dart';
import '../constants/dimensions.dart';
import '../constants/widgets.dart';
import '../controllers/item_controller.dart';
import '../helper/DBHelper.dart';
import '../models/item_image.dart';
import '../models/my_items_server_model.dart';
import '../screens/addItem/VideoPlayerScreen.dart';
import '../widgets/app_icon.dart';
import '../widgets/big_text.dart';

enum FileFomatIds { JPG, JPEG, PNG, MP4 }

class ItemDetailsViewForm extends StatefulWidget {
  final MyItemsServerModel itemInfo;

  ItemDetailsViewForm(this.itemInfo);

  //final ItemInfoSQLLite itemInfo;

  @override
  State<ItemDetailsViewForm> createState() => _ItemDetailsViewFormState();
}

class _ItemDetailsViewFormState extends State<ItemDetailsViewForm> {
  final _formKey = GlobalKey<FormState>();

  final _itemNameController = TextEditingController();
  final _itemDescController = TextEditingController();

  final _keyWordsController = TextEditingController();
  final _valueController = TextEditingController();
  final _valueUnitsController = TextEditingController();

  bool uploading = false;
  double val = 0;

  var itemController = Get.find<ItemController>();
  Dialogs alert = Dialogs();

  DBHelper dbHelper = DBHelper();

  bool _isConnected = false;
  late List<ItemImage> images;

  PageController pageController = PageController(viewportFraction: 0.85);
  double _curPageValue = 0.0;
  double _scaleFactor = 0.8;
  double _height = Dimensions.pageViewContainer;

  final List<String> _valueType = [
    'Select value type',
    'Cash value',
    'Needs appraisal',
    'Sentimental, has cash value',
    'Sentimental, no cash value'
  ];

  final List<String> _categoryList = [
    'Select category',
    'Crafts',
    'Dolls & Bears',
    'Health & Beauty',
    'Pet Supplies',
    'Toys & Hobbies',
    'Books & Magazines',
    'Business & Industrial',
    'Cameras & Photo',
    'Cell Phones & Accessories',
    'Computers/Tablets & Networking',
    'Electronics',
    'Home & Garden',
    'Musical Instruments & Gear',
    'Headphones',
    'Portable Audio & Home Audio',
    'Video Game Consoles',
    'Smart Home',
    'Shoes & Accessories',
    'Clothing and accessories',
    'Jewellery & Watches',
    'Sporting Goods',
    'Movies & TV',
    'Music',
    'Video Games',
    'Motors: Cars & Trucks',
    'Motors: Parts & Accessories',
    'Tires',
    'Art',
    'Sports Mem',
    'Cards & Fan Shop',
  ];

  final List<String> _conditionList = [
    'Select condition',
    'New',
    'Used',
    'Like New',
    'Good',
    'Very Good'
  ];

  final List<String> _statusList = [
    'Select status',
    'Not for sale',
    'Available',
    'Sold'
  ];

  final List<String> _valueUnitsList = [
    'Select value units',
    'USD',
    'EUR',
    'JPY'
  ];

  final List<String> _additionalOptions = [
    'Select additional option',
    'Make it an estate item',
    'I want to share it',
    'I want to sell it',
    'I want to rent it',
    'I want it appraised',
    'I want to donate it'
  ];

  int itemCode = 0;
  //late ItemInfoSQLLite itemInfo;

  bool _btnEnabled = false;

  bool isLoading = true;
  late final InternetConnectionCheckerPlus _connectionChecker;
  var imgFile;
  final ImagePicker imagePicker = ImagePicker();

  String? mediaUrl;
  String? thumbnailUrl;
  bool isVideo = false;
  String? itemId;

  Auth authService = Auth();
  final storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _connectionChecker = InternetConnectionCheckerPlus();
    _checkConnection();
    _startMonitoring();

    _itemNameController.text = widget.itemInfo.name!;
    _itemDescController.text = widget.itemInfo.description!;
    _valueController.text = widget.itemInfo.valueAmount!.toString();
    _valueUnitsController.text = widget.itemInfo.valueUnits!;
    selectedValueType = widget.itemInfo.valueType!;
    selectedCondtion = widget.itemInfo.condition!;
    selectedStatus = widget.itemInfo.status!;
    _keyWordsController.text = widget.itemInfo.keywords!;
    itemId = widget.itemInfo.id!.toString();

    getMyItemAttachmentsList(itemId!);

    pageController.addListener(() {
      setState(() {
        _curPageValue = pageController.page!;
      });
    });

    validateItemNameButton();
    validateItemDetailsUpdateButton();
    validateItemAdditonalOptionsUpdateButton();
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

  void validateItemNameButton() {
    bool isValid = true;

    isValid = _itemNameController.text.length > 3;

    setState(() {
      _btnEnabled = isValid;
    });
  }

  List<Map<String, String>> mediaList = [];

  getMyItemAttachmentsList(String itemId) {
    itemController.getMyItemsAttachmentsController(itemId);
  }

  MyItemByIdServerModel? myItemByIdServerModel;
  getMyItemById(String itemId) async {
    await itemController.getMyItemById(itemId).then((__) {
      setState(() {
        myItemByIdServerModel = itemController.myItemByIdServer;
      });
      _itemNameController.text = myItemByIdServerModel!.name!;
      _itemDescController.text = myItemByIdServerModel!.description!;
      _valueController.text = myItemByIdServerModel!.valueAmount!.toString();
      _valueUnitsController.text = myItemByIdServerModel!.valueUnits!;
      selectedValueType = myItemByIdServerModel!.valueType!;
      selectedCondtion = myItemByIdServerModel!.condition!;
      selectedStatus = myItemByIdServerModel!.status!;
      _keyWordsController.text = myItemByIdServerModel!.keywords!;
    });
  }

  void validateItemNameUpdateButton() {
    bool isValid = true;

    isValid = _itemNameController.text.length > 3 ||
        selectedCondtion.isNotEmpty ||
        selectedValueType.isNotEmpty ||
        _valueController.text.length > 3 ||
        selectedStatus.isNotEmpty;

    setState(() {
      _btnEnabled = isValid;
    });
  }

  void validateItemDetailsUpdateButton() {
    bool isValid = true;

    isValid = selectedCategory.isNotEmpty ||
        _keyWordsController.text.length > 3 ||
        selectedCondtion.isNotEmpty ||
        selectedValueType.isNotEmpty ||
        _valueController.text.length > 3 ||
        selectedStatus.isNotEmpty ||
        selectedAdditionalOptions.isNotEmpty;

    setState(() {
      _btnEnabled = isValid;
    });
  }

  void validateItemAdditonalOptionsUpdateButton() {
    bool isValid = true;

    isValid = selectedAdditionalOptions.isNotEmpty;

    setState(() {
      _btnEnabled = isValid;
    });
  }

  @override
  void dispose() {
    _itemNameController.dispose();
    _itemDescController.dispose();
    _keyWordsController.dispose();
    _valueController.dispose();
    _valueUnitsController.dispose();
    pageController.dispose();
    super.dispose();
  }

  Future<File> compressImage(File imageFile) async {
    final dir = await getTemporaryDirectory();
    final targetPath =
        '${dir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';

    var result = await FlutterImageCompress.compressAndGetFile(
      imageFile.absolute.path, targetPath,
      quality: 70, // Adjust quality (0-100)
    );

    return File(result!.path);
  }

  String? getMimeType(String filePath) {
    return lookupMimeType(filePath);
  }

  Future<String?> getImageFormat(String filePath) async {
    final File file = File(filePath);
    final Uint8List imageBytes = await file.readAsBytes();
    final img.Image? image = img.decodeImage(imageBytes);

    if (image == null) return null;

    // Determine format based on magic numbers
    if (filePath.toLowerCase().endsWith('.png')) return "PNG";
    if (filePath.toLowerCase().endsWith('.jpg') ||
        filePath.toLowerCase().endsWith('.jpeg')) return "JPEG";
    if (filePath.toLowerCase().endsWith('.gif')) return "GIF";
    if (filePath.toLowerCase().endsWith('.bmp')) return "BMP";
    if (filePath.toLowerCase().endsWith('.webp')) return "WEBP";

    return "Unknown Format";
  }

  Future<File?> compressVideo(File videoFile) async {
    File videoCopressedFile = File(videoFile.path);
    // Compress the video
    final MediaInfo? compressedVideo = await VideoCompress.compressVideo(
      videoCopressedFile.path,
      quality: VideoQuality
          .MediumQuality, // LowQuality, MediumQuality, HighestQuality
      deleteOrigin: false, // Set to true to remove the original file
    );

    return compressedVideo?.file;
  }

  pickVideo(ImageSource source) async {
    final videoFile = await imagePicker.pickVideo(source: source);

    if (videoFile != null) {
      alert.showLoaderDialog(context);

      File? compressedVideo = await compressVideo(File(videoFile.path));

      /* String? fileFormat = await getImageFormat(compressedVideo!.path);
      print("${fileFormat}");*/

      int videoFormat = 0;
      if (_isVideo(compressedVideo!.path)) {
        videoFormat = 4;
      }

      String? contentType = getMimeType(compressedVideo.path);
      print("${contentType}");

      itemController
          .addMyItemMediaAsAttachment(itemId!, videoFormat, contentType!,
              "false", File(compressedVideo.path))
          .then((result) {
        if (result.isSuccess) {
          // print(itemController.myItemId);
        }
      });

      Navigator.pop(context);

      setState(() {
        _btnEnabled = true;
      });
    }
  }

  pickImage(ImageSource source) async {
    try {
      var imgFile = await imagePicker.pickImage(source: source);

      if (imgFile != null) {
        alert.showLoaderDialog(context);

        File? compresssedImg = await compressImage(File(imgFile.path));

        String? fileFormat = await getImageFormat(compresssedImg.path);
        int finalFileFormat = 0;

        switch (fileFormat!.toLowerCase()) {
          case "jpg":
            finalFileFormat = 1;
            break;
          case "jpeg":
            finalFileFormat = 2;
            break;
          case "png":
            finalFileFormat = 3;
            break;
          case "gif":
            finalFileFormat = 4;
            break;
          case "bmp":
            finalFileFormat = 5;
            break;
          case "webp":
            finalFileFormat = 6;
            break;
          default:
        }
        print("${finalFileFormat}");

        String? contentType = getMimeType(compresssedImg.path);
        print("${contentType}");

        itemController
            .addMyItemMediaAsAttachment(itemId!, finalFileFormat, contentType!,
                "false", File(compresssedImg.path))
            .then((result) {
          if (result.isSuccess) {
            // print(itemController.myItemId);
          }
        });

        Navigator.pop(context);

        setState(() {
          _btnEnabled = true;
        });

        // refreshImages();
      }
    } catch (e) {
      return null;
    }
  }

  bool _isVideo(String path) {
    final videoExtensions = ['.mp4', '.mov', '.avi', '.mkv', '.3gp'];
    return videoExtensions.any((ext) => path.toLowerCase().endsWith(ext));
  }

  final Map<String, ImageProvider> _cache = {};
  Future<ImageProvider?> _getThumbnailImage(String mediaUrl) async {
    if (_cache.containsKey(mediaUrl)) {
      return _cache[mediaUrl];
    }

    if (_isVideo(mediaUrl)) {
      // final tempDir = await getTemporaryDirectory();

      final thumbData = await VideoThumbnail.thumbnailData(
        video: mediaUrl,
        // thumbnailPath: tempDir.path,
        imageFormat: ImageFormat.JPEG,
        maxWidth: 150,
        quality: 75,
      );

      if (thumbData != null) {
        final imageProvider = MemoryImage(thumbData);
        _cache[mediaUrl] = imageProvider;
        return imageProvider;
      }
      return null;
    } else {
      return CachedNetworkImageProvider(mediaUrl);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _bodyWidget();
  }

  _bodyWidget() {
    return GetBuilder<ItemController>(
      builder: (controller) {
        return controller.isLoaded
            ? Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: Dimensions.height10),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Column(
                            children: [
                              SizedBox(
                                height: 50,
                                child: GestureDetector(
                                  onTap: () async {
                                    await pickImage(ImageSource.camera);
                                  },
                                  child: Icon(Icons.camera_enhance,
                                      size: 50, color: AppThemeColor),
                                ),
                              ),
                              SizedBox(
                                height: 20,
                                width: 100,
                                child: Text("Take another photo"),
                              )
                            ],
                          ),
                          Column(
                            children: [
                              SizedBox(
                                height: 50,
                                child: GestureDetector(
                                  onTap: () {
                                    pickImage(ImageSource.gallery);
                                  },
                                  child: Icon(Icons.browse_gallery_outlined,
                                      size: 50, color: AppThemeColor),
                                ),
                              ),
                              SizedBox(
                                  height: 20,
                                  width: 100,
                                  child: Text("Upload another photo")),
                            ],
                          ),
                          Column(
                            children: [
                              SizedBox(
                                height: 50,
                                child: GestureDetector(
                                  onTap: () {
                                    pickVideo(ImageSource.camera);
                                  },
                                  child: Icon(Icons.video_file_outlined,
                                      size: 50, color: AppThemeColor),
                                ),
                              ),
                              SizedBox(
                                height: 20,
                                width: 100,
                                child: Text(
                                  "Record a video",
                                  style: TextStyle(
                                      fontSize: Dimensions.font16,
                                      fontWeight: FontWeight.bold,
                                      color: AppThemeColor),
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                      SizedBox(
                        height: Dimensions.height15,
                      ),
                      Container(
                        //color: Colors.red,
                        height: Dimensions.pageViewContainer,
                        child: PageView.builder(
                          controller: pageController,
                          itemCount: controller
                              .myItemAttachmentsListIndexServer.length,
                          itemBuilder: (context, position) {
                            /*  String url = controller
                                .myItemAttachmentsListIndexServer[position]
                                .imgUrl!;

                            return FutureBuilder<String?>(
                              future: generateVideoThumbnail(url),
                              builder: (context, snapshot) {
                                if (snapshot.hasData && snapshot.data != null) {
                                  return _buildPageItem(position, snapshot);
                                }
                                return Container();
                              },
                            );*/

                            return _buildPageItem(
                                position,
                                controller.myItemAttachmentsListIndexServer[
                                    position]);
                          },
                        ),
                      ),
                      SizedBox(
                        height: Dimensions.height15,
                      ),
                      Center(
                        child: new DotsIndicator(
                          dotsCount: max(
                              1,
                              controller
                                  .myItemAttachmentsListIndexServer.length),
                          position: _curPageValue,
                          decorator: DotsDecorator(
                            activeColor: AppColors.primaryColor,
                            size: const Size.square(9.0),
                            activeSize: const Size(18.0, 9.0),
                            activeShape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5.0)),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: Dimensions.height15,
                              ),

                              /// Expansion title for the name and description
                              ExpansionTile(
                                initiallyExpanded: true,
                                title: BigText(
                                  text: "Edit  item details",
                                  color: AppColors.paraColor,
                                ),
                                children: [
                                  SizedBox(
                                    height: Dimensions.height20,
                                  ),
                                  //Item name
                                  TextFormField(
                                    controller: _itemNameController,
                                    keyboardType: TextInputType.text,
                                    decoration: InputDecoration(
                                      labelText: 'Item name',
                                      hintText: 'Enter your item name',
                                      hintStyle: TextStyle(
                                        color: AppColors.greyColor,
                                        fontSize: 12,
                                      ),
                                      contentPadding: const EdgeInsets.all(20),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    onChanged: (value) {
                                      validateItemNameUpdateButton();
                                    },
                                  ),

                                  SizedBox(
                                    height: Dimensions.height20,
                                  ),
                                  //Item description
                                  TextFormField(
                                    controller: _itemDescController,
                                    maxLines: 3,
                                    keyboardType: TextInputType.text,
                                    decoration: InputDecoration(
                                        labelText: 'Item description',
                                        hintText: 'Enter item description',
                                        hintStyle: TextStyle(
                                          color: AppColors.greyColor,
                                          fontSize: 12,
                                        ),
                                        contentPadding:
                                            const EdgeInsets.all(20),
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8))),
                                  ),

                                  SizedBox(
                                    height: Dimensions.height15,
                                  ),

                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      //Value type dropdown
                                      Container(
                                        height: 60,
                                        width: 220,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                              Dimensions.radius30),
                                          boxShadow: [
                                            BoxShadow(
                                              blurRadius: 10,
                                              spreadRadius: 7,
                                              offset: Offset(1, 1),
                                              color:
                                                  Colors.grey.withOpacity(0.2),
                                            )
                                          ],
                                        ),
                                        margin: EdgeInsets.only(
                                            left: Dimensions.height10 / 2,
                                            right: Dimensions.height10 / 2),
                                        child: DropdownButtonFormField<String>(
                                          hint: const Text("Select value"),
                                          decoration: InputDecoration(
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      Dimensions.radius30),
                                              borderSide: BorderSide(
                                                  color: Colors.white),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      Dimensions.radius30),
                                              borderSide: BorderSide(
                                                  color: Colors.white),
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      Dimensions.radius30),
                                            ),
                                          ),
                                          items: _valueType
                                              .map((String dropDownStringItem) {
                                            return DropdownMenuItem<String>(
                                                value: dropDownStringItem,
                                                child:
                                                    Text(dropDownStringItem));
                                          }).toList(),
                                          onChanged:
                                              (String? newValueSelected) {
                                            _valueTypeDropdownSelected(
                                                newValueSelected!);
                                            validateItemNameUpdateButton();
                                          },
                                          value: selectedValueType,
                                        ),
                                      ),

                                      //TextBox Othervalue
                                      Container(
                                        height: 60,
                                        width: 120,
                                        child: TextFormField(
                                          controller: _valueController,
                                          keyboardType:
                                              TextInputType.numberWithOptions(
                                                  decimal: true, signed: false),
                                          decoration: InputDecoration(
                                            labelText: 'Item value',
                                            hintText: 'Enter item value',
                                            hintStyle: TextStyle(
                                              color: AppColors.greyColor,
                                              fontSize: 12,
                                            ),
                                            contentPadding:
                                                const EdgeInsets.all(20),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                          onChanged: (value) {
                                            validateItemNameUpdateButton();
                                          },
                                        ),
                                      )
                                    ],
                                  ),

                                  SizedBox(
                                    height: Dimensions.height20,
                                  ),

                                  Container(
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(
                                          Dimensions.radius30),
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
                                        left: Dimensions.height10 / 2,
                                        right: Dimensions.height10 / 2),
                                    child: DropdownButtonFormField<String>(
                                      hint: const Text("Select status"),
                                      decoration: InputDecoration(
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                              Dimensions.radius30),
                                          borderSide:
                                              BorderSide(color: Colors.white),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                              Dimensions.radius30),
                                          borderSide:
                                              BorderSide(color: Colors.white),
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                              Dimensions.radius30),
                                        ),
                                      ),
                                      items: _statusList
                                          .map((String dropDownStringItem) {
                                        return DropdownMenuItem<String>(
                                            value: dropDownStringItem,
                                            child: Text(dropDownStringItem));
                                      }).toList(),
                                      onChanged: (String? newValueSelected) {
                                        _statusDropdownSelected(
                                            newValueSelected!);
                                        validateItemNameUpdateButton();
                                      },
                                      value: selectedStatus,
                                    ),
                                  ),

                                  SizedBox(
                                    height: Dimensions.height15,
                                  ),

                                  Container(
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(
                                          Dimensions.radius30),
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
                                        left: Dimensions.height10 / 2,
                                        right: Dimensions.height10 / 2),
                                    child: DropdownButtonFormField<String>(
                                      hint: const Text("Select value units"),
                                      decoration: InputDecoration(
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                              Dimensions.radius30),
                                          borderSide:
                                              BorderSide(color: Colors.white),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                              Dimensions.radius30),
                                          borderSide:
                                              BorderSide(color: Colors.white),
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                              Dimensions.radius30),
                                        ),
                                      ),
                                      items: _valueUnitsList
                                          .map((String dropDownStringItem) {
                                        return DropdownMenuItem<String>(
                                            value: dropDownStringItem,
                                            child: Text(dropDownStringItem));
                                      }).toList(),
                                      onChanged: (String? newValueSelected) {
                                        _valueUnitsDropdownSelected(
                                            newValueSelected!);
                                        validateItemNameUpdateButton();
                                      },
                                      value: selectedValueUnits,
                                    ),
                                  ),

                                  SizedBox(
                                    height: Dimensions.height20,
                                  ),

                                  /// Dropdown conditions
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(
                                          Dimensions.radius30),
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
                                        left: Dimensions.height10,
                                        right: Dimensions.height10),
                                    child: DropdownButtonFormField<String>(
                                      hint: const Text("Select condition"),
                                      decoration: InputDecoration(
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                              Dimensions.radius30),
                                          borderSide:
                                              BorderSide(color: Colors.white),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                              Dimensions.radius30),
                                          borderSide:
                                              BorderSide(color: Colors.white),
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                              Dimensions.radius30),
                                        ),
                                      ),
                                      items: _conditionList
                                          .map((String dropDownStringItem) {
                                        return DropdownMenuItem<String>(
                                            value: dropDownStringItem,
                                            child: Text(dropDownStringItem));
                                      }).toList(),
                                      onChanged: (String? newValueSelected) {
                                        _conditionDropdownSelected(
                                            newValueSelected!);
                                        validateItemNameUpdateButton();
                                      },
                                      value: selectedCondtion,
                                    ),
                                  ),

                                  SizedBox(
                                    height: Dimensions.height20,
                                  ),

                                  ///Textbox keywords
                                  TextFormField(
                                    controller: _keyWordsController,
                                    keyboardType: TextInputType.text,
                                    maxLines: 3,
                                    decoration: InputDecoration(
                                      labelText: 'Item keywords',
                                      hintText: 'Enter item keywords',
                                      hintStyle: TextStyle(
                                        color: AppColors.greyColor,
                                        fontSize: 12,
                                      ),
                                      contentPadding: const EdgeInsets.all(20),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    onChanged: (value) {
                                      validateItemNameUpdateButton();
                                    },
                                  ),

                                  SizedBox(
                                    height: Dimensions.height20,
                                  ),

                                  /// Dropdown Additional Options
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(
                                          Dimensions.radius30),
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
                                        left: Dimensions.height10,
                                        right: Dimensions.height10),
                                    child: DropdownButtonFormField<String>(
                                      hint: const Text(
                                          "Select additional options"),
                                      decoration: InputDecoration(
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                              Dimensions.radius30),
                                          borderSide:
                                              BorderSide(color: Colors.white),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                              Dimensions.radius30),
                                          borderSide:
                                              BorderSide(color: Colors.white),
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                              Dimensions.radius30),
                                        ),
                                      ),
                                      items: _additionalOptions
                                          .map((String dropDownStringItem) {
                                        return DropdownMenuItem<String>(
                                            value: dropDownStringItem,
                                            child: Text(dropDownStringItem));
                                      }).toList(),
                                      onChanged: (String? newValueSelected) {
                                        _additionalOptionsDropdownSelected(
                                            newValueSelected!);
                                        validateItemDetailsUpdateButton();
                                      },
                                      value: selectedAdditionalOptions,
                                    ),
                                  ),

                                  SizedBox(
                                    height: Dimensions.height20,
                                  ),

                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 15),
                                    child: roundedButton(
                                      context: context,
                                      bgColor: _btnEnabled
                                          ? AppColors.secondaryColor
                                          : Colors.grey[400],
                                      textColor: _btnEnabled
                                          ? AppColors.whiteColor
                                          : Colors.grey[350],
                                      borderColor: _btnEnabled
                                          ? AppColors.secondaryColor
                                          : Colors.grey[400],
                                      text: 'Update',
                                      onPressed: () async {
                                        alert.showLoaderDialog(context);

                                        itemController
                                            .updateMyItem(
                                          itemId!,
                                          _itemNameController.text.trim(),
                                          _itemDescController.text.trim(),
                                          selectedValueType,
                                          _valueController.text
                                              .replaceAll('\$', ''),
                                          selectedValueUnits,
                                          selectedStatus,
                                          selectedCondtion,
                                          _keyWordsController.text.trim(),
                                        )
                                            .then(
                                          (response) {
                                            print(response);
                                            if (response.isSuccess) {
                                              Navigator.of(context).pushNamed(
                                                  ItemsListScreen.screenId);
                                            }
                                          },
                                        );
                                        Navigator.pop(context);
                                      },
                                    ),
                                  ),

                                  SizedBox(
                                    height: Dimensions.height20,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              )
            : CircularProgressIndicator();
      },
    );
  }

  updateItemDetails_SQLLiteDB(
      String itemCategory,
      String itemYMM,
      String itemKeywords,
      String itemConditions,
      String itemValueType,
      String itemValue,
      String itemStatus,
      int itemCode) {
    itemController.updateItemDetails_SQLLite(
        itemCategory,
        itemYMM,
        itemKeywords,
        itemConditions,
        itemValueType,
        itemValue,
        itemStatus,
        itemCode);
  }

  updateItemNameById(String item_name, String item_desc, int itemId) {
    try {
      itemController.updateItemNameById(item_name, item_desc, itemId);
    } catch (e) {}
  }

  Widget _placeholderBox(Widget child) {
    return Container(
      width: 200,
      height: 120,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(child: child),
    );
  }

  Widget _buildPageItem(int index, MyitemImgsModel attachment) {
    Matrix4 matrix = new Matrix4.identity();
    if (index == _curPageValue.floor()) {
      var curScale = 1 - (_curPageValue - index) * (1 - _scaleFactor);
      var curTrans = _height * (1 - curScale) / 2;
      matrix = Matrix4.diagonal3Values(1, curScale, 1)
        ..setTranslationRaw(0, curTrans, 0);
    } else if (index == _curPageValue.floor() + 1) {
      var curScale =
          _scaleFactor + (_curPageValue - index + 1) * (1 - _scaleFactor);
      var curTrans = _height * (1 - curScale) / 2;
      Matrix4.diagonal3Values(1, curScale, 1);
      matrix = Matrix4.diagonal3Values(1, curScale, 1)
        ..setTranslationRaw(0, curTrans, 0);
    } else {
      var curScale = 0.8;
      matrix = Matrix4.diagonal3Values(1, curScale, 1)
        ..setTranslationRaw(0, _height * (1 - _scaleFactor) / 2, 1);
    }
    return Transform(
      transform: matrix,
      child: Stack(
        children: [
          FutureBuilder<ImageProvider?>(
            future: _getThumbnailImage(attachment.imgUrl!),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                //return const Center(child: CircularProgressIndicator());
                return const SizedBox(
                  width: 200,
                  height: 120,
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (snapshot.hasData && snapshot.data != null) {
                return Container(
                  height: Dimensions.pageViewContainer,
                  margin: EdgeInsets.only(
                      left: Dimensions.height10, right: Dimensions.height10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(Dimensions.radius30),
                    color: index.isEven ? Color(0xff00AABF) : Color(0xFF8f837f),
                    image: DecorationImage(
                        fit: BoxFit.cover, image: snapshot.data!),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 5,
                        spreadRadius: 2,
                        offset: Offset(2, 3),
                      )
                    ],
                  ),
                  alignment: Alignment.center,
                  child: _isVideo(attachment.imgUrl!)
                      ? GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => VideoPlayerScreen(
                                    videoUrl: attachment.imgUrl!),
                              ),
                            );
                          },
                          child: Icon(
                            Icons.play_circle_fill,
                            size: 50,
                            color: Colors.white,
                          ),
                        )
                      : null,
                );
              } else {
                return _placeholderBox(
                    const Icon(Icons.broken_image, size: 40));
              }
            },
          ),
          Container(
            padding: EdgeInsets.only(
                left: Dimensions.width20,
                right: Dimensions.width20,
                top: Dimensions.height20,
                bottom: Dimensions.height20),
            child: GestureDetector(
              onTap: () {
                print('Open media: $mediaUrl');
              },
              child: AppIcon(
                icon: Icons.delete,
                backgroundColor: Colors.red,
                iconSize: Dimensions.iconSize16,
                iconColor: Colors.white,
              ),
            ),
          )
        ],
      ),
    );
  }

  var selectedCategory = "Select category";
  void _categoryDropdownSelected(String newValueSelected) {
    setState(() {
      selectedCategory = newValueSelected;
    });
  }

  var selectedCondtion = "Select condition";
  void _conditionDropdownSelected(String newValueSelected) {
    setState(() {
      selectedCondtion = newValueSelected;
    });
  }

  var selectedValueType = "Select value type";
  void _valueTypeDropdownSelected(String newValueSelected) {
    setState(() {
      selectedValueType = newValueSelected;
    });
  }

  var selectedStatus = "Select status";
  void _statusDropdownSelected(String newValueSelected) {
    setState(() {
      selectedStatus = newValueSelected;
    });
  }

  var selectedValueUnits = "Select value units";
  void _valueUnitsDropdownSelected(String newValueSelected) {
    setState(() {
      selectedValueUnits = newValueSelected;
    });
  }

  var selectedAdditionalOptions = "Select additional option";
  void _additionalOptionsDropdownSelected(String newValueSelected) {
    setState(() {
      selectedAdditionalOptions = newValueSelected;
    });
  }

  Future<void> confirmDialog(int id, String image_path) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Warning!'),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                const Text('Are you sure want delete this image?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Yes'),
              onPressed: () async {
                Navigator.of(context).pop();

                //Delete the item image from local storage
                final targetFile = await Directory(image_path);
                targetFile.deleteSync(recursive: true);

                await itemController.deleteItemImageById_SQLLite(id);
                Get.snackbar('Success', 'Image deleted successfully');

                //  refreshImages();
              },
            ),
            TextButton(
              child: const Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
