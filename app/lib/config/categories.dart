import 'package:flutter/material.dart';
import 'theme.dart';

class ReceiptCategory {
  final String key;
  final String label;
  final IconData icon;
  final Color color;

  const ReceiptCategory({
    required this.key,
    required this.label,
    required this.icon,
    required this.color,
  });
}

const List<ReceiptCategory> categories = [
  ReceiptCategory(
    key: 'advertising',
    label: 'Advertising',
    icon: Icons.campaign,
    color: AppTheme.orange,
  ),
  ReceiptCategory(
    key: 'meals',
    label: 'Meals',
    icon: Icons.restaurant,
    color: AppTheme.red,
  ),
  ReceiptCategory(
    key: 'travel',
    label: 'Travel',
    icon: Icons.flight,
    color: AppTheme.indigo,
  ),
  ReceiptCategory(
    key: 'office_supplies',
    label: 'Office Supplies',
    icon: Icons.print,
    color: AppTheme.green,
  ),
  ReceiptCategory(
    key: 'software',
    label: 'Software/Tools',
    icon: Icons.computer,
    color: AppTheme.blue,
  ),
  ReceiptCategory(
    key: 'utilities',
    label: 'Utilities/Phone',
    icon: Icons.phone_iphone,
    color: AppTheme.teal,
  ),
  ReceiptCategory(
    key: 'rent',
    label: 'Rent/Workspace',
    icon: Icons.business,
    color: AppTheme.purple,
  ),
  ReceiptCategory(
    key: 'shipping',
    label: 'Shipping/Postage',
    icon: Icons.local_shipping,
    color: AppTheme.textSecondary,
  ),
  ReceiptCategory(
    key: 'insurance',
    label: 'Insurance',
    icon: Icons.shield,
    color: AppTheme.green,
  ),
  ReceiptCategory(
    key: 'other',
    label: 'Other',
    icon: Icons.more_horiz,
    color: AppTheme.textSecondary,
  ),
];

Map<String, ReceiptCategory> get categoryMap => {
  'advertising': categories[0],
  'meals': categories[1],
  'travel': categories[2],
  'office_supplies': categories[3],
  'software': categories[4],
  'utilities': categories[5],
  'rent': categories[6],
  'shipping': categories[7],
  'insurance': categories[8],
  'other': categories[9],
};

String guessCategory(String vendorName) {
  final lower = vendorName.toLowerCase();
  if (lower.contains('starbucks') ||
      lower.contains('restaurant') ||
      lower.contains('cafe') ||
      lower.contains('doordash') ||
      lower.contains('ubereats')) {
    return 'meals';
  }
  if (lower.contains('uber') ||
      lower.contains('lyft') ||
      lower.contains('delta') ||
      lower.contains('united') ||
      lower.contains('airbnb') ||
      lower.contains('hotel')) {
    return 'travel';
  }
  if (lower.contains('adobe') ||
      lower.contains('notion') ||
      lower.contains('slack') ||
      lower.contains('github') ||
      lower.contains('figma')) {
    return 'software';
  }
  if (lower.contains('amazon') ||
      lower.contains('staples') ||
      lower.contains('office')) {
    return 'office_supplies';
  }
  if (lower.contains('verizon') ||
      lower.contains('at&t') ||
      lower.contains('t-mobile')) {
    return 'utilities';
  }
  if (lower.contains('wework') || lower.contains('regus')) {
    return 'rent';
  }
  if (lower.contains('fedex') ||
      lower.contains('ups') ||
      lower.contains('usps')) {
    return 'shipping';
  }
  if (lower.contains('google ads') ||
      lower.contains('facebook ads') ||
      lower.contains('meta ads')) {
    return 'advertising';
  }
  return 'other';
}
