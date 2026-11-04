# Flutter — interface de develop raccordée au backend

Direction demandée le 4 novembre 2026 : conserver les écrans de `develop`, sans
refonte graphique, et remplacer les données de démonstration par les API du BO.

## Branche et interface

- Travail exclusivement sur `feature/flutter-modern-connected`, issue de `develop-2`.
- `develop` reste à `a03316d`, `develop-2` à `97ddca3`.
- Le lancement normal utilise AppTheme, MainScaffold, les cartes, le fond marin,
  le logo, les animations et la navigation d’origine. Aucun flag LEGACY_UI requis.
- Les dimensions de certains composants s’adaptent au contenu pour éviter les
  débordements sur téléphone. Aucun nouveau thème graphique.
- Les écrans de l’essai graphique précédent restent dans `features/connected`
  mais ne sont plus utilisés par la navigation. Son adaptateur ClubApi est réutilisé.

## Raccordements des écrans d’origine

- Authentification existante, identité et association actives, changement d’association,
  déconnexion, espace administrateur conditionné par le rôle.
- Accueil : événements futurs publiés, pagination complète et identifiants distincts
  même pour deux sorties de même catégorie. Participation et liste d’attente serveur.
- Covoiturage : offre liée à l’événement, consultation, réservation et annulation.
- Galerie : albums, couverture, photos et plein écran.
- Documents : liste et catégories serveur, téléchargement authentifié et partage.
- Annonces : liste, recherche, filtres, favoris, détail, contact, publication et photos.
- Quiz : questionnaires serveur, soumission des index d’origine et résultat enregistré.
- Formulaires administrateur : message, événement/entraînement avec date, album et
  photos, document et consultation des membres. Erreurs visibles, doubles soumissions bloquées.

## Limites explicites

Les liens de paiement, le profil chinois, les données sportives personnelles et
la lecture des messages par les membres n’ont pas d’API adaptée dans le backend
actuel. Les écrans concernés indiquent une absence de données ou une indisponibilité ;
aucun paiement, score ou enregistrement fictif. La présentation institutionnelle
« Asaspp » reste le contenu statique de develop. La lecture des messages est réservée
aux administrateurs par le serveur. Le backend n’a pas été modifié.

Les anciens écrans détaillés du prototype (historique quiz, gestion complète de
ses trajets et annonces, suivi avancé des membres) ne sont pas exposés dans cette
navigation : seuls les parcours de l’interface d’origine sont raccordés.

## Vérifications

- `flutter test` : 9 tests réussis, dont accueil d’origine à 390 × 844, événements
  de même catégorie, exclusion des brouillons et réponse serveur WAITLISTED.
- `flutter analyze` : aucune erreur ni warning ; des recommandations de style et
  dépréciations Flutter subsistent dans les écrans historiques.
- Compilation Web et inspection visuelle de l’interface d’origine.
- Recette en lecture sur le backend local avec le compte de test : événements,
  galerie, documents, annonces et quiz répondent HTTP 200. Les quatre derniers
  modules sont actuellement vides. L’administration répond 403 pour ce membre.
- Les écritures administrateur et les sélecteurs/partages natifs restent à recetter
  sur appareil avec un compte administrateur. Aucun APK livré par ce changement.

## Lancement

```sh
flutter run --dart-define=API_BASE_URL=http://ADRESSE_DU_SERVEUR:8080
flutter build web --pwa-strategy=none --dart-define=API_BASE_URL=http://localhost:8080
```

Sur téléphone physique, utiliser l’adresse réseau du backend ; localhost désigne
le téléphone lui-même. Ne pas utiliser la cible visuelle pour une recette métier.

`tool/visual_preview.dart` est un aperçu distinct avec fixtures explicites et
écritures refusées. Il utilise les mêmes écrans et le même thème que l’application.
`tool/serve_preview.py` sert les fichiers sans cache HTTP.

Aperçu connecté de cette session : `http://localhost:59765/original/#/home`.
Le sous-chemin `/original/` évite les anciens fichiers conservés par le navigateur.
Compilation correspondante :

```sh
flutter build web --pwa-strategy=none --base-href=/original/ --output=build/web/original --dart-define=API_BASE_URL=http://localhost:8080
python3 tool/serve_preview.py --directory build/web --port 59765
```

Connexion et affichage des événements réels vérifiés dans le navigateur. Le test
mobile couvre aussi une liste de 35 événements pour contrôler les indicateurs.
