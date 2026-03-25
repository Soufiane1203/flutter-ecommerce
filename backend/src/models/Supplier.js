/**
 * Modèle Supplier (Fournisseur)
 * Représente un fournisseur de produits
 */

class Supplier {
  constructor({ id, name, email, phone, address, status, created_at, updated_at }) {
    this.id = id;
    this.name = name;
    this.email = email;
    this.phone = phone;
    this.address = address;
    this.status = status || 'active';
    this.createdAt = created_at;
    this.updatedAt = updated_at;
  }

  /**
   * Convertir l'objet en format JSON
   */
  toJSON() {
    return {
      id: this.id,
      name: this.name,
      email: this.email,
      phone: this.phone,
      address: this.address,
      status: this.status,
      createdAt: this.createdAt,
      updatedAt: this.updatedAt,
    };
  }

  /**
   * Créer une instance depuis les données de la DB
   */
  static fromDB(row) {
    return new Supplier(row);
  }
}

module.exports = Supplier;
