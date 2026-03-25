/**
 * Service de gestion des produits
 * CRUD complet, filtrage, recherche, pagination
 */

const db = require('../config/database');
const { AppError } = require('../middleware/errorHandler');

/**
 * Récupérer tous les produits avec pagination et filtres
 */
const getAllProducts = async (filters) => {
  const {
    page = 1,
    limit = 20,
    category_id,
    min_price,
    max_price,
    search,
    brand,
    is_active = true,
    sort_by = 'created_at',
    sort_order = 'DESC',
  } = filters;

  // Calcul de l'offset
  const offset = (page - 1) * limit;

  // Construction de la requête dynamique
  let whereConditions = [];
  let queryParams = [];
  let paramCounter = 1;

  // Filtrer par statut actif (par défaut true pour les users)
  whereConditions.push(`p.is_active = $${paramCounter}`);
  queryParams.push(is_active);
  paramCounter++;

  // Filtrer par catégorie
  if (category_id) {
    whereConditions.push(`p.category_id = $${paramCounter}`);
    queryParams.push(category_id);
    paramCounter++;
  }

  // Filtrer par prix minimum
  if (min_price) {
    whereConditions.push(`p.price >= $${paramCounter}`);
    queryParams.push(min_price);
    paramCounter++;
  }

  // Filtrer par prix maximum
  if (max_price) {
    whereConditions.push(`p.price <= $${paramCounter}`);
    queryParams.push(max_price);
    paramCounter++;
  }

  // Filtrer par marque
  if (brand) {
    whereConditions.push(`LOWER(p.brand) = LOWER($${paramCounter})`);
    queryParams.push(brand);
    paramCounter++;
  }

  // Recherche par nom, description ou marque
  if (search) {
    whereConditions.push(
      `(LOWER(p.name) LIKE LOWER($${paramCounter}) OR LOWER(p.description) LIKE LOWER($${paramCounter}) OR LOWER(p.brand) LIKE LOWER($${paramCounter}))`
    );
    queryParams.push(`%${search}%`);
    paramCounter++;
  }

  const whereClause =
    whereConditions.length > 0 ? 'WHERE ' + whereConditions.join(' AND ') : '';

  // Valider le tri
  const allowedSortColumns = ['name', 'price', 'created_at', 'stock_quantity'];
  const sortColumn = allowedSortColumns.includes(sort_by) ? sort_by : 'created_at';
  const sortDirection = sort_order.toUpperCase() === 'ASC' ? 'ASC' : 'DESC';

  // Requête principale
  const query = `
    SELECT 
      p.id, p.name, p.description, p.price, p.stock_quantity,
      p.category_id, c.name as category_name,
      p.image_url, p.brand, p.specifications, p.is_active,
      p.created_at, p.updated_at
    FROM products p
    LEFT JOIN categories c ON p.category_id = c.id
    ${whereClause}
    ORDER BY p.${sortColumn} ${sortDirection}
    LIMIT $${paramCounter} OFFSET $${paramCounter + 1}
  `;

  queryParams.push(limit, offset);

  // Compter le total
  const countQuery = `
    SELECT COUNT(*) as total
    FROM products p
    ${whereClause}
  `;

  const [productsResult, countResult] = await Promise.all([
    db.query(query, queryParams),
    db.query(countQuery, queryParams.slice(0, -2)), // Enlever limit et offset
  ]);

  return {
    products: productsResult.rows,
    total: parseInt(countResult.rows[0].total),
    page: parseInt(page),
    limit: parseInt(limit),
  };
};

/**
 * Récupérer un produit par son ID
 */
const getProductById = async (productId) => {
  const result = await db.query(
    `SELECT 
      p.id, p.name, p.description, p.price, p.stock_quantity,
      p.category_id, c.name as category_name,
      p.image_url, p.brand, p.specifications, p.is_active,
      p.created_at, p.updated_at
    FROM products p
    LEFT JOIN categories c ON p.category_id = c.id
    WHERE p.id = $1`,
    [productId]
  );

  if (result.rows.length === 0) {
    throw new AppError('Produit non trouvé', 404);
  }

  return result.rows[0];
};

/**
 * Créer un nouveau produit (Admin uniquement)
 */
const createProduct = async (productData) => {
  const {
    name,
    description,
    price,
    stock_quantity,
    category_id,
    image_url,
    brand,
    specifications,
  } = productData;

  const result = await db.query(
    `INSERT INTO products 
    (name, description, price, stock_quantity, category_id, image_url, brand, specifications) 
    VALUES ($1, $2, $3, $4, $5, $6, $7, $8) 
    RETURNING *`,
    [
      name,
      description,
      price,
      stock_quantity,
      category_id,
      image_url,
      brand,
      specifications ? JSON.stringify(specifications) : null,
    ]
  );

  return result.rows[0];
};

/**
 * Mettre à jour un produit (Admin uniquement)
 */
const updateProduct = async (productId, productData) => {
  const {
    name,
    description,
    price,
    stock_quantity,
    category_id,
    image_url,
    brand,
    specifications,
    is_active,
  } = productData;

  // Vérifier que le produit existe
  const existingProduct = await db.query('SELECT id FROM products WHERE id = $1', [
    productId,
  ]);

  if (existingProduct.rows.length === 0) {
    throw new AppError('Produit non trouvé', 404);
  }

  const result = await db.query(
    `UPDATE products 
    SET 
      name = COALESCE($1, name),
      description = COALESCE($2, description),
      price = COALESCE($3, price),
      stock_quantity = COALESCE($4, stock_quantity),
      category_id = COALESCE($5, category_id),
      image_url = COALESCE($6, image_url),
      brand = COALESCE($7, brand),
      specifications = COALESCE($8, specifications),
      is_active = COALESCE($9, is_active),
      updated_at = CURRENT_TIMESTAMP
    WHERE id = $10
    RETURNING *`,
    [
      name,
      description,
      price,
      stock_quantity,
      category_id,
      image_url,
      brand,
      specifications ? JSON.stringify(specifications) : null,
      is_active,
      productId,
    ]
  );

  return result.rows[0];
};

/**
 * Supprimer un produit (Admin uniquement)
 */
const deleteProduct = async (productId) => {
  const result = await db.query('DELETE FROM products WHERE id = $1 RETURNING id', [
    productId,
  ]);

  if (result.rows.length === 0) {
    throw new AppError('Produit non trouvé', 404);
  }

  return { message: 'Produit supprimé avec succès' };
};

/**
 * Récupérer toutes les catégories
 */
const getAllCategories = async () => {
  const result = await db.query(
    `SELECT c.*, COUNT(p.id) as product_count
    FROM categories c
    LEFT JOIN products p ON c.id = p.category_id AND p.is_active = true
    GROUP BY c.id
    ORDER BY c.name`
  );

  return result.rows;
};

/**
 * Récupérer les marques disponibles
 */
const getAllBrands = async () => {
  const result = await db.query(
    `SELECT DISTINCT brand 
    FROM products 
    WHERE brand IS NOT NULL AND is_active = true
    ORDER BY brand`
  );

  return result.rows.map((row) => row.brand);
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
