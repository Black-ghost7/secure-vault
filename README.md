# Secure Vault

An offline encryption app for Android. Encrypt and decrypt files and text with a password you choose, and generate strong passwords. No accounts, no servers, no data collection.

## Features

- Encrypt and decrypt files (output is saved as `<name>.enc`)
- Encrypt and decrypt text
- Strong password generator with adjustable length
- Save results to any folder you pick, or share them with other apps
- Original files are never deleted or modified
- Interface in English, Arabic, and French (follows the phone language)

## Security design

| Component | Choice |
|---|---|
| Encryption | AES-256-GCM (authenticated encryption) |
| Key derivation | Scrypt (64 MB memory) |
| Salt and nonce | Random, unique per file |
| Tamper detection | Any change to an encrypted file is detected on decryption |
| Network | None. The app works fully offline and sends no data anywhere |

The password is the only key. There is no backdoor and no recovery: if you forget it, your files cannot be recovered by anyone, including the developer.

## Download and install

1. Download `secure-vault.apk` from the [latest release](https://github.com/Black-ghost7/secure-vault/releases/latest).
2. Open the file and allow installation from this source if the phone asks.
3. If Play Protect shows a warning, choose **More details**, then **Install anyway**.

Requires Android 7.0 or newer. Package name: `com.ghost.securevault`.

## Build from source

Requires the [Flutter SDK](https://docs.flutter.dev/get-started/install).

    flutter pub get
    flutter run

Run the checks:

    flutter analyze && flutter test

Build a release APK:

    flutter build apk --release

The APK is created at `build/app/outputs/flutter-apk/app-release.apk`. Release builds are also produced automatically by GitHub Actions on every push to `main` and published on the Releases page, signed with the maintainer's key.

## Project structure

    lib/crypto/vault_crypto.dart     encryption and decryption
    lib/password_tools.dart          password generator and strength
    lib/screens/                     files, text, generator, and about screens
    lib/l10n/strings.dart            translations
    lib/widgets/common.dart          shared widgets

## Security note

This is a personal project and its code has not been audited by a security professional. Do not rely on it as the only protection for critical data. Security reviews and bug reports are welcome through GitHub Issues.

## Author

Built by [Black-ghost7](https://github.com/Black-ghost7).
