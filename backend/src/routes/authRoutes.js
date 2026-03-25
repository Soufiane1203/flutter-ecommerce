/**
 * Routes d'authentification
 * /api/auth
 */

const express = require('express');
const router = express.Router();
const { body } = require('express-validator');
const authController = require('../controllers/authController');
const { authenticate } = require('../middleware/auth');
const validate = require('../middleware/validate');

/**
 * @route   POST /api/auth/register
 * @desc    Inscription d'un nouvel utilisateur
 * @access  Public
 */
router.post(
  '/register',
  [
    body('email').isEmail().withMessage('Email invalide'),
    body('password')
      .isLength({ min: 6 })
      .withMessage('Le mot de passe doit contenir au moins 6 caractères'),
    body('full_name')
      .notEmpty()
      .withMessage('Le nom complet est requis')
      .isLength({ min: 2 })
      .withMessage('Le nom doit contenir au moins 2 caractères'),
    body('phone')
      .optional()
      .isMobilePhone()
      .withMessage('Numéro de téléphone invalide'),
  ],
  validate,
  authController.register
);

/**
 * @route   POST /api/auth/login
 * @desc    Connexion d'un utilisateur
 * @access  Public
 */
router.post(
  '/login',
  [
    body('email').isEmail().withMessage('Email invalide'),
    body('password').notEmpty().withMessage('Le mot de passe est requis'),
  ],
  validate,
  authController.login
);

/**
 * @route   GET /api/auth/profile
 * @desc    Récupérer le profil de l'utilisateur connecté
 * @access  Private
 */
router.get('/profile', authenticate, authController.getProfile);

/**
 * @route   PUT /api/auth/profile
 * @desc    Mettre à jour le profil
 * @access  Private
 */
router.put(
  '/profile',
  authenticate,
  [
    body('full_name')
      .optional()
      .isLength({ min: 2 })
      .withMessage('Le nom doit contenir au moins 2 caractères'),
    body('phone')
      .optional()
      .isMobilePhone()
      .withMessage('Numéro de téléphone invalide'),
  ],
  validate,
  authController.updateProfile
);

/**
 * @route   POST /api/auth/change-password
 * @desc    Changer le mot de passe
 * @access  Private
 */
router.post(
  '/change-password',
  authenticate,
  [
    body('currentPassword')
      .notEmpty()
      .withMessage('Le mot de passe actuel est requis'),
    body('newPassword')
      .isLength({ min: 6 })
      .withMessage('Le nouveau mot de passe doit contenir au moins 6 caractères'),
  ],
  validate,
  authController.changePassword
);

module.exports = router;
