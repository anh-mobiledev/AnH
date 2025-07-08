import 'package:get/get.dart';

import '../data/repository/use_case_repo.dart';

class UseCaseController extends GetxController {
  final UseCaseRepo useCaseRepo;

  UseCaseController({required this.useCaseRepo});

  Future<String> getUserId() {
    return useCaseRepo.getUserId();
  }

  Future<void> insertUseCaseSQLLite(String name, String desc) async {
    try {
      await useCaseRepo.SaveUseCaseSQLLiteDB(name, desc);
    } catch (e) {
      throw e;
    }
  }
}
