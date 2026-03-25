/**
 * Service de gestion des commandes
 * Créer, consulter et gérer les commandes
 */

const db = require('../config/database');
const { AppError } = require('../middleware/errorHandler');

/**
 * Créer une nouvelle commande à partir du panier
 */
const createOrder = async (userId, orderData) => {
  const { shipping_address, phone, notes } = orderData;

  // Récupérer le panier de l'utilisateur
  const cartResult = await db.query(
    `SELECT 
      ci.product_id, ci.quantity,
      p.price, p.stock_quantity, p.name
    FROM cart_items ci
    JOIN products p ON ci.product_id = p.id
    WHERE ci.user_id = $1 AND p.is_active = true`,
    [userId]
  );

  if (cartResult.rows.length === 0) {
    throw new AppError('Le panier est vide', 400);
  }

  const cartItems = cartResult.rows;

  // Vérifier la disponibilité des stocks
  for (const item of cartItems) {
    if (item.stock_quantity < item.quantity) {
      throw new AppError(
        `Stock insuffisant pour le produit "${item.name}". Seulement ${item.stock_quantity} disponibles`,
        400
      );
    }
  }

  // Calculer le montant total
  const totalAmount = cartItems.reduce(
    (sum, item) => sum + parseFloat(item.price) * item.quantity,
    0
  );

  // Démarrer une transaction
  const client = await db.getClient();

  try {
    await client.query('BEGIN');

    // Créer la commande
    const orderResult = await client.query(
      `INSERT INTO orders (user_id, total_amount, shipping_address, phone, notes, status)
       VALUES ($1, $2, $3, $4, $5, 'pending')
       RETURNING *`,
      [userId, totalAmount, shipping_address, phone, notes]
    );

    const order = orderResult.rows[0];

    // Créer les items de la commande et mettre à jour les stocks
    for (const item of cartItems) {
      const subtotal = parseFloat(item.price) * item.quantity;

      // Insérer l'item de commande
      await client.query(
        `INSERT INTO order_items (order_id, product_id, quantity, unit_price, subtotal)
         VALUES ($1, $2, $3, $4, $5)`,
        [order.id, item.product_id, item.quantity, item.price, subtotal]
      );

      // Réduire le stock
      await client.query(
        'UPDATE products SET stock_quantity = stock_quantity - $1 WHERE id = $2',
        [item.quantity, item.product_id]
      );
    }

    // Vider le panier
    await client.query('DELETE FROM cart_items WHERE user_id = $1', [userId]);

    await client.query('COMMIT');

    // Récupérer la commande complète avec les items
    return await getOrderById(userId, order.id);
  } catch (error) {
    await client.query('ROLLBACK');
    throw error;
  } finally {
    client.release();
  }
};

/**
 * Récupérer toutes les commandes d'un utilisateur
 */
const getUserOrders = async (userId, filters = {}) => {
  const { page = 1, limit = 20, status } = filters;
  const offset = (page - 1) * limit;

  let whereClause = 'WHERE o.user_id = $1';
  let queryParams = [userId];
  let paramCounter = 2;

  if (status) {
    whereClause += ` AND o.status = $${paramCounter}`;
    queryParams.push(status);
    paramCounter++;
  }

  queryParams.push(limit, offset);

  const query = `
    SELECT 
      o.id, o.total_amount, o.status, o.shipping_address, 
      o.phone, o.notes, o.created_at, o.updated_at,
      COUNT(oi.id) as item_count
    FROM orders o
    LEFT JOIN order_items oi ON o.id = oi.order_id
    ${whereClause}
    GROUP BY o.id
    ORDER BY o.created_at DESC
    LIMIT $${paramCounter} OFFSET $${paramCounter + 1}
  `;

  const countQuery = `
    SELECT COUNT(*) as total
    FROM orders o
    ${whereClause}
  `;

  const [ordersResult, countResult] = await Promise.all([
    db.query(query, queryParams),
    db.query(countQuery, queryParams.slice(0, -2)),
  ]);

  return {
    orders: ordersResult.rows,
    total: parseInt(countResult.rows[0].total),
    page: parseInt(page),
    limit: parseInt(limit),
  };
};

/**
 * Récupérer une commande par son ID
 */
const getOrderById = async (userId, orderId, isAdmin = false) => {
  // Les admins peuvent voir toutes les commandes, les users seulement les leurs
  let query = `
    SELECT 
      o.id, o.user_id, o.total_amount, o.status, o.shipping_address,
      o.phone, o.notes, o.created_at, o.updated_at,
      u.full_name, u.email
    FROM orders o
    JOIN users u ON o.user_id = u.id
    WHERE o.id = $1
  `;

  const queryParams = [orderId];

  if (!isAdmin) {
    query += ' AND o.user_id = $2';
    queryParams.push(userId);
  }

  const orderResult = await db.query(query, queryParams);

  if (orderResult.rows.length === 0) {
    throw new AppError('Commande non trouvée', 404);
  }

  const order = orderResult.rows[0];

  // Récupérer les items de la commande
  const itemsResult = await db.query(
    `SELECT 
      oi.id, oi.quantity, oi.unit_price, oi.subtotal,
      p.id as product_id, p.name, p.image_url, p.brand
    FROM order_items oi
    JOIN products p ON oi.product_id = p.id
    WHERE oi.order_id = $1`,
    [orderId]
  );

  return {
    ...order,
    items: itemsResult.rows,
  };
};

/**
 * Récupérer toutes les commandes (Admin uniquement)
 */
const getAllOrders = async (filters = {}) => {
  const { page = 1, limit = 20, status, user_id } = filters;
  const offset = (page - 1) * limit;

  let whereConditions = [];
  let queryParams = [];
  let paramCounter = 1;

  if (status) {
    whereConditions.push(`o.status = $${paramCounter}`);
    queryParams.push(status);
    paramCounter++;
  }

  if (user_id) {
    whereConditions.push(`o.user_id = $${paramCounter}`);
    queryParams.push(user_id);
    paramCounter++;
  }

  const whereClause =
    whereConditions.length > 0 ? 'WHERE ' + whereConditions.join(' AND ') : '';

  queryParams.push(limit, offset);

  const query = `
    SELECT 
      o.id, o.user_id, o.total_amount, o.status, o.shipping_address,
      o.phone, o.created_at, o.updated_at,
      u.full_name, u.email,
      COUNT(oi.id) as item_count
    FROM orders o
    JOIN users u ON o.user_id = u.id
    LEFT JOIN order_items oi ON o.id = oi.order_id
    ${whereClause}
    GROUP BY o.id, u.full_name, u.email
    ORDER BY o.created_at DESC
    LIMIT $${paramCounter} OFFSET $${paramCounter + 1}
  `;

  const countQuery = `
    SELECT COUNT(*) as total
    FROM orders o
    ${whereClause}
  `;

  const [ordersResult, countResult] = await Promise.all([
    db.query(query, queryParams),
    db.query(countQuery, queryParams.slice(0, -2)),
  ]);

  return {
    orders: ordersResult.rows,
    total: parseInt(countResult.rows[0].total),
    page: parseInt(page),
    limit: parseInt(limit),
  };
};

/**
 * Mettre à jour le statut d'une commande (Admin uniquement)
 */
const updateOrderStatus = async (orderId, status) => {
  const validStatuses = ['pending', 'confirmed', 'shipped', 'delivered', 'cancelled'];

  if (!validStatuses.includes(status)) {
    throw new AppError('Statut de commande invalide', 400);
  }

  const result = await db.query(
    `UPDATE orders 
     SET status = $1, updated_at = CURRENT_TIMESTAMP
     WHERE id = $2
     RETURNING *`,
    [status, orderId]
  );

  if (result.rows.length === 0) {
    throw new AppError('Commande non trouvée', 404);
  }

  return result.rows[0];
};

/**
 * Annuler une commande (User ou Admin)
 */
const cancelOrder = async (userId, orderId, isAdmin = false) => {
  // Récupérer la commande
  let query = 'SELECT * FROM orders WHERE id = $1';
  const queryParams = [orderId];

  if (!isAdmin) {
    query += ' AND user_id = $2';
    queryParams.push(userId);
  }

  const orderResult = await db.query(query, queryParams);

  if (orderResult.rows.length === 0) {
    throw new AppError('Commande non trouvée', 404);
  }

  const order = orderResult.rows[0];

  // Vérifier si la commande peut être annulée
  if (order.status === 'cancelled') {
    throw new AppError('Cette commande est déjà annulée', 400);
  }

  if (order.status === 'delivered') {
    throw new AppError('Une commande livrée ne peut pas être annulée', 400);
  }

  // Démarrer une transaction pour restaurer les stocks
  const client = await db.getClient();

  try {
    await client.query('BEGIN');

    // Récupérer les items de la commande
    const itemsResult = await client.query(
      'SELECT product_id, quantity FROM order_items WHERE order_id = $1',
      [orderId]
    );

    // Restaurer les stocks
    for (const item of itemsResult.rows) {
      await client.query(
        'UPDATE products SET stock_quantity = stock_quantity + $1 WHERE id = $2',
        [item.quantity, item.product_id]
      );
    }

    // Mettre à jour le statut de la commande
    const result = await client.query(
      `UPDATE orders 
       SET status = 'cancelled', updated_at = CURRENT_TIMESTAMP
       WHERE id = $1
       RETURNING *`,
      [orderId]
    );

    await client.query('COMMIT');

    return result.rows[0];
  } catch (error) {
    await client.query('ROLLBACK');
    throw error;
  } finally {
    client.release();
  }
};

module.exports = {
  createOrder,
  getUserOrders,
  getOrderById,
  getAllOrders,
  updateOrderStatus,
  cancelOrder,
};
