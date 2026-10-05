# CIVIC

CIVIC is a civic legal companion and statutory defense directory designed for Indian citizens. It delivers immediate, verified legal guidance, procedural safeguards, and emergency resources for real-world interactions, including traffic checkpoints, police encounters, arrest protocols, and regulatory filings.

The application reflects recent legal transitions in India, aligning procedures with the Bharatiya Nyaya Sanhita (BNS 2023), Bharatiya Nagarik Suraksha Sanhita (BNSS 2023), the Constitution of India, and relevant provisions of the Motor Vehicles Act.

Live Web Deployment: https://civic-84e44.web.app

---

## Key Features

- Statutory Protocol Gallery: Pinned showcase gallery presenting core citizen safeguards, including Traffic Stop Protocols, Arrest Safeguards, Zero FIR Mandates, Digital Device Privacy, and Night Arrest Restrictions for Women.
- 28+ Offline Scenario Cards: Actionable, step-by-step guidance for high-pressure situations such as unwarranted searches, vehicle impoundment, detention procedures, and bail rights.
- Transition Reference (CrPC to BNSS and IPC to BNS): Cross-reference tables and statutory breakdowns to help citizens understand active legal terminology and procedural changes.
- Emergency Dispatch and Directory: Quick access to national emergency helplines, state legal service authorities, verified legal clinics, and court directories.
- Digital Rights and Evidence Safeguards: Protocols for recording interactions legally under Indian law, protecting digital devices from unlawful searches, and preserving digital evidence.
- Accessibility and Audio Narration: Built-in text-to-speech functionality (`flutter_tts`) and audio recording capabilities for capturing notes or listening to rights on demand.
- Offline-First Reliability: Critical statutory articles, procedural checklists, and emergency numbers are stored locally for immediate access in low-connectivity or no-network environments.
- Flexible Authentication: Anonymous guest access for privacy-sensitive research alongside Google Sign-In and email authentication powered by Firebase.

---

## Architecture and Structure

The codebase is organized modularly by feature:

```
lib/
|-- core/
|   |-- constants/          # Application strings, routes, and asset paths
|   |-- theme/              # Color palettes, typography, and component styling
|   +-- utils/              # Helper utilities, animations, and common formatters
|-- features/
|   |-- auth/               # Firebase authentication (Anonymous, Email, Google)
|   |-- directory/          # Legal clinic directories, court listings, rights guides
|   |-- navigation/         # Bottom navigation, responsive layout, dynamic footer
|   |-- onboarding/         # Initial walkthrough and legal context onboarding
|   |-- scenarios/          # 28+ statutory defense scenario guides and checklists
|   |-- showcase/           # Horizontal scroll gallery for primary protocols
|   |-- splash_loading/     # Application initialization and asset preloading
|   +-- tabs/               # Primary application modules:
|       |-- ask/            # Rights queries and legal Q&A interface
|       |-- help/           # Emergency dispatch, panic response, and helplines
|       |-- home/           # Dashboard, quick actions, and featured scenarios
|       |-- notes/          # Personal legal incident logs and voice notes
|       +-- prepare/        # Checklists for FIRs, court appearances, and RTIs
+-- firebase_options.dart   # Firebase configuration for Web, Android, and Windows
```

---

## Technology Stack

- Framework: Flutter SDK 3.13.2+
- Language: Dart 3.1+
- State and Flow: ValueNotifier architecture and responsive viewport controllers
- Cloud and Backend: Firebase Core, Firebase Authentication, Cloud Firestore
- Typography: Google Fonts (Plus Jakarta Sans, JetBrains Mono, Inter)
- Audio and Media: flutter_tts, record, audioplayers, file_picker, image_picker
- Platform Support: Web, Android, Windows

---

## Getting Started

### Prerequisites

- Flutter SDK (version 3.13.2 or later)
- Dart SDK (version 3.1.0 or later)
- Google Chrome or Chromium (for web development)
- Android Studio / Android SDK (for Android deployment)
- Firebase CLI (for deployment and cloud configuration)

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/Rishit-07/Civic.git
   cd civic
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the development server:
   - For Web:
     ```bash
     flutter run -d chrome
     ```
   - For Android:
     ```bash
     flutter run -d <device-id>
     ```
   - For Windows:
     ```bash
     flutter run -d windows
     ```

### Testing

Run the test suite with:

```bash
flutter test
```

---

## Deployment

### Web Deployment (Firebase Hosting)

The web version is deployed to Firebase Hosting. To build and deploy updates:

1. Build the production release bundle:
   ```bash
   flutter build web --release
   ```

2. Deploy using the Firebase CLI:
   ```bash
   firebase deploy --only hosting
   ```

Live URL: https://civic-84e44.web.app

---

## Legal Frameworks Referenced

- Constitution of India (Articles 19, 20, 21, 22, 32, 226)
- Bharatiya Nagarik Suraksha Sanhita (BNSS), 2023
- Bharatiya Nyaya Sanhita (BNS), 2023
- Bharatiya Sakshya Adhiniyam (BSA), 2023
- Motor Vehicles Act, 1988 (and 2019 Amendment)
- Right to Information Act (RTI), 2005
- D.K. Basu Guidelines on Arrest and Custodial Interrogation

---

## Legal Disclaimer

CIVIC is designed strictly for informational, educational, and civic literacy purposes. It is not a substitute for formal legal representation or professional legal counsel. Laws and court precedents are subject to amendment and regional interpretation. In urgent legal situations, always consult a licensed advocate or contact your state legal aid services authority.
