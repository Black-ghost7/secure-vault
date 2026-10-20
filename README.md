# Secure Vault

Flutter app for Android to encrypt text and files and to generate strong passwords.

## Features

- Encrypt and decrypt text
- Encrypt and decrypt files
- Strong password generator
- Arabic and English interface

## Run

    flutter pub get
    flutter run

## Test

    flutter analyze && flutter test

## Build APK

    flutter build apk --release

The APK file is at `build/app/outputs/flutter-apk/app-release.apk`.
Ready-made APK files for each version are attached to the **Releases** page of this repository.

## Install on Android

1. Download `app-release.apk` from the latest release.
2. Open the file and allow installation from this source if the phone asks.
3. If Play Protect shows a warning, choose **More details** then **Install anyway**.

## Security note

This is a personal project and its code has not been audited by a security professional.
Do not rely on it as the only protection for critical data.

---

# Secure Vault (بالعربية)

تطبيق Flutter لنظام Android لتشفير النصوص والملفات وتوليد كلمات سر قوية.

## المميزات

- تشفير النصوص وفك تشفيرها
- تشفير الملفات وفك تشفيرها
- مولّد كلمات سر قوية
- واجهة بالعربية والإنجليزية

## التشغيل

    flutter pub get
    flutter run

## الاختبار

    flutter analyze && flutter test

## بناء ملف APK

    flutter build apk --release

ملفات APK الجاهزة لكل إصدار موجودة في صفحة **Releases** في هذا المستودع.

## تنبيه أمني

هذا مشروع شخصي ولم يراجع كوده مختص في الأمن. لا تعتمد عليه وحده لحماية بيانات مهمة.
