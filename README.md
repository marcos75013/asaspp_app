# ASASPP App

Application mobile MultiAsso — branche `feature/mobile-session`.

## Connexion au backend en ligne

Le backend utilisé par défaut est **https://multi-asso-api.onrender.com**.
Aucun serveur local ni tunnel USB vers un backend local n’est nécessaire.

### VS Code

1. Ouvrir ce dépôt sur la branche `feature/mobile-session`.
2. Choisir le téléphone ou l’émulateur dans VS Code.
3. Dans « Exécuter et déboguer », choisir **Flutter — backend Render**, puis lancer.

Cette configuration fournit explicitement l’adresse Render à Flutter et n’exécute
pas de tâche `adb reverse` vers un serveur local.

### Ligne de commande

```bash
flutter pub get
flutter run --dart-define=API_BASE_URL=https://multi-asso-api.onrender.com
```

L’adresse est fixée à la compilation. Après un changement d’adresse ou de
configuration de lancement, arrêter complètement l’application et la relancer :
un simple hot reload ne suffit pas. Une ancienne option
`--dart-define=API_BASE_URL=...` dans une configuration personnelle peut remplacer
l’adresse par défaut ; utiliser la configuration Render fournie ci-dessus.

### APK Android

```bash
flutter build apk --release --dart-define=API_BASE_URL=https://multi-asso-api.onrender.com
```

Le manifeste principal déclare la permission Internet, y compris pour les APK de
production. La permission du manifeste debug seule ne suffit pas pour un APK
release.

Utiliser un compte membre créé sur le BO en ligne. Le mot de passe demandé est
celui du compte membre, pas celui de PostgreSQL/Neon.

## Vérifications

```bash
flutter analyze
flutter test
```

L’API de connexion mobile est `POST /api/mobile/auth/token`. Le profil et le
contexte sont ensuite récupérés auprès du même backend. Cette configuration ne
change ni la base de données ni les mots de passe.
