# Lancer eFoot Arena (Flutter)

Le repo contient le code Dart + `google-services.json`, mais **pas** le scaffolding Android/iOS complet
(généré normalement par `flutter create`).

## 1. Générer les dossiers natifs

```bash
git clone https://github.com/GoraDevProAi/Efoot-Arena.git
cd Efoot-Arena/mobile

# Génère android/ et ios/ sans écraser lib/ ni pubspec.yaml
flutter create . --project-name efoot_arena --org com.efootarena
```

## 2. Package Android

Vérifie dans `android/app/build.gradle` :

```gradle
applicationId "com.efootarena.app"
```

Le fichier `android/app/google-services.json` est déjà dans le repo.

Dans `android/settings.gradle` / `android/app/build.gradle`, assure-toi que le plugin Google Services est appliqué (FlutterFire le documente).

## 3. Dépendances & run

```bash
flutter pub get
flutter run
```

## 4. Firebase à activer

- Authentication : Email + Google  
- Firestore + rules (`firebase/firestore.rules`)  
- Storage + rules (`firebase/storage.rules`)  
- Cloud Messaging  
- Cloud Function notifications (plan Blaze) — voir SETUP.md  

## 5. Indexes Firestore

Au premier classement régional / défis, Firebase affichera un lien pour créer les indexes composites — clique dessus.
