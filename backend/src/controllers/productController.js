/**
 * Contrôleur de gestion des produits
 * Gère les requêtes HTTP pour les produits
 */

const productService = require('../services/productService');
const { successResponse, paginatedResponse } = require('../utils/response');

/**
 * Récupérer tous les produits avec pagination et filtres
 * GET /api/products
 */
const getAllProducts = async (req, res, next) => {
  try {
    const result = await productService.getAllProducts(req.query);
    paginatedResponse(
      res,
      result.products,
      result.page,
      result.limit,
      result.total,
      'Produits récupérés'
    );
  } catch (error) {
    next(error);
  }
};

/**
 * Récupérer un produit par son ID
 * GET /api/products/:id
 */
const getProductById = async (req, res, next) => {
  try {
    const product = await productService.getProductById(req.params.id);
    successResponse(res, product, 'Produit récupéré');
  } catch (error) {
    next(error);
  }
};

/**
 * Créer un nouveau produit (Admin)
 * POST /api/products
 */
const createProduct = async (req, res, next) => {
  try {
    // Logs pour debug
    console.log('📦 CREATE PRODUCT - Body:', JSON.stringify(req.body, null, 2));
    console.log('📦 CREATE PRODUCT - File:', req.file ? req.file.filename : 'Aucun fichier');
    
    // Si une image a été uploadée, ajouter l'URL
    if (req.file) {
      req.body.image_url = `/uploads/${req.file.filename}`;
    }

    const product = await productService.createProduct(req.body);
    successResponse(res, product, 'Produit créé avec succès', 201);
  } catch (error) {
    console.error('❌ CREATE PRODUCT ERROR:', error.message);
    next(error);
  }
};

/**
 * Mettre à jour un produit (Admin)
 * PUT /api/products/:id
 */
const updateProduct = async (req, res, next) => {
  try {
    // Si une nouvelle image a été uploadée, ajouter l'URL
    if (req.file) {
      req.body.image_url = `/uploads/${req.file.filename}`;
    }

    const product = await productService.updateProduct(req.params.id, req.body);
    successResponse(res, product, 'Produit mis à jour');
  } catch (error) {
    next(error);
  }
};

/**
 * Supprimer un produit (Admin)
 * DELETE /api/products/:id
 */
const deleteProduct = async (req, res, next) => {
  try {
    const result = await productService.deleteProduct(req.params.id);
    successResponse(res, result, 'Produit supprimé');
  } catch (error) {
    next(error);
  }
};

/**
 * Récupérer toutes les catégories
 * GET /api/products/categories/all
 */
const getAllCategories = async (req, res, next) => {
  try {
    const categories = await productService.getAllCategories();
    successResponse(res, categories, 'Catégories récupérées');
  } catch (error) {
    next(error);
  }
};

/**
 * Récupérer toutes les marques
 * GET /api/products/brands/all
 */
const getAllBrands = async (req, res, next) => {
  try {
    const brands = await productService.getAllBrands();
    successResponse(res, brands, 'Marques récupérées');
  } catch (error) {
    next(error);
  }
};

module.exports = {
  getAllProducts,
  getProductById,
  createProduct,
  updateProduct,
  deleteProduct,
  getAllCategories,
  getAllBrands,
};
