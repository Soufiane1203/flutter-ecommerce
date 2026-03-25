/**
 * Routes de gestion des produits
 * /api/products
 */

const express = require('express');
const router = express.Router();
const { body } = require('express-validator');
const productController = require('../controllers/productController');
const { authenticate, isAdmin } = require('../middleware/auth');
const upload = require('../middleware/upload');
const validate = require('../middleware/validate');

/**
 * @route   GET /api/products/categories/all
 * @desc    Récupérer toutes les catégories
 * @access  Public
 */
router.get('/categories/all', productController.getAllCategories);

/**
 * @route   GET /api/products/brands/all
 * @desc    Récupérer toutes les marques
 * @access  Public
 */
router.get('/brands/all', productController.getAllBrands);

/**
 * @route   GET /api/products
 * @desc    Récupérer tous les produits avec pagination et filtres
 * @access  Public
 * @query   page, limit, category_id, min_price, max_price, search, brand, sort_by, sort_order
 */
router.get('/', productController.getAllProducts);

/**
 * @route   GET /api/products/:id
 * @desc    Récupérer un produit par son ID
 * @access  Public
 */
router.get('/:id', productController.getProductById);

/**
 * @route   POST /api/products
 * @desc    Créer un nouveau produit
 * @access  Private/Admin
 */
router.post(
  '/',
  authenticate,
  isAdmin,
  upload.single('image'),
  [
    body('name')
      .notEmpty()
      .withMessage('Le nom du produit est requis')
      .isLength({ min: 3 })
      .withMessage('Le nom doit contenir au moins 3 caractères'),
    body('description')
      .optional()
      .isLength({ max: 2000 })
      .withMessage('La description ne doit pas dépasser 2000 caractères'),
    body('price')
      .notEmpty()
      .withMessage('Le prix est requis')
      .isFloat({ min: 0 })
      .withMessage('Le prix doit être un nombre positif'),
    body('stock_quantity')
      .notEmpty()
      .withMessage('La quantité en stock est requise')
      .isInt({ min: 0 })
      .withMessage('La quantité doit être un nombre entier positif'),
    body('category_id')
      .notEmpty()
      .withMessage('La catégorie est requise')
      .isInt()
      .withMessage('ID de catégorie invalide'),
    body('brand').optional().isLength({ max: 100 }),
  ],
  validate,
  productController.createProduct
);

/**
 * @route   PUT /api/products/:id
 * @desc    Mettre à jour un produit
 * @access  Private/Admin
 */
router.put(
  '/:id',
  authenticate,
  isAdmin,
  upload.single('image'),
  [
    body('name')
      .optional()
      .isLength({ min: 3 })
      .withMessage('Le nom doit contenir au moins 3 caractères'),
    body('description')
      .optional()
      .isLength({ max: 2000 })
      .withMessage('La description ne doit pas dépasser 2000 caractères'),
    body('price')
      .optional()
      .isFloat({ min: 0 })
      .withMessage('Le prix doit être un nombre positif'),
    body('stock_quantity')
      .optional()
      .isInt({ min: 0 })
      .withMessage('La quantité doit être un nombre entier positif'),
    body('category_id').optional().isInt().withMessage('ID de catégorie invalide'),
    body('is_active').optional().isBoolean().withMessage('is_active doit être booléen'),
  ],
  validate,
  productController.updateProduct
);

/**
 * @route   DELETE /api/products/:id
 * @desc    Supprimer un produit
 * @access  Private/Admin
 */
router.delete('/:id', authenticate, isAdmin, productController.deleteProduct);

/**
 * @route   POST /api/products/upload-image
 * @desc    Upload une image de produit
 * @access  Private/Admin
 */
router.post(
  '/upload-image',
  authenticate,
  isAdmin,
  upload.single('image'),
  (req, res) => {
    try {
      if (!req.file) {
        return res.status(400).json({ 
          success: false, 
          message: 'Aucun fichier uploadé' 
        });
      }
      
      const imageUrl = `/uploads/${req.file.filename}`;
      res.status(200).json({ 
        success: true, 
        data: { imageUrl } 
      });
    } catch (error) {
      console.error('Erreur upload image:', error);
      res.status(500).json({ 
        success: false, 
        message: 'Erreur lors de l\'upload' 
      });
    }
  }
);

module.exports = router;
