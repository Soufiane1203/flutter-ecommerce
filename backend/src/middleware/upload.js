/**
 * Configuration de Multer pour l'upload d'images
 * Gère le stockage et la validation des fichiers
 */

const multer = require('multer');
const path = require('path');
const config = require('../config/config');

// Configuration du stockage
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, config.upload.path);
  },
  filename: (req, file, cb) => {
    // Générer un nom de fichier unique
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1e9);
    const ext = path.extname(file.originalname);
    cb(null, 'product-' + uniqueSuffix + ext);
  },
});

// Filtrer les types de fichiers autorisés
const fileFilter = (req, file, cb) => {
  if (config.upload.allowedMimeTypes.includes(file.mimetype)) {
    cb(null, true);
  } else {
    cb(
      new Error(
        'Type de fichier non autorisé. Formats acceptés: JPEG, JPG, PNG, WEBP'
      ),
      false
    );
  }
};

// Configuration de multer
const upload = multer({
  storage: storage,
  limits: {
    fileSize: config.upload.maxFileSize,
  },
  fileFilter: fileFilter,
});

module.exports = upload;
