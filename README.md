<img width="1156" height="628" alt="image" src="https://github.com/user-attachments/assets/fb280143-8c10-4349-b5ba-ccdb9f91cef8" />

## Local setup

The app expects local Firebase platform configuration and an untracked `.env`
file. Keep credentials out of Git and provision them on each developer or CI
machine before building.

Required local files:

- `.env`
- `android/app/google-services.json`

The iOS and macOS Firebase plist files and `lib/firebase_options.dart` are
already part of the repository.

## Android release signing

Release builds require a real release keystore and never fall back to the debug
certificate. Copy `android/key.properties.example` to
`android/key.properties`, then replace its values with the release keystore
credentials. The resulting `key.properties` file remains ignored by Git.

## Firebase security rollout

Deploy the Firestore rules and indexes before releasing the app changes:

```sh
firebase deploy --only firestore:rules,firestore:indexes
```

Existing share links need an `export_storage_access` record before the new
Storage rules can authorize downloads. After the updated app is available,
owners can backfill their existing links by opening **My Shared Links** once.
Backfill all legacy links before deploying the restrictive Storage rules:

```sh
firebase deploy --only storage
```

New share links create both records atomically and need no migration.
