# Elles - Assistant Santé Intime Africain

Une application mobile inspirée par l'Afrique pour aider les femmes à suivre leur cycle menstruel, fertilité et santé intime.

## 🌸 Fonctionnalités

- **Calendrier Menstruel Intelligent**: Suivi automatique des cycles avec calculs de fertilité
- **Prédictions Avancées**: Ovulation, fenêtre fertile, et jours sûrs
- **Suivi d'Intimité**: Marquage des rapports avec des icônes ❤️
- **Interface Africaine**: Design inspiré par les tons terreux et les traditions africaines
- **Texte en Français**: Interface entièrement localisée pour l'audience africaine

## 🛠️ Stack Technologique

### Backend (FastAPI + MySQL)
- **FastAPI**: Framework web moderne et rapide
- **MySQL**: Base de données robuste
- **SQLAlchemy**: ORM pour la gestion des données
- **Pydantic**: Validation et sérialisation des données

### Frontend (Flutter)
- **Flutter**: Framework mobile cross-platform
- **Material Design**: Composants UI adaptatifs
- **Animations**: Transitions fluides avec flutter_staggered_animations
- **Calendrier**: Widget table_calendar pour l'affichage mensuel

## 🎨 Design Africain

### Palette de Couleurs
- **Brun Principal**: `#8B4513` - Couleur principale UI
- **Fond Crème**: `#FFF8E7` - Arrière-plan du calendrier
- **Règles**: `#A0522D` - Période menstruelle
- **Fertilité**: `#228B22` - Jours fertiles
- **Ovulation**: `#DAA520` - Jour d'ovulation
- **Jours Sûrs**: `#87CEEB` - Jours non-fertiles

### Éléments Visuels
- Tons terreux chauds
- UI arrondie et douce
- Ombres de style africain
- Transitions graduelles
- Animations pulse et glow

## 🚀 Installation

### Backend
```bash
cd backend
pip install -r requirements.txt
python run.py
```

### Frontend
```bash
cd elle
flutter pub get
flutter run
```

## 📱 Structure de l'Application

### Backend (Python)
```
backend/
├── main.py              # Points d'entrée API
├── database.py          # Modèles et configuration DB
├── schemas.py           # Schémas Pydantic
├── cycle_calculator.py  # Logique de calcul de cycle
├── requirements.txt     # Dépendances Python
└── run.py              # Script de démarrage
```

### Frontend (Flutter)
```
elle/lib/
├── models/             # Modèles de données
├── services/           # Services API
├── screens/            # Écrans principaux
├── widgets/            # Composants réutilisables
├── utils/              # Thème et utilitaires
└── main.dart           # Point d'entrée Flutter
```

## 🔄 Calculs de Cycle

### Algorithme Standard
- **Ovulation**: `date_début + (durée_cycle - 14)`
- **Fenêtre Fertile**: `[ovulation - 4 jours à ovulation + 1 jour]`
- **Période Menstruelle**: `date_début à date_début + durée_règles`
- **Jours Sûrs**: Jours non-fertiles et non-menstruels

### Données Suivies
- Date de début du cycle
- Durée moyenne du cycle (21-35 jours)
- Durée des règles (3-8 jours)
- Dates des rapports intimes

## 🌍 Localisation

- **Langue**: Français (locale fr_FR)
- **Messages**: Tous les textes utilisateur en français
- **Calendrier**: Format de date européen
- **Culturellement Adapté**: Terminologie respectueuse et appropriée

## 🎯 Messages Utilisateur

- **Règles**: "Période de règles en cours"
- **Fertilité**: "Aujourd'hui est un jour fertile 🌿"
- **Ovulation**: "Jour d'ovulation 🌟"
- **Prédictions**: "Les règles devraient commencer demain 🩸"

## 📊 API Endpoints

### Cycles
- `POST /cycles/` - Créer un nouveau cycle
- `GET /cycles/{user_id}` - Obtenir les calculs de cycle
- `POST /cycles/{user_id}/intercourse` - Basculer le statut d'intimité

### Réponses
- Toutes les réponses incluent les calculs automatiques
- Gestion d'erreurs en français
- Validation des données d'entrée

## 🔮 Fonctionnalités Futures

- **IA Prédictive**: Apprentissage automatique pour les prédictions
- **Notifications**: Rappels de cycle et de fertilité
- **Santé Globale**: Suivi des symptômes et de l'humeur
- **Communauté**: Partage d'expériences entre utilisatrices
- **Multi-langues**: Support pour langues locales africaines

## 🤝 Contribution

Cette application est conçue pour servir les femmes africaines avec respect et sensibilité culturelle. Les contributions sont les bienvenues pour améliorer l'expérience utilisateur et ajouter des fonctionnalités adaptées aux besoins locaux.

## 📝 Licence

Ce projet est développé pour l'autonomisation des femmes africaines dans leur santé intime et reproductive.