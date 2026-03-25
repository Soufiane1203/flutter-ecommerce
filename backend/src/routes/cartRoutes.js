/**
 * Routes de gestion du panier
 * /api/cart
 */

const express = require('express');
const router = express.Router();
const { body } = require('express-validator');
const cartController = require('../controllers/cartController');
const { authenticate } = require('../middleware/auth');
const validate = require('../middleware/validate');

/**
 * @route   GET /api/cart
 * @desc    Récupérer le panier de l'utilisateur
 * @access  Private
 */
router.get('/', authenticate, cartController.getCart);

/**
 * @route   POST /api/cart
 * @desc    Ajouter un produit au panier
 * @access  Private
 */
router.post(
  '/',
  authenticate,
  [
    body('product_id')
      .notEmpty()
      .withMessage('L\'ID du produit est requis')
      .isInt()
      .withMessage('ID de produit invalide'),
    body('quantity')
      .optional()
      .isInt({ min: 1 })
      .withMessage('La quantité doit être un nombre entier positif'),
  ],
  validate,
  cartController.addToCart
);

/**
 * @route   PUT /api/cart/:id
 * @desc    Mettre à jour la quantité d'un article
 * @access  Private
 */
router.put(
  '/:id',
  authenticate,
  [
    body('quantity')
      .notEmpty()
      .withMessage('La quantité est requise')
      .isInt({ min: 1 })
      .withMessage('La quantité doit être un nombre entier positif'),
  ],
  validate,
  cartController.updateCartItem
);

/**
 * @route   DELETE /api/cart/:id
 * @desc    Supprimer un article du panier
 * @access  Private
 */
router.delete('/:id', authenticate, cartController.removeFromCart);

/**
 * @route   DELETE /api/cart
 * @desc    Vider le panier
 * @access  Private
 */
router.delete('/', authenticate, cartController.clearCart);

module.exports = router;
