# Athaar Privacy Notice — Draft for Owner Review

**Status: DRAFT — NOT FOR PUBLICATION**  
**Last reviewed against the current repository:** 2026-11-28  
**Application:** Athaar (أَثَر)

> This is an engineering disclosure draft based on the current source tree. It is not legal advice. The owner must complete the operator identity, jurisdiction, contact details, retention and legal review before publishing it or submitting the app to a store.

## 1. Who operates Athaar

- Legal/operator name: **[OWNER MUST COMPLETE]**
- Country and business/contact address: **[OWNER MUST COMPLETE]**
- Privacy contact email: **[OWNER MUST COMPLETE]**
- Public support website: **[OWNER MUST COMPLETE]**

Do not publish this notice while these fields are incomplete.

## 2. Account and cloud storage

The current local-first application does not require an Athaar account. The current repository does not configure an Athaar application backend, cloud account system, user-profile service, or cloud synchronization service. User-owned reading and learning records are stored in the application's local database on the device.

This statement must be rechecked if authentication, synchronization, analytics, crash reporting, payment, messaging, or other backend services are added.

## 3. Information stored on the device

The current application stores local application data such as:

- Reading position and Quran navigation state.
- Bookmarks and private notes.
- Memorization status and revision-session progress.
- Personal adhkar counters and related local progress.
- Application settings and local metadata.
- Recitation files that the user explicitly downloads, stored in the application's private support directory on supported native platforms.

These records are intended to remain on the device. The current code does not upload these local records to an Athaar-operated server. Recitation downloads can be deleted from the application interface. Other local records are removed when application data is cleared or the application is uninstalled, subject to the operating system's behavior and backup settings.

The current implementation does not provide a verified cross-device backup or account-based recovery service. Users should not assume local records will survive uninstalling, device loss, or clearing application data.

## 4. Network requests and third-party providers

Some study features require an internet connection. The application makes requests to third-party services for the requested religious content:

| Feature | Provider | Request behavior |
|---|---|---|
| Tafsir | jsDelivr-hosted pinned Al-Jami' Al-Wajiz data release | The selected surah and ayah reference are requested when the study screen loads tafsir. |
| Translation catalogue and selected ayah translation | QuranEnc | The catalogue is requested when the study screen loads; the selected translation and ayah are requested when a translation is loaded. |
| Reciter catalogue and ayah audio metadata | AlQuran Cloud API | The catalogue is requested when the study screen loads; ayah audio metadata is requested when the user starts playback. |
| Full-surah audio downloads and playback | Islamic Network CDN | Audio files are requested only after the user initiates a download or playback action. |

A network provider may receive the IP address, connection metadata, requested URL/resource identifiers (including the selected surah/ayah where part of the URL), and technical request headers. These providers operate under their own terms and privacy practices. Athaar does not control their independent server logs or retention.

The application code does not intentionally send the user's private notes, bookmarks, memorization progress, adhkar counts, or local database to these content providers.

## 5. Audio and microphone

The current main-branch application provides recitation streaming and user-initiated private offline recitation downloads. It does not currently include an integrated voice-recording or speech-assessment workflow in the main release candidate. Any future microphone or recording feature requires a separate permission, clear in-app notice, explicit user action, retention controls, and a new privacy review before release.

## 6. Analytics, advertising, and payments

The current main-branch dependency and application configuration reviewed for this draft does not identify an Athaar analytics SDK, advertising SDK, payment SDK, or user-account backend. This must be confirmed by a final dependency, native manifest, and build-configuration audit before publication.

Do not state that the app is ad-free, payment-free, or free of all third-party tracking unless that final audit confirms it for every shipped platform and build variant.

## 7. Quran and learning content

The application uses locally bundled Quran text under its source-specific terms and online content providers for selected translations, tafsir, and recitations. Source attribution and licence details are presented in the application's About/Sources area. Content providers may process content requests as described above.

## 8. Data security

Local records are stored within application-managed storage. The current local-first architecture is designed to avoid sending private learning records to an Athaar server. No system can guarantee absolute security. Device access controls, operating-system security, backups, and device compromise may affect the confidentiality of locally stored information.

## 9. User choices and deletion

- Users may use the core local reading and progress features without creating an Athaar account.
- Users may delete downloaded recitation files through the audio interface.
- Users may clear the application's local data or uninstall it using operating-system controls; this removes locally stored records subject to operating-system and backup behavior.
- Network-dependent tafsir, translation, and audio features may be unavailable when offline unless the relevant audio has already been downloaded.

Before public release, the owner must verify whether the app exposes a complete in-app deletion/reset path for all local learning data and add it if required.

## 10. Changes to this notice

This notice must be updated whenever the application adds a backend, account, synchronization, microphone, recording, analytics, crash reporting, advertising, payment, messaging, or other feature that changes data collection or sharing.

## 11. Owner completion checklist

- [ ] Enter the legal operator name and country.
- [ ] Enter a monitored privacy contact email and support URL.
- [ ] Review the final Android, iOS, Windows, and Web dependency/permission manifests.
- [ ] Confirm backup behavior for each platform.
- [ ] Confirm whether the app offers a complete local-data deletion/reset control.
- [ ] Recheck all third-party providers' current privacy notices and terms.
- [ ] Obtain jurisdiction-specific legal review.
- [ ] Publish a stable public HTTPS URL and link it from the app/store listings.
- [ ] Re-review after every material data-flow change.

## 12. Source-code data-flow verification addendum — 2026-11-28

The current Quran study screen starts the following requests when the study screen is opened; they are not all delayed until the user taps a separate content button:

- Tafsir: a pinned Al-Jami' Al-Wajiz JSON resource is fetched from jsDelivr.
- Translation: the QuranEnc catalogue is fetched, then the default selected translation for the current ayah is fetched.
- Recitation: the AlQuran Cloud reciter catalogue is fetched.
- When the user presses Play, AlQuran Cloud ayah-audio metadata is fetched; the returned HTTPS audio URL is then streamed.
- When the user explicitly downloads a surah, the full-surah MP3 is requested from `cdn.islamic.network` and stored in the app support directory.

The content requests include resource identifiers and may include the current surah/ayah or selected edition in the URL. Providers may receive the device IP address, request headers and connection metadata. The current source code does not intentionally include private notes, bookmarks, memorization progress, or adhkar counters in these requests.

The inspected Android manifest contains the INTERNET permission and no microphone permission. The inspected iOS Info.plist contains no microphone usage description. This matches the fact that the current main/PR #37 candidate does not integrate microphone recording or speech recognition. This is a source-file observation, not a substitute for a final merged-artifact and transitive-SDK audit on all platforms.

The settings disclosure was corrected on the PR #37 candidate to state that opening the study screen automatically initiates the catalogue/content requests above. It must not imply that every external request happens only after a separate tap.

**Still required before publication:** final network/SDK audit on release artifacts, platform backup-behavior verification, a complete in-app deletion/reset verification, operator identity and contact details, public HTTPS publication, and jurisdiction-specific legal review. This addendum does not turn the draft into a published or legally approved privacy policy.
