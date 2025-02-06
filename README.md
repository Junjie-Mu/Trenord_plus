# Trenord_plus

This is the repository for the project of DESIGN AND IMPLEMENTATION OF MOBILE APPLICATIONS(DIMA)[2024-25] course held at Polimi.

⚠️ The project has no relation to the real-world  **Trenord**. It is only intended for learning purposes and as an attempt to explore application scenarios for some new features.

## Overview
The Trenord+ App is designed to enhance the user
experience of railway commuters in the Lombardy
region, featuring the following four core functional
modules:
- **Train Tourism**: provides ticket adding, travel reminders, and location-based recommendations for nearby tourist attractions, restaurants, lodging, and shopping.
- **Travel Safety**: integrates safety features such as location sharing, emergency assistance (SOS), and emergency contact settings within the interface.
- **Voice Guidance**: utilizes text-to-speech technology to read out page transitions and important information, enhancing accessibility for users.
- **Personalized Appearance**: allows users to customize the interface theme color based on their preferences and usage habits.
### Framework
- Development Language: **Dart**
- Framework: **Flutter**
- State Management: **GetX** 
- Backend Services: **Firebase**
### User Interface
| ![image](https://github.com/user-attachments/assets/0bbd293f-5159-4cdd-9534-d2eb584e5ab5) | ![image](https://github.com/user-attachments/assets/cb588b9a-12b9-4149-9b3d-99704c12c1db) | ![image](https://github.com/user-attachments/assets/7498db02-f0c8-4ca4-8834-66c9634a7b25) |
|----------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------|
| ![](https://github.com/user-attachments/assets/b8ce7f45-a81e-4433-96c6-493faebef544) | ![](https://github.com/user-attachments/assets/b78e7d0d-6359-4b73-8729-1bf91bcbc755) | ![](https://github.com/user-attachments/assets/4c03bc11-5a4f-4a64-a4a7-d03bc244abf1) |
### Project structure
MVC+S (Model-View-Controller + Service) architecture based on GetX.
```lib/
├── controllers/    # GetX controllers
├── models/         # Data models
├── screens/        # UI screens
├── services/       # Service layer
├── theme/          # Theme configuration
├── utils/          # Utility classes
└── widgets/        # Reusable components
```

### Dependencies
```agsl
dependencies:
  flutter:
    sdk: flutter
  get: ^4.6.6
  firebase_core: ^2.24.2
  firebase_auth: ^4.15.3
  cloud_firestore: ^4.13.6
  google_maps_webservice: ^0.0.20-nullsafety.5
  shared_preferences: ^2.2.2
  flutter_tts: ^3.8.4
  url_launcher: ^6.2.5
  share_plus: ^7.2.1
```
