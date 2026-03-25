# Flutter E-Commerce App

Une application e-commerce complète développée avec Flutter (frontend) et Node.js/Express (backend).

## 📱 Architecture

**Frontend (Flutter)**
- Architecture clean avec BLoC pattern
- Models et repositories pour la gestion des données
- UI réactive et responsive

**Backend (Node.js/Express)**
- API RESTful pour les produits, commandes, authentification
- Gestion des utilisateurs et suppliers
- Gestion des images et uploads

## 🚀 Installation

### Prérequis
- Flutter SDK
- Node.js >= 14
- MySQL/MariaDB

### Backend
```bash
cd backend
npm install
npm start
```

### Frontend
```bash
cd frontend
flutter pub get
flutter run
```

## 📁 Structure du projet

```
├── backend/          # API Node.js/Express
│   ├── src/
│   │   ├── controllers/
│   │   ├── routes/
│   │   ├── services/
│   │   └── models/
│   └── package.json
└── frontend/         # Application Flutter
    ├── lib/
    │   ├── presentation/
    │   ├── data/
    │   └── domain/
    └── pubspec.yaml
```

## 🔧 Configuration

Voir les fichiers `backend/.env` et `frontend/lib/core/constants/` pour la configuration.

## 📄 License

MIT
