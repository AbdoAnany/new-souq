// String extensions for common operations
extension StringExtensions on String {
  // Capitalize first letter
  String get capitalize => 
    isEmpty ? this : '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  
  // Title case
  String get titleCase => 
    split(' ').map((word) => word.capitalize).join(' ');
  
  // Check if string is email
  bool get isEmail {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(this);
  }
  
  // Check if string is phone number
  bool get isPhoneNumber {
    final phoneRegex = RegExp(r'^\+?[\d\s\-\(\)]{10,}$');
    return phoneRegex.hasMatch(this);
  }
  
  // Remove all whitespace
  String get removeWhitespace => replaceAll(RegExp(r'\s+'), '');
  
  // Check if string is numeric
  bool get isNumeric => double.tryParse(this) != null;
  
  // Convert to double safely
  double? get toDouble => double.tryParse(this);
  
  // Convert to int safely
  int? get toInt => int.tryParse(this);
  
  // Truncate string with ellipsis
  String truncate(int maxLength, [String ellipsis = '...']) {
    return length <= maxLength ? this : '${substring(0, maxLength)}$ellipsis';
  }
  
  // Check if string contains only alphabets
  bool get isAlpha => RegExp(r'^[a-zA-Z]+$').hasMatch(this);
  
  // Check if string contains only alphanumeric characters
  bool get isAlphaNumeric => RegExp(r'^[a-zA-Z0-9]+$').hasMatch(this);
  
  // Convert to currency format
  String toCurrency([String symbol = '\$']) => '$symbol${toDouble?.toStringAsFixed(2) ?? '0.00'}';
}
