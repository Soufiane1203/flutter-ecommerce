/**
 * Routes de gestion des commandes
 * /api/orders
 */

const express = require('express');
const router = express.Router();
const { body } = require('express-validator');
const orderController = require('../controllers/orderController');
const { authenticate, isAdmin } = require('../middleware/auth');
const validate = require('../middleware/validate');

/**
 * @route   GET /api/orders/admin/all
 * @desc    Récupérer toutes les commandes (Admin)
 * @access  Private/Admin
 */
router.get('/admin/all', authenticate, isAdmin, orderController.getAllOrders);

/**
 * @route   GET /api/orders
 * @desc    Récupérer les commandes de l'utilisateur
 * @access  Private
 */
router.get('/', authenticate, orderController.getUserOrders);

/**
 * @route   GET /api/orders/:id
 * @desc    Récupérer une commande par son ID
 * @access  Private
 */
router.get('/:id', authenticate, orderController.getOrderById);

/**
 * @route   POST /api/orders
 * @desc    Créer une nouvelle commande
 * @access  Private
 */
router.post(
  '/',
  authenticate,
  [
    body('shipping_address')
      .notEmpty()
      .withMessage('L\'adresse de livraison est requise')
      .isLength({ min: 10 })
      .withMessage('L\'adresse doit contenir au moins 10 caractères'),
    body('phone')
      .notEmpty()
      .withMessage('Le numéro de téléphone est requis')
      .isLength({ min: 8 })
      .withMessage('Numéro de téléphone trop court (min 8 chiffres)'),
    body('notes').optional().isLength({ max: 500 }),
  ],
  validate,
  orderController.createOrder
);

/**
 * @route   POST /api/orders/:id/cancel
 * @desc    Annuler une commande
 * @access  Private
 */
router.post('/:id/cancel', authenticate, orderController.cancelOrder);

/**
 * @route   PUT /api/orders/:id/status
 * @desc    Mettre à jour le statut d'une commande (Admin)
 * @access  Private/Admin
 */
router.put(
  '/:id/status',
  authenticate,
  isAdmin,
  [
    body('status')
      .notEmpty()
      .withMessage('Le statut est requis')
      .isIn(['pending', 'confirmed', 'shipped', 'delivered', 'cancelled'])
      .withMessage('Statut invalide'),
  ],
  validate,
  orderController.updateOrderStatus
);

module.exports = router;
