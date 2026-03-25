/**
 * Contrôleur d'authentification
 * Gère les requêtes HTTP pour l'authentification
 */

const authService = require('../services/authService');
const { successResponse, errorResponse } = require('../utils/response');

/**
 * Inscription d'un nouvel utilisateur
 * POST /api/auth/register
 */
const register = async (req, res, next) => {
  try {
    const result = await authService.register(req.body);
    successResponse(res, result, 'Inscription réussie', 201);
  } catch (error) {
    next(error);
  }
};

/**
 * Connexion d'un utilisateur
 * POST /api/auth/login
 */
const login = async (req, res, next) => {
  try {
    const { email, password } = req.body;
    const result = await authService.login(email, password);
    successResponse(res, result, 'Connexion réussie');
  } catch (error) {
    next(error);
  }
};

/**
 * Récupérer le profil de l'utilisateur connecté
 * GET /api/auth/profile
 */
const getProfile = async (req, res, next) => {
  try {
    const profile = await authService.getProfile(req.user.id);
    successResponse(res, profile, 'Profil récupéré');
  } catch (error) {
    next(error);
  }
};

/**
 * Mettre à jour le profil
 * PUT /api/auth/profile
 */
const updateProfile = async (req, res, next) => {
  try {
    const profile = await authService.updateProfile(req.user.id, req.body);
    successResponse(res, profile, 'Profil mis à jour');
  } catch (error) {
    next(error);
  }
};

/**
 * Changer le mot de passe
 * POST /api/auth/change-password
 */
const changePassword = async (req, res, next) => {
  try {
    const { currentPassword, newPassword } = req.body;
    const result = await authService.changePassword(
      req.user.id,
      currentPassword,
      newPassword
    );
    successResponse(res, result, 'Mot de passe modifié');
  } catch (error) {
    next(error);
  }
};

module.exports = {
  register,
  login,
  getProfile,
  updateProfile,
  changePassword,
};
