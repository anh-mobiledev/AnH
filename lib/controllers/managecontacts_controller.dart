import 'package:get/get.dart';
import 'package:pam_app/models/contact_create_body.dart';
import 'package:pam_app/models/contact_update_body.dart';

import '../data/repository/manage_contact_repo.dart';
import '../models/response_model.dart';

class ManageContactController extends GetxController {
  final ManageContactsRepo contactsRepo;
  ManageContactController({required this.contactsRepo});

  late String _itemId;
  String get finId => _itemId;

//Create Contact
  Future<ResponseModel> contactCreate(
      ContactCreateBody ContactCreateBody) async {
    Response response = await contactsRepo.contactCreate(ContactCreateBody);
    print('status code ${response.statusCode}');
    print('status text ${response.statusText}');
    late ResponseModel responseModel;
    if (response.statusCode == 200) {
      _itemId = response.body["id"];
      print(_itemId);
      // contactsRepo.saveUserToken(response.body["auth_token"]);
      responseModel = ResponseModel(true, response.body["auth_token"], "");
    } else {
      responseModel = ResponseModel(false, response.statusText!, "");
    }

    update();
    return responseModel;
  }

  //Update Contact
  Future<ResponseModel> contactUpdate(
      ContactUpdateBody contactUpdateBody) async {
    Response response = await contactsRepo.contactUpdate(contactUpdateBody);
    late ResponseModel responseModel;
    if (response.statusCode == 200) {
      // contactsRepo.saveUserToken(response.body["auth_token"]);
      responseModel = ResponseModel(true, response.body["auth_token"], "");
    } else {
      responseModel = ResponseModel(false, response.statusText!, "");
    }

    update();
    return responseModel;
  }
}
