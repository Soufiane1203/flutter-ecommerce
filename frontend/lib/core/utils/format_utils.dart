import 'package:intl/intl.dart';

/// Utilitaires pour le formatage de données
class FormatUtils {
  /// Formater un prix en euros avec 2 décimales
  static String formatPrice(double price) {
    final formatter = NumberFormat.currency(
      locale: 'fr_FR',
      symbol: '€',
      decimalDigits: 2,
    );
    return formatter.format(price);
  }

  /// Formater une date au format français
  static String formatDate(DateTime date) {
    final formatter = DateFormat('dd/MM/yyyy', 'fr_FR');
    return formatter.format(date);
  }

  /// Formater une date avec l'heure
  static String formatDateTime(DateTime dateTime) {
    final formatter = DateFormat('dd/MM/yyyy à HH:mm', 'fr_FR');
    return formatter.format(dateTime);
  }

  /// Formater un nombre avec séparateur de milliers
  static String formatNumber(int number) {
    final formatter = NumberFormat('#,###', 'fr_FR');
    return formatter.format(number);
  }

  /// Tronquer un texte avec ellipsis
  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  /// Capitaliser la première lettre
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  /// Traduire les statuts de commande
  static String translateOrderStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'En attente';
      case 'confirmed':
        return 'Confirmée';
      case 'shipped':
        return 'Expédiée';
      case 'delivered':
        return 'Livrée';
      case 'cancelled':
        return 'Annulée';
      default:
        return status;
    }
  }
}
