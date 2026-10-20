<p align="center">
  <img src="assets/icon/app-logo.png" alt="Flutter Logo" width="200">
</p>

<h1 align="center">Android Ransomware Simulation</h1>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter">
  <img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart">
  <img src="https://img.shields.io/badge/Kotlin-7F52FF?style=for-the-badge&logo=kotlin&logoColor=white" alt="Kotlin">
  <img src="https://img.shields.io/badge/Platform-Android-3DDC84?style=for-the-badge&logo=android&logoColor=white" alt="Android">
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Project-Educational-blue?style=flat-square" alt="Educational Project">
  <img src="https://img.shields.io/badge/Type-Proof%20of%20Concept-orange?style=flat-square" alt="Proof of Concept">
  <img src="https://img.shields.io/badge/License-Academic%20Use-lightgrey?style=flat-square" alt="Academic Use">
</p>

<p align="center">
  An educational project and system security assignment designed to demonstrate how a "lock-screen" ransomware mechanism operates within the Android operating system, built using <strong>Flutter</strong> and <strong>native Kotlin</strong>.
</p>

---

## Table of Contents

- [About the Project](#-about-the-project)
- [Key Features](#-key-features)
- [Technologies Used](#-technologies-used)
- [Architecture](#-architecture)
- [Installation & Testing](#-installation--testing)
- [Security Analysis & Limitations](#-security-analysis--limitations)
- [Legal & Ethical Warning](#-legal--ethical-warning)

---

## About the Project

This application was developed as a Proof of Concept (PoC) to explore security vulnerabilities and interface control mechanisms on Android devices. The project leverages an official Android operating system feature—**Lock Task Mode (Screen Pinning)**—combined with a background service (`BroadcastReceiver`) to simulate the behavior of ransomware, making it difficult for an average user to force-close the application.

---

## Key Features

1. **Kiosk / Lock Task Mode**: Completely locks the screen and disables physical or system navigation buttons (Home, Recent Apps, Back) via a *Method Channel* that communicates with native Android code.

2. **Persistent Autostart (`BOOT_COMPLETED`)**: Utilizes a `BroadcastReceiver` written in Kotlin to automatically relaunch the application and lock the screen immediately after the device reboots.

3. **Countdown Timer**: A real-time simulation of a deadline for a ransom payment.

4. **Virtual Keyboard Fix**: Addresses Android’s *Direct Boot* limitations by implementing a structured `FocusNode`, ensuring the virtual keyboard can be invoked to enter the decryption password.

5. **Anti-Bypass (`PopScope`)**: Prevents navigation gestures or the "back" button from exiting the application before the correct password has been entered.

---

## Technologies Used

- **Framework**: Flutter (Dart)
- **Native Bridge**: Method Channel (`com.simulasi.lockscreen/lock`)
- **Native Language**: Kotlin (Android API Level 21+)
- **Android Components**:
  - `Activity` (SingleTop, LockTaskMode)
  - `BroadcastReceiver` (Boot Persistence)
  - `SystemUiMode` (Immersive Sticky)

---

## Architectural Structure

```text
lib/
└── main.dart                 # UI Interface (Flutter), Timer, & Focus Controller

android/app/src/main/
├── AndroidManifest.xml       # System Permissions, Receiver, & Lock Task Mode Configuration
└── kotlin/com/example/ransim/
    ├── MainActivity.kt       # Method Channel bridge for starting/stopping Lock Task
    └── BootReceiver.kt       # Captures device reboot completion signals
```

---

## Installation & Testing

### 1. Clone the Repository

```bash
git clone [https://github.com/pangeran-droid/android-ransomware-simulation.git](https://github.com/pangeran-droid/android-ransomware-simulation.git)
cd android-ransomware-simulation
```

### 2. Install Flutter Dependencies

```bash
flutter pub get
```

### 3. Build & Install the APK on a Physical Device

⚠️ **Important Note:** Features such as Lock Task Mode and Reboot Persistence can only be effectively tested on a physical Android device (using standard emulators is not recommended).

```bash
flutter build apk --release
# or run directly via USB Debugging
flutter run --release
```

### 4. Additional Device Configuration (Optional for Reboot Testing)

Open the application manually at least once after installation (required by Android’s sandbox security policy to enable the Broadcast Receiver).

Go to Phone Settings -> Apps -> Manage Apps -> [Your App Name], then enable the "Autostart" (or "Background Running") permission to ensure the reboot simulation functions correctly.

---

## Security Analysis & Limitations

**Decryption Key Storage:** In this simulation version, the decryption password (`hacker123`) is stored in plaintext within the local source code. In a real-world implementation, this is vulnerable to reverse engineering (decompilation using tools such as JADX).

**Sandbox & Direct Boot:** Following a reboot, the Android operating system keeps local storage encrypted until the user unlocks the device for the first time. A delay is incorporated into the application to allow essential system services and the Input Method Editor (keyboard) to become ready.

---

## ⚠️ Legal & Ethical Warning

> This project is created strictly for academic, educational, and security research purposes. It is strictly prohibited to use the code or concepts from this repository to distribute actual malware, engage in extortion, or compromise third-party devices without authorization. The developer assumes no responsibility for any misuse of this software.
