# ASASPP App

Application mobile MultiAsso.

## Configuration de l'API

L'URL du backend est fournie au build avec `API_BASE_URL`. Sans paramètre,
l'application utilise `http://localhost:8080`.

```bash
flutter run --dart-define=API_BASE_URL=http://192.168.1.36:8080
```

Pour un émulateur Android, utiliser généralement :

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080
```
