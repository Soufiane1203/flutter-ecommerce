-- ============================================
-- Script SQL pour E-commerce Database
-- Base de données PostgreSQL
-- À exécuter dans DBeaver
-- ============================================

-- Supprimer la base de données si elle existe (optionnel)
-- DROP DATABASE IF EXISTS ecommerce_db;

-- Créer la base de données
CREATE DATABASE ecommerce_db;

-- Se connecter à la base de données ecommerce_db avant d'exécuter le reste

-- ============================================
-- TABLE: users
-- Gestion des utilisateurs (clients et admins)
-- ============================================
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(255) NOT NULL,
    phone VARCHAR(50),
    role VARCHAR(20) NOT NULL DEFAULT 'user' CHECK (role IN ('user', 'admin')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Index pour améliorer les performances
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_role ON users(role);

-- ============================================
-- TABLE: suppliers (Fournisseurs)
-- Gestion des fournisseurs de produits
-- ============================================
CREATE TABLE suppliers (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE,
    phone VARCHAR(50),
    address TEXT,
    status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'inactive')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_suppliers_status ON suppliers(status);

-- ============================================
-- TABLE: categories
-- Catégories de produits
-- ============================================
CREATE TABLE categories (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- TABLE: products
-- Produits (téléphones, PC, gadgets)
-- ============================================
CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(10, 2) NOT NULL CHECK (price >= 0),
    stock_quantity INTEGER NOT NULL DEFAULT 0 CHECK (stock_quantity >= 0),
    category_id INTEGER REFERENCES categories(id) ON DELETE SET NULL,
    image_url VARCHAR(500),
    brand VARCHAR(100),
    specifications JSONB, -- Stockage flexible pour les spécifications techniques
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Index pour améliorer les performances
CREATE INDEX idx_products_category ON products(category_id);
CREATE INDEX idx_products_price ON products(price);
CREATE INDEX idx_products_name ON products(name);
CREATE INDEX idx_products_active ON products(is_active);

-- ============================================
-- TABLE: cart_items
-- Panier d'achat des utilisateurs
-- ============================================
CREATE TABLE cart_items (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    product_id INTEGER NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    quantity INTEGER NOT NULL DEFAULT 1 CHECK (quantity > 0),
    added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, product_id) -- Un produit ne peut être qu'une seule fois dans le panier
);

-- Index pour améliorer les performances
CREATE INDEX idx_cart_user ON cart_items(user_id);
CREATE INDEX idx_cart_product ON cart_items(product_id);

-- ============================================
-- TABLE: orders
-- Commandes passées par les utilisateurs
-- ============================================
CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    total_amount DECIMAL(10, 2) NOT NULL CHECK (total_amount >= 0),
    status VARCHAR(50) NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'confirmed', 'shipped', 'delivered', 'cancelled')),
    shipping_address TEXT NOT NULL,
    phone VARCHAR(50) NOT NULL,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Index pour améliorer les performances
CREATE INDEX idx_orders_user ON orders(user_id);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_orders_created ON orders(created_at DESC);

-- ============================================
-- TABLE: order_items
-- Détails des produits dans chaque commande
-- ============================================
CREATE TABLE order_items (
    id SERIAL PRIMARY KEY,
    order_id INTEGER NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    product_id INTEGER NOT NULL REFERENCES products(id) ON DELETE RESTRICT,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    unit_price DECIMAL(10, 2) NOT NULL CHECK (unit_price >= 0),
    subtotal DECIMAL(10, 2) NOT NULL CHECK (subtotal >= 0)
);

-- Index pour améliorer les performances
CREATE INDEX idx_order_items_order ON order_items(order_id);
CREATE INDEX idx_order_items_product ON order_items(product_id);

-- ============================================
-- TRIGGERS pour updated_at
-- ============================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_products_updated_at BEFORE UPDATE ON products
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_orders_updated_at BEFORE UPDATE ON orders
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- DONNÉES DE TEST
-- ============================================

-- Insertion des catégories
INSERT INTO categories (name, description) VALUES
('Smartphones', 'Téléphones mobiles de dernière génération'),
('Laptops', 'Ordinateurs portables pour tous les besoins'),
('Tablets', 'Tablettes tactiles'),
('Accessories', 'Accessoires et gadgets électroniques'),
('Smartwatches', 'Montres connectées');

-- Insertion d'un utilisateur admin (mot de passe: admin123)
-- Hash bcrypt pour 'admin123'
INSERT INTO users (email, password_hash, full_name, phone, role) VALUES
('admin@ecommerce.com', '$2b$10$8Z8vXq5Y5YqW5Y5Y5Y5Y5uO5Y5Y5Y5Y5Y5Y5Y5Y5Y5Y5Y5Y5Y5Y5Y', 'Admin Principal', '+33612345678', 'admin');

-- Insertion d'un utilisateur test (mot de passe: user123)
-- Hash bcrypt pour 'user123'
INSERT INTO users (email, password_hash, full_name, phone, role) VALUES
('user@test.com', '$2b$10$9A9wYr6Z6ZrX6Z6Z6Z6Z6uP6Z6Z6Z6Z6Z6Z6Z6Z6Z6Z6Z6Z6Z6Z6Z', 'John Doe', '+33698765432', 'user');

-- Insertion de produits de test
INSERT INTO products (name, description, price, stock_quantity, category_id, image_url, brand, specifications) VALUES
-- Smartphones
('iPhone 15 Pro Max', 'Le dernier flagship Apple avec puce A17 Pro, écran Super Retina XDR 6.7" et système photo professionnel', 1299.99, 50, 1, 'https://example.com/iphone15promax.jpg', 'Apple', '{"ram": "8GB", "storage": "256GB", "screen": "6.7 inches", "battery": "4422 mAh", "processor": "A17 Pro"}'),
('Samsung Galaxy S24 Ultra', 'Smartphone premium avec S Pen intégré, écran Dynamic AMOLED 6.8" et appareil photo 200MP', 1199.99, 45, 1, 'https://example.com/galaxys24ultra.jpg', 'Samsung', '{"ram": "12GB", "storage": "512GB", "screen": "6.8 inches", "battery": "5000 mAh", "processor": "Snapdragon 8 Gen 3"}'),
('Google Pixel 8 Pro', 'Intelligence artificielle avancée, photographie exceptionnelle avec Tensor G3', 899.99, 60, 1, 'https://example.com/pixel8pro.jpg', 'Google', '{"ram": "12GB", "storage": "256GB", "screen": "6.7 inches", "battery": "5050 mAh", "processor": "Google Tensor G3"}'),
('OnePlus 12', 'Performance flagship avec écran 120Hz et charge rapide 100W', 799.99, 40, 1, 'https://example.com/oneplus12.jpg', 'OnePlus', '{"ram": "16GB", "storage": "512GB", "screen": "6.82 inches", "battery": "5400 mAh", "processor": "Snapdragon 8 Gen 3"}'),
('Xiaomi 14 Pro', 'Appareil photo Leica, écran AMOLED 120Hz et charge sans fil 50W', 699.99, 55, 1, 'https://example.com/xiaomi14pro.jpg', 'Xiaomi', '{"ram": "12GB", "storage": "256GB", "screen": "6.73 inches", "battery": "4880 mAh", "processor": "Snapdragon 8 Gen 3"}'),

-- Laptops
('MacBook Pro 16" M3 Pro', 'Puissance professionnelle avec puce M3 Pro, écran Liquid Retina XDR et autonomie exceptionnelle', 2499.99, 30, 2, 'https://example.com/macbookpro16.jpg', 'Apple', '{"ram": "18GB", "storage": "512GB SSD", "screen": "16 inches", "processor": "M3 Pro", "graphics": "GPU 18-core"}'),
('Dell XPS 15', 'Ultrabook premium avec écran InfinityEdge 4K et performances professionnelles', 1899.99, 25, 2, 'https://example.com/dellxps15.jpg', 'Dell', '{"ram": "32GB", "storage": "1TB SSD", "screen": "15.6 inches", "processor": "Intel Core i9-13900H", "graphics": "NVIDIA RTX 4060"}'),
('ASUS ROG Zephyrus G16', 'PC gaming portable avec écran 240Hz et RTX 4080', 2299.99, 20, 2, 'https://example.com/rogzephyrus.jpg', 'ASUS', '{"ram": "32GB", "storage": "2TB SSD", "screen": "16 inches", "processor": "Intel Core i9-13900H", "graphics": "NVIDIA RTX 4080"}'),
('HP Spectre x360 14', 'Convertible élégant avec écran tactile OLED et design premium', 1599.99, 35, 2, 'https://example.com/hpspectre.jpg', 'HP', '{"ram": "16GB", "storage": "1TB SSD", "screen": "14 inches", "processor": "Intel Core i7-1355U", "graphics": "Intel Iris Xe"}'),
('Lenovo ThinkPad X1 Carbon Gen 11', 'Ultraportable professionnel robuste et performant', 1799.99, 28, 2, 'https://example.com/thinkpadx1.jpg', 'Lenovo', '{"ram": "16GB", "storage": "512GB SSD", "screen": "14 inches", "processor": "Intel Core i7-1365U", "graphics": "Intel Iris Xe"}'),

-- Tablets
('iPad Pro 12.9" M2', 'Tablette ultra-puissante avec puce M2 et écran Liquid Retina XDR', 1099.99, 40, 3, 'https://example.com/ipadpro.jpg', 'Apple', '{"ram": "8GB", "storage": "256GB", "screen": "12.9 inches", "processor": "M2"}'),
('Samsung Galaxy Tab S9 Ultra', 'Tablette Android premium avec écran AMOLED géant et S Pen', 999.99, 35, 3, 'https://example.com/tabs9ultra.jpg', 'Samsung', '{"ram": "12GB", "storage": "512GB", "screen": "14.6 inches", "processor": "Snapdragon 8 Gen 2"}'),

-- Accessories
('AirPods Pro 2', 'Écouteurs sans fil avec réduction de bruit active et audio spatial', 279.99, 100, 4, 'https://example.com/airpodspro2.jpg', 'Apple', '{"battery": "6h + 30h case", "connectivity": "Bluetooth 5.3", "features": "ANC, Spatial Audio"}'),
('Sony WH-1000XM5', 'Casque audio premium avec la meilleure réduction de bruit', 399.99, 75, 4, 'https://example.com/sonywh1000xm5.jpg', 'Sony', '{"battery": "30h", "connectivity": "Bluetooth 5.2", "features": "ANC, LDAC"}'),
('Anker PowerBank 20000mAh', 'Batterie externe haute capacité avec charge rapide PD 30W', 59.99, 150, 4, 'https://example.com/ankerpowerbank.jpg', 'Anker', '{"capacity": "20000mAh", "output": "30W PD", "ports": "USB-C + USB-A"}'),
('Logitech MX Master 3S', 'Souris ergonomique professionnelle avec défilement ultra-rapide', 99.99, 80, 4, 'https://example.com/mxmaster3s.jpg', 'Logitech', '{"dpi": "8000", "battery": "70 days", "connectivity": "Bluetooth + USB"}'),

-- Smartwatches
('Apple Watch Series 9', 'Montre connectée avec écran always-on et suivi santé avancé', 449.99, 60, 5, 'https://example.com/applewatch9.jpg', 'Apple', '{"screen": "1.9 inches", "battery": "18h", "features": "ECG, Blood Oxygen, GPS"}'),
('Samsung Galaxy Watch 6', 'Montre connectée Wear OS avec suivi fitness complet', 349.99, 55, 5, 'https://example.com/galaxywatch6.jpg', 'Samsung', '{"screen": "1.5 inches", "battery": "40h", "features": "ECG, Body Composition, GPS"}'),
('Garmin Fenix 7', 'Montre GPS multisport avec autonomie exceptionnelle', 599.99, 30, 5, 'https://example.com/garminfenix7.jpg', 'Garmin', '{"screen": "1.3 inches", "battery": "18 days", "features": "GPS, Heart Rate, Altimeter"}');

-- ============================================
-- VÉRIFICATIONS
-- ============================================

-- Compter les enregistrements
SELECT 'Categories' as table_name, COUNT(*) as count FROM categories
UNION ALL
SELECT 'Users', COUNT(*) FROM users
UNION ALL
SELECT 'Products', COUNT(*) FROM products
UNION ALL
SELECT 'Suppliers', COUNT(*) FROM suppliers;

-- Données de test pour les fournisseurs
INSERT INTO suppliers (name, email, phone, address, status) VALUES
('TechSupply France', 'contact@techsupply.fr', '+33 1 40 50 60 70', '15 Avenue des Champs-Élysées, 75008 Paris', 'active'),
('Global Electronics', 'info@globalelectronics.com', '+33 1 45 67 89 00', '28 Rue de Rivoli, 75004 Paris', 'active'),
('Mobile World Distribution', 'sales@mobileworld.fr', '+33 4 78 90 12 34', '10 Place Bellecour, 69002 Lyon', 'active'),
('Gadget Pro Suppliers', 'contact@gadgetpro.fr', '+33 5 56 78 90 12', '45 Cours de l\'Intendance, 33000 Bordeaux', 'active'),
('PC Components France', 'info@pccomponents.fr', '+33 3 20 30 40 50', '8 Rue Faidherbe, 59000 Lille', 'inactive');

-- Afficher les produits par catégorie
SELECT 
    c.name as category,
    COUNT(p.id) as product_count
FROM categories c
LEFT JOIN products p ON c.id = p.category_id
GROUP BY c.name
ORDER BY product_count DESC;

-- ============================================
-- REQUÊTES UTILES POUR TESTER
-- ============================================

-- Voir tous les produits avec leur catégorie
-- SELECT p.id, p.name, p.price, p.stock_quantity, c.name as category 
-- FROM products p 
-- JOIN categories c ON p.category_id = c.id 
-- ORDER BY p.created_at DESC;

-- Voir le panier d'un utilisateur
-- SELECT ci.*, p.name, p.price, (p.price * ci.quantity) as total
-- FROM cart_items ci
-- JOIN products p ON ci.product_id = p.id
-- WHERE ci.user_id = 1;

-- Voir les commandes d'un utilisateur
-- SELECT o.*, u.full_name, u.email
-- FROM orders o
-- JOIN users u ON o.user_id = u.id
-- ORDER BY o.created_at DESC;
