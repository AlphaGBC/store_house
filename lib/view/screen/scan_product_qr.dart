import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:store_house/data/model/itemsmodel.dart';
import 'package:store_house/sqflite.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:store_house/controller/items/view_controller.dart';

class ScanProductQrPage extends StatefulWidget {
  const ScanProductQrPage({super.key});

  @override
  State<ScanProductQrPage> createState() => _ScanProductQrPageState();
}

class _ScanProductQrPageState extends State<ScanProductQrPage> {
  final MobileScannerController cameraController = MobileScannerController();
  final SqlDb sqlDb = SqlDb();

  late ItemsControllerImp itemsController;

  bool isProcessing = false;

  @override
  void initState() {
    super.initState();
    itemsController = Get.find<ItemsControllerImp>();
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  // تحويل Map<dynamic,dynamic> -> Map<String,dynamic>
  Map<String, dynamic> _toStringKeyMap(Map raw) {
    final Map<String, dynamic> out = {};
    raw.forEach((k, v) {
      out[k.toString()] = v;
    });
    return out;
  }

  // محاولة تحويل الـ Map إلى ItemsModel إن كانت الدالة متوفرة في موديلك
  ItemsModel? _tryConvertToModel(Map<String, dynamic> row) {
    try {
      return ItemsModel.fromJson(row);
    } catch (_) {
      return null;
    }
  }

  // التعامل عند إيجاد صف مطابق: إيقاف الكاميرا ثم التنقل
  Future<void> _handleFoundAndNavigate(Map<String, dynamic> row) async {
    setState(() => isProcessing = true);

    final int? catId =
        itemsController.catid != null
            ? int.tryParse(itemsController.catid!)
            : null;

    // أوقف الكاميرا فورًا لتفادي كشف مكرر أو تداخل
    try {
      await cameraController.stop();
    } catch (_) {
      // تجاهل أي خطأ في الإيقاف
    }

    // مهلة صغيرة للسماح بإنهاء عملية الكاميرا (يحسن الاستقرار على بعض الأجهزة)
    await Future.delayed(const Duration(milliseconds: 150));

    // حاول تحويل للخوارزمي إلى موديل
    final ItemsModel? model = _tryConvertToModel(row);

    try {
      if (model != null) {
        // استخدم دالة المتحكم (هي تستعمل Get.toNamed داخليًا كما عندك)
        itemsController.goToPageEdit(model, catId);
        // لا ننادي Get.back() هنا — نترك التنقل الذي تقوم به الدالة
      } else {
        // fallback: لو لم نتمكن من إنشاء موديل مرّر الخريطة مباشرة عبر راوت اسم (عدل الاسم إن لزم)
        // استبدل '/itemsedit' باسم الراوت الفعلي إن لم يكن هو نفسه
        await Get.offNamed(
          '/itemsedit',
          arguments: {"ItemsModel": row, "catid": catId},
        );
      }
    } catch (e) {
      // خطأ أثناء التنقل — أعِد تشغيل الكاميرا وأخبر المستخدم
      if (kDebugMode) {
        print('Navigation error: $e');
      }
      await Get.defaultDialog(
        title: "خطأ",
        middleText: "حدث خطأ أثناء الانتقال إلى صفحة التعديل:\n$e",
        confirm: ElevatedButton(
          onPressed: () => Get.back(),
          child: const Text("حسناً"),
        ),
      );
      // حاول إعادة تشغيل الكاميرا للسماح بالمحاولة مرة أخرى
      try {
        await cameraController.start();
      } catch (_) {}
      setState(() => isProcessing = false);
    }
  }

  // الدالة الرئيسية التي تُستدعى عند اكتشاف رمز QR
  void _onDetect(BarcodeCapture capture) async {
    if (isProcessing) return;

    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final String? raw = barcodes.first.rawValue;
    if (raw == null || raw.trim().isEmpty) return;

    setState(() => isProcessing = true);
    final String scanned = raw.trim();

    try {
      final db = await sqlDb.db;
      if (db == null) throw Exception('Local DB not available');

      // استعلام مباشر وسريع: WHERE items_qr = ?
      final List<Map> rawRows = await db.query(
        'itemsview',
        where: 'items_qr = ?',
        whereArgs: [scanned],
      );

      if (rawRows.isNotEmpty) {
        final Map<String, dynamic> row = _toStringKeyMap(
          Map.from(rawRows.first),
        );
        await _handleFoundAndNavigate(row);
        return;
      }

      // إن لم نجد تطابقًا دقيقًا: جرّب TRIM(...) = ? (بعض القيم مخزنة مع مسافات)
      final List<Map> trimRows = await db.rawQuery(
        'SELECT * FROM itemsview WHERE TRIM(items_qr) = ?',
        [scanned],
      );
      if (trimRows.isNotEmpty) {
        final Map<String, dynamic> row = _toStringKeyMap(
          Map.from(trimRows.first),
        );
        await _handleFoundAndNavigate(row);
        return;
      }

      // لا نتيجة → أخبر المستخدم مع خيارات
      await Get.defaultDialog(
        title: "غير موجود",
        middleText:
            'لم يتم العثور على منتج يطابق هذا الرمز.\nالنص الممسوح: "$scanned"',
        actions: [
          TextButton(
            onPressed: () {
              Get.back(); // إغلاق الـ dialog والعودة لصفحة المسح
              setState(() => isProcessing = false);
            },
            child: const Text('إعادة مسح'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              setState(() => isProcessing = false);
              _showManualSearchDialog(scanned);
            },
            child: const Text('بحث يدوي / لصق'),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              await _showFirstRowsDebug();
              setState(() => isProcessing = false);
            },
            child: const Text('عرض أول 5 سجلات'),
          ),
        ],
      );
      return;
    } catch (e) {
      if (kDebugMode) {
        print('Search error: $e');
      }
      await Get.defaultDialog(
        title: "خطأ",
        middleText: "حدث خطأ أثناء البحث في قاعدة البيانات المحلية.\n$e",
        confirm: ElevatedButton(
          onPressed: () => Get.back(),
          child: const Text("حسناً"),
        ),
      );
      setState(() => isProcessing = false);
      return;
    }
  }

  // حوار للبحث اليدوي (لصق النص أو تعديله وتجربته)
  void _showManualSearchDialog(String initial) {
    final TextEditingController t = TextEditingController(text: initial);
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('بحث يدوي'),
            content: TextField(
              controller: t,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'ألصق أو اكتب نص الـ QR هنا',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('إلغاء'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.of(ctx).pop();
                  setState(() => isProcessing = true);
                  final q = t.text.trim();
                  try {
                    final db = await sqlDb.db;
                    final List<Map> rawRows = await db!.query(
                      'itemsview',
                      where: 'items_qr = ?',
                      whereArgs: [q],
                    );
                    if (rawRows.isNotEmpty) {
                      final Map<String, dynamic> row = _toStringKeyMap(
                        Map.from(rawRows.first),
                      );
                      await _handleFoundAndNavigate(row);
                      return;
                    } else {
                      await Get.defaultDialog(
                        title: 'لم يتم العثور',
                        middleText: 'لا توجد نتيجة للبحث اليدوي.',
                        confirm: ElevatedButton(
                          onPressed: () => Get.back(),
                          child: const Text('حسناً'),
                        ),
                      );
                      setState(() => isProcessing = false);
                    }
                  } catch (e) {
                    await Get.defaultDialog(
                      title: 'خطأ',
                      middleText: 'فشل البحث اليدوي: $e',
                      confirm: ElevatedButton(
                        onPressed: () => Get.back(),
                        child: const Text('حسناً'),
                      ),
                    );
                    setState(() => isProcessing = false);
                  }
                },
                child: const Text('بحث'),
              ),
            ],
          ),
    );
  }

  // لعرض أول 5 سجلات لمساعدة debug
  Future<void> _showFirstRowsDebug() async {
    try {
      final db = await sqlDb.db;
      final List<Map> raw = await db!.query('itemsview', limit: 5);
      final rows = raw.map((r) => _toStringKeyMap(Map.from(r))).toList();

      await Get.defaultDialog(
        title: 'أول 5 سجلات (debug)',
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: rows.length,
            itemBuilder: (_, i) {
              final row = rows[i];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:
                        row.entries
                            .map((e) => Text('${e.key}: ${e.value}'))
                            .toList(),
                  ),
                ),
              );
            },
          ),
        ),
        confirm: ElevatedButton(
          onPressed: () => Get.back(),
          child: const Text('إغلاق'),
        ),
      );
    } catch (e) {
      await Get.defaultDialog(
        title: 'خطأ',
        middleText: 'فشل جلب السجلات: $e',
        confirm: ElevatedButton(
          onPressed: () => Get.back(),
          child: const Text('حسراً'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("مسح QR المنتج"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: () => cameraController.toggleTorch(),
          ),
          IconButton(
            icon: const Icon(Icons.flip_camera_ios),
            onPressed: () => cameraController.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(controller: cameraController, onDetect: _onDetect),
          // إطار توجيه
          Center(
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white70, width: 2),
              ),
            ),
          ),
          if (isProcessing)
            Positioned(
              top: 24,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.65),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 12),
                      Text(
                        "جارٍ البحث عن المنتج...",
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
