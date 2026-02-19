import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:store_house/core/class/statusrequest.dart';
import 'package:store_house/sqflite.dart';

class RevenueController extends GetxController {
  final SqlDb sqlDb = SqlDb();
  StatusRequest statusRequest = StatusRequest.none;

  // Revenue totals for POS 1
  double dailyPos1 = 0.0;
  double weeklyPos1 = 0.0;
  double monthlyPos1 = 0.0;
  double customPos1 = 0.0;

  // Revenue totals for POS 2
  double dailyPos2 = 0.0;
  double weeklyPos2 = 0.0;
  double monthlyPos2 = 0.0;
  double customPos2 = 0.0;

  DateTime? startDate;
  DateTime? endDate;

  @override
  void onInit() {
    calculateAllRevenue();
    super.onInit();
  }

  Future<void> calculateAllRevenue() async {
    statusRequest = StatusRequest.loading;
    update();

    try {
      final db = await sqlDb.db;
      final now = DateTime.now();
      final today = DateFormat('yyyy-MM-dd').format(now);
      
      // Weekly: last 7 days
      final weekAgo = DateFormat('yyyy-MM-dd').format(now.subtract(const Duration(days: 7)));
      
      // Monthly: current month
      final monthStart = DateFormat('yyyy-MM-01').format(now);

      // 1. Daily Revenue
      dailyPos1 = await _getRevenue(db!, today, today, 1);
      dailyPos2 = await _getRevenue(db, today, today, 2);

      // 2. Weekly Revenue
      weeklyPos1 = await _getRevenue(db, weekAgo, today, 1);
      weeklyPos2 = await _getRevenue(db, weekAgo, today, 2);

      // 3. Monthly Revenue
      monthlyPos1 = await _getRevenue(db, monthStart, today, 1);
      monthlyPos2 = await _getRevenue(db, monthStart, today, 2);

      statusRequest = StatusRequest.success;
    } catch (e) {
      statusRequest = StatusRequest.failure;
      debugPrint("Revenue Calculation Error: $e");
    }
    update();
  }

  Future<double> _getRevenue(dynamic db, String start, String end, int pos) async {
    // SQLite query to sum total from orders table within date range and for specific POS
    // Note: created_at is stored as CURRENT_TIMESTAMP (YYYY-MM-DD HH:MM:SS)
    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT SUM(total) as total_revenue 
      FROM orders 
      WHERE date(created_at) BETWEEN ? AND ? 
      AND pos_source = ?
    ''', [start, end, pos]);

    return double.tryParse(result.first['total_revenue']?.toString() ?? "0") ?? 0.0;
  }

  Future<void> calculateCustomRevenue(DateTime start, DateTime end) async {
    startDate = start;
    endDate = end;
    
    final db = await sqlDb.db;
    final s = DateFormat('yyyy-MM-dd').format(start);
    final e = DateFormat('yyyy-MM-dd').format(end);

    customPos1 = await _getRevenue(db!, s, e, 1);
    customPos2 = await _getRevenue(db, s, e, 2);
    
    update();
  }

  void resetCustom() {
    startDate = null;
    endDate = null;
    customPos1 = 0.0;
    customPos2 = 0.0;
    update();
  }
}
