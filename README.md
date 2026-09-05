# eFoot Arena

**Compete. Dominate. Rise.**

Plateforme compétitive eFootball Mobile — Afrique → International.

## Stack

- **Mobile** : Flutter (Riverpod, GoRouter, Firebase)
- **Web** : Next.js (landing)
- **Backend** : Firebase (Auth, Firestore, Storage, FCM, Cloud Functions)

## Fonctionnalités (MVP+)

| Module | Description |
|--------|-------------|
| Auth | Email, Google, onboarding, mot de passe oublié |
| Home | Stats, actions rapides, activité récente |
| Profil | Stats, édition, avatar, Premium badge |
| Défis 1v1 | Créer, accepter, score, matchmaking auto |
| Équipes | Créer, rejoindre, logo, kick |
| Clan Wars | Battles inter-équipes |
| Classement | Mondial / région / pays |
| Tournois | Créer, inscrire, démarrer, vainqueur |
| Chat | Salon communautaire temps réel |
| Highlights | Publier images / likes |
| Marketplace | Annonces coaching / comptes |
| Premium | Freemium (activation test 30j) |
| Notifications | FCM + file `notification_queue` |
| Réglages | Hub vers toutes les sections |

## Lancer l'app mobile

```bash
git clone https://github.com/GoraDevProAi/Efoot-Arena.git
cd Efoot-Arena/mobile

# Générer android/ ios/ si absents
flutter create . --project-name efoot_arena --org com.efootarena

# Vérifier applicationId = com.efootarena.app
flutter pub get
flutter run
```

Voir aussi : [docs/RUN_APP.md](docs/RUN_APP.md) · [docs/SETUP.md](docs/SETUP.md)

## Firebase

Projet : `efoot-arena-c288b`

À activer :
1. Authentication (Email + Google)
2. Firestore + déployer `firebase/firestore.rules`
3. Storage + `firebase/storage.rules`
4. Cloud Messaging
5. Cloud Functions (plan Blaze) pour les push — `firebase/functions`

```bash
firebase deploy --only firestore:rules,storage
cd firebase/functions && npm install && firebase deploy --only functions
```

## Structure

```
efoot-arena/
├── mobile/          # Flutter app
├── web/             # Next.js landing
├── firebase/        # rules + functions
├── docs/            # guides
└── shared/          # (réservé)
```

## Repo

https://github.com/GoraDevProAi/Efoot-Arena
