import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:pam_app/controllers/item_controller.dart';
import 'package:pam_app/services/auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/colours.dart';
import '../constants/validators.dart';
import '../constants/widgets.dart';
import '../screens/home_screen.dart';

class AddionalOptionsForm extends StatefulWidget {
  const AddionalOptionsForm({super.key});

  @override
  State<AddionalOptionsForm> createState() => _AddionalOptionsFormState();
}

class _AddionalOptionsFormState extends State<AddionalOptionsForm> {
  late SharedPreferences sharedPreferences;
  final List<String> _fuelType = [
    'Make it an estate item',
    'I want to share it',
    'I want to sell it',
    'I want to rent it',
    'I want it appraised',
    'I want to donate it'
  ];
  late TextEditingController _txtAdditionOptionsController;
  late FocusNode _txtAdditionOptionsControllerNode;

  final _formKey = GlobalKey<FormState>();
  var itemController = Get.find<ItemController>();
  Auth authService = Auth();
  final storage = const FlutterSecureStorage();

  @override
  void initState() {
    _txtAdditionOptionsController = TextEditingController();
    _txtAdditionOptionsControllerNode = FocusNode();
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    _txtAdditionOptionsController.dispose();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return sellCarFormWidget();
  }

  /*storeEntry(String options) async {
    sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setBool("skipbtn", false);
    var collection = FirebaseFirestore.instance.collection('item_media');
    collection
        .doc(sharedPreferences.getString(
            'documentID')) // <-- Doc ID where data should be updated.
        .update({'additional_options': options}).then((value) {
      Navigator.pushNamed(context, HomeScreen.screenId);
      Get.snackbar('Success', 'Data is stored successfully');
    });
  }*/

  _additionalOptionsListView(BuildContext context) {
    return openBottomSheet(
      context: context,
      appBarTitle: 'Select Options',
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: _fuelType.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            onTap: () {
              setState(() {
                _txtAdditionOptionsController.text = _fuelType[index];
              });
              Navigator.pop(context);
            },
            title: Text(_fuelType[index]),
          );
        },
      ),
    );
  }

  sellCarFormWidget() {
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 20,
            ),
            InkWell(
              onTap: () {
                _additionalOptionsListView(context);
              },
              child: TextFormField(
                controller: _txtAdditionOptionsController,
                focusNode: _txtAdditionOptionsControllerNode,
                enabled: false,
                validator: (value) {
                  return checkNullEmptyValidation(value, 'text');
                },
                decoration: InputDecoration(
                  suffixIcon: Icon(
                    Icons.arrow_drop_down_sharp,
                    size: 30,
                    color: AppColors.blackColor,
                  ),
                  labelText: 'Additional options',
                  errorStyle: const TextStyle(color: Colors.red, fontSize: 10),
                  labelStyle: TextStyle(
                    color: AppColors.greyColor,
                    fontSize: 14,
                  ),
                  contentPadding: const EdgeInsets.all(15),
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: roundedButton(
                context: context,
                bgColor: AppColors.secondaryColor,
                text: 'Finished',
                textColor: AppColors.whiteColor,
                onPressed: () async {
                  itemController
                      .updateMyItem(
                          itemController.myItemId,
                          args['itemName'],
                          args['itemDesc'],
                          args['valueType'],
                          args['valueAmt'],
                          args['valueUnits'],
                          args['status'],
                          args['condition'],
                          args['keywords'])
                      .then((result) {
                    if (result.isSuccess) {
                      Navigator.pushNamed(context, HomeScreen.screenId);
                    }
                  });
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
