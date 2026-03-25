/**
 * Serveur principal de l'application E-commerce
 * Backend Node.js + Express.js + PostgreSQL
 */

const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const path = require('path');
require('dotenv').config();

const config = require('./config/config');
const { notFound, errorHandler } = require('./middleware/errorHandler');

// Import des routes
const authRoutes = require('./routes/authRoutes');
const productRoutes = require('./routes/productRoutes');
const cartRoutes = require('./routes/cartRoutes');
const orderRoutes = require('./routes/orderRoutes');
const supplierRoutes = require('./routes/supplierRoutes');

// Initialisation de l'application Express
const app = express();

// ============================================
// MIDDLEWARES GLOBAUX
// ============================================

// Sécurité avec Helmet
app.use(helmet());

// CORS - Permettre les requêtes cross-origin
app.use(
  cors({
    origin: '*', // À remplacer par l'URL du frontend Flutter en production
    credentials: true,
  })
);

// Logger les requêtes HTTP
if (config.nodeEnv === 'development') {
  app.use(morgan('dev'));
}

// Parser le body des requêtes
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Servir les fichiers statiques (images uploadées)
app.use('/uploads', express.static(path.join(__dirname, '../uploads')));

// ============================================
// ROUTES
// ============================================

// Route de santé (health check)
app.get('/health', (req, res) => {
  res.json({
    success: true,
    message: 'API E-commerce fonctionnelle',
    timestamp: new Date().toISOString(),
    environment: config.nodeEnv,
  });
});

// Routes de l'API
app.use('/api/auth', authRoutes);
app.use('/api/products', productRoutes);
app.use('/api/cart', cartRoutes);
app.use('/api/orders', orderRoutes);
app.use('/api/suppliers', supplierRoutes);

// ============================================
// GESTION DES ERREURS
// ============================================

// Route non trouvée (404)
app.use(notFound);

// Gestionnaire global des erreurs
app.use(errorHandler);

// ============================================
// DÉMARRAGE DU SERVEUR
// ============================================

const PORT = config.port;

app.listen(PORT, () => {
  console.log('\n🚀 ======================================');
  console.log(`🚀 Serveur E-commerce démarré avec succès`);
  console.log(`🚀 Environnement: ${config.nodeEnv}`);
  console.log(`🚀 Port: ${PORT}`);
  console.log(`🚀 URL: http://localhost:${PORT}`);
  console.log(`🚀 Health Check: http://localhost:${PORT}/health`);
  console.log('🚀 ======================================\n');
});

// Gestion des erreurs non gérées (log mais ne crash pas le serveur)
process.on('unhandledRejection', (err) => {
  console.error('⚠️ UNHANDLED REJECTION (logged, server continues):');
  console.error(err);
});

process.on('uncaughtException', (err) => {
  console.error('⚠️ UNCAUGHT EXCEPTION (logged, server continues):');
  console.error(err);
});

module.exports = app;
