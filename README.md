# CareTrack

A Flutter healthcare coordination app built on Firebase, connecting medical staff and patients through real-time status tracking, health reports, and proximity-based alerts.

## Overview

CareTrack lets medical staff monitor patient health status and review submitted reports, while patients can log symptoms and receive local alerts when someone marked unhealthy is nearby — powered by geolocation and local push notifications.

## Features

### Patients
- Register and log in with email and password
- Submit health reports
- Automatic background check for nearby patients marked unhealthy (within 200 meters)
- Local notification on detection, with a map view of nearby cases
- View account profile, including current health status

### Medical Staff
- View a list of all registered patients
- Toggle a patient's health status (Healthy / Patient)
- View and delete submitted patient reports
- View account profile

### Shared
- Password reset via email
- Logout

## Tech Stack

- **Flutter** (Dart) — client application
- **Firebase Authentication** — email/password auth
- **Cloud Firestore** — application database
- **go_router** — declarative navigation with role-based redirects
- **geoflutterfire_plus** — geohash-based Firestore proximity queries
- **flutter_local_notifications** — local push alerts
- **flutter_map** + OpenStreetMap — map rendering (no API key/billing required)
- **geolocator** / **permission_handler** — device location access

## Architecture

Feature-first folder structure, grouped by domain rather than file type:

```
lib/
  core/
    models/       # data models (User, Report)
    services/      # Firebase/Firestore/location/notification logic
    router/        # go_router config + auth-aware redirects
    theme/         # app-wide theming
  features/
    auth/          # welcome, register, login, forgot password
    patient/       # patient home, report submission, nearby-patients map
    staff/         # patients list, reports management
    profile/        # shared profile screen (staff + patient)
```

## Getting Started

### Prerequisites

- Flutter SDK
- A Firebase project with **Authentication** (email/password provider) and **Firestore** enabled
- Firebase CLI and FlutterFire CLI installed

### Setup

1. Clone the repository and install dependencies:
   ```
   flutter pub get
   ```
2. Connect the app to your own Firebase project:
   ```
   flutterfire configure
   ```
3. Add the following permissions to `android/app/src/main/AndroidManifest.xml`:
   ```xml
   <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
   <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
   <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
   ```
4. Run the app:
   ```
   flutter run
   ```
5. On first run, if a proximity query fails with a Firestore index error, follow the link in the error message to auto-create the required composite index.

## Security

Firestore access is enforced through role-based security rules:

- Users may only update specific fields on their own account
- Health status changes are restricted to medical staff accounts
- Report visibility and deletion are restricted to medical staff
- Report creation is restricted to the authenticated patient submitting it

## Notes

- Distance calculations use a 200-meter radius, matching the app's proximity-alert requirement.
- Map tiles are served by OpenStreetMap's public tile server, suitable for development and demo use.