class AppLink {
  static const String server = "https://sahlhastore.com/maher_store_php";
  static const String imageststatic =
      "https://sahlhastore.com/maher_store_php/Upload";
  //========================== Image ============================
  static const String imagestCategories = "$imageststatic/categories";
  static const String imagestItems = "$imageststatic/items";

  // ================================= Auth ========================== //

  static const String login = "$server/auth/login.php";

  // Categories

  static const String categoriesview = "$server/categories/view.php";
  static const String categoriesupgrade = "$server/categories/upgrade.php";
  static const String categoriesaddupgrade =
      "$server/categories/addupgrade.php";
  static const String categoriesdelete = "$server/categories/delete.php";
  static const String categoriesedit = "$server/categories/edit.php";

  static const String categoriesadd = "$server/categories/add.php";

  // items

  static const String itemsview = "$server/items/view.php";
  static const String itemsadd = "$server/items/add.php";
  static const String itemsedit = "$server/items/edit.php";
  static const String itemsdelete = "$server/items/delete.php";
  static const String itemsupgrade = "$server/items/upgrade.php";
  // static const String itemsddupgrade = "$server/items/addupgrade.php";

  static const String usdview = "$server/usd/view.php";
  static const String usdedit = "$server/usd/edit.php";

  static const String wholesaleview = "$server/wholesale/view.php";
  static const String wholesaleadd = "$server/wholesale/add.php";
  static const String wholesaledelete = "$server/wholesale/delete.php";

  static const String supplierview = "$server/supplier/view.php";
  static const String supplieradd = "$server/supplier/add.php";
  static const String supplierdelete = "$server/supplier/delete.php";

  static const String vieworder = "$server/order/view.php";

  static const String incomingInvoicesAdd = "$server/incomingInvoices/add.php";
  static const String incomingInvoicesEdit =
      "$server/incomingInvoices/edit.php";

  static const String incomingInvoicesview =
      "$server/incomingInvoices/view.php";

  static const String issuedinvoicesAdd = "$server/issuedinvoices/add.php";
  static const String issuedinvoicesview = "$server/issuedinvoices/view.php";
}
