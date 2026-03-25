/**
 * Contrôleur de gestion des commandes
 * Gère les requêtes HTTP pour les commandes
 */

const orderService = require('../services/orderService');
const { successResponse, paginatedResponse } = require('../utils/response');

/**
 * Créer une nouvelle commande
 * POST /api/orders
 */
const createOrder = async (req, res, next) => {
  try {
    console.log('📦 CREATE ORDER - User ID:', req.user.id);
    console.log('📦 CREATE ORDER - Body:', JSON.stringify(req.body, null, 2));
    
    const order = await orderService.createOrder(req.user.id, req.body);
    
    console.log('✅ ORDER CREATED - ID:', order.id, 'Status:', order.status);
    
    successResponse(res, order, 'Commande créée avec succès', 201);
  } catch (error) {
    console.error('❌ CREATE ORDER ERROR:', error.message);
    next(error);
  }
};

/**
 * Récupérer les commandes de l'utilisateur
 * GET /api/orders
 */
const getUserOrders = async (req, res, next) => {
  try {
    const result = await orderService.getUserOrders(req.user.id, req.query);
    paginatedResponse(
      res,
      result.orders,
      result.page,
      result.limit,
      result.total,
      'Commandes récupérées'
    );
  } catch (error) {
    next(error);
  }
};

/**
 * Récupérer une commande par son ID
 * GET /api/orders/:id
 */
const getOrderById = async (req, res, next) => {
  try {
    const isAdmin = req.user.role === 'admin';
    const order = await orderService.getOrderById(
      req.user.id,
      req.params.id,
      isAdmin
    );
    successResponse(res, order, 'Commande récupérée');
  } catch (error) {
    next(error);
  }
};

/**
 * Annuler une commande
 * POST /api/orders/:id/cancel
 */
const cancelOrder = async (req, res, next) => {
  try {
    const isAdmin = req.user.role === 'admin';
    const order = await orderService.cancelOrder(
      req.user.id,
      req.params.id,
      isAdmin
    );
    successResponse(res, order, 'Commande annulée');
  } catch (error) {
    next(error);
  }
};

/**
 * Récupérer toutes les commandes (Admin)
 * GET /api/orders/admin/all
 */
const getAllOrders = async (req, res, next) => {
  try {
    const result = await orderService.getAllOrders(req.query);
    paginatedResponse(
      res,
      result.orders,
      result.page,
      result.limit,
      result.total,
      'Toutes les commandes récupérées'
    );
  } catch (error) {
    next(error);
  }
};

/**
 * Mettre à jour le statut d'une commande (Admin)
 * PUT /api/orders/:id/status
 */
const updateOrderStatus = async (req, res, next) => {
  try {
    const { status } = req.body;
    const order = await orderService.updateOrderStatus(req.params.id, status);
    successResponse(res, order, 'Statut de la commande mis à jour');
  } catch (error) {
    next(error);
  }
};

module.exports = {
  createOrder,
  getUserOrders,
  getOrderById,
  cancelOrder,
  getAllOrders,
  updateOrderStatus,
};
