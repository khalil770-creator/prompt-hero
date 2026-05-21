# Prompt Vault

A production-quality Flutter application — a curated library of top Claude AI prompts, organized by category. Supports Web, Android, and iOS.

---

## Features

- **Browse** categories and prompts organized by topic
- **Rate** prompts 1–5 stars (per-user, averaged with Firestore transactions)
- **Share** any prompt via WhatsApp (deep link on web, native share sheet on mobile) or copy to clipboard
- **Submit requests** for new categories or prompts, reviewed by admins
- **Admin panel**: create/edit/delete categories and prompts, reorder them (up/down), review and approve/reject user requests
- **Authentication**: email + password via Firebase Auth
- **Dark mode** support via Material 3

---

## Tech Stack

| Concern | Library |
|---|---|
| Framework | Flutter (latest stable) |
| Backend | Firebase Auth + Cloud Firestore |
| State | flutter_riverpod |
| Routing | go_router |
| Fonts | google_fonts (Poppins) |
| Sharing | share_plus + url_launcher |
| Rating UI | flutter_rating_bar |
| Animations | flutter_animate |
| Loading skeleton | shimmer |

---

## Setup Instructions

### 1. Prerequisites

- Flutter SDK >= 3.3.0
- A Firebase project (create one at https://console.firebase.google.com)
- FlutterFire CLI

### 2. Clone & install dependencies

```bash
cd C:/GIT_TOP/prompt_vault
flutter pub get
```

### 3. Configure Firebase

#### a. Install FlutterFire CLI
```bash
dart pub global activate flutterfire_cli
```

#### b. Log in to Firebase
```bash
firebase login
```

#### c. Configure your project
```bash
flutterfire configure
```

Select your Firebase project and the target platforms (Web, Android, iOS). This will:
- Generate `lib/firebase_options.dart` (replacing the placeholder)
- Download `google-services.json` for Android
- Download `GoogleService-Info.plist` for iOS

### 4. Enable Firebase services

In the Firebase Console:

1. **Authentication** → Sign-in method → Enable **Email/Password**
2. **Firestore Database** → Create database → Start in **test mode** (then secure with rules below)

### 5. Firestore Security Rules

Go to Firestore → Rules and paste:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    function isSignedIn() {
      return request.auth != null;
    }

    function isAdmin() {
      return isSignedIn() &&
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }

    // Users collection
    match /users/{uid} {
      allow read: if isSignedIn() && (request.auth.uid == uid || isAdmin());
      allow create: if isSignedIn() && request.auth.uid == uid;
      allow update: if isAdmin();
    }

    // Categories — public read, admin write
    match /categories/{catId} {
      allow read: if true;
      allow write: if isAdmin();

      // Prompts subcollection — public read, admin write
      match /prompts/{promptId} {
        allow read: if true;
        allow write: if isAdmin();
      }
    }

    // Ratings — authenticated users can write their own, public read
    match /ratings/{ratingId} {
      allow read: if true;
      allow create, update: if isSignedIn() &&
        ratingId == (request.auth.uid + '_' + request.resource.data.promptId);
    }

    // Requests — users can create/read their own; admins can manage all
    match /requests/{requestId} {
      allow read: if isSignedIn() &&
        (resource.data.userId == request.auth.uid || isAdmin());
      allow create: if isSignedIn();
      allow update: if isAdmin();
    }
  }
}
```

### 6. Set up an admin user

1. Run the app and register a user account
2. In the Firebase Console → Firestore → `users` collection → find the newly created document
3. Manually set the `role` field to `"admin"`
4. Sign out and sign back in — you'll now see the Admin Panel

---

## Running the App

```bash
# Web
flutter run -d chrome

# Android
flutter run -d android

# iOS (macOS only)
flutter run -d ios

# All platforms (choose at prompt)
flutter run
```

---

## Firestore Data Schema

```
/categories/{id}
  - name: string
  - description: string
  - iconName: string        (key from AppConstants.categoryIcons)
  - gradientIndex: number   (0–7, references AppColors.categoryGradients)
  - order: number           (for sorting)
  - promptCount: number     (maintained automatically)
  - createdAt: timestamp
  - createdBy: string (uid)

/categories/{id}/prompts/{id}
  - title: string
  - text: string
  - order: number
  - avgRating: number       (maintained via Firestore transaction)
  - ratingCount: number
  - createdAt: timestamp
  - createdBy: string (uid)

/ratings/{userId}_{promptId}
  - userId: string
  - promptId: string
  - categoryId: string
  - rating: number (1–5)
  - timestamp: timestamp

/requests/{id}
  - type: "category" | "prompt"
  - userId: string
  - userEmail: string
  - title: string
  - details: string
  - categoryId?: string     (for prompt requests)
  - status: "pending" | "approved" | "rejected"
  - createdAt: timestamp
  - reviewNote?: string

/users/{uid}
  - email: string
  - role: "admin" | "user"
  - createdAt: timestamp
```

---

## Sample Seed Data

The following 3 categories (with 5 prompts each) are defined as constants in `lib/core/constants/app_constants.dart`. They are **not** written to Firestore automatically — an admin must create them through the Admin Panel or you can seed via a script.

### Category 1: Writing & Content Creation
| # | Title |
|---|---|
| 1 | Viral Blog Post Outline |
| 2 | Engaging Social Media Caption |
| 3 | Story with Vivid Characters |
| 4 | Product Description Writer |
| 5 | Newsletter Introduction Hook |

### Category 2: Business Strategy
| # | Title |
|---|---|
| 1 | SWOT Analysis Generator |
| 2 | Go-to-Market Strategy |
| 3 | Competitive Analysis Framework |
| 4 | OKR Goal Setting |
| 5 | Business Model Canvas |

### Category 3: Email & Communication
| # | Title |
|---|---|
| 1 | Cold Outreach Email |
| 2 | Follow-Up Email Sequence |
| 3 | Difficult Conversation Email |
| 4 | Partnership Proposal Email |
| 5 | Executive Summary Email |

---

## Project Structure

```
lib/
├── main.dart
├── firebase_options.dart       ← REPLACE with FlutterFire CLI output
├── core/
│   ├── theme/
│   │   ├── app_colors.dart
│   │   └── app_theme.dart
│   ├── router/
│   │   └── app_router.dart
│   ├── constants/
│   │   └── app_constants.dart
│   └── utils/
│       └── share_utils.dart
├── models/
│   ├── category_model.dart
│   ├── prompt_model.dart
│   ├── request_model.dart
│   └── user_model.dart
├── services/
│   ├── auth_service.dart
│   └── firestore_service.dart
└── features/
    ├── auth/
    ├── home/
    ├── category/
    ├── prompt/
    ├── admin/
    ├── requests/
    └── profile/
```

---

## Color Palette

| Token | Value | Usage |
|---|---|---|
| Primary | `#4F46E5` | Buttons, active states, headers |
| Secondary | `#F59E0B` | Accents, ratings |
| Background | `#F8FAFC` | Page background |
| Surface | `#FFFFFF` | Cards, dialogs |
| Success | `#10B981` | Approved status |
| Error | `#EF4444` | Errors, delete |
| Warning | `#F59E0B` | Pending status |

---

## License

MIT — use freely for personal and commercial projects.
