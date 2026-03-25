const pool = require('../config/database');
const Supplier = require('../models/Supplier');

/**
 * Service pour gérer les fournisseurs
 */
class SupplierService {
  /**
   * Récupérer tous les fournisseurs
   */
  async getAll(filters = {}) {
    try {
      let query = 'SELECT * FROM suppliers';
      const params = [];
      const conditions = [];

      // Filtrer par statut
      if (filters.status) {
        conditions.push(`status = $${params.length + 1}`);
        params.push(filters.status);
      }

      // Recherche par nom
      if (filters.search) {
        conditions.push(`name ILIKE $${params.length + 1}`);
        params.push(`%${filters.search}%`);
      }

      if (conditions.length > 0) {
        query += ` WHERE ${conditions.join(' AND ')}`;
      }

      query += ' ORDER BY created_at DESC';

      const result = await pool.query(query, params);
      return result.rows.map(row => Supplier.fromDB(row));
    } catch (error) {
      throw new Error(`Erreur lors de la récupération des fournisseurs: ${error.message}`);
    }
  }

  /**
   * Récupérer un fournisseur par ID
   */
  async getById(id) {
    try {
      const result = await pool.query('SELECT * FROM suppliers WHERE id = $1', [id]);

      if (result.rows.length === 0) {
        throw new Error('Fournisseur introuvable');
      }

      return Supplier.fromDB(result.rows[0]);
    } catch (error) {
      throw error;
    }
  }

  /**
   * Créer un nouveau fournisseur
   */
  async create(supplierData) {
    try {
      const { name, email, phone, address, status = 'active' } = supplierData;

      // Vérifier si l'email existe déjà
      if (email) {
        const existingSupplier = await pool.query('SELECT id FROM suppliers WHERE email = $1', [email]);
        if (existingSupplier.rows.length > 0) {
          throw new Error('Un fournisseur avec cet email existe déjà');
        }
      }

      const result = await pool.query(
        `INSERT INTO suppliers (name, email, phone, address, status)
         VALUES ($1, $2, $3, $4, $5)
         RETURNING *`,
        [name, email, phone, address, status]
      );

      return Supplier.fromDB(result.rows[0]);
    } catch (error) {
      throw error;
    }
  }

  /**
   * Mettre à jour un fournisseur
   */
  async update(id, supplierData) {
    try {
      const { name, email, phone, address, status } = supplierData;

      // Vérifier si le fournisseur existe
      await this.getById(id);

      // Vérifier si l'email est déjà utilisé par un autre fournisseur
      if (email) {
        const existingSupplier = await pool.query(
          'SELECT id FROM suppliers WHERE email = $1 AND id != $2',
          [email, id]
        );
        if (existingSupplier.rows.length > 0) {
          throw new Error('Un autre fournisseur utilise déjà cet email');
        }
      }

      const result = await pool.query(
        `UPDATE suppliers
         SET name = COALESCE($1, name),
             email = COALESCE($2, email),
             phone = COALESCE($3, phone),
             address = COALESCE($4, address),
             status = COALESCE($5, status),
             updated_at = CURRENT_TIMESTAMP
         WHERE id = $6
         RETURNING *`,
        [name, email, phone, address, status, id]
      );

      return Supplier.fromDB(result.rows[0]);
    } catch (error) {
      throw error;
    }
  }

  /**
   * Supprimer un fournisseur
   */
  async delete(id) {
    try {
      // Vérifier si le fournisseur existe
      await this.getById(id);

      await pool.query('DELETE FROM suppliers WHERE id = $1', [id]);

      return { message: 'Fournisseur supprimé avec succès' };
    } catch (error) {
      throw error;
    }
  }

  /**
   * Changer le statut d'un fournisseur
   */
  async changeStatus(id, status) {
    try {
      if (!['active', 'inactive'].includes(status)) {
        throw new Error('Statut invalide. Utilisez "active" ou "inactive"');
      }

      const result = await pool.query(
        `UPDATE suppliers
         SET status = $1, updated_at = CURRENT_TIMESTAMP
         WHERE id = $2
         RETURNING *`,
        [status, id]
      );

      if (result.rows.length === 0) {
        throw new Error('Fournisseur introuvable');
      }

      return Supplier.fromDB(result.rows[0]);
    } catch (error) {
      throw error;
    }
  }
}

module.exports = new SupplierService();
