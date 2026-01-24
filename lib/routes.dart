import 'package:get/get.dart';
import 'package:store_house/SqfliteTest.dart';
import 'package:store_house/core/middleware/mymiddleware.dart';
import 'package:store_house/core/shared/categories_view_shared.dart';
import 'package:store_house/view/screen/auth/login.dart';
import 'package:store_house/view/screen/categories/add.dart';
import 'package:store_house/view/screen/categories/edit.dart';
import 'package:store_house/view/screen/categories/view.dart';
import 'package:store_house/view/screen/home.dart';
import 'package:store_house/view/screen/invoices/incoming_invoices.dart';
import 'package:store_house/view/screen/invoices/incoming_invoices_add.dart';
import 'package:store_house/view/screen/issued_invoices/issued_invoices.dart';
import 'package:store_house/view/screen/issued_invoices/issued_invoices_add.dart';
import 'package:store_house/view/screen/issued_invoices/issued_invoices_view.dart';
import 'package:store_house/view/screen/items/add.dart';
import 'package:store_house/view/screen/items/edit.dart';
import 'package:store_house/view/screen/items/view.dart';
import 'package:store_house/view/screen/order_page.dart';
import 'package:store_house/view/screen/scan_product_qr.dart';
import 'package:store_house/view/screen/usd/usd_edit.dart';
import 'package:store_house/view/screen/usd/usd_view.dart';
import 'package:store_house/view/screen/wholesale/wholesale_add.dart';
import 'package:store_house/view/screen/wholesale/wholesale_view.dart';

class AppRoute {
  static const String login = "/login";
  // Home
  static const String homepage = "/homepage";
  static const String categoriesView = "/categoriesview";
  static const String categoriesEdit = "/categoriesEdit";
  static const String categoriesAdd = "/categoriesAdd";
  static const String itemsView = "/itemsView";
  static const String categoriesViewShared = "/categoriesViewShared";
  static const String itemsedit = "/itemsedit";
  static const String itemsAdd = "/itemsAdd";
  static const String scanProductQrPage = "/scanProductQrPage";
  static const String usdView = "/usdView";
  static const String usdEdit = "/usdEdit";
  static const String wholesaleView = "/wholesaleView";
  static const String wholesaleAdd = "/wholesaleAdd";

  static const String orderCardsPage = "/orderCardsPage";
  static const String incomingInvoices = "/incomingInvoices";
  static const String incomingInvoicesAdd = "/incomingInvoicesAdd";
  static const String sqflitetest = "/sqflitetest";

  static const String issuedInvoices = "/issuedInvoices";
  static const String issuedInvoicesAdd = "/issuedInvoicesAdd";
  static const String issuedInvoicesView = "/issuedInvoicesView";
}

List<GetPage<dynamic>>? routes = [
  GetPage(name: "/", page: () => const Login(), middlewares: [MyMiddleWare()]),

  //  Auth
  GetPage(name: AppRoute.login, page: () => const Login()),
  GetPage(name: AppRoute.homepage, page: () => const HomePage()),
  GetPage(name: AppRoute.categoriesView, page: () => const CategoriesView()),
  GetPage(name: AppRoute.categoriesEdit, page: () => const CategoriesEdit()),
  GetPage(name: AppRoute.categoriesAdd, page: () => const CategoriesAdd()),
  GetPage(name: AppRoute.itemsView, page: () => const ItemsView()),
  GetPage(name: AppRoute.itemsedit, page: () => const ItemsEdit()),
  GetPage(name: AppRoute.itemsAdd, page: () => const ItemsAdd()),
  GetPage(
    name: AppRoute.scanProductQrPage,
    page: () => const ScanProductQrPage(),
  ),
  GetPage(
    name: AppRoute.categoriesViewShared,
    page: () => const CategoriesViewShared(),
  ),
  GetPage(name: AppRoute.usdView, page: () => const UsdView()),
  GetPage(name: AppRoute.usdEdit, page: () => const UsdEdit()),
  GetPage(name: AppRoute.wholesaleView, page: () => const WholesaleView()),
  GetPage(name: AppRoute.wholesaleAdd, page: () => const WholesaleAdd()),

  GetPage(name: AppRoute.orderCardsPage, page: () => const OrderCardsPage()),
  GetPage(
    name: AppRoute.incomingInvoices,
    page: () => const IncomingInvoices(),
  ),
  GetPage(
    name: AppRoute.incomingInvoicesAdd,
    page: () => const IncomingInvoicesAdd(),
  ),

  GetPage(name: AppRoute.sqflitetest, page: () => const Sqflitetest()),

  GetPage(name: AppRoute.issuedInvoices, page: () => const IssuedInvoices()),
  GetPage(
    name: AppRoute.issuedInvoicesAdd,
    page: () => const IssuedInvoicesAdd(),
  ),
  GetPage(
    name: AppRoute.issuedInvoicesView,
    page: () => const IssuedInvoicesView(),
  ),
];
