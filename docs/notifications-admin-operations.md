# Athaar notification operations

- Local reminders run on each device and need no account or network.
- Admin broadcasts use the FCM topic `athaar_all`; users explicitly opt in.
- Firebase Console project access is the administration authorization boundary.
- Restrict project access to trusted maintainers and require multi-factor authentication.
- Use announcements only for service notices and important updates. Do not include personal or confidential information.
- Preview Arabic title/body and audience before sending; retain campaign history in Firebase Console.
- Respect opt-out and never silently re-subscribe a user.

There is no in-app admin composer, custom login, per-user targeting, or delivery
receipt dashboard in this phase. Those require a separately designed secure
administration system.
