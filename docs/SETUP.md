# Guide de configuration eFoot Arena

## 1. Prérequis

- Node.js 20+
- Flutter 3.22+
- Compte Firebase
- Compte Google Cloud (pour Google Sign-In)

## 2. Configuration Firebase (obligatoire)

### Créer le projet
1. Va sur https://console.firebase.google.com
2. Clique **Add project** → nomme-le `efoot-arena`
3. Désactive Google Analytics si tu veux (optionnel)

### Activer les services
1. **Authentication** → Sign-in method
   - Active **Email/Password**
   - Active **Google**
2. **Firestore Database** → Create database
   - Mode : **Production**
   - Location : `europe-west1` (ou plus proche de l’Afrique)
3. **Storage** → Get started (pour les avatars + logos d’équipes)
4. **Cloud Messaging** → pour les notifications push

### Ajouter les apps
1. **Android** : package name `com.efootarena.app`
2. **iOS** : bundle ID `com.efootarena.app`
3. **Web** : enregistre l’app web

### FlutterFire CLI
```bash
cd mobile
dart pub global activate flutterfire_cli
flutterfire configure
```
Ça génère automatiquement `lib/firebase_options.dart` avec les bonnes clés.

### Déployer les règles
```bash
npm install -g firebase-tools
firebase login
firebase init  # sélectionne Firestore
firebase deploy --only firestore:rules
```

## 3. Lancer le mobile

```bash
cd mobile
flutter pub get
flutter run
```

## 4. Lancer le web

```bash
cd web
npm install
npm run dev
```
Ouvre http://localhost:3000

## 5. Variables d’environnement (web – plus tard)

Quand on ajoutera Firebase côté web :
```env
NEXT_PUBLIC_FIREBASE_API_KEY=...
NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN=...
NEXT_PUBLIC_FIREBASE_PROJECT_ID=efoot-arena
...
```

## Ordre de développement recommandé

1. ✅ Structure + modèles + AuthService
2. ⬜ Configurer Firebase réel
3. ⬜ Écrans Auth (Login / Register / Onboarding)
4. ⬜ Home + Navigation bottom bar
5. ⬜ Profil joueur
6. ⬜ Création / rejoindre équipe
7. ⬜ Système de défis 1v1
8. ⬜ Classement
9. ⬜ Notifications
