import 'package:flutter/material.dart';

class LedgrrCategory {
  final String id;
  final String name;
  final String type;
  final Color color;

  const LedgrrCategory({
    required this.id,
    required this.name,
    required this.type,
    required this.color,
  });
}

class CategoryData {
  static const List<LedgrrCategory> all = [
    LedgrrCategory(id: 'food', name: 'Food', type: 'expense', color: Color(0xFFE05C2A)),
    LedgrrCategory(id: 'transport', name: 'Transport', type: 'expense', color: Color(0xFF2D7DD2)),
    LedgrrCategory(id: 'shopping', name: 'Shopping', type: 'expense', color: Color(0xFFB5446E)),
    LedgrrCategory(id: 'health', name: 'Health', type: 'expense', color: Color(0xFF1A8C7A)),
    LedgrrCategory(id: 'utilities', name: 'Utilities', type: 'expense', color: Color(0xFF7B5EA7)),
    LedgrrCategory(id: 'rent', name: 'Rent', type: 'expense', color: Color(0xFF4A4A4A)),
    LedgrrCategory(id: 'education', name: 'Education', type: 'expense', color: Color(0xFF0D47C8)),
    LedgrrCategory(id: 'entertainment', name: 'Fun', type: 'expense', color: Color(0xFFFF6B9D)),
    LedgrrCategory(id: 'subscriptions', name: 'Subscriptions', type: 'expense', color: Color(0xFF00897B)),
    LedgrrCategory(id: 'medical', name: 'Medical', type: 'expense', color: Color(0xFFE53935)),
    LedgrrCategory(id: 'fuel', name: 'Fuel', type: 'expense', color: Color(0xFFF57C00)),
    LedgrrCategory(id: 'groceries', name: 'Groceries', type: 'expense', color: Color(0xFF558B2F)),
    LedgrrCategory(id: 'clothing', name: 'Clothing', type: 'expense', color: Color(0xFF6A1B9A)),
    LedgrrCategory(id: 'personalcare', name: 'Self Care', type: 'expense', color: Color(0xFFEC407A)),
    LedgrrCategory(id: 'dining', name: 'Dining Out', type: 'expense', color: Color(0xFFFF7043)),
    LedgrrCategory(id: 'coffee', name: 'Coffee', type: 'expense', color: Color(0xFF795548)),
    LedgrrCategory(id: 'social', name: 'Social', type: 'expense', color: Color(0xFF26C6DA)),
    LedgrrCategory(id: 'family', name: 'Family', type: 'expense', color: Color(0xFFEF5350)),
    LedgrrCategory(id: 'electricity', name: 'Electricity', type: 'expense', color: Color(0xFFFDD835)),
    LedgrrCategory(id: 'water', name: 'Water', type: 'expense', color: Color(0xFF29B6F6)),
    LedgrrCategory(id: 'internet', name: 'Internet', type: 'expense', color: Color(0xFF5C6BC0)),
    LedgrrCategory(id: 'mobile', name: 'Mobile', type: 'expense', color: Color(0xFF26A69A)),
    LedgrrCategory(id: 'savings', name: 'Savings', type: 'expense', color: Color(0xFF66BB6A)),
    LedgrrCategory(id: 'other_expense', name: 'Other', type: 'expense', color: Color(0xFF9E9E9E)),
    LedgrrCategory(id: 'salary', name: 'Salary', type: 'income', color: Color(0xFF1A8C7A)),
    LedgrrCategory(id: 'freelance', name: 'Freelance', type: 'income', color: Color(0xFF2D7DD2)),
    LedgrrCategory(id: 'allowance', name: 'Allowance', type: 'income', color: Color(0xFF7B5EA7)),
    LedgrrCategory(id: 'gift', name: 'Gift', type: 'income', color: Color(0xFFEC407A)),
    LedgrrCategory(id: 'investment', name: 'Investment', type: 'income', color: Color(0xFF00897B)),
    LedgrrCategory(id: 'refund', name: 'Refund', type: 'income', color: Color(0xFFFF7043)),
    LedgrrCategory(id: 'business', name: 'Business', type: 'income', color: Color(0xFF5C6BC0)),
    LedgrrCategory(id: 'other_income', name: 'Other', type: 'income', color: Color(0xFF9E9E9E)),
  ];

  static List<LedgrrCategory> get expenses =>
      all.where((c) => c.type == 'expense').toList();

  static List<LedgrrCategory> get incomes =>
      all.where((c) => c.type == 'income').toList();

  static LedgrrCategory? findById(String id) {
    try {
      return all.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }
}