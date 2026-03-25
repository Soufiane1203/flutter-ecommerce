/// Validateurs pour les formulaires
class Validators {
  // Getters pour compatibilité avec les formulaires
  static String? Function(String?) get email => validateEmail;
  static String? Function(String?) get password => validatePassword;
  
  // Méthode required pour compatibilité
  static String? Function(String?) required(String message) {
    return (String? value) {
      if (value == null || value.isEmpty) {
        return message;
      }
      return null;
    };
  }

  /// Valider un email
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'L\'email est requis';
    }
    
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    
    if (!emailRegex.hasMatch(value)) {
      return 'Email invalide';
    }
    
    return null;
  }

  /// Valider un mot de passe
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Le mot de passe est requis';
    }
    
    if (value.length < 6) {
      return 'Le mot de passe doit contenir au moins 6 caractères';
    }
    
    return null;
  }

  /// Valider un nom
  static String? validateName(String? value, [String fieldName = 'nom']) {
    if (value == null || value.isEmpty) {
      return 'Le $fieldName est requis';
    }
    
    if (value.length < 2) {
      return 'Le $fieldName doit contenir au moins 2 caractères';
    }
    
    return null;
  }

  /// Valider un numéro de téléphone
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Le numéro de téléphone est requis';
    }
    
    final phoneRegex = RegExp(r'^\+?[0-9]{10,}$');
    
    if (!phoneRegex.hasMatch(value.replaceAll(RegExp(r'\s'), ''))) {
      return 'Numéro de téléphone invalide';
    }
    
    return null;
  }

  /// Valider un prix
  static String? validatePrice(String? value) {
    if (value == null || value.isEmpty) {
      return 'Le prix est requis';
    }
    
    final price = double.tryParse(value);
    if (price == null || price < 0) {
      return 'Prix invalide';
    }
    
    return null;
  }

  /// Valider une quantité
  static String? validateQuantity(String? value) {
    if (value == null || value.isEmpty) {
      return 'La quantité est requise';
    }
    
    final quantity = int.tryParse(value);
    if (quantity == null || quantity < 0) {
      return 'Quantité invalide';
    }
    
    return null;
  }

  /// Valider une adresse
  static String? validateAddress(String? value) {
    if (value == null || value.isEmpty) {
      return 'L\'adresse est requise';
    }
    
    if (value.length < 10) {
      return 'L\'adresse doit contenir au moins 10 caractères';
    }
    
    return null;
  }
}
