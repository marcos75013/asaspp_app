# Flutter — nouvelle expérience connectée

Travail du 4 novembre 2026, exclusivement dans `asaspp_app`.

## Isolation et comparaison

- Branche : `feature/flutter-modern-connected`, créée depuis `develop-2` (`97ddca3`).
- `develop` reste sur `a03316d` ; `develop-2` reste sur `97ddca3`.
- Aucun merge ni push effectué. Aucun fichier du backend ou des BO modifié.
- Les écrans historiques sont conservés. Pour lancer leur navigation :

```sh
flutter run --dart-define=LEGACY_UI=true
```

## Nouvelle expérience

Connexion, sélection d’association, accueil, agenda, modules du club et profil.
Palette ivoire / vert profond, cartes, navigation Material 3, formulaires défilants,
états de chargement / erreur / absence de données, recherche et actualisation.
Les modules visibles dépendent du contexte serveur ; l’espace administrateur
n’est lié que pour le rôle ADMIN.

`lib/features/connected` contient les nouveaux écrans et l’adaptateur API.
Les requêtes sont attachées à l’association de l’écran ; elles ne changent pas
implicitement d’association à la suite d’une modification du stockage local.
Les jetons restent gérés par le mécanisme existant. Les anciens Cubit de maquette
ne sont pas créés dans la nouvelle interface.

## Raccordements présents

| Module | Parcours disponibles |
|---|---|
| Événements | Agenda paginé, recherche, détail, dates, capacité, réponses, liste d’attente renvoyée par le serveur |
| Covoiturage | Liste par événement, offre / demande, création / modification / suppression de son trajet, réservation / annulation, passagers du conducteur |
| Galerie | Albums, couverture, photos, plein écran avec zoom et navigation |
| Documents | Liste, recherche, récupération authentifiée puis enregistrement / partage du fichier |
| Annonces | Liste, recherche, favoris, filtres personnelles / favorites, détail, contact, création / modification / suppression de ses annonces, ajout de photos |
| Quiz | Liste publiée, questions, choix, soumission des index d’origine, correction serveur, historique personnel |
| Administration | Consultation des membres, profils sportifs, cotisations et justificatifs, alertes, statistiques de présence, création / modification / publication de messages |

Le partage de documents utilise share_plus 12.x, en conservant les versions
préexistantes de package_info_plus et geolocator_linux. Les photos d’annonces
utilisent le multipart avec type MIME explicite et contrôles de format / taille.

## Lancement connecté

```sh
flutter run -d chrome --web-port=64006 --dart-define=API_BASE_URL=http://localhost:8080
```

Le backend doit être lancé séparément. Le port 64006 est déjà autorisé dans son
CORS. L’URL API est paramétrable ; sans paramètre, l’adresse de développement
historique est conservée. Utiliser une API HTTPS pour une distribution mobile.
Pour un émulateur Android, l’adresse de la machine hôte est `10.0.2.2`.
L’accès HTTP sur les appareils dépend également de leur configuration réseau.

## Aperçu graphique sans identifiants

```sh
flutter run -d chrome --web-port=59765 --target=tool/visual_preview.dart
```

Cet exécutable séparé affiche une bannière « DONNÉES FICTIVES ». Il injecte des
réponses locales dans les mêmes écrans et rejette toutes les mutations.
Il n’est jamais importé par l’entrée de l’application et ne constitue pas une
validation du backend. Il permet d’examiner le design sans modifier le compte
ni réinitialiser son mot de passe.

## Périmètre restant et limites

- La recette avec un compte réel et sur appareils Android/iOS reste nécessaire.
  Le mot de passe du compte fourni n’est pas connu ; aucun mot de passe modifié.
- La gestion avancée du BO n’est pas intégralement transposée : édition des
  membres et cotisations, dépôt / validation des justificatifs, édition des
  événements / récurrences, pointage, préparation des palanquées et fiches de
  sécurité, administration des albums, documents et quiz restent au BO.
- Le backend ne propose pas actuellement d’API membre pour les messages publiés,
  la fiche détaillée / l’organigramme du club, son propre dossier sportif et
  les cotisations. Ces informations ne sont pas simulées dans l’app connectée.
- Paiements externes et profil chinois historiques restent dans le mode LEGACY_UI ;
  aucune API correspondante n’a été identifiée pour les raccorder.
- Point backend identifié : la recherche `/api/events` renvoie aussi les
  brouillons. L’interface membre filtre `published == true`, mais ce filtrage
  **ne constitue pas un contrôle de sécurité**. Le serveur doit lui-même limiter
  la lecture et les actions membres aux événements publiés avant production.
- Les fichiers d’analyse historiques restent conservés ; leurs avertissements
  informatifs de dépréciation ne sont pas corrigés par cette refonte.

## Vérifications

Les tests `test/connected_test.dart` vérifient notamment : association et jeton
sur les requêtes, réponse serveur WAITLISTED, erreur réseau et nouvelle tentative,
index des réponses aux quiz, mise en page sur petit écran et navigation du club.
La vérification visuelle de la connexion a été effectuée à 390 × 844.
Consulter le compte rendu du chat pour les résultats finaux de compilation.

### Résultats de cette session

- 7 tests Flutter réussis, dont navigation Accueil / Mon club / Profil à 390 × 844.
- `flutter analyze --no-fatal-infos` : succès, aucune erreur ni avertissement ;
  129 remarques informatives dans le code historique conservé.
- Compilation web de l’app connectée et de la démonstration : succès.
- Accueil et catalogue de modules inspectés visuellement à 390 × 844.
- Compilation Android : non validée. Une première erreur sur les classes générées
  de package_info_plus a conduit à régénérer ses sorties. La tentative suivante
  a été arrêtée par `No space left on device`. Les sorties Android de `build/app`
  ont été nettoyées avec autorisation ; aucun APK livré.
- iOS : pas de compilation ni recette sur appareil lors de cette session.
- Recette backend authentifiée : non effectuée, identifiants non disponibles.

Aperçus locaux laissés démarrés :
- Application connectée : http://localhost:64006
- Démonstration vérifiée, données fictives : http://127.0.0.1:59765

Le second hôte évite un ancien cache Service Worker de démonstration sur
localhost. Le backend local existant a été lancé sur le port 8080 sans modification
de son code. Les modifications Flutter restent locales sur la branche dédiée.

## Ajustement demandé : moderniser l’existant

La première direction graphique vert / ivoire a été écartée à la demande de
l’utilisateur. La version actuelle reprend le fond sous-marin `bg_mer.png`, les
bleus historiques, le logo du club (logo serveur en priorité, ASASPP en repli
uniquement pour le club ASASPP), le plongeur et les illustrations de catégories.
L’accueil présente les sorties en cartes défilantes, puis le covoiturage et les
modules. Les onglets reprennent Accueil / Mon club / Galerie / Annonces selon les
modules activés ; le profil est accessible dans l’en-tête et l’agenda depuis
l’accueil. La connexion retrouve le fond marin et une carte blanche lisible.
Aucun raccordement API supprimé. Les 7 tests passent après mise à jour du test de
navigation. Analyse : aucune erreur ni avertissement, remarques historiques
informatives uniquement. La capture `flutter-modern-preview.jpg` documente la
première proposition, et ne représente plus cette direction graphique.

### Cache de l’aperçu corrigé

L’ancien Service Worker conservait la première proposition sur le port 59765.
L’aperçu actuel est servi sur http://127.0.0.1:59766 avec les en-têtes HTTP
`Cache-Control: no-store`. Le fond marin, les illustrations et les onglets
historiques ont été vérifiés visuellement dans le navigateur. La capture actuelle
est `flutter-ocean-preview.jpg`.

```sh
python3 tool/serve_preview.py --directory /tmp/multi-asso-visual-preview --port 59766
```
