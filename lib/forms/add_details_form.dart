import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:pam_app/constants/dimensions.dart';
import 'package:pam_app/services/auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../common/alert.dart';
import '../constants/colours.dart';
import '../constants/widgets.dart';
import '../controllers/item_controller.dart';
import '../screens/addItem/additional_options.dart';
import '../screens/home_screen.dart';

class AddDetailsForm extends StatefulWidget {
  const AddDetailsForm({super.key});

  @override
  State<AddDetailsForm> createState() => _AddDetailsFormState();
}

class _AddDetailsFormState extends State<AddDetailsForm> {
  late SharedPreferences sharedPreferences;
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _categoryController;
  late final FocusNode _categoryNode;
  late final TextEditingController _yearmakemodelController;
  late final FocusNode _yearmakemodelNode;
  late final TextEditingController _keyWordsController;
  late final FocusNode _keyWordsNode;
  late final TextEditingController _conditionController;
  late final FocusNode _conditionNode;
  late TextEditingController _valueTypeController;
  late FocusNode _valueTypeNode;
  late TextEditingController _valueController;
  late FocusNode _valueNode;
  late TextEditingController _statusController;
  late FocusNode _statusNode;
  late String locationValue;
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

  final List<String> _statusList = [
    'Select status',
    'Not for sale',
    'Available',
    'Sold'
  ];

  var itemController = Get.find<ItemController>();
  Dialogs alert = Dialogs();

  bool _isConnected = false;

  bool _btnEnabled = false;
  late final InternetConnectionCheckerPlus _connectionChecker;

  Auth authService = Auth();
  final storage = const FlutterSecureStorage();

  @override
  void initState() {
    _yearmakemodelController = TextEditingController();
    _yearmakemodelNode = FocusNode();

    _keyWordsController = TextEditingController();
    _keyWordsNode = FocusNode();

    _conditionController = TextEditingController();
    _conditionNode = FocusNode();

    _valueTypeController = TextEditingController();
    _valueTypeNode = FocusNode();

    _valueController = TextEditingController();
    _valueNode = FocusNode();

    _statusController = TextEditingController();
    _statusNode = FocusNode();

    // TODO: implement initState
    super.initState();
    _connectionChecker = InternetConnectionCheckerPlus();
    _checkConnection();
    _startMonitoring();
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

  void validateButton() {
    bool isValid = true;

    isValid = _yearmakemodelController.text.length > 3 ||
        _keyWordsController.text.length > 3 ||
        _valueController.text.length > 3;

    setState(() {
      _btnEnabled = isValid;
    });
  }

  @override
  void dispose() {
    _yearmakemodelController.dispose();
    _yearmakemodelNode.dispose();

    _keyWordsController.dispose();
    _keyWordsNode.dispose();

    _conditionController.dispose();
    _conditionNode.dispose();

    _valueTypeController.dispose();
    _valueTypeNode.dispose();

    _valueController.dispose();
    _valueNode.dispose();

    _statusController.dispose();
    _statusNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return bodyWidget();
  }

  updateItemDetails_SQLLiteDB(
      String itemYMM,
      String itemKeywords,
      String itemConditions,
      String itemValueType,
      String itemValue,
      String itemStatus) async {
    itemController.updateItemDetails_SQLLite("", itemYMM, itemKeywords,
        itemConditions, itemValueType, itemValue, itemStatus, 0);
  }

  bodyWidget() {
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    print('<=====> ${args['itemName']} \n ${args['itemDesc']}');

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //Value type dropdown
                    Container(
                      height: 60,
                      width: 220,
                      decoration: BoxDecoration(
                        color: Colors.white,
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
                          left: Dimensions.height10 / 2,
                          right: Dimensions.height10 / 2),
                      child: DropdownButtonFormField<String>(
                        hint: const Text("Select value"),
                        decoration: InputDecoration(
                          focusedBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(Dimensions.radius30),
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(Dimensions.radius30),
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(Dimensions.radius30),
                          ),
                        ),
                        items: _valueType.map((String dropDownStringItem) {
                          return DropdownMenuItem<String>(
                              value: dropDownStringItem,
                              child: Text(dropDownStringItem));
                        }).toList(),
                        onChanged: (String? newValueSelected) {
                          _valueTypeDropdownSelected(newValueSelected!);
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
                        keyboardType: TextInputType.numberWithOptions(
                            decimal: true, signed: false),
                        decoration: InputDecoration(
                          labelText: 'Item value',
                          hintText: 'Enter item value',
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
                    borderRadius: BorderRadius.circular(Dimensions.radius30),
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
                        borderRadius:
                            BorderRadius.circular(Dimensions.radius30),
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(Dimensions.radius30),
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(Dimensions.radius30),
                      ),
                    ),
                    items: _statusList.map((String dropDownStringItem) {
                      return DropdownMenuItem<String>(
                          value: dropDownStringItem,
                          child: Text(dropDownStringItem));
                    }).toList(),
                    onChanged: (String? newValueSelected) {
                      _statusDropdownSelected(newValueSelected!);
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
                    borderRadius: BorderRadius.circular(Dimensions.radius30),
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
                        borderRadius:
                            BorderRadius.circular(Dimensions.radius30),
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(Dimensions.radius30),
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(Dimensions.radius30),
                      ),
                    ),
                    items: _valueUnitsList.map((String dropDownStringItem) {
                      return DropdownMenuItem<String>(
                          value: dropDownStringItem,
                          child: Text(dropDownStringItem));
                    }).toList(),
                    onChanged: (String? newValueSelected) {
                      _valueUnitsDropdownSelected(newValueSelected!);
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
                    borderRadius: BorderRadius.circular(Dimensions.radius30),
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
                      left: Dimensions.height10, right: Dimensions.height10),
                  child: DropdownButtonFormField<String>(
                    hint: const Text("Select condition"),
                    decoration: InputDecoration(
                      focusedBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(Dimensions.radius30),
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(Dimensions.radius30),
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(Dimensions.radius30),
                      ),
                    ),
                    items: _conditionList.map((String dropDownStringItem) {
                      return DropdownMenuItem<String>(
                          value: dropDownStringItem,
                          child: Text(dropDownStringItem));
                    }).toList(),
                    onChanged: (String? newValueSelected) {
                      _conditionDropdownSelected(newValueSelected!);
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
              ],
            ),
          ),
        ),
        SizedBox(height: Dimensions.height15),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: roundedButton(
              context: context,
              bgColor:
                  _btnEnabled ? AppColors.secondaryColor : Colors.grey[400],
              textColor: _btnEnabled ? AppColors.whiteColor : Colors.grey[350],
              borderColor:
                  _btnEnabled ? AppColors.secondaryColor : Colors.grey[400],
              text: 'Save and add more details',
              onPressed: _btnEnabled
                  ? () async {
                      alert.showLoaderDialog(context);
                      /*  await updateItemDetails_SQLLiteDB(
                          _yearmakemodelController.text,
                          _keyWordsController.text,
                          _conditionController.text,
                          _valueTypeController.text,
                          _valueController.text,
                          _statusController.text);*/

                      itemController
                          .updateMyItem(
                              itemController.myItemId,
                              args['itemName'],
                              args['itemDesc'],
                              selectedValueType,
                              _valueController.text,
                              selectedValueUnits,
                              selectedStatus,
                              selectedCondtion,
                              _keyWordsController.text.trim())
                          .then((result) {
                        if (result.isSuccess) {
                          Navigator.pop(context);

                          Navigator.of(context).pushNamed(
                              AddionalOptionsScreen.screenId,
                              arguments: {
                                'itemName': args['itemName'],
                                'itemDesc': args['itemDesc'],
                                'valueType': selectedValueType,
                                'valueAmt': _valueController.text,
                                'valueUnits': selectedValueUnits,
                                'status': selectedStatus,
                                'condition': selectedCondtion,
                                'keywords': _keyWordsController.text.trim()
                              });
                        }
                      });
                    }
                  : null),
        ),
        const SizedBox(
          height: 10,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: roundedButton(
              context: context,
              bgColor: AppColors.secondaryColor,
              text: 'Save and return to home',
              textColor: AppColors.whiteColor,
              onPressed: () async {
                Navigator.of(context).pushNamed(HomeScreen.screenId);
              }),
        )
      ],
    );
  }

  void validateItemNameUpdateButton() {
    bool isValid = true;

    isValid = selectedCondtion.isNotEmpty ||
        selectedValueType.isNotEmpty ||
        _valueController.text.length > 3 ||
        selectedStatus.isNotEmpty;

    setState(() {
      _btnEnabled = isValid;
    });
  }

  void validateItemDetailsUpdateButton() {
    bool isValid = true;

    isValid = _keyWordsController.text.length > 3 ||
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
}
