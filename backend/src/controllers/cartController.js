/**
 * Contrôleur de gestion du panier
 * Gère les requêtes HTTP pour le panier d'achat
 */

const cartService = require('../services/cartService');
const { successResponse } = require('../utils/response');

/**
 * Récupérer le panier de l'utilisateur
 * GET /api/cart
 */
const getCart = async (req, res, next) => {
  try {
    const cart = await cartService.getCart(req.user.id);
    successResponse(res, cart, 'Panier récupéré');
  } catch (error) {
    next(error);
  }
};

/**
 * Ajouter un produit au panier
 * POST /api/cart
 */
const addToCart = async (req, res, next) => {
  try {
    const { product_id, quantity } = req.body;
    const cartItem = await cartService.addToCart(req.user.id, product_id, quantity);
    successResponse(res, cartItem, 'Produit ajouté au panier', 201);
  } catch (error) {
    next(error);
  }
};

/**
 * Mettre à jour la quantité d'un article
 * PUT /api/cart/:id
 */
const updateCartItem = async (req, res, next) => {
  try {
    const { quantity } = req.body;
    const cartItem = await cartService.updateCartItem(
      req.user.id,
      req.params.id,
      quantity
    );
    successResponse(res, cartItem, 'Quantité mise à jour');
  } catch (error) {
    next(error);
  }
};

/**
 * Supprimer un article du panier
 * DELETE /api/cart/:id
 */
const removeFromCart = async (req, res, next) => {
  try {
    const result = await cartService.removeFromCart(req.user.id, req.params.id);
    successResponse(res, result, 'Article supprimé du panier');
  } catch (error) {
    next(error);
  }
};

/**
 * Vider le panier
 * DELETE /api/cart
 */
const clearCart = async (req, res, next) => {
  try {
    const result = await cartService.clearCart(req.user.id);
    successResponse(res, result, 'Panier vidé');
  } catch (error) {
    next(error);
  }
};

module.exports = {
  getCart,
  addToCart,
  updateCartItem,
  removeFromCart,
  clearCart,
};
