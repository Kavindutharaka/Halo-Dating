# Halo App — Firebase Setup & OTP Integration Guide

## 1. Create Firebase Project

1. Go to https://console.firebase.google.com
2. Click **Add project** → Name it `halo-e1d1a` (or your project name)
3. Disable Google Analytics (not needed) → **Create project**

---

## 2. Register Android App

1. In Firebase Console → **Project Settings** (gear icon) → **General**
2. Scroll to **Your apps** → Click **Add app** → Choose **Android**
3. Fill in:
   - Android package name: `com.halo.halo`
   - App nickname: `Halo Android`
4. Click **Register app**
5. **Download `google-services.json`**
6. Place it at: `android/app/google-services.json`
7. Click **Next** through the remaining steps (Gradle files are already configured)

---

## 3. Enable Phone Authentication

1. Firebase Console → **Authentication** (left sidebar)
2. Click **Get started** (first time) → **Sign-in method** tab
3. Click **Phone** provider
4. Toggle **Enable** → Click **Save**

---

## 4. Add SHA Fingerprints (REQUIRED for Android OTP)

Phone Auth on Android requires your app's SHA keys registered in Firebase.

### Get your debug SHA keys:
```
cd android
.\gradlew signingReport
```

Copy the **SHA-1** and **SHA-256** from the output, then:

1. Firebase Console → **Project Settings** → **General**
2. Scroll to your Android app → Click **Add fingerprint**
3. Add **SHA-1** → Save
4. Add **SHA-256** → Save
5. **Re-download `google-services.json`** and replace `android/app/google-services.json`

> ⚠️ After adding fingerprints you MUST download and replace google-services.json — the file changes.

---

## 5. Enable Sri Lanka SMS Region

By default Firebase blocks SMS to some regions including Sri Lanka (+94).

1. Firebase Console → **Authentication** → **Settings** tab
2. Click **SMS region policy**
3. Choose **Allowlist** and add **LK (Sri Lanka)**
   - OR choose **All regions allowed**
4. Click **Save**

---

## 6. Add Test Phone Numbers (for development)

Avoid real SMS costs while testing:

1. Firebase Console → **Authentication** → **Sign-in method**
2. Scroll to **Phone numbers for testing**
3. Click **Add phone number**
4. Add: Phone `+94767378686` → Code `123456`
5. Click **Save**

These numbers bypass real SMS and always work with the test code you set.

---

## 7. Set Up Firestore Database

1. Firebase Console → **Firestore Database** (left sidebar)
2. Click **Create database**
3. Choose **Start in test mode** (for development) → **Next**
4. Select region: `asia-south1 (Mumbai)` (closest to Sri Lanka) → **Enable**

### Firestore Security Rules (paste in Rules tab):
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Users can read/write their own profile
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }

    // Likes — authenticated users can create, only owner can read
    match /likes/{likeId} {
      allow read, write: if request.auth != null;
    }

    // Matches — only matched users can read
    match /matches/{matchId} {
      allow read, write: if request.auth != null &&
        (resource == null || request.auth.uid in resource.data.users);

      match /messages/{messageId} {
        allow read, write: if request.auth != null;
      }
    }

    // Reports — authenticated users can create
    match /reports/{reportId} {
      allow create: if request.auth != null;
      allow read, write: if false; // admin only
    }

    // Verifications — only owner can create/read
    match /verifications/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

---

## 8. Set Up Firebase Storage

1. Firebase Console → **Storage** (left sidebar)
2. Click **Get started** → **Next** → **Done**

### Storage Security Rules (paste in Rules tab):
```
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {

    // Profile photos — authenticated users can read, only owner can write
    match /profile_photos/{userId}/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }

    // Verification docs — only owner can read/write, NOT publicly readable
    match /verification_docs/{userId}/{allPaths=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

---

## 9. How OTP Authentication Works in This App

### Flow Diagram:
```
User enters phone number
        ↓
App calls Firebase.verifyPhoneNumber()
        ↓
Firebase sends SMS to the number
        ↓
User enters 6-digit OTP
        ↓
App creates PhoneAuthCredential(verificationId + OTP)
        ↓
App calls Firebase.signInWithCredential(credential)
        ↓
Firebase verifies → Returns FirebaseUser
        ↓
App checks Firestore for existing user doc
    ├── Exists → load user data
    └── New user → create user doc in Firestore
        ↓
AuthProvider notifies → AuthWrapper rebuilds
    ├── isProfileComplete = false → ProfileSetupScreen
    └── isProfileComplete = true  → MainNavigation
```

### Code location:
| Step | File |
|------|------|
| Send OTP | `lib/providers/auth_provider.dart` → `sendOtp()` |
| Handle OTP sent | `lib/providers/auth_provider.dart` → `onCodeSent` callback |
| Verify OTP | `lib/providers/auth_provider.dart` → `verifyOtp()` |
| Phone input UI | `lib/screens/auth/phone_login_screen.dart` |
| OTP input UI | `lib/screens/auth/otp_verification_screen.dart` |
| Auth state routing | `lib/main.dart` → `AuthWrapper` |

---

## 10. Common OTP Errors & Fixes

| Error | Cause | Fix |
|-------|-------|-----|
| `CONFIGURATION_NOT_FOUND` | Phone Auth not enabled OR SHA not added | Steps 3 + 4 above |
| `SMS unable to be sent until region enabled` | +94 region blocked | Step 5 above |
| `invalid-phone-number` | Wrong format | Use format `+94XXXXXXXXX` (no spaces) |
| `too-many-requests` | Rate limit hit | Wait 1 hour or use test numbers |
| `session-expired` | OTP timeout (60s) | Request new OTP |
| `invalid-verification-code` | Wrong OTP entered | Check the SMS or use test number |
| `No AppCheckProvider` warning | App Check not set up | Optional — won't block auth |

---

## 11. Quick Test Checklist

After completing setup, verify each step:

- [ ] `google-services.json` is in `android/app/`
- [ ] Phone Auth is enabled in Firebase Console
- [ ] SHA-1 and SHA-256 are added in Project Settings
- [ ] `google-services.json` was re-downloaded after adding SHA keys
- [ ] Sri Lanka (+94) is in the SMS allowlist
- [ ] Test phone number added (optional but recommended)
- [ ] Firestore database created
- [ ] Security rules updated
- [ ] Firebase Storage enabled
- [ ] Run `flutter run` → enter phone → receive OTP → verify

---

## 12. Firestore Database Structure

```
users/
  {uid}/
    name, dateOfBirth, gender, city, bio
    photoUrls[], isPremium, premiumUntil
    isVerified, verificationStatus
    isProfileComplete, dailyLikesUsed
    personalityAnswers{}, lifestyleAnswers{}
    relationshipAnswers{}, funAnswers{}

likes/
  {fromUid}_{toUid}/
    fromUserId, toUserId, likedAt

matches/
  {matchId}/
    userId1, userId2, users[], matchedAt
    lastMessage, lastMessageAt

    messages/
      {messageId}/
        senderId, text, sentAt, isRead

reports/
  {reportId}/
    reportedByUid, reportedUserUid
    reason, details, reportedAt

verifications/
  {uid}/
    userId, idPhotoUrl, selfieUrl
    status, submittedAt
```
