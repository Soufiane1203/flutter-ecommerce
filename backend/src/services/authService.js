/**
 * Service d'authentification
 * Gère l'inscription, la connexion et la gestion des utilisateurs
 */

const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const db = require('../config/database');
const config = require('../config/config');
const { AppError } = require('../middleware/errorHandler');

/**
 * Inscription d'un nouvel utilisateur
 */
const register = async (userData) => {
  const { email, password, full_name, phone, role = 'user' } = userData;

  // Vérifier si l'email existe déjà
  const existingUser = await db.query('SELECT id FROM users WHERE email = $1', [
    email,
  ]);

  if (existingUser.rows.length > 0) {
    throw new AppError('Cet email est déjà utilisé', 400);
  }

  // Hasher le mot de passe
  const saltRounds = 10;
  const passwordHash = await bcrypt.hash(password, saltRounds);

  // Insérer le nouvel utilisateur
  const result = await db.query(
    `INSERT INTO users (email, password_hash, full_name, phone, role) 
     VALUES ($1, $2, $3, $4, $5) 
     RETURNING id, email, full_name, phone, role, created_at`,
    [email, passwordHash, full_name, phone, role]
  );

  const user = result.rows[0];

  // Générer le token JWT
  const token = generateToken(user);

  return {
    user: {
      id: user.id,
      email: user.email,
      full_name: user.full_name,
      phone: user.phone,
      role: user.role,
      created_at: user.created_at,
    },
    token,
  };
};

/**
 * Connexion d'un utilisateur
 */
const login = async (email, password) => {
  // Récupérer l'utilisateur
  const result = await db.query(
    'SELECT id, email, password_hash, full_name, phone, role, created_at FROM users WHERE email = $1',
    [email]
  );

  if (result.rows.length === 0) {
    throw new AppError('Email ou mot de passe incorrect', 401);
  }

  const user = result.rows[0];

  // Vérifier le mot de passe
  const isPasswordValid = await bcrypt.compare(password, user.password_hash);

  if (!isPasswordValid) {
    throw new AppError('Email ou mot de passe incorrect', 401);
  }

  // Générer le token JWT
  const token = generateToken(user);

  return {
    user: {
      id: user.id,
      email: user.email,
      full_name: user.full_name,
      phone: user.phone,
      role: user.role,
      created_at: user.created_at,
    },
    token,
  };
};

/**
 * Récupérer le profil d'un utilisateur
 */
const getProfile = async (userId) => {
  const result = await db.query(
    'SELECT id, email, full_name, phone, role, created_at FROM users WHERE id = $1',
    [userId]
  );

  if (result.rows.length === 0) {
    throw new AppError('Utilisateur non trouvé', 404);
  }

  return result.rows[0];
};

/**
 * Mettre à jour le profil d'un utilisateur
 */
const updateProfile = async (userId, updateData) => {
  const { full_name, phone } = updateData;

  const result = await db.query(
    `UPDATE users 
     SET full_name = COALESCE($1, full_name), 
         phone = COALESCE($2, phone),
         updated_at = CURRENT_TIMESTAMP
     WHERE id = $3 
     RETURNING id, email, full_name, phone, role, created_at, updated_at`,
    [full_name, phone, userId]
  );

  if (result.rows.length === 0) {
    throw new AppError('Utilisateur non trouvé', 404);
  }

  return result.rows[0];
};

/**
 * Changer le mot de passe
 */
const changePassword = async (userId, currentPassword, newPassword) => {
  // Récupérer l'utilisateur
  const result = await db.query(
    'SELECT password_hash FROM users WHERE id = $1',
    [userId]
  );

  if (result.rows.length === 0) {
    throw new AppError('Utilisateur non trouvé', 404);
  }

  const user = result.rows[0];

  // Vérifier le mot de passe actuel
  const isPasswordValid = await bcrypt.compare(
    currentPassword,
    user.password_hash
  );

  if (!isPasswordValid) {
    throw new AppError('Mot de passe actuel incorrect', 401);
  }

  // Hasher le nouveau mot de passe
  const saltRounds = 10;
  const newPasswordHash = await bcrypt.hash(newPassword, saltRounds);

  // Mettre à jour le mot de passe
  await db.query(
    'UPDATE users SET password_hash = $1, updated_at = CURRENT_TIMESTAMP WHERE id = $2',
    [newPasswordHash, userId]
  );

  return { message: 'Mot de passe modifié avec succès' };
};

/**
 * Générer un token JWT
 */
const generateToken = (user) => {
  return jwt.sign(
    {
      id: user.id,
      email: user.email,
      role: user.role,
    },
    config.jwt.secret,
    { expiresIn: config.jwt.expiresIn }
  );
};

module.exports = {
  register,
  login,
  getProfile,
  updateProfile,
  changePassword,
};
