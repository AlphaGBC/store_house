import 'package:get/get.dart';

class HomeControllerImp extends GetxController {
  int selectedPageNum = 0;

  void setSelectedPage(int num) {
    selectedPageNum = num;
  }

  int get selected => selectedPageNum;
}
