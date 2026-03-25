/**
 * Service de gestion du panier d'achat
 * Ajouter, consulter, modifier, supprimer des articles du panier
 */

const db = require('../config/database');
const { AppError } = require('../middleware/errorHandler');

/**
 * Récupérer le panier d'un utilisateur
 */
const getCart = async (userId) => {
  const result = await db.query(
    `SELECT 
      ci.id, ci.quantity, ci.added_at,
      p.id as product_id, p.name, p.description, p.price, 
      p.stock_quantity, p.image_url, p.brand,
      (p.price * ci.quantity) as subtotal
    FROM cart_items ci
    JOIN products p ON ci.product_id = p.id
    WHERE ci.user_id = $1 AND p.is_active = true
    ORDER BY ci.added_at DESC`,
    [userId]
  );

  // Calculer le total du panier
  const total = result.rows.reduce((sum, item) => sum + parseFloat(item.subtotal), 0);

  return {
    items: result.rows,
    total: parseFloat(total.toFixed(2)),
    itemCount: result.rows.length,
  };
};

/**
 * Ajouter un produit au panier
 */
const addToCart = async (userId, productId, quantity = 1) => {
  // Vérifier que le produit existe et est disponible
  const productResult = await db.query(
    'SELECT id, stock_quantity, is_active, price FROM products WHERE id = $1',
    [productId]
  );

  if (productResult.rows.length === 0) {
    throw new AppError('Produit non trouvé', 404);
  }

  const product = productResult.rows[0];

  if (!product.is_active) {
    throw new AppError('Ce produit n\'est plus disponible', 400);
  }

  if (product.stock_quantity < quantity) {
    throw new AppError(
      `Stock insuffisant. Seulement ${product.stock_quantity} articles disponibles`,
      400
    );
  }

  // Vérifier si le produit est déjà dans le panier
  const existingCartItem = await db.query(
    'SELECT id, quantity FROM cart_items WHERE user_id = $1 AND product_id = $2',
    [userId, productId]
  );

  let result;

  if (existingCartItem.rows.length > 0) {
    // Mettre à jour la quantité
    const newQuantity = existingCartItem.rows[0].quantity + quantity;

    if (product.stock_quantity < newQuantity) {
      throw new AppError(
        `Stock insuffisant. Seulement ${product.stock_quantity} articles disponibles`,
        400
      );
    }

    result = await db.query(
      'UPDATE cart_items SET quantity = $1 WHERE id = $2 RETURNING *',
      [newQuantity, existingCartItem.rows[0].id]
    );
  } else {
    // Ajouter un nouvel article au panier
    result = await db.query(
      'INSERT INTO cart_items (user_id, product_id, quantity) VALUES ($1, $2, $3) RETURNING *',
      [userId, productId, quantity]
    );
  }

  // Récupérer les détails complets de l'article ajouté
  const cartItemDetails = await db.query(
    `SELECT 
      ci.id, ci.quantity, ci.added_at,
      p.id as product_id, p.name, p.price, p.image_url,
      (p.price * ci.quantity) as subtotal
    FROM cart_items ci
    JOIN products p ON ci.product_id = p.id
    WHERE ci.id = $1`,
    [result.rows[0].id]
  );

  return cartItemDetails.rows[0];
};

/**
 * Mettre à jour la quantité d'un article dans le panier
 */
const updateCartItem = async (userId, cartItemId, quantity) => {
  // Vérifier que l'article appartient à l'utilisateur
  const cartItemResult = await db.query(
    `SELECT ci.id, ci.product_id, p.stock_quantity 
    FROM cart_items ci
    JOIN products p ON ci.product_id = p.id
    WHERE ci.id = $1 AND ci.user_id = $2`,
    [cartItemId, userId]
  );

  if (cartItemResult.rows.length === 0) {
    throw new AppError('Article du panier non trouvé', 404);
  }

  const cartItem = cartItemResult.rows[0];

  if (quantity <= 0) {
    throw new AppError('La quantité doit être supérieure à 0', 400);
  }

  if (cartItem.stock_quantity < quantity) {
    throw new AppError(
      `Stock insuffisant. Seulement ${cartItem.stock_quantity} articles disponibles`,
      400
    );
  }

  // Mettre à jour la quantité
  await db.query('UPDATE cart_items SET quantity = $1 WHERE id = $2', [
    quantity,
    cartItemId,
  ]);

  // Récupérer les détails mis à jour
  const updatedItem = await db.query(
    `SELECT 
      ci.id, ci.quantity, ci.added_at,
      p.id as product_id, p.name, p.price, p.image_url,
      (p.price * ci.quantity) as subtotal
    FROM cart_items ci
    JOIN products p ON ci.product_id = p.id
    WHERE ci.id = $1`,
    [cartItemId]
  );

  return updatedItem.rows[0];
};

/**
 * Supprimer un article du panier
 */
const removeFromCart = async (userId, cartItemId) => {
  const result = await db.query(
    'DELETE FROM cart_items WHERE id = $1 AND user_id = $2 RETURNING id',
    [cartItemId, userId]
  );

  if (result.rows.length === 0) {
    throw new AppError('Article du panier non trouvé', 404);
  }

  return { message: 'Article supprimé du panier' };
};

/**
 * Vider le panier
 */
const clearCart = async (userId) => {
  await db.query('DELETE FROM cart_items WHERE user_id = $1', [userId]);
  return { message: 'Panier vidé avec succès' };
};

module.exports = {
  getCart,
  addToCart,
  updateCartItem,
  removeFromCart,
  clearCart,
};
