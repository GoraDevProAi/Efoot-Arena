# Lancement local eFoot Arena — checklist

## Prérequis sur ton PC

1. **Flutter SDK** (3.22+ recommandé)  
   https://docs.flutter.dev/get-started/install  
   Vérifie : `flutter doctor`

2. **Android Studio** + SDK + un émulateur **ou** un téléphone en USB (mode développeur)

3. **Compte Firebase** projet `efoot-arena-c288b`  
   - Auth : Email/Password + Google activés  
   - Firestore créé  
   - Storage activé  

## Étapes (dans l’ordre)

```bash
# 1. Cloner
git clone https://github.com/GoraDevProAi/Efoot-Arena.git
cd Efoot-Arena/mobile

# 2. Générer les dossiers natifs Android/iOS (IMPORTANT)
#    Le repo a le code Dart + google-services.json, pas le scaffolding complet.
flutter create . --project-name efoot_arena --org com.efootarena

# 3. Vérifier que google-services.json est toujours là
ls android/app/google-services.json

# 4. applicationId Android
# Ouvre android/app/build.gradle (ou build.gradle.kts)
# applicationId / namespace = com.efootarena.app

# 5. Plugin Google Services (si pas déjà ajouté par FlutterFire)
# android/settings.gradle : id "com.google.gms.google-services" version "4.4.2" apply false
# android/app/build.gradle : id "com.google.gms.google-services"

# 6. Dépendances
flutter pub get

# 7. Analyser (erreurs de compilation)
flutter analyze

# 8. Lancer
flutter devices
flutter run
```

## Firebase à faire avant le 1er test réel

1. Console → **Authentication** → Email + Google  
2. **Firestore** → créer base + coller / déployer `firebase/firestore.rules`  
3. **Storage** → déployer `firebase/storage.rules`  
4. Si index demandé (classement, marketplace) → cliquer le lien dans l’erreur rouge  

## Scénario de test minimal

1. **Register** un compte (email + username + pays)  
2. Voir le **Home** (stats à 0)  
3. **Profil** → modifier bio  
4. Créer un **2e compte** (autre émulateur / web auth plus tard) pour tester un **défi**  
5. **Équipe** → créer → rejoindre avec le 2e compte  
6. **Chat** → envoyer un message  
7. **Classement** → voir les joueurs apparaître  

## Erreurs fréquentes

| Erreur | Solution |
|--------|----------|
| `google-services.json` manquant | Recopier depuis Firebase Console dans `android/app/` |
| `PlatformException` Auth | Activer Email/Password dans Firebase |
| `PERMISSION_DENIED` Firestore | Déployer les rules |
| Index required | Créer l’index via le lien Firebase |
| `applicationId` mismatch | Doit être `com.efootarena.app` |
| Package name Google Sign-In | SHA-1 dans Firebase (Android) |

### SHA-1 (Google Sign-In Android)

```bash
cd android
./gradlew signingReport
# Copier SHA-1 debug → Firebase Console → Project settings → Android app
```

## Ce que l’environnement Grok ne peut pas faire

- Exécuter `flutter run` (pas de SDK Flutter ici)  
- Ouvrir un émulateur Android  

Le test réel se fait **sur ta machine**.
