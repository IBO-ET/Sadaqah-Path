# Sadaqah Path

**Sadaqah Path** is a free and open-source Windows desktop application for prayer times and Quran reading.

It is designed to be simple, calm, and free from ads, subscriptions, and user accounts.

## Features

- Daily prayer times for Fajr, Dhuhr, Asr, Maghrib, and Isha
- Next-prayer display and countdown
- Automatic Adhan at prayer time
- Nature video background through YouTube
- Full Quran text available offline after build preparation
- 114 Surahs
- Quran search
- Save the last reading position
- Adjustable Quran font size
- Arabic, German, and English interface
- Windows 64-bit and 32-bit support
- No ads, no subscriptions, no account required

> The Windows edition does not include Qibla and does not request precise location access. Qibla is planned for the mobile edition.

## Download

For normal users, download the latest Windows installer from the **Releases** section:

`Sadaqah-Path-2.1.2-Setup.exe`

The installer lets the user choose:

- English, Deutsch, or العربية
- Windows 64-bit or 32-bit

## Build from source

Requirements:

- Windows 10/11
- Node.js
- NSIS for the combined multilingual installer
- Internet access during the initial build

Run:

```bat
Build-Professional-Setup.cmd
```

The final installer is created in:

```text
dist\Sadaqah-Path-2.1.2-Setup.exe
```

## Quran text

Quran text is sourced from the **Tanzil Project**, Uthmani Quran Text Version 1.1.

- Source: https://tanzil.net
- License: Creative Commons Attribution 3.0
- The project verifies 6236 ayahs during preparation.
- The Tanzil source text is distributed without modification.

See `data/TANZIL_ATTRIBUTION.txt` and `THIRD_PARTY_NOTICES.md`.

## Prayer times

Prayer-time data is requested at runtime from AlAdhan.

The app stores today's retrieved prayer times locally as a same-day fallback.

## Background video and Adhan

The nature background is played using YouTube's embedded player. Video rights remain with the respective owner.

The current Adhan audio is streamed from its external source and is not distributed under the MIT license of this repository.

## Privacy

Sadaqah Path:

- has no user account
- contains no advertising
- contains no advertising trackers
- does not sell user data
- does not request GPS on Windows
- stores app preferences and reading position locally

The selected city and country are sent to the prayer-times service to retrieve daily prayer times. YouTube receives normal web requests when the video background is enabled.

See `PRIVACY.md`.

## Languages

- العربية
- Deutsch
- English

## License

Application source code: **MIT License**.

Third-party data and media remain under their own licenses and terms.

See `LICENSE` and `THIRD_PARTY_NOTICES.md`.

## Developer

**Ebrahim Tayfour — ET TECH**

---

## العربية

**Sadaqah Path** تطبيق Windows مجاني ومفتوح المصدر لمواقيت الصلاة وقراءة القرآن الكريم.

التطبيق بدون إعلانات أو اشتراكات أو حساب مستخدم، ويدعم العربية والألمانية والإنجليزية، بالإضافة إلى Windows 64-bit و32-bit.

للمستخدم العادي: نزّل ملف `Sadaqah-Path-2.1.2-Setup.exe` من قسم **Releases**.

---

## Deutsch

**Sadaqah Path** ist eine kostenlose Open-Source-Windows-App für Gebetszeiten und das Lesen des Korans.

Die App enthält keine Werbung, keine Abonnements und kein Benutzerkonto. Sie unterstützt Deutsch, Arabisch und Englisch sowie Windows 64-Bit und 32-Bit.

Für normale Nutzer: Lade `Sadaqah-Path-2.1.2-Setup.exe` im Bereich **Releases** herunter.
