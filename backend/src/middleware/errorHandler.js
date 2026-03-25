/**
 * Middleware de gestion globale des erreurs
 * Capture toutes les erreurs et renvoie des réponses standardisées
 */

/**
 * Gestionnaire d'erreurs 404 - Route non trouvée
 */
const notFound = (req, res, next) => {
  res.status(404).json({
    success: false,
    message: `Route non trouvée: ${req.originalUrl}`,
  });
};

/**
 * Gestionnaire global des erreurs
 */
const errorHandler = (err, req, res, next) => {
  console.error('❌ Erreur:', err);

  // Erreur de validation PostgreSQL
  if (err.code && err.code.startsWith('23')) {
    if (err.code === '23505') {
      return res.status(400).json({
        success: false,
        message: 'Cette valeur existe déjà dans la base de données',
        error: err.detail,
      });
    }
    if (err.code === '23503') {
      return res.status(400).json({
        success: false,
        message: 'Référence invalide à une ressource',
        error: err.detail,
      });
    }
  }

  // Erreur personnalisée
  if (err.statusCode) {
    return res.status(err.statusCode).json({
      success: false,
      message: err.message,
    });
  }

  // Erreur par défaut
  res.status(500).json({
    success: false,
    message: 'Erreur interne du serveur',
    error: process.env.NODE_ENV === 'development' ? err.message : undefined,
  });
};

/**
 * Classe d'erreur personnalisée
 */
class AppError extends Error {
  constructor(message, statusCode) {
    super(message);
    this.statusCode = statusCode;
    this.isOperational = true;

    Error.captureStackTrace(this, this.constructor);
  }
}

module.exports = {
  notFound,
  errorHandler,
  AppError,
};
