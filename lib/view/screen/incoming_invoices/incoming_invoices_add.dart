import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:store_house/controller/incoming_invoices/add_controller.dart';
import 'package:store_house/core/class/handlingdataview.dart';
;

class IncomingInvoicesAdd extends StatefulWidget {
  const IncomingInvoicesAdd({super.key});

  @override
  State<IncomingInvoicesAdd> createState() => _IncomingInvoicesAddState();
}

class _IncomingInvoicesAddState extends State<IncomingInvoicesAdd> {
  @override
  Widget build(BuildContext context) {
    final IncomingInvoicesAddController controller = Get.put(
      IncomingInvoicesAddController(),
    );
    return Scaffold(
      appBar: AppBar(title: const Text("اضافة فاتورة جديدة"), centerTitle: true),
    
      body: GetBuilder<IncomingInvoicesAddController>(
        builder:
            (controller) => HandlingDataView(
              statusRequest: controller.statusRequest,
              widget: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                   
                  ],
                )
              ),
            ),
      ),
    );
  }
}
