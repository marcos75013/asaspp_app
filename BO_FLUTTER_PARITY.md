# Nouveautés du BO dans Flutter

État du 4 novembre 2026. Branche `feature/flutter-modern-connected` uniquement.
Les BO et le backend n’ont pas été modifiés. L’accueil, le thème marin, les cartes
et la navigation de `develop` restent en place. Les nouveaux écrans de gestion
utilisent ce thème et des formulaires Flutter ; aucun retour à la maquette rejetée.

## Couverture du BO d’association

| Fonction du BO | Parcours Flutter |
|---|---|
| Association | Consultation, changement du nom et du logo |
| Membres | Recherche, ajout avec résultat de l’invitation serveur, rôle, retrait de l’association |
| Profil sportif | Identité, niveau/qualifications de plongée ou équipe/catégorie/poste de football, licence, certificat |
| Cotisation | Saison, statut, montants, date, mode de paiement et notes |
| Justificatifs | Liste, dépôt, téléchargement/partage, vérification, suppression et alertes d’expiration |
| Événements | Pagination complète, création et modification, catégorie personnalisée et image, publication, capacité, récurrence hebdomadaire/mensuelle et jours sélectionnés |
| Séries | Modification/suppression de l’occurrence ou de cette occurrence et des suivantes, avec choix explicite et confirmation avant suppression |
| Présences | Réponses et liste d’attente, pointage après le début si activé, statistiques déclarées et vérifiées |
| Plongée | Fiches liées aux événements, site, profondeur, directeur, consignes et statut ; dossiers des plongeurs ; palanquées, guide et participants |
| Covoiturage | Modération des annonces de trajet et consultation des passagers |
| Documents | Liste et recherche, catégories, ajout, modification, brouillon/publication, téléchargement/partage, suppression |
| Albums | Création, modification, brouillon/publication, ajout de photos, couverture, suppression de photos et d’album |
| Annonces | Modération, activation/masquage, statut et suppression |
| Messages | Liste, création, modification, brouillon/publication et suppression |
| Quiz | Création/édition du questionnaire, 2 à 6 choix par question, bonnes réponses et explications, seuil, publication, suppression, résultats des membres |

Les modules activés par le BO pilotent aussi les entrées de la navigation et de
l’espace administrateur. La préparation des plongées est proposée uniquement aux
associations dont le backend indique l’activité DIVING. Le BO global de la plateforme
(création d’associations, configuration globale) n’est pas exposé aux membres du club.

## Nouveautés visibles par les membres

- Bouton d’actualisation de l’accueil pour recharger le contexte et les événements.
- Détail des événements : lieu, description, fin, catégorie, récurrence, places,
  effectifs, réponse personnelle et liste d’attente. Image de catégorie fournie par le BO.
- Offres **et demandes** de covoiturage ; modification/suppression de son trajet,
  passagers du conducteur, réservation et annulation.
- « Mes annonces » : modification, statut, gestion des photos et suppression.
- « Mes résultats » pour l’historique des quiz ; correction retournée par le serveur
  après une tentative, avec conservation des index de questions/choix d’origine.

## Contrôles et limites

- Les écritures utilisent les mêmes routes, méthodes et paramètres que le BO.
  Chaque requête est liée à une association explicite.
- Les opérations de suppression demandent confirmation dans l’application.
- Les formulaires valident aussi les champs hors écran et bloquent les doubles clics.
  Les erreurs serveur restent visibles ; aucun succès ni enregistrement simulé.
- Les formulaires d’administration sont accessibles aux administrateurs. Le compte
  réel utilisé pour la recette est membre : aucun changement de rôle n’a été effectué.
- L’API actuelle permet d’affecter une catégorie illustrée lors de la création d’un événement, mais pas de changer cette liaison après création. Le formulaire de modification ne propose donc pas une action sans effet. Une date de fin existante doit être conservée ou remplacée.
- Les endpoints existants ne permettent pas à un membre de gérer son propre dossier
  médical/cotisation ni de lire les messages administrateur. Ces droits ne sont pas
  contournés. Paiements et profil chinois restent sans API adaptée.
- Les envois de fichiers, le partage natif et les écritures avec un compte administrateur
  réel nécessitent encore une recette sur appareil. Aucun email réel ni modification de
  dossier réel n’a été déclenché pendant les tests.

## Validation

- 16 tests Flutter : interface d’origine sur téléphone, droits et modules, pagination,
  brouillons, portée de série, justificatifs (succès et refus), quiz et validation des formulaires.
- Analyse Dart sans erreur ni warning (recommandations de style historiques restantes).
- Compilations Web de l’application et de l’aperçu administrateur séparé.

Application connectée : `http://localhost:59765/original/#/home`.
Démonstration administrateur : `http://127.0.0.1:59766/#/admin-home`.
Cette dernière affiche un bandeau « DONNÉES FICTIVES » et refuse toutes les écritures.
