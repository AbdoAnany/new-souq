import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:souq/utils/app_localizations.dart';

class FormatterUtil {
  static String formatCurrency(double amount, {String? locale}) {
    final format = NumberFormat.currency(
      locale: locale ?? 'en_US',
      symbol: '\$',
      decimalDigits: 2,
    );
    return format.format(amount);
  }
  
  static String formatDateShort(DateTime date, {String? locale}) {
    final format = DateFormat.yMd(locale);
    return format.format(date);
  }
  
  static String formatDateLong(DateTime date, {String? locale}) {
    final format = DateFormat.yMMMMd(locale);
    return format.format(date);
  }
  
  static String formatDateTime(DateTime date, {String? locale}) {
    final format = DateFormat.yMd(locale).add_jm();
    return format.format(date);
  }
  
  // For Arabic/RTL text handling
  static String getLocalizedText(BuildContext context, String englishText, String arabicText) {
    return AppLocalizations.of(context).locale.languageCode == 'ar' ? arabicText : englishText;
  }
  
  // Format numbers for Arabic display (Eastern Arabic numerals)
  static String formatNumber(BuildContext context, int number) {
    if (AppLocalizations.of(context).locale.languageCode == 'ar') {
      String latinNumber = number.toString();
      Map<String, String> easternArabicNumerals = {
        '0': '٠', '1': '١', '2': '٢', '3': '٣', '4': '٤', 
        '5': '٥', '6': '٦', '7': '٧', '8': '٨', '9': '٩',
      };
      
      String arabicNumber = '';
      for (int i = 0; i < latinNumber.length; i++) {
        arabicNumber += easternArabicNumerals[latinNumber[i]] ?? latinNumber[i];
      }
      return arabicNumber;
    } else {
      return number.toString();
    }
  }
  
  // Format prices with appropriate currency symbol and direction
  static String formatPrice(BuildContext context, double price, {String currencyCode = 'USD'}) {
    final isArabic = AppLocalizations.of(context).locale.languageCode == 'ar';
    final currencySymbols = {
      'USD': '\$',
      'EGP': 'ج.م',
      'SAR': 'ر.س',
      'AED': 'د.إ',
    };
    
    final symbol = currencySymbols[currencyCode] ?? '\$';
    final formattedPrice = price.toStringAsFixed(2);
    
    if (isArabic) {
      return '${formatNumber(context, price.toInt())} $symbol';
    } else {
      return '$symbol$formattedPrice';
    }
  }
}
