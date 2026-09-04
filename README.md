# eFoot Arena

**Compete. Dominate. Rise.**

Plateforme compétitive eFootball Mobile — Afrique → International.

## Structure du projet

```
efoot-arena/
├── mobile/                 # Application Flutter (Android + iOS)
│   ├── lib/
│   │   ├── core/           # Theme, constants, services, router
│   │   ├── features/       # Auth, Profile, Teams, Challenges, Ranking, Home
│   │   └── shared/         # Models + Widgets réutilisables
│   ├── assets/
│   └── pubspec.yaml
│
├── web/                    # Site web Next.js 15 (App Router)
│   ├── src/
│   └── package.json
│
├── firebase/               # Configuration Firebase
│   ├── firestore.rules
│   └── (indexes, functions à venir)
│
├── shared/                 # Types / constantes partagés (futur)
└── docs/                   # Documentation
```

## Stack technique

| Partie          | Technologie                          |
|-----------------|--------------------------------------|
| Mobile          | Flutter + Riverpod + GoRouter        |
| Web             | Next.js 15 + TypeScript + Tailwind   |
| Backend         | Firebase (Auth, Firestore, FCM, Storage) |
| State           | Riverpod                             |
| Navigation      | GoRouter                             |

## MVP – Fonctionnalités prioritaires

1. Authentification (Email + Google)
2. Profil joueur (création + édition)
3. Système d’équipes
4. Défis 1v1
5. Stats basiques (W/L, winrate, streak)
6. Classement simple
7. Notifications push

## Démarrage rapide

### 1. Firebase

1. Crée un projet sur [Firebase Console](https://console.firebase.google.com)
2. Active **Authentication** (Email/Password + Google)
3. Crée une base **Firestore**
4. Copie les configs dans `mobile/lib/firebase_options.dart`
5. Déploie les règles : `firebase deploy --only firestore:rules`

### 2. Mobile (Flutter)

```bash
cd mobile
flutter pub get
flutterfire configure   # génère firebase_options.dart
flutter run
```

### 3. Web (Next.js)

```bash
cd web
npm install
npm run dev
```

## Architecture Firestore

```
users/{uid}
  - username, email, country, region, avatarUrl, bio
  - stats: { wins, losses, winrate, streak, points, rank }
  - teamId, isPremium, createdAt, lastActive

teams/{teamId}
  - name, logoUrl, ownerId, memberIds, adminIds
  - stats, country, region, isOpen

challenges/{challengeId}
  - challengerId, opponentId, status
  - winnerId, scores, createdAt, expiresAt

matches/{matchId}
rankings/{region}
```

## Progression actuelle

- [x] Structure monorepo
- [x] Modèles de données (User, Team, Challenge)
- [x] AuthService complet
- [x] Thème dark (eFootball style)
- [x] Router + protection des routes
- [x] Règles Firestore de base
- [ ] Écrans Auth (Login / Register / Onboarding)
- [ ] Écran Home
- [ ] Profil + Édition
- [ ] Teams
- [ ] Challenges 1v1
- [ ] Ranking
- [ ] Configuration Firebase réelle

## Prochaines étapes

1. Configurer le vrai projet Firebase
2. Créer les écrans d’authentification
3. Implémenter le flow complet d’inscription
4. Construire l’UI Home + Profil

---

**Slogan :** Compete. Dominate. Rise.
