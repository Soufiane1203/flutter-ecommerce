/**
 * Middleware de validation des données
 * Utilise express-validator pour valider les entrées
 */

const { validationResult } = require('express-validator');

/**
 * Vérifie les résultats de validation et renvoie les erreurs
 */
const validate = (req, res, next) => {
  const errors = validationResult(req);

  if (!errors.isEmpty()) {
    return res.status(400).json({
      success: false,
      message: 'Erreurs de validation',
      errors: errors.array().map((err) => ({
        field: err.path || err.param,
        message: err.msg,
      })),
    });
  }

  next();
};

module.exports = validate;
