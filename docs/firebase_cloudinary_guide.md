**Firebase + Google Sign-In + Cloudinary — Implementation Guide**

This short guide explains how Firebase Authentication (email/password + Google Sign-In), Firestore storage for notes, and Cloudinary-based image uploads were implemented in this Flutter project. It's written to be easy to follow and includes where to look in the codebase and simple troubleshooting steps.

**Prerequisites**
- Flutter SDK installed and working.
- A Firebase project configured with Android/iOS apps added.
- A Cloudinary account (cloud name and an upload preset).
- Device or emulator available for running the app.

**Quick commands**
- Install packages:
```
flutter pub get
```
- Run the app (replace `<device-id>` as needed):
```
flutter run -d <device-id>
```

**High-level flow**
- Authentication state is observed in `main.dart`. The app shows either the `HomePage` or the `LoginPage` depending on the Firebase auth state stream.
- `AuthService` wraps Firebase Auth operations (email/password, Google sign-in, password reset, sign-out).
- `CrudService` wraps Firestore operations and Cloudinary uploads. The Add dialog in `HomePage` uses `CrudService` to pick, upload, preview, and save images.

**Where to look in the repo (key files)**
- `lib/auth_service.dart` — all auth functions:
  - `signInWithEmail` — sign in using email/password
  - `registerWithEmail` — create new user (now rethrows errors so UI can show messages)
  - `signInWithGoogle` — Google Sign-In flow (has a timeout and catches errors)
  - `sendPasswordResetEmail` — sends password reset link to the email
  - `signOut` — sign out the user

- `lib/login.dart` — login UI and the "Forgot password" dialog. It calls `AuthService.sendPasswordResetEmail`.

- `lib/register.dart` — register UI; displays specific error messages from registration failures.

- `lib/home_page.dart` — home UI, greeting ("Hey, [first name]!"), sign out button, and Add dialog. The Add dialog can pick an image, upload it to Cloudinary, preview it, and save the document with `image_url` to Firestore.

- `lib/crud_service.dart` — Cloudinary client and Firestore CRUD:
  - Cloudinary client is created with `CloudinaryPublic('your_cloud_name', 'your_preset')`.
  - `pickImageForAddItem()` — uses `ImagePicker` to select a photo from device, uploads it to Cloudinary, and returns the secure URL.
  - `addItemWithImage(name, quantity, imageUrl)` — writes a Firestore document that includes `image_url`.
  - `addItem(name, quantity)` — convenience wrapper for items without images.

**Firebase setup checklist**
1. Create a Firebase project and add Android and/or iOS apps.
2. Download and add `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) into your Flutter project per Firebase instructions.
3. In Firebase Console → Authentication → Sign-in method, enable:
   - Email/Password
   - Google (enable the provider)
4. For Android Google Sign-In: add the app's SHA-1 (and SHA-256 if needed) to Firebase project settings and re-download `google-services.json` after adding.
5. In Firebase Console → Firestore, create a test collection or allow the app (rules depend on your workflow). For development you can use permissive rules, but secure properly before production.
6. For password reset emails: check Authentication → Templates (sender email) and ensure the sender is a verified email. Also check spam/promotions folders when testing.

**Google Sign-In common gotchas**
- If Google sign-in returns `DEVELOPER_ERROR` or fails to authenticate on Android:
  - Make sure the SHA-1 in Firebase console matches the signing key used by the app (debug vs release signing).
  - Ensure the OAuth client in the Google Cloud console is configured for the correct package name and SHA-1.
  - Re-download `google-services.json` and rebuild the app after making changes.

**Cloudinary setup and how we use it**
1. Create a Cloudinary account and note your Cloud name.
2. Create an upload preset (for quick setup you can make an unsigned preset; for production use signed uploads).
3. In `lib/crud_service.dart` you will see something like:
```dart
final cloudinary = CloudinaryPublic('dg1cz2twr', 'flutter_notes_preset');
```
Replace `'dg1cz2twr'` and `'flutter_notes_preset'` with your Cloudinary cloud name and preset.
4. The app uploads files using `CloudinaryFile.fromFile` with `resourceType: CloudinaryResourceType.Image`.
5. After upload the code uses the returned `secureUrl` and writes it to Firestore in the `image_url` field for the note document.

Security note: unsigned presets let clients upload directly and are convenient for prototypes, but for production you should either use signed uploads or route uploads through a trusted server to keep credentials private and limit what can be uploaded.

**Testing the flow locally**
1. Run the app with `flutter run`.
2. Register a new user with email/password in the Register screen. If registration fails, the UI shows the returned error message (e.g., weak-password, email-already-in-use).
3. Try "Sign in with Google" — follow the Google account picker; if it hangs, watch logs for `DEVELOPER_ERROR` and check SHA-1.
4. Use the "Forgot password" dialog to request a reset email — open the test email inbox and check Spam/Promotions.
5. In `HomePage`, open the Add dialog, choose Upload Image, pick a device image, wait for the upload to complete (a preview will appear), then Save. Verify in Firestore that the document has `image_url` with a Cloudinary URL.

**Troubleshooting**
- Password reset email not received:
  - Check Firebase Console → Authentication → Templates: confirm the template sender email is verified.
  - Check Spam/Promotions and all inbox tabs.
  - If using a custom domain or email sending restrictions, confirm that Firebase can send emails for your project.

- Google Sign-In failing with `DEVELOPER_ERROR`:
  - Double-check SHA-1 and package name in Firebase project settings.
  - Ensure OAuth client in Google Cloud Console matches the app configuration.
  - Rebuild and reinstall the app after changes.

- Cloudinary upload fails or returns errors:
  - Confirm your `cloudName` and `uploadPreset` are correct and the preset allows unsigned uploads if you're uploading directly from the client.
  - Check Cloudinary account usage limits and CORS settings.

- Device/emulator issues:
  - For Google Sign-In, make sure the emulator has Google Play services and an available Google account.
  - If `flutter run` reports "No supported devices found" use `flutter devices` to list devices and pick a valid id.

**Where we made the main code changes**
- Auth improvements: `lib/auth_service.dart` — added timeouts, better error propagation, and explicit `sendPasswordResetEmail` usage.
- Login & Register UI: `lib/login.dart`, `lib/register.dart` — improved error display and styles consistent with the home page.
- Home page & image flow: `lib/home_page.dart` — added greeting, sign-out button, and an Add dialog that calls `CrudService.pickImageForAddItem()` and `addItemWithImage()`.
- Cloudinary + Firestore: `lib/crud_service.dart` — Cloudinary client and upload logic; Firestore writes include `image_url`.

**Next steps / ideas**
- Use signed Cloudinary uploads (server-side signing) for production security.
- Add image deletion: remove images from Cloudinary when deleting items in Firestore.
- Add a loading indicator and better error dialogs around upload and sign-in steps for improved UX.
- Add unit or integration tests for auth flows and upload flows where possible.

If you want, I can:
- Update the file with screenshots or inline code examples for specific functions.
- Add a script or helper to validate that `google-services.json` contains expected SHA-1 values.
- Implement image deletion when an item is deleted.

File created: `docs/firebase_cloudinary_guide.md` — open it in your editor for quick review.