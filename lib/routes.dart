import 'package:get/get.dart';
import 'package:store_house/core/middleware/mymiddleware.dart';
import 'package:store_house/core/shared/categories_view_shared.dart';
import 'package:store_house/view/screen/auth/login.dart';
import 'package:store_house/view/screen/categories/add.dart';
import 'package:store_house/view/screen/categories/edit.dart';
import 'package:store_house/view/screen/categories/view.dart';
import 'package:store_house/view/screen/home.dart';
import 'package:store_house/view/screen/incoming_invoices/incoming_invoices.dart';
import 'package:store_house/view/screen/incoming_invoices/incoming_invoices_add.dart';
import 'package:store_house/view/screen/incoming_invoices/incoming_invoices_details.dart';
import 'package:store_house/view/screen/incoming_invoices/incoming_invoices_edit.dart';
import 'package:store_house/view/screen/transfer/transfer_view.dart';
import 'package:store_house/view/screen/transfer/transfer_add.dart';
import 'package:store_house/view/screen/transfer/transfer_details.dart';
import 'package:store_house/view/screen/items/add.dart';
import 'package:store_house/view/screen/items/edit.dart';
import 'package:store_house/view/screen/items/item_movement.dart';
import 'package:store_house/view/screen/items/view.dart';
import 'package:store_house/view/screen/order_page.dart';
import 'package:store_house/view/screen/scan_product_qr.dart';
import 'package:store_house/view/screen/supplier/supplier_add.dart';
import 'package:store_house/view/screen/supplier/supplier_view.dart';
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

  static const String supplierView = "/supplierView";
  static const String supplierAdd = "/supplierAdd";

  static const String orderCardsPage = "/orderCardsPage";
  static const String incomingInvoices = "/incomingInvoices";
  static const String incomingInvoicesAdd = "/incomingInvoicesAdd";
  static const String incomingInvoicesDetails = "/incomingInvoicesDetails";
  static const String incomingInvoicesEdit = "/incomingInvoicesEdit";
  static const String transferView = "/transferView";
  static const String transferAdd = "/transferAdd";
  static const String transferDetails = "/transferDetails";

  static const String itemMovement = "/itemMovement";
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

  GetPage(name: AppRoute.supplierView, page: () => const SupplierView()),
  GetPage(name: AppRoute.supplierAdd, page: () => const SupplierAdd()),

  GetPage(name: AppRoute.orderCardsPage, page: () => const OrderCardsPage()),
  GetPage(
    name: AppRoute.incomingInvoices,
    page: () => const IncomingInvoices(),
  ),
  GetPage(
    name: AppRoute.incomingInvoicesAdd,
    page: () => const IncomingInvoicesAdd(),
  ),
  GetPage(
    name: AppRoute.incomingInvoicesDetails,
    page: () => const IncomingInvoicesDetails(),
  ),

  GetPage(
    name: AppRoute.incomingInvoicesEdit,
    page: () => const IncomingInvoicesEdit(),
  ),
  GetPage(name: AppRoute.transferView, page: () => const TransferView()),
  GetPage(name: AppRoute.transferAdd, page: () => const TransferAdd()),
  GetPage(name: AppRoute.transferDetails, page: () => const TransferDetails()),

  GetPage(name: AppRoute.itemMovement, page: () => const ItemMovementView()),
];
