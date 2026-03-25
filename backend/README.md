# 🛍️ Backend E-commerce - API REST

Backend complet pour application e-commerce Flutter vendant des téléphones, PC portables et gadgets électroniques.

## 📋 Table des matières

- [Technologies](#technologies)
- [Fonctionnalités](#fonctionnalités)
- [Installation](#installation)
- [Configuration](#configuration)
- [Démarrage](#démarrage)
- [Documentation API](#documentation-api)
- [Structure du projet](#structure-du-projet)

## 🚀 Technologies

- **Node.js** - Runtime JavaScript
- **Express.js** - Framework web
- **PostgreSQL** - Base de données relationnelle
- **JWT** - Authentification sécurisée
- **bcrypt** - Hash des mots de passe
- **Multer** - Upload de fichiers
- **express-validator** - Validation des données

## ✨ Fonctionnalités

### Authentification
- ✅ Inscription et connexion sécurisées
- ✅ Gestion de profil utilisateur
- ✅ Changement de mot de passe
- ✅ Rôles : `user` et `admin`
- ✅ Protection JWT pour les routes privées

### Produits
- ✅ CRUD complet (Admin uniquement pour CUD)
- ✅ Pagination et filtres avancés
- ✅ Recherche par nom/description
- ✅ Filtrage par catégorie, prix, marque
- ✅ Upload d'images produits
- ✅ Gestion des stocks

### Panier
- ✅ Ajouter/Modifier/Supprimer des articles
- ✅ Calcul automatique des totaux
- ✅ Vérification des stocks en temps réel

### Commandes
- ✅ Créer une commande depuis le panier
- ✅ Historique des commandes utilisateur
- ✅ Gestion des statuts (pending, confirmed, shipped, delivered, cancelled)
- ✅ Annulation avec restauration des stocks
- ✅ Panel admin pour gérer toutes les commandes

## 📦 Installation

### Prérequis

- Node.js (v14 ou supérieur)
- PostgreSQL (v12 ou supérieur)
- DBeaver ou pgAdmin (pour gérer la base de données)

### Étapes d'installation

1. **Installer les dépendances**

```powershell
cd backend
npm install
```

2. **Configurer PostgreSQL**

- Ouvrez **DBeaver** et connectez-vous à votre serveur PostgreSQL
- Ouvrez le fichier `database/schema.sql`
- Exécutez le script SQL complet pour :
  - Créer la base de données `ecommerce_db`
  - Créer toutes les tables (users, products, categories, cart_items, orders, order_items)
  - Insérer les données de test (catégories et produits)
  - Créer un compte admin par défaut

3. **Configurer les variables d'environnement**

Copiez le fichier `.env.example` en `.env` :

```powershell
Copy-Item .env.example .env
```

Modifiez le fichier `.env` avec vos informations :

```env
# Configuration du serveur
PORT=3000
NODE_ENV=development

# Configuration PostgreSQL
DB_HOST=localhost
DB_PORT=5432
DB_USER=postgres
DB_PASSWORD=votre_mot_de_passe
DB_NAME=ecommerce_db

# Configuration JWT
JWT_SECRET=votre_secret_jwt_super_securise_changez_moi
JWT_EXPIRES_IN=7d

# Configuration des uploads
UPLOAD_PATH=./uploads
MAX_FILE_SIZE=5242880
```

## 🎯 Configuration

### Compte Admin par défaut

Après avoir exécuté le script SQL, un compte admin est créé :

- **Email**: `admin@ecommerce.com`
- **Mot de passe**: `admin123`

⚠️ **Important** : Changez ce mot de passe en production !

### Compte Utilisateur de test

Un compte utilisateur est également créé :

- **Email**: `user@test.com`
- **Mot de passe**: `user123`

## 🚀 Démarrage

### Mode développement (avec auto-reload)

```powershell
npm run dev
```

### Mode production

```powershell
npm start
```

Le serveur démarre sur `http://localhost:3000`

Pour vérifier que le serveur fonctionne :

```powershell
curl http://localhost:3000/health
```

## 📚 Documentation API

### Base URL

```
http://localhost:3000/api
```

### Authentification

Toutes les routes protégées nécessitent un token JWT dans l'en-tête :

```
Authorization: Bearer <votre_token_jwt>
```

---

## 🔐 Endpoints Authentification

### Inscription

```http
POST /api/auth/register
Content-Type: application/json

{
  "email": "john@example.com",
  "password": "password123",
  "full_name": "John Doe",
  "phone": "+33612345678"
}
```

**Réponse** :
```json
{
  "success": true,
  "message": "Inscription réussie",
  "data": {
    "user": {
      "id": 1,
      "email": "john@example.com",
      "full_name": "John Doe",
      "phone": "+33612345678",
      "role": "user"
    },
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
}
```

### Connexion

```http
POST /api/auth/login
Content-Type: application/json

{
  "email": "john@example.com",
  "password": "password123"
}
```

### Profil utilisateur

```http
GET /api/auth/profile
Authorization: Bearer <token>
```

### Mettre à jour le profil

```http
PUT /api/auth/profile
Authorization: Bearer <token>
Content-Type: application/json

{
  "full_name": "John Smith",
  "phone": "+33698765432"
}
```

### Changer le mot de passe

```http
POST /api/auth/change-password
Authorization: Bearer <token>
Content-Type: application/json

{
  "currentPassword": "password123",
  "newPassword": "newpassword456"
}
```

---

## 📱 Endpoints Produits

### Liste des produits (avec filtres)

```http
GET /api/products?page=1&limit=20&category_id=1&min_price=100&max_price=1000&search=iphone&brand=Apple&sort_by=price&sort_order=ASC
```

**Paramètres de requête** :
- `page` (optionnel) : Numéro de page (défaut: 1)
- `limit` (optionnel) : Nombre d'éléments par page (défaut: 20)
- `category_id` (optionnel) : Filtrer par catégorie
- `min_price` (optionnel) : Prix minimum
- `max_price` (optionnel) : Prix maximum
- `search` (optionnel) : Recherche dans le nom et la description
- `brand` (optionnel) : Filtrer par marque
- `sort_by` (optionnel) : Trier par (name, price, created_at, stock_quantity)
- `sort_order` (optionnel) : ASC ou DESC

**Réponse** :
```json
{
  "success": true,
  "message": "Produits récupérés",
  "data": [
    {
      "id": 1,
      "name": "iPhone 15 Pro Max",
      "description": "Le dernier flagship Apple...",
      "price": 1299.99,
      "stock_quantity": 50,
      "category_id": 1,
      "category_name": "Smartphones",
      "image_url": "https://example.com/iphone15promax.jpg",
      "brand": "Apple",
      "specifications": {
        "ram": "8GB",
        "storage": "256GB",
        "screen": "6.7 inches"
      },
      "is_active": true,
      "created_at": "2025-11-20T10:00:00.000Z"
    }
  ],
  "pagination": {
    "currentPage": 1,
    "itemsPerPage": 20,
    "totalItems": 18,
    "totalPages": 1,
    "hasNextPage": false,
    "hasPreviousPage": false
  }
}
```

### Détails d'un produit

```http
GET /api/products/:id
```

### Liste des catégories

```http
GET /api/products/categories/all
```

### Liste des marques

```http
GET /api/products/brands/all
```

### Créer un produit (Admin)

```http
POST /api/products
Authorization: Bearer <admin_token>
Content-Type: multipart/form-data

{
  "name": "Samsung Galaxy S24",
  "description": "Smartphone premium Samsung",
  "price": 899.99,
  "stock_quantity": 30,
  "category_id": 1,
  "brand": "Samsung",
  "specifications": {
    "ram": "12GB",
    "storage": "256GB"
  },
  "image": <fichier_image>
}
```

### Mettre à jour un produit (Admin)

```http
PUT /api/products/:id
Authorization: Bearer <admin_token>
Content-Type: multipart/form-data

{
  "price": 849.99,
  "stock_quantity": 25,
  "image": <nouveau_fichier_image_optionnel>
}
```

### Supprimer un produit (Admin)

```http
DELETE /api/products/:id
Authorization: Bearer <admin_token>
```

---

## 🛒 Endpoints Panier

### Voir le panier

```http
GET /api/cart
Authorization: Bearer <token>
```

**Réponse** :
```json
{
  "success": true,
  "message": "Panier récupéré",
  "data": {
    "items": [
      {
        "id": 1,
        "quantity": 2,
        "product_id": 1,
        "name": "iPhone 15 Pro Max",
        "price": 1299.99,
        "image_url": "...",
        "subtotal": 2599.98
      }
    ],
    "total": 2599.98,
    "itemCount": 1
  }
}
```

### Ajouter au panier

```http
POST /api/cart
Authorization: Bearer <token>
Content-Type: application/json

{
  "product_id": 1,
  "quantity": 2
}
```

### Modifier la quantité

```http
PUT /api/cart/:cart_item_id
Authorization: Bearer <token>
Content-Type: application/json

{
  "quantity": 3
}
```

### Supprimer un article

```http
DELETE /api/cart/:cart_item_id
Authorization: Bearer <token>
```

### Vider le panier

```http
DELETE /api/cart
Authorization: Bearer <token>
```

---

## 📦 Endpoints Commandes

### Créer une commande

```http
POST /api/orders
Authorization: Bearer <token>
Content-Type: application/json

{
  "shipping_address": "123 Rue de la Paix, 75001 Paris, France",
  "phone": "+33612345678",
  "notes": "Livraison entre 14h et 18h"
}
```

**Note** : La commande est créée à partir du contenu actuel du panier.

### Liste des commandes de l'utilisateur

```http
GET /api/orders?page=1&limit=20&status=pending
Authorization: Bearer <token>
```

**Paramètres** :
- `page` (optionnel) : Numéro de page
- `limit` (optionnel) : Nombre d'éléments par page
- `status` (optionnel) : Filtrer par statut (pending, confirmed, shipped, delivered, cancelled)

### Détails d'une commande

```http
GET /api/orders/:order_id
Authorization: Bearer <token>
```

**Réponse** :
```json
{
  "success": true,
  "message": "Commande récupérée",
  "data": {
    "id": 1,
    "user_id": 2,
    "total_amount": 2599.98,
    "status": "pending",
    "shipping_address": "123 Rue de la Paix...",
    "phone": "+33612345678",
    "notes": "Livraison entre 14h et 18h",
    "created_at": "2025-11-20T14:30:00.000Z",
    "full_name": "John Doe",
    "email": "john@example.com",
    "items": [
      {
        "id": 1,
        "quantity": 2,
        "unit_price": 1299.99,
        "subtotal": 2599.98,
        "product_id": 1,
        "name": "iPhone 15 Pro Max",
        "image_url": "...",
        "brand": "Apple"
      }
    ]
  }
}
```

### Annuler une commande

```http
POST /api/orders/:order_id/cancel
Authorization: Bearer <token>
```

### Liste de toutes les commandes (Admin)

```http
GET /api/orders/admin/all?page=1&limit=20&status=pending&user_id=2
Authorization: Bearer <admin_token>
```

### Mettre à jour le statut (Admin)

```http
PUT /api/orders/:order_id/status
Authorization: Bearer <admin_token>
Content-Type: application/json

{
  "status": "shipped"
}
```

**Statuts disponibles** :
- `pending` : En attente
- `confirmed` : Confirmée
- `shipped` : Expédiée
- `delivered` : Livrée
- `cancelled` : Annulée

---

## 📁 Structure du projet

```
backend/
├── src/
│   ├── config/
│   │   ├── config.js           # Configuration générale
│   │   └── database.js         # Connexion PostgreSQL
│   ├── controllers/
│   │   ├── authController.js   # Contrôleur authentification
│   │   ├── productController.js # Contrôleur produits
│   │   ├── cartController.js   # Contrôleur panier
│   │   └── orderController.js  # Contrôleur commandes
│   ├── services/
│   │   ├── authService.js      # Logique métier auth
│   │   ├── productService.js   # Logique métier produits
│   │   ├── cartService.js      # Logique métier panier
│   │   └── orderService.js     # Logique métier commandes
│   ├── routes/
│   │   ├── authRoutes.js       # Routes authentification
│   │   ├── productRoutes.js    # Routes produits
│   │   ├── cartRoutes.js       # Routes panier
│   │   └── orderRoutes.js      # Routes commandes
│   ├── middleware/
│   │   ├── auth.js             # Middleware JWT
│   │   ├── validate.js         # Middleware validation
│   │   ├── errorHandler.js     # Gestion des erreurs
│   │   └── upload.js           # Upload d'images (Multer)
│   ├── utils/
│   │   └── response.js         # Réponses standardisées
│   └── server.js               # Point d'entrée du serveur
├── database/
│   └── schema.sql              # Script SQL complet
├── uploads/                    # Dossier des images uploadées
├── .env                        # Variables d'environnement
├── .env.example                # Exemple de configuration
├── .gitignore
├── package.json
└── README.md                   # Ce fichier
```

## 🔒 Sécurité

- ✅ Mots de passe hashés avec bcrypt (10 rounds)
- ✅ JWT avec expiration configurable
- ✅ Validation des entrées côté serveur
- ✅ Protection contre les injections SQL (paramètres préparés)
- ✅ Helmet.js pour les headers de sécurité
- ✅ CORS configuré
- ✅ Vérification des rôles (user/admin)
- ✅ Limite de taille des fichiers uploadés

## 🛠️ Codes d'erreur HTTP

- `200` : Succès
- `201` : Ressource créée
- `400` : Requête invalide
- `401` : Non authentifié
- `403` : Accès interdit
- `404` : Ressource non trouvée
- `500` : Erreur serveur

## 📝 Notes importantes

1. **Hashes de mots de passe** : Les mots de passe dans le script SQL (`admin123` et `user123`) doivent être hashés avec bcrypt avant utilisation en production. Pour générer un hash :

```javascript
const bcrypt = require('bcrypt');
const hash = await bcrypt.hash('votre_mot_de_passe', 10);
console.log(hash);
```

2. **JWT Secret** : Changez la valeur de `JWT_SECRET` dans le fichier `.env` par une valeur aléatoire et sécurisée.

3. **Base de données** : Assurez-vous que PostgreSQL est en cours d'exécution et que les informations de connexion dans `.env` sont correctes.

4. **Upload d'images** : Le dossier `uploads/` stocke les images. En production, utilisez un service cloud (AWS S3, Cloudinary, etc.).

5. **CORS** : Modifiez la configuration CORS dans `server.js` pour autoriser uniquement votre frontend Flutter en production.

## 🐛 Dépannage

### Erreur de connexion PostgreSQL

Vérifiez :
- PostgreSQL est démarré
- Les informations de connexion dans `.env` sont correctes
- Le firewall autorise la connexion au port 5432

### Erreur "JWT Secret not defined"

Assurez-vous que le fichier `.env` existe et contient `JWT_SECRET`.

### Port déjà utilisé

Changez le port dans `.env` ou arrêtez l'application utilisant le port 3000.

## 🚀 Prochaines étapes

Pour connecter ce backend à votre application Flutter :

1. Utilisez le package `http` ou `dio` dans Flutter
2. Stockez le JWT dans `SharedPreferences` ou `secure_storage`
3. Ajoutez le token dans l'en-tête `Authorization` pour chaque requête protégée

Exemple Flutter :

```dart
final response = await http.get(
  Uri.parse('http://localhost:3000/api/products'),
  headers: {
    'Authorization': 'Bearer $token',
    'Content-Type': 'application/json',
  },
);
```

## 📧 Support

Pour toute question ou problème, créez une issue dans le repository.

---

**Développé avec ❤️ pour votre application e-commerce Flutter**
