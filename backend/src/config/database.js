/**
 * Configuration de la base de données PostgreSQL
 * Gestion du pool de connexions pour optimiser les performances
 */

const { Pool } = require('pg');
require('dotenv').config();

// Configuration du pool de connexions
const pool = new Pool({
  host: process.env.DB_HOST || 'localhost',
  port: process.env.DB_PORT || 5432,
  user: process.env.DB_USER || 'postgres',
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME || 'ecommerce_db',
  max: 20, // Nombre maximum de connexions dans le pool
  idleTimeoutMillis: 30000, // Temps avant qu'une connexion inactive soit fermée
  connectionTimeoutMillis: 2000, // Temps d'attente maximum pour obtenir une connexion
});

// Gestion des événements du pool
pool.on('connect', () => {
  console.log('📦 Nouvelle connexion établie avec PostgreSQL');
});

pool.on('error', (err) => {
  console.error('⚠️ Erreur avec le client PostgreSQL (logged, continues):', err.message);
  // Ne pas crasher le serveur, juste logger l'erreur
});

// Test de connexion au démarrage
pool.query('SELECT NOW()', (err, res) => {
  if (err) {
    console.error('❌ Erreur de connexion à PostgreSQL:', err);
  } else {
    console.log('✅ PostgreSQL connecté avec succès:', res.rows[0].now);
  }
});

/**
 * Exécuter une requête SQL
 * @param {string} text - Requête SQL
 * @param {Array} params - Paramètres de la requête
 * @returns {Promise} Résultat de la requête
 */
const query = (text, params) => {
  return pool.query(text, params);
};

/**
 * Obtenir un client du pool pour des transactions
 * @returns {Promise} Client de connexion
 */
const getClient = () => {
  return pool.connect();
};

module.exports = {
  query,
  getClient,
  pool,
};
