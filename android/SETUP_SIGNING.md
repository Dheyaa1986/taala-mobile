# Android Signing Setup

## 1. Rotate keystore (required — old password was in Git)

The previous password `Zxcv@bnm1` was committed to `build.gradle`. Treat it as compromised:

1. Generate a new upload key **or** change keystore passwords.
2. Update [Google Play Console](https://play.google.com/console) → App signing → Upload key if you replace the key.
3. Never commit `key.properties` or `.jks` files.

```powershell
cd android
Copy-Item key.properties.example key.properties
# Edit key.properties with your NEW passwords
notepad key.properties
```

Expected `key.properties`:

```properties
storePassword=<NEW_PASSWORD>
keyPassword=<NEW_PASSWORD>
keyAlias=upload
storeFile=app/upload-key.jks
```

## 2. Build release

```powershell
cd ..
flutter build appbundle --release
```

## 3. Remove certificate from Git history (one-time)

After commit that removes `upload-certificate.pem`, purge history:

```bash
# Requires git-filter-repo or BFG — run from taala-mobile clone
git filter-repo --path upload-certificate.pem --invert-paths
```

Then force-push only after team agreement.
