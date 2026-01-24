import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SqlDb {
  static Database? _db;

  Future<Database?> get db async {
    if (_db == null) {
      _db = await intialDb();

      return _db;
    } else {
      return _db;
    }
  }

  intialDb() async {
    String databasepath = await getDatabasesPath();

    String path = join(databasepath, 'MaherStore.db');

    Database mydb = await openDatabase(
      path,
      onCreate: _onCreate,
      version: 1,
      onUpgrade: _onUpgrade,
    );

    return mydb;
  }

  _onUpgrade(Database db, int oldversion, int newversion) async {
    if (kDebugMode) {
      print("onUpgrade =====================================");
    }
  }

  _onCreate(Database db, int version) async {
    Batch batch = db.batch();

    batch.execute('''
CREATE TABLE categories (
  categories_id INTEGER PRIMARY KEY,
  categories_name TEXT NOT NULL,
  categories_image TEXT NOT NULL,
  categories_date TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
)
''');

    batch.execute('''
CREATE TABLE itemsview (
    items_id INTEGER PRIMARY KEY AUTOINCREMENT,
    items_name TEXT NOT NULL,
    items_storehouse_count INTEGER NOT NULL,
    items_pointofsale1_count INTEGER NOT NULL,
    items_pointofsale2_count INTEGER NOT NULL,
    items_cost_price NUMERIC,
    items_wholesale_price NUMERIC,
    items_retail_price NUMERIC,
    items_wholesale_discount NUMERIC,
    items_retail_discount NUMERIC,
    items_qr TEXT NOT NULL,
    items_categories INTEGER NOT NULL,
    items_date TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    categories_id INTEGER NOT NULL,
    categories_name TEXT NOT NULL,
    categories_image TEXT NOT NULL,
    categories_date TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    itemswholesalepricediscount NUMERIC,
    itemsretailpricediscount NUMERIC
);

''');

    batch.execute('''
CREATE TABLE usd (
  usd_id INTEGER PRIMARY KEY,
  usd_price TEXT NOT NULL,
  usd_data TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
)
''');

    batch.execute('''
CREATE TABLE wholesale_customers (
  wholesale_customers_id INTEGER PRIMARY KEY,
  wholesale_customers_name TEXT NOT NULL,
  wholesale_customers_date TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
)
''');

    // Orders table: stores high level order info and raw JSON
    batch.execute('''
CREATE TABLE orders (
  orders_id INTEGER PRIMARY KEY,
  wholesale_customers_id INTEGER,
  wholesale_customers_name TEXT,
  total_items_count INTEGER NOT NULL DEFAULT 0,
  subtotal NUMERIC NOT NULL DEFAULT 0,
  discount_amount NUMERIC NOT NULL DEFAULT 0,
  total NUMERIC NOT NULL DEFAULT 0,
  is_wholesale INTEGER NOT NULL DEFAULT 0,
  status TEXT NOT NULL DEFAULT 'local',
  pos_source INTEGER NOT NULL DEFAULT 1,
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  raw_json TEXT
)
''');

    // Order items table: stores each item belonging to an order
    batch.execute('''
CREATE TABLE order_items (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  orders_id INTEGER NOT NULL,
  ordersdetails_id INTEGER,
  items_id INTEGER,
  items_name TEXT,
  items_image TEXT,
  items_quantity INTEGER DEFAULT 0,
  items_unit_price NUMERIC DEFAULT 0,
  items_discount_percentage NUMERIC DEFAULT 0,
  items_price_before_discount NUMERIC DEFAULT 0,
  items_price_after_discount NUMERIC DEFAULT 0,
  items_total_price NUMERIC DEFAULT 0,
  is_wholesale INTEGER DEFAULT 0
)
''');

    batch.execute('''
CREATE TABLE incoming_invoices (
  invoice_id INTEGER PRIMARY KEY AUTOINCREMENT,
  supplier_name TEXT NOT NULL,
  invoice_date TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  status TEXT NOT NULL DEFAULT 'open'
)
''');

    batch.execute('''
CREATE TABLE incoming_invoice_items (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  invoice_id INTEGER NOT NULL,
  items_id INTEGER NOT NULL,
  items_name TEXT NOT NULL,
  storehouse_count INTEGER,
  pos1_count INTEGER,
  pos2_count INTEGER,
  cost_price NUMERIC,
  wholesale_price NUMERIC,
  retail_price NUMERIC,
  wholesale_discount NUMERIC,
  retail_discount NUMERIC
)
''');

    batch.execute('''
CREATE TABLE issued_invoices (
  issued_invoices_id INTEGER PRIMARY KEY AUTOINCREMENT,
  supplier_name TEXT NOT NULL,
  issued_invoices_date TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  status TEXT NOT NULL DEFAULT 'open'
)
''');

    batch.execute('''
CREATE TABLE issued_invoices_items (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  issued_invoices_id INTEGER NOT NULL,
  items_id INTEGER NOT NULL,
  items_name TEXT NOT NULL,
  storehouse_count INTEGER,
  pos1_count INTEGER,
  pos2_count INTEGER,
  cost_price NUMERIC,
  wholesale_price NUMERIC,
  retail_price NUMERIC,
  wholesale_discount NUMERIC,
  retail_discount NUMERIC
)
''');

    await batch.commit();

    if (kDebugMode) {
      print(" onCreate =====================================");
    }
  }

  read(String table) async {
    Database? mydb = await db;

    List<Map> response = await mydb!.query(table);

    return response;
  }

  insert(String table, Map<String, Object?> values) async {
    Database? mydb = await db;

    int response = await mydb!.insert(table, values);

    return response;
  }

  update(String table, Map<String, Object?> values, String? mywhere) async {
    Database? mydb = await db;

    int response = await mydb!.update(table, values, where: mywhere);

    return response;
  }

  delete(String table, String? mywhere) async {
    Database? mydb = await db;

    int response = await mydb!.delete(table, where: mywhere);

    return response;
  }

  mydeleteDatabase() async {
    String databasepath = await getDatabasesPath();
    String path = join(databasepath, 'MaherStore.db');
    await deleteDatabase(path);
  }
}
