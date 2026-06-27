# Mouktassab — Mobile App

A school management mobile app connecting **Teachers**, **Parents**, **Students**, and **Administrators** on one platform.

**Features:**
- Role-based dashboards (Teacher, Parent, Student, Admin)
- Real-time chat between teachers and parents
- Attendance tracking with instant parent notifications
- Exercise creation, submission, and grading
- AI dropout prediction for students
- Dark/light mode, Arabic/English language switcher
- Multi-role support (e.g., a teacher who is also a parent)

---

## Tech Stack

| Layer | Technology |
|---|---|
| **Framework** | Flutter (Dart) |
| **State Management** | GetX |
| **HTTP Client** | Dio with JWT auto-refresh |
| **Real-time** | WebSocket (web_socket_channel) |
| **Backend** | Django REST API (hosted on Render) |
| **Database** | PostgreSQL (Neon) |

> Backend URL: `https://school-backend-9j8f.onrender.com/api`

---

## APK Installation

The compiled APK is available for direct installation on Android devices.

1. Download the APK file
2. On your phone, open the file and allow installation from unknown sources if prompted
3. Open the app and log in with your credentials

---

## Test Accounts

| Role | Email | Password |
|---|---|---|
| **Teacher** | teacher@example.com | teacher123 |
| **Parent** | parent@example.com | parent123 |
| **Student** | student@example.com | student123 |
| **Admin** | admin@example.com | admin123 |

---

## Development Setup

If you want to modify or extend the app:

### Install These First

| Program | Version |
|---|---|
| **Flutter SDK** | 3.41.9+ |
| **Dart** | 3.11.5+ |
| **Android Studio** | latest (includes Android SDK 36.1.0 + bundled JDK 21) |

After installing Flutter, run `flutter doctor` in a terminal and fix any red ✗ items before continuing.

### Run App

1. Clone the project:

```bash
git clone -b mobile-frontend https://github.com/ndjmst492002/school_mobile.git
```

2. Open the project in **Android Studio**
3. Open the terminal inside Android Studio (bottom bar → **Terminal** tab)
4. Install dependencies:

```bash
flutter pub get
```

5. Connect your phone (pick ONE method):

**Method A — USB cable (easiest):**
   - Plug the phone into the PC
   - On the phone: pull down the notification shade → tap the USB notification → switch to **Transferring files / Android Auto**
   - Go to Developer options → Enable **USB debugging**
   - Accept the **"Allow USB debugging?"** popup

**Method B — Wireless (no cable):**
   - Make sure phone and PC are on the **same Wi-Fi**
   - On the phone: **Settings → Developer options → Wireless debugging → toggle ON**
   - Tap **"Pair using QR code"** or **"Pair device with pairing code"**
   - On Android Studio: **Device Manager (phone icon in the right sidebar)** → click **"Pair using Wi-Fi"** → scan QR or enter the 6-digit code

6. Select your phone from the list of available devices (top toolbar dropdown)
7. Run the app:

```bash
flutter run
```

> Or build an APK: `flutter build apk --release`

> Ensure the backend is running locally or open https://school-backend-9j8f.onrender.com in a browser first to wake it up from cold start (~30s) before opening the app.

---

## Project Structure

```
lib/
├── main.dart
├── app/
│   ├── data/
│   │   ├── models/        # Data classes (ClassModel, Exercise, etc.)
│   │   ├── services/      # API services (AuthApi, StudentApi, etc.)
│   │   └── providers/     # Dio HTTP client with JWT interceptor
│   ├── modules/           # Feature modules (login, student, teacher, etc.)
│   ├── routes/            # Navigation routes
│   └── theme/             # Dark/light theme colors
```


