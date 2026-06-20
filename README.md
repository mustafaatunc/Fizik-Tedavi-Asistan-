# 🏋️‍♂️ AI-Powered Physical Therapy & Fitness Assistant

An intelligent, privacy-first mobile application that acts as a digital physical therapist and fitness coach. Built with **Flutter**, it uses **On-Device Machine Learning (Edge AI)** to track 33 human skeletal landmarks in real-time, calculates biomechanical joint angles, and provides a dynamic AI-driven workout routine based on cumulative muscle development.

<p align="center">
  <img src="[Add Image URL: App Mockup/Cover Image]" alt="App Cover" width="100%">
</p>

## ✨ Key Features

* **Real-Time Pose Detection:** Utilizes Google ML Kit to process camera frames at 30 FPS, instantly mapping 33 body landmarks without any internet connection.
* **Biomechanical Analysis:** Calculates precise joint angles (e.g., knee depth during squats) using the trigonometric `atan2` function and applies a **Moving Average Filter** to eliminate camera jitter.
* **Finite State Machine (FSM):** accurately tracks workout phases (start, peak, finish) to prevent "cheat reps" and logically counts valid repetitions.
* **Continuous Learning AI Coach:** Stores workout data in a local **Hive NoSQL** database to calculate muscle asymmetry (Legs, Core, Arms, Back). It autonomously generates a daily adaptive workout prescription based on the user's weakest muscle group.
* **Voice Assistant (TTS):** Real-time audio feedback corrects the user's posture instantly (e.g., "You are bending too much!").
* **Gamification & Analytics:** Includes an EXP/Leveling system, achievement badges, and a custom Radar Chart to visualize physical development. Detailed session line-charts are rendered via `fl_chart`.
* **100% Privacy-First:** No camera data or personal health metrics are sent to the cloud. Everything runs strictly on the edge (device).

## 📸 Screenshots

<p align="center">
  <img src="[Add Image URL: Camera Screen]" width="24%">
  <img src="[Add Image URL: Result Graph Screen]" width="24%">
  <img src="[Add Image URL: AI Program Screen]" width="24%">
  <img src="[Add Image URL: Profile/Radar Screen]" width="24%">
</p>

## 🛠️ Technical Architecture & Tech Stack

* **Frontend Framework:** Flutter (Dart)
* **Machine Learning:** Google ML Kit Pose Detection API
* **Local Database:** Hive (NoSQL, blazing fast offline storage)
* **Charting:** fl_chart (for interactive biomechanical line charts)
* **Audio:** flutter_tts (Text-to-Speech)

### The Mathematical Model
To translate 2D camera pixels into 3D biomechanical understanding, the system extracts X and Y coordinates of specific joints and calculates the internal relative angle using Euclidean geometry:

$$\theta = \left| \text{atan2}(y_3-y_2, x_3-x_2) - \text{atan2}(y_1-y_2, x_1-x_2) \right| \times \frac{180}{\pi}$$

### Academic Validation
The core posture-correction logic has been tested and validated against the **UI-PRMD** (University of Idaho Physical Rehabilitation Movement Data) dataset to ensure clinical relevance in detecting flawed movement patterns.

## 🚀 Getting Started

### Prerequisites
* Flutter SDK (latest stable version)
* Android Studio / Xcode
* A physical device (Real-time ML Kit processing performs poorly on emulators)

### Installation
1. Clone the repository:
   ```bash
   git clone [https://github.com/yourusername/your-repo-name.git](https://github.com/yourusername/your-repo-name.git)
