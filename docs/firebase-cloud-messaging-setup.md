# Athaar — Firebase Cloud Messaging setup

This integration is optional. Quran content, activity tracking and scheduled
reminders continue to work without Firebase or an internet connection.

## Firebase project setup

1. Create a Firebase project for Athaar.
2. Add an Android app with application ID `com.athaar.athaar`.
3. Download `google-services.json` into `android/app/google-services.json`.
4. Add the iOS app using bundle ID `com.athaar.athaar`.
5. Download `GoogleService-Info.plist` into `ios/Runner/GoogleService-Info.plist` and add it to the Runner target in Xcode.
6. Enable Firebase Cloud Messaging in Project Settings.
7. For iOS, upload an APNs authentication key in Firebase Project Settings → Cloud Messaging. Enable Push Notifications and Background Modes → Remote notifications for the Runner target.
8. Rebuild. Android applies the Google Services Gradle plugin only when the JSON file exists. The Athaar Android and iOS client configuration files are already present in this feature branch. These client files identify the Firebase app; they are not Admin SDK credentials. Never commit a Firebase service-account private key, Admin SDK JSON, APNs private key, or other server-side secret.

The Flutter client initializes Firebase from the native configuration bundled with each platform target. A build without
the native files gracefully disables remote announcements without affecting local
notifications.

## User opt-in

In Settings → Notifications, the user can enable or disable
“استقبال إعلانات وتنبيهات الإدارة”. Only opted-in installations subscribe to
the FCM topic `athaar_all`. Registration tokens are not displayed or sent to an
Athaar-owned server.

## Sending an administration announcement

Use the Firebase Console with an account that has the appropriate project
permissions:

1. Open Messaging / Firebase Cloud Messaging.
2. Create a notification campaign.
3. Set the target to **Topic** and enter `athaar_all`.
4. Add the Arabic title and body, preview and send.

Firebase Console is the trusted administration surface in this first phase.
The mobile application contains no sender credentials or public send endpoint.
Messages are public announcements; do not include personal or confidential data.

## Cost and release checks

FCM message delivery itself has no per-message charge. Other Firebase products
and project usage remain subject to their own quotas and terms. This first phase
does not add Firestore, Authentication, Cloud Functions or Supabase.

Before release, test Android 13+ permission prompts and foreground/background/
terminated delivery. Test iOS on a physical device after APNs is configured.
Verify opt-out, and update the privacy notice to explain optional push alerts.
