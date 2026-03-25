const express = require('express');
const router = express.Router();
const supplierController = require('../controllers/supplierController');
const { authenticate } = require('../middleware/auth');

/**
 * Routes pour les fournisseurs
 * Base URL: /api/suppliers
 */

// Routes publiques (authentification requise)
router.get('/', authenticate, supplierController.getAllSuppliers);
router.get('/:id', authenticate, supplierController.getSupplierById);

// Routes admin uniquement
router.post('/', authenticate, supplierController.createSupplier);
router.put('/:id', authenticate, supplierController.updateSupplier);
router.delete('/:id', authenticate, supplierController.deleteSupplier);
router.patch('/:id/status', authenticate, supplierController.changeStatus);

module.exports = router;
