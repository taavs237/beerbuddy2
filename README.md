# BeerBuddy 

BeerBuddy is a Flutter mobile application for tracking beers you have tried.
The app is built using an **offline-first architecture** and synchronizes data with Firebase when connectivity is available.

This project was developed as a course project for a Flutter mobile development course.

---

##  Features

- User authentication using Firebase Authentication
- Add, edit, delete beers
- Rate beers and add comments
- Attach photos to beers
- Offline-first behavior using Hive
- Automatic cloud synchronization with Firebase Firestore
- Private image storage using Firebase Storage
- Search beers by name or comment
- Conflict resolution using last-write-wins strategy
- Manual and automatic synchronization

---

##  Architecture Overview

- **UI layer**: Flutter screens and widgets
- **Local data layer**: Hive database (offline source of truth)
- **Cloud sync**:
  - Firebase Firestore for structured data
  - Firebase Storage for images
- **Synchronization**:
  - Triggered on connectivity changes
  - Can be triggered manually by the user
  - Uses timestamps for conflict resolution

More details can be found in the `/docs` folder.

---

##  Data Model

The main entity used in the app is `Beer`.

See [`docs/data_model.md`](docs/data_model.md) for a detailed description.

---

##  Offline-First & Synchronization

- All data is stored locally using Hive
- Local changes are marked as pending
- Synchronization uploads local changes to Firebase
- Remote updates are pulled and merged
- Conflicts are resolved using a **last-write-wins** strategy based on timestamps
- Images are uploaded only when connectivity is available

More details can be found in [`docs/challenge.md`](docs/challenge.md).

---

##  Security

- Firebase Authentication is required to use the app
- Users can only access their own data
- Firebase Security Rules restrict access to authenticated users
- Images are stored in private Firebase Storage paths

Security rules are included in the repository.

---

##  Project Structure (simplified)
lib/
├── data/
│ ├── beer_local_repository.dart
│ ├── beer_sync_service.dart
│ └── beer_image_storage_service.dart
├── models/
│ └── beer.dart
├── ui/
│ └── screens/
│ ├── beer_list_screen.dart
│ └── beer_edit_screen.dart
docs/
├── data_model.md
├── challenge.md
└── architecture.md
firebase/
├── firestore.rules
└── storage.rules


---

##  Getting Started

### Prerequisites
- Flutter SDK
- Firebase project
- Firebase CLI (optional)

### Setup
1. Clone the repository
2. Run `flutter pub get`
3. Configure Firebase for the project
4. Run the app on a real or virtual device

---

##  Quality & Stability

- Long-running operations are asynchronous
- Loading, empty, and error states are handled
- The app does not crash during common usage
- `flutter analyze` passes with no critical issues

---

##  Course Requirements

This project satisfies the following course requirements:

- At least 3 screens with proper navigation
- User authentication using Firebase
- Offline-first behavior
- Cloud data synchronization
- Conflict resolution
- Firebase Security Rules included
- Public Git repository with documentation

---

##  Demo

The application can be demonstrated using a real or virtual mobile device.


---

##  Author

Developed by Taavi Purtsak

---

##  License

This project is for educational purposes.


