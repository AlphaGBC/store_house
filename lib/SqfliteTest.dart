import 'package:flutter/material.dart';
import 'package:store_house/sqflite.dart';

class Sqflitetest extends StatefulWidget {
  const Sqflitetest({super.key});

  @override
  State<Sqflitetest> createState() => _SqflitetestState();
}

class _SqflitetestState extends State<Sqflitetest> {
  SqlDb sqlDb = SqlDb();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("SqfliteTest")),
      body: Column(
        children: [
          Center(
            child: MaterialButton(
              color: Colors.blue,
              textColor: Colors.white,
              onPressed: () async {
                int response = await sqlDb.insert("notes", {
                  "note": "",
                  "title": "",
                });
                print(response);
              },
              child: const Text("Insert Data"),
            ),
          ),
          Center(
            child: MaterialButton(
              color: Colors.blue,
              textColor: Colors.white,
              onPressed: () async {
                List<Map> response = await sqlDb.read("itemsview");
                print("$response");
              },
              child: const Text("Read Data"),
            ),
          ),
          Center(
            child: MaterialButton(
              color: Colors.blue,
              textColor: Colors.white,
              onPressed: () async {
                int response = await sqlDb.delete("notes", "id = num");
                print("$response");
              },
              child: const Text("Delete Data"),
            ),
          ),
          Center(
            child: MaterialButton(
              color: Colors.blue,
              textColor: Colors.white,
              onPressed: () async {
                int response = await sqlDb.update("notes", {
                  "note": "",
                  "title": "",
                }, "id = num");
                print("$response");
              },
              child: const Text("Update Data"),
            ),
          ),
        ],
      ),
    );
  }
}
