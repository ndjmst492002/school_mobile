# Mouktassab — Mobile App

A Flutter app (Chrome web + real Android device) backed by a Django REST + WebSocket server.
Three roles: **Teacher**, **Parent**, **Student** (plus Admin), with chat, attendance, exercises, AI prediction, and Chargily payments.

---

## 1. Install These First

| Program | Version | Why |
|---|---|---|---|
| **Python** | 3.12 | Backend runtime (the language Django is written in) |
| **Git** | latest | Clones the project from the repository |
| **PostgreSQL + pgAdmin 4** | 12+ (latest recommended) | The database — stores all users, classes, exercises, messages |
| **Flutter (stable)** | 3.41.9 (latest recommended) | Builds the mobile/web app — install from [flutter.dev](https://flutter.dev) |
| **Android Studio** | latest recommended | Brings JDK 17 + Android SDK + a built-in terminal |
| **Google Chrome** | latest recommended | The browser we use to test the web version |
| **Visual Studio (Code or Community)** | latest recommended | For editing the backend code + has its own terminal |
| **ngrok** | latest recommended | Gives the backend a public HTTPS URL — Chargily needs it to redirect after payment (download from [ngrok.com](https://ngrok.com/download)) |

After installing Flutter, open a terminal and run `flutter doctor` — fix any red ✗ items before continuing.

---

## 2. Get the Project

Open a terminal in the folder where you want the project (e.g. Desktop):

### Backend

```bash
git clone -b added-level-table --single-branch https://github.com/ZA3MA3/school_backend.git
cd school_backend
git pull
cd ..
```
### Mobile App

```bash
git clone -b mobile-frontend --single-branch https://github.com/ndjmst492002/school_mobile.git school_mobile
cd school_mobile
git pull
cd ..
```

You should now have `school_backend/` and `school_mobile/` side by side.

---

## 3. Backend Setup

The backend is a **Django** server. It exposes the API (URLs the app calls) and handles the database, WebSocket chat, and Twilio/Chargily integrations.

### 3.1. Install pgAdmin 4

> **What is pgAdmin?** A visual tool for managing your local PostgreSQL database. We use it to load the `school_db_4` file.

1. Download pgAdmin 4 from <https://www.pgadmin.org/download/> (Windows installer)
2. Run the installer → Next → Next → Install
3. When prompted, set a **master password** (this is for pgAdmin itself, not postgres — pick anything you'll remember)
4. Open pgAdmin 4 → it asks for the master password → enter it
5. In the left panel, click **Servers** → **Register** → **Server…**
6. On the **General** tab, name it `Local Postgres`
7. On the **Connection** tab, enter:

| Field | Value |
|---|---|
| Host name / address | `localhost` |
| Port | `5432` |
| Maintenance database | `postgres` |
| Username | `postgres` |
| Password | `admin123` |

> These credentials **must match the `.env` file** in the next step. If your local postgres user has a different password, change `DB_PASSWORD` in `.env` to match.

8. Click **Save** → you should see your server appear in the left panel

### 3.2. Restore the database

With the database file `school_db_4` follow these steps:

1. Open **pgAdmin 4** → right-click **Databases** → **Create** → **Database** → name it `school_db_4` → Save
2. Right-click the new `school_db_4` → **Restore…**
3. **Format:** `Custom` or `Tar` (whichever the file was)
4. **Filename:** browse to the `school_db_4` file → **Restore**

#### Verify the restore

Quick check that the file loaded correctly:

1. In the left panel, expand `school_db_4` → **Schemas** → **Tables**
2. Look for the **users** table — right-click it → **View/Edit Data** → **All Rows**
3. You should see a list of users (the 5 test accounts + admin)

If the table list is empty or no rows appear, the restore didn't pick up the data — re-do the restore step and double-check the file path.

### 3.3. Get a public URL with ngrok

> **Why ngrok?** Chargily sends the user back to `FRONTEND_URL` after a payment. Your Django backend is running on `http://localhost:8000` — that's only reachable from your own PC. Chargily's servers can't see it, so the payment redirect would fail. ngrok gives the backend a **public HTTPS URL** that anyone (including Chargily) can reach.

1. Go to **[ngrok.com](https://ngrok.com)** → **Sign up free** (Google or email)
2. After signing in, the dashboard shows **Your Authtoken** — copy it
3. Open a CMD/PowerShell terminal and run (keep it running, don't close it):
   ```bash
   ngrok config add-authtoken YOUR_AUTHTOKEN_HERE
   ```
4. Now start the tunnel — this forwards your local port 8000 to a public HTTPS URL:
   ```bash
   ngrok http 8000
   ```
5. The terminal shows a screen like:
   ```
   Session Status   online
   Forwarding       https://xxxx-xxx-xxx-xxx-xxx.ngrok-free.app -> http://localhost:8000
   ```
6. Copy the **`https://....ngrok-free.app`** URL and paste it into `FRONTEND_URL=` in your `.env` file
7. **Also add the ngrok URL to Django's allowed hosts** — open `school_backend/school_backend/settings.py` and find the `ALLOWED_HOSTS` list (line 49). Add the ngrok URL as a string inside the list, for example:
   ```python
   ALLOWED_HOSTS = ['localhost', '127.0.0.1','rendering-rebate-headcount.ngrok-free.dev', '192.168.1.3', 'c5c3-154-252-33-236.ngrok-free.app']
   ```
   (The part before `ngrok-free.app` is different every time you restart ngrok — use your actual URL.)
8. Save both the `.env` and `settings.py` files

> **Important:** every time you restart `ngrok http 8000`, the URL changes. So:
> - Start **ngrok first** → copy the new URL → paste into `.env` → then start the backend (`daphne`).
> - If you restart ngrok, copy the new URL into `.env` and restart the backend.

> **Leave the ngrok terminal open** — closing it stops the public URL.

### 3.4. Get your Chargily test keys

1. Go to **[pay.chargily.net/test](https://pay.chargily.com/dashboard/login)** → sign up / log in
2. Then to the **Dashboard** → **Developers Corner** → **Test Mode Keys**
3. Copy the **Public key** (starts with `test_pk_…`) → paste into `TEST_CHARGILY_PUBLIC`
4. Copy the **Secret key** (starts with `test_sk_…`) → paste into both `TEST_CHARGILY_PRIVATE` **and** `CHARGILY_WEBHOOK_SECRET`

### 3.5. Set up the Chargily webhook (2 minutes)

> **Why a webhook?** When a user pays on Chargily's site, Chargily needs to notify your backend so it can activate the subscription. That notification is sent to a **webhook URL** — an endpoint on your backend that Chargily calls automatically. Without this, paid subscriptions stay inactive forever.

1. Go to **Dashboard** → **Developers corner** → **Webhook endpoint**
2. In the **URL** field, paste your ngrok URL followed by `/api/users/payments/webhook/`. For example:
   ```
   https://xxxx-xxx-xxx-xxx-xxx.ngrok-free.app/api/users/payments/webhook/
   ```
3. Click **Save**

> Make sure the ngrok URL here matches the `FRONTEND_URL` you set in `.env` — both should be the same `https://....ngrok-free.app` address.

### 3.6. Install + run the backend

Open the `school_backend` folder in **Visual Studio** (or VS Code). Open its terminal (**View → Terminal** in VS, or the integrated terminal in VS Code with **Ctrl+`**) and run these commands one by one:

```bash
python -m venv venv
venv\Scripts\activate
pip install -r requirements.txt
python manage.py migrate
daphne -b 0.0.0.0 -p 8000 school_backend.asgi:application
```

> Use **`daphne`**, not `runserver` — the app uses **WebSocket** (live chat) which requires ASGI, not the regular HTTP server.
>
> If `pip install` fails on `tensorflow`, first run `pip install --upgrade setuptools wheel` then retry.

You should see `Starting server at 0.0.0.0:8000`. **Leave this terminal open** — closing it stops the backend.

If postgres complains about the password, change `DB_PASSWORD` in `.env` to match your local postgres user, save, and re-run the `daphne` command.

---

## 4. Run the App on Chrome (Web)

> **Why Chrome?** It's the fastest way to test changes compared to a phone. The same Flutter code runs in the browser.

1. Open the `school_mobile` folder in **Android Studio**
2. Wait for the first **Gradle sync** to finish (progress bar in the bottom-right) — this downloads the Android build tools
3. Open the **terminal inside Android Studio** (bottom bar → **Terminal** tab)
4. Run:

```bash
flutter pub get
flutter run -d chrome --web-port 5000
```

> `flutter run -d chrome --web-port 5000` — forces Chrome to open on **port 5000** instead of a random port. This is required because **Google Sign-In only works on whitelisted ports**, and `5000` is the one registered in Google Cloud Console for this project. Don't change it.

Chrome opens at `http://localhost:5000/` with the **Mouktassab** login screen. You're done.

---

## 5. Run the App on a Real Android Device

The phone and your PC must be on the **same Wi-Fi** network.

> **Why Wi-Fi, not USB?** You can use either. USB is simpler; wireless is more convenient for repeated testing.

### 5.1. Set the backend URL on the phone

> **What is a base URL?** It's the address the Flutter app uses to call the backend. On Chrome, the app and the backend are on the same machine, so `localhost` works. On a phone, "localhost" points to the phone itself — so we point it at your PC's LAN IP instead.

1. Find your PC's LAN IP — open a terminal and run `ipconfig`, look for `IPv4 Address` under Wi-Fi (e.g. `192.168.1.3`)
2. In Android Studio, open `lib/app/data/providers/api_provider.dart` (line 13):

```dart
//static const String baseUrl = 'http://localhost:8000/api';
static const String baseUrl = 'http://192.168.1.3:8000/api';   // <-- your IP adress (from ipconfig command)
```

3. If your IP is **not** `192.168.1.3`, also open `school_backend/school_backend/settings.py` line 49, add your IP inside `ALLOWED_HOSTS` (e.g. `'192.168.1.10'`), save, and **restart the backend**.

### 5.2. Enable Developer Mode on the phone

Settings → About phone → tap **Build number** 7 times → "You are now a developer!" appears.

> This unlocks the hidden **Developer options** menu where USB/Wireless debugging is turned on.

### 5.3. Connect the phone (pick ONE method)

**Method A — USB cable (easiest):**

1. Plug the phone into the PC
2. On the phone: pull down the notification shade → tap the USB notification → switch to **Transferring files / Android Auto**
3. Go to Developer options → Click USB debugging
4. Accept the **"Allow USB debugging?"** popup

**Method B — Wireless (no cable):**

1. Make sure phone and PC are on the **same Wi-Fi**
2. On the phone: **Settings → Developer options → Wireless debugging → toggle ON**
3. Tap **"Pair using QR code"** or **"Pair device with pairing code"**
4. On the PC: **Android Studio → Device Manager (the phone icon in the right sidebar)** → click the **"Pair using Wi-Fi"** button
5. Choose **"Pair using QR code"** (scan the one on the phone) **or** **"Pair using pairing code"** (enter the 6-digit code shown on the phone)
6. Once paired, the phone appears in Android Studio's device dropdown.

### 5.4. Launch

In Android Studio:

1. Top toolbar **device dropdown** (right of the green Run ▶ button) → pick your device
2. Click the green **Run ▶** button

> **What happens on first Run?** Android Studio compiles the app to native Android code (3–5 minutes the first time). After that, just click ▶ to rebuild, or press **R** in the Run panel to **hot-reload** — Flutter pushes code changes to the running app in ~1 second.

---

## 6. Test Accounts

These are seeded in the database:

| Role | Email | Password |
|---|---|---|
| **Teacher** | teacher@example.com | teacher123 |
| **Parent** | parent1@example.com | parent123 (has student dashboards) |
| **Admin** | admin@example.com | admin123 |

To sign in, open the app → **Sign in to your account** → enter the email + password → **Login**.

### Sign in with your own Google account

You can also use any Google account to create a brand-new account. The app asks you to pick a role during signup, and the role you pick decides what plan you pay for and which dashboard you land on.

1. Open the app → **Sign in to your account**
2. Click **Sign in with Google**
3. Pick your Google account in the popup → grant permission
4. Enter your **phone number** → the backend generates a verification code
5. Enter the OTP code **`123456`** → you're taken to **Select Your Role**

> **Why `123456`?** Because the `.env` file sets `TWILIO_USE_TEST=True` and uses Twilio's magic test phone number `+15005550006`. In test mode Twilio does **not** actually send any SMS — it just pretends to. So the backend hard-codes the OTP to `123456` (see `users/views.py:1745`) instead of generating a random code, so you can complete verification without needing a real phone. In production, Twilio sends a real random 6-digit code by SMS.
6. Pick one role or both, then complete the matching profile form:

| Role(s) you pick | What you fill in next | Redirected to |
|---|---|---|
| **Teacher only** | Hire date, specialization, level, class | **Teacher Dashboard** (subscription: 3,000 DZD) |
| **Parent only** | Your occupation + at least 1 child (name, enrollment date) | **Parent Dashboard** (subscription: 2,000 DZD) |
| **Teacher + Parent** | Teacher form **then** Parent form (Step 1 of 2 → Step 2 of 2) | Dashboard picker (subscription: 5,000 DZD) — you can switch roles from the AppBar later |

> After completing the form, the app sends you back to the **Login** screen. Sign in with Google one more time to continue.

#### Paying with Chargily (Subscription step)

When you log in, the app checks if your subscription is active. If not, it shows a **Subscription Required** screen before letting you into the dashboard.

1. On the Subscription screen, click **Subscribe Now**
2. A Chargily **checkout page** opens in your browser (web) or in an in-app WebView (mobile)
3. Fill in the card fields — it doesn't matter if the details are correct, it's test mode
4. Click **Pay** → Chargily shows a success page
5. The app auto-detects the success → closes the checkout → polls your subscription status
6. Within a few seconds you're redirected to your **Dashboard** (Teacher / Parent / both)

> After this, the Subscription page is only shown again if your subscription expires.

If Google Sign-In shows a "redirect URI mismatch" error, make sure Chrome is running on **port 5000** (Android Studio's saved run config handles this — don't change it).
