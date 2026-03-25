const supplierService = require('../services/supplierService');

/**
 * Récupérer tous les fournisseurs
 * GET /api/suppliers
 */
const getAllSuppliers = async (req, res, next) => {
  try {
    const { status, search } = req.query;
    const filters = {};

    if (status) filters.status = status;
    if (search) filters.search = search;

    const suppliers = await supplierService.getAll(filters);

    res.json({
      success: true,
      count: suppliers.length,
      data: suppliers,
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Récupérer un fournisseur par ID
 * GET /api/suppliers/:id
 */
const getSupplierById = async (req, res, next) => {
  try {
    const { id } = req.params;
    const supplier = await supplierService.getById(id);

    res.json({
      success: true,
      data: supplier,
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Créer un nouveau fournisseur (Admin uniquement)
 * POST /api/suppliers
 */
const createSupplier = async (req, res, next) => {
  try {
    const { name, email, phone, address, status } = req.body;

    // Validation
    if (!name) {
      return res.status(400).json({
        success: false,
        message: 'Le nom du fournisseur est requis',
      });
    }

    const supplier = await supplierService.create({
      name,
      email,
      phone,
      address,
      status,
    });

    res.status(201).json({
      success: true,
      message: 'Fournisseur créé avec succès',
      data: supplier,
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Mettre à jour un fournisseur (Admin uniquement)
 * PUT /api/suppliers/:id
 */
const updateSupplier = async (req, res, next) => {
  try {
    const { id } = req.params;
    const { name, email, phone, address, status } = req.body;

    const supplier = await supplierService.update(id, {
      name,
      email,
      phone,
      address,
      status,
    });

    res.json({
      success: true,
      message: 'Fournisseur mis à jour avec succès',
      data: supplier,
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Supprimer un fournisseur (Admin uniquement)
 * DELETE /api/suppliers/:id
 */
const deleteSupplier = async (req, res, next) => {
  try {
    const { id } = req.params;
    const result = await supplierService.delete(id);

    res.json({
      success: true,
      message: result.message,
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Changer le statut d'un fournisseur (Admin uniquement)
 * PATCH /api/suppliers/:id/status
 */
const changeStatus = async (req, res, next) => {
  try {
    const { id } = req.params;
    const { status } = req.body;

    if (!status) {
      return res.status(400).json({
        success: false,
        message: 'Le statut est requis',
      });
    }

    const supplier = await supplierService.changeStatus(id, status);

    res.json({
      success: true,
      message: 'Statut du fournisseur mis à jour',
      data: supplier,
    });
  } catch (error) {
    next(error);
  }
};

module.exports = {
  getAllSuppliers,
  getSupplierById,
  createSupplier,
  updateSupplier,
  deleteSupplier,
  changeStatus,
};