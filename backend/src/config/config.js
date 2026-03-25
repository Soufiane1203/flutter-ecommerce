/**
 * Configuration générale de l'application
 */

require('dotenv').config();

module.exports = {
  // Configuration du serveur
  port: process.env.PORT || 3000,
  nodeEnv: process.env.NODE_ENV || 'development',

  // Configuration JWT
  jwt: {
    secret: process.env.JWT_SECRET || 'changez_ce_secret_en_production',
    expiresIn: process.env.JWT_EXPIRES_IN || '7d',
  },

  // Configuration des uploads
  upload: {
    path: process.env.UPLOAD_PATH || './uploads',
    maxFileSize: parseInt(process.env.MAX_FILE_SIZE) || 5 * 1024 * 1024, // 5MB par défaut
    allowedMimeTypes: ['image/jpeg', 'image/jpg', 'image/png', 'image/webp'],
  },

  // Configuration de la pagination
  pagination: {
    defaultPage: 1,
    defaultLimit: 20,
    maxLimit: 100,
  },
};
