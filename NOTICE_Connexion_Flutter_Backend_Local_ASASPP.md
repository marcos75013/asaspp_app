# Notice — Lancer Flutter avec le backend local Spring Boot

## Contexte

Le backend Spring Boot du projet ASASPP / Multi-Asso SaaS tourne en local sur le Mac :

```bash
http://localhost:8080
```

L’API backend est accessible via :

```bash
http://localhost:8080/api
```

Attention : selon l’appareil utilisé pour lancer Flutter, `localhost` ne signifie pas toujours la même chose.

---

## 1. Résumé rapide des environnements

| Environnement | Cas d’utilisation | URL backend | Commande Flutter |
|---|---|---|---|
| `local` | iOS Simulator, macOS, Web local | `http://localhost:8080` | `flutter run --dart-define=APP_ENV=local` |
| `android` | Android Emulator | `http://10.0.2.2:8080` | `flutter run --dart-define=APP_ENV=android` |
| `device` | Vrai téléphone Android/iPhone branché | `http://IP_DU_MAC:8080` | `flutter run --dart-define=APP_ENV=device` |
| `prod` | API en ligne | `https://ton-api-production.com` | `flutter run --dart-define=APP_ENV=prod` |

---

## 2. Cas iOS Simulator, macOS ou Web local

Pour iOS Simulator, macOS ou Flutter Web, `localhost` pointe bien vers le Mac.

### Commande

```bash
flutter run --dart-define=APP_ENV=local
```

### Configuration attendue dans `AppConfig`

```dart
case 'local':
default:
  return 'http://localhost:8080';
```

### Log attendu

```text
uri: http://localhost:8080/api/auth/token
```

---

## 3. Cas Android Emulator

Sur Android Emulator, `localhost` pointe vers l’émulateur Android, pas vers le Mac.

Pour accéder au backend local du Mac, il faut utiliser :

```text
10.0.2.2
```

### Commande

```bash
flutter run --dart-define=APP_ENV=android
```

### Configuration attendue dans `AppConfig`

```dart
case 'android':
  return 'http://10.0.2.2:8080';
```

### Log attendu

```text
uri: http://10.0.2.2:8080/api/auth/token
```

---

## 4. Cas vrai téléphone Android branché en USB

Sur un vrai téléphone Android, `localhost` pointe vers le téléphone lui-même.

Donc si Flutter affiche :

```text
uri: http://localhost:8080/api/auth/token
```

sur un vrai téléphone Android, c’est mauvais. Le téléphone essaie d’appeler son propre `localhost`, pas le backend du Mac.

### Étape 1 — Trouver l’IP locale du Mac

Sur le Mac, lancer :

```bash
ipconfig getifaddr en0
```

Exemple de résultat :

```text
192.168.1.42
```

Si cette commande ne retourne rien, essayer :

```bash
ipconfig getifaddr en1
```

### Étape 2 — Modifier `AppConfig`

Dans `AppConfig`, mettre l’IP du Mac dans le cas `device`.

Exemple :

```dart
case 'device':
  return 'http://192.168.1.42:8080';
```

Il faut bien remplacer `192.168.1.42` par l’IP réelle du Mac.

### Étape 3 — Vérifier les devices Flutter

```bash
flutter devices
```

Exemple de résultat :

```text
Found 2 connected devices:
  2201117TG (mobile) • 123456ABCDEF • android-arm64 • Android
  macOS (desktop)    • macos        • darwin-arm64
```

### Étape 4 — Lancer sur le vrai téléphone Android

Si un seul téléphone est connecté :

```bash
flutter run --dart-define=APP_ENV=device
```

Si plusieurs devices sont détectés :

```bash
flutter run -d ID_DU_DEVICE --dart-define=APP_ENV=device
```

Exemple :

```bash
flutter run -d 123456ABCDEF --dart-define=APP_ENV=device
```

### Log attendu sur vrai téléphone Android

```text
uri: http://192.168.x.x:8080/api/auth/token
```

Exemple :

```text
uri: http://192.168.1.42:8080/api/auth/token
```

---

## 5. Condition importante pour le vrai téléphone

Le téléphone et le Mac doivent être sur le même réseau.

Ça fonctionne si :

```text
Mac et téléphone sur le même Wi-Fi
```

ou :

```text
Mac connecté au partage de connexion du téléphone
```

Ça ne fonctionne généralement pas si :

```text
Téléphone en 5G
Mac sur un Wi-Fi différent
```

Dans ce cas, le téléphone ne peut pas joindre le backend local du Mac.

---

## 6. Configuration complète conseillée de `AppConfig`

```dart
class AppConfig {
  AppConfig._();

  static const String environment = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'local',
  );

  static String get backendBaseUrl {
    switch (environment) {
      case 'android':
        // Android Emulator :
        // 10.0.2.2 permet d'accéder au localhost du Mac.
        // Commande :
        // flutter run --dart-define=APP_ENV=android
        return 'http://10.0.2.2:8080';

      case 'device':
        // Vrai téléphone Android/iPhone :
        // remplacer l'IP ci-dessous par l'IP locale du Mac.
        // Pour récupérer l'IP du Mac :
        // ipconfig getifaddr en0
        // Commande simple :
        // flutter run --dart-define=APP_ENV=device
        // Si plusieurs devices :
        // flutter devices
        // flutter run -d ID_DU_DEVICE --dart-define=APP_ENV=device
        return 'http://192.168.1.42:8080';

      case 'prod':
        return 'https://ton-api-production.com';

      case 'local':
      default:
        // iOS Simulator / macOS / Web local.
        // Commande :
        // flutter run --dart-define=APP_ENV=local
        return 'http://localhost:8080';
    }
  }

  static String get apiBaseUrl {
    return '$backendBaseUrl/api';
  }

  static String buildBackendUrl(String? path) {
    if (path == null || path.isEmpty) {
      return '';
    }

    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }

    if (path.startsWith('/')) {
      return '$backendBaseUrl$path';
    }

    return '$backendBaseUrl/$path';
  }
}
```

---

## 7. Commandes à retenir

### iOS Simulator / macOS / Web

```bash
flutter run --dart-define=APP_ENV=local
```

### Android Emulator

```bash
flutter run --dart-define=APP_ENV=android
```

### Vrai téléphone Android

```bash
flutter run --dart-define=APP_ENV=device
```

### Vrai téléphone Android avec ID du device

```bash
flutter devices
flutter run -d ID_DU_DEVICE --dart-define=APP_ENV=device
```

Exemple :

```bash
flutter run -d 123456ABCDEF --dart-define=APP_ENV=device
```

---

## 8. Endpoints utiles pour tester

### Login

```http
POST /api/auth/token
```

Test avec curl depuis le Mac :

```bash
curl -i -X POST http://localhost:8080/api/auth/token \
  -H "Content-Type: application/json" \
  -d '{
    "email": "marcos@example.com",
    "password": "password"
  }'
```

Réponse attendue :

```json
{
  "token": "eyJ..."
}
```

### Contexte mobile

```http
GET /api/mobile/context
```

Test avec curl depuis le Mac :

```bash
curl -i -X GET http://localhost:8080/api/mobile/context \
  -H "Authorization: Bearer TOKEN_ICI"
```

Réponse attendue :

```json
{
  "user": {
    "id": 6,
    "email": "marcos@example.com",
    "firstName": null,
    "lastName": null
  },
  "associations": [
    {
      "id": 6,
      "name": "Fight31",
      "logoUrl": "/uploads/logos/xxx.png",
      "roles": ["ADMIN"],
      "modules": [
        "MEMBERS",
        "CLUB_IDENTITY",
        "ORGANIZATION",
        "CLUB_COMMUNICATION"
      ]
    }
  ]
}
```

---

## 9. Rappel important sur `X-Association-Id`

L’endpoint suivant ne demande pas `X-Association-Id` :

```http
GET /api/mobile/context
```

Pourquoi ?

Parce qu’il sert justement à récupérer les associations disponibles pour l’utilisateur connecté.

Après cet appel, Flutter connaît l’association choisie.

Les futurs appels métier devront ensuite envoyer :

```http
Authorization: Bearer TOKEN
X-Association-Id: ID_ASSOCIATION_CHOISIE
```

Exemple :

```http
Authorization: Bearer eyJ...
X-Association-Id: 6
```

---

## 10. Diagnostic rapide

### Mauvais log sur vrai téléphone Android

```text
uri: http://localhost:8080/api/auth/token
```

Problème :

```text
Flutter appelle le localhost du téléphone.
```

Solution :

```bash
flutter run --dart-define=APP_ENV=device
```

et vérifier que `AppConfig` contient bien l’IP locale du Mac.

### Bon log sur Android Emulator

```text
uri: http://10.0.2.2:8080/api/auth/token
```

### Bon log sur vrai téléphone Android

```text
uri: http://192.168.x.x:8080/api/auth/token
```

---

## 11. À retenir absolument

- `localhost` fonctionne pour iOS Simulator, macOS et Web local.
- `localhost` ne fonctionne pas pour Android Emulator : utiliser `10.0.2.2`.
- `localhost` ne fonctionne pas pour un vrai téléphone Android : utiliser l’IP locale du Mac.
- Pour un vrai téléphone, Mac et téléphone doivent être sur le même réseau.
- Pour le mobile, le premier appel après login est `GET /api/mobile/context` sans `X-Association-Id`.
- Ensuite seulement, Flutter utilise `X-Association-Id` pour les endpoints métier.
