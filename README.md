# Shell-Bash-Bridge

Application Flutter mobile (MVP) pour apprendre Bash et PowerShell, consulter des fiches de commandes, comparer des équivalences, passer des quiz et suivre sa progression.

## Stack

- Flutter + Dart
- Material 3
- Riverpod (state management)
- go_router (navigation)
- SharedPreferences (persistance locale MVP)

## Fonctionnalités

- Parcours Bash et PowerShell
- Fiches de commandes avec syntaxe, exemple, erreurs fréquentes et conseils
- Comparaison Bash ↔ PowerShell par action
- Recherche + filtres (catégorie, difficulté, favoris)
- Favoris persistés localement
- Quiz (15 questions) avec score
- Suivi de progression + badges + série d’apprentissage

## Architecture

Feature-first avec séparation claire:

- `app/`: bootstrapping, thème, router
- `core/`: constantes, enums, widgets partagés
- `features/`: domain/data/presentation par feature
- `providers/`: providers Riverpod (commands, filters, favorites, progression, quiz)

## Lancer le projet

```bash
flutter pub get
flutter run
```

## Analyse et qualité

```bash
flutter analyze
flutter test
```

## Roadmap MVP+

- Export/Import progression
- Persistance Isar/SQLite
- Sync cloud optionnelle
- Packs de quiz par niveau
