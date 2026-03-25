# Flutter E-Commerce

Application e-commerce mobile complète avec:
- Un frontend Flutter pour l'experience utilisateur.
- Un backend Node.js/Express pour l'API REST.
- Une base SQL pour stocker produits, paniers, commandes et comptes.

Le projet est structure en deux parties principales:
- `frontend/`: application mobile Flutter.
- `backend/`: serveur API + logique metier.

## Ce que fait l'application

L'application permet de gerer un mini-ecosysteme e-commerce de bout en bout:
- Authentification des utilisateurs (inscription/connexion selon endpoints exposes).
- Consultation du catalogue produits.
- Gestion du panier.
- Passage et suivi des commandes.
- Gestion des fournisseurs cote administration/backend.
- Gestion d'images produit via upload cote API.

## Fonctionnalites principales

### Cote utilisateur
- Navigation dans les produits.
- Ajout/suppression/modification des articles dans le panier.
- Creation de commande a partir du panier.
- Consultation de l'historique ou des details de commande (selon l'ecran implemente).

### Cote API (backend)
- Endpoints d'authentification.
- Endpoints produits.
- Endpoints panier.
- Endpoints commandes.
- Endpoints fournisseurs.
- Middleware de validation, authentification, gestion d'erreurs et upload.

## Stack technique

### Frontend
- Flutter / Dart.
- Organisation en couches (`presentation`, `data`, `domain`).
- Dossier `blocs/` pour la gestion d'etat.
- Dossier `screens/` pour les pages.
- Dossier `widgets/` pour les composants reutilisables.

### Backend
- Node.js + Express.
- Architecture par couches:
- `routes` pour les routes HTTP.
- `controllers` pour le traitement des requetes.
- `services` pour la logique metier.
- `middleware` pour auth/validation/erreurs/upload.
- `config` pour la configuration applicative et base de donnees.
- SQL schema fourni dans `backend/database/schema.sql`.

## Demarrage rapide

## Prerequis
- Flutter SDK installe et configure.
- Node.js (v14 ou plus recommande).
- npm.
- Base de donnees SQL (MySQL/MariaDB).

## 1) Lancer le backend

```bash
cd backend
npm install
npm start
```

Si besoin, adapter la configuration base/API dans les fichiers de `backend/src/config/`.

## 2) Lancer le frontend

```bash
cd frontend
flutter pub get
flutter run
```

## Structure du projet

```text
.
├── backend/
│   ├── database/
│   │   └── schema.sql
│   ├── src/
│   │   ├── config/
│   │   ├── controllers/
│   │   ├── middleware/
│   │   ├── models/
│   │   ├── routes/
│   │   ├── services/
│   │   └── utils/
│   └── uploads/
└── frontend/
    ├── lib/
    │   ├── core/
    │   ├── data/
    │   ├── domain/
    │   └── presentation/
    ├── test/
    └── web/
```

## Endpoints API (resume)

Les routes sont organisees par module dans `backend/src/routes/`:
- `authRoutes.js`
- `productRoutes.js`
- `cartRoutes.js`
- `orderRoutes.js`
- `supplierRoutes.js`

Consulte les fichiers de routes/controllers pour le detail exact des URLs, methodes et payloads.

## Statut du projet

Projet en cours de developpement. La base architecturelle est en place avec separation claire frontend/backend et modules metier principaux.

## Licence

MIT
