import 'package:intl/intl.dart';

class FormatUtils {
  // Currency formatter for TZS with 2 decimal places
  static final NumberFormat currencyFormat = NumberFormat.currency(
    locale: 'en_TZ',
    symbol: 'TZS ',
    decimalDigits: 2,
  );

  // Formats a number into TZS currency format with 2 decimal places.
  // If the amount is null or 0, returns "TZS 0.00".
  static String formatCurrency(dynamic amount) {
    final parsedAmount = num.tryParse(amount?.toString() ?? '0') ?? 0;
    return currencyFormat.format(parsedAmount);
  }

  // Date formatter - formal TZ style (e.g., 12 June 2025)
  static final DateFormat timeFormat = DateFormat("d MMMM y", "en_US");

  // Formats a date string (e.g., "2025-06-12") to "12 June 2025".
  // Returns an empty string if the input is null or invalid.
  static String formatDate(String? dateString) {
    if (dateString == null) return '';
    try {
      final date = DateTime.parse(dateString);
      return timeFormat.format(date);
    } catch (e) {
      return '';
    }
  }

  /// Formats the ratio of two values as TZS, rounded.
  static String formatCurrencyRatio(dynamic numerator, dynamic denominator) {
    final num top = num.tryParse(numerator?.toString() ?? '0') ?? 0;
    final num bottom = num.tryParse(denominator?.toString() ?? '0') ?? 0;
    final ratio = (bottom > 0 ? top / bottom : top).round();
    return formatCurrency(ratio);
  }

  /// Normalize a phone number for WhatsApp usage:
  /// - If it starts with '+', remove the '+'
  /// - If it starts with '0', assume Tanzania (replace with '255')
  /// - If it already starts with a country code (e.g., 1, 44, 91, 255), keep it
  static String normalizePhoneNumber(String phoneNumber) {
    String cleaned = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');

    if (cleaned.startsWith('+')) {
      cleaned = cleaned.substring(1);
    }

    if (cleaned.startsWith('0')) {
      // Assume local Tanzanian number
      cleaned = '255${cleaned.substring(1)}';
    }

    return cleaned;
  }
}