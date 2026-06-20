# 🏋️‍♂️ AI-Powered Physical Therapy & Fitness Assistant

An intelligent, privacy-first mobile application that acts as a digital physical therapist and fitness coach. Built with **Flutter**, it uses **On-Device Machine Learning (Edge AI)** to track 33 human skeletal landmarks in real-time, calculates biomechanical joint angles, and provides a dynamic AI-driven workout routine based on cumulative muscle development.

<p align="center">
  <img src="https://github.com/user-attachments/assets/e79f2a94-5473-407a-9ce3-c8a126a572bf" width="30%" alt="App Cover">
</p>

---

## ✨ Key Features

* **Real-Time Pose Detection:** Utilizes Google ML Kit to process camera frames at 30 FPS, instantly mapping 33 body landmarks without any internet connection.
* **Biomechanical Analysis:** Calculates precise joint angles (e.g., knee depth during squats) using the trigonometric `atan2` function and applies a **Moving Average Filter** to eliminate camera jitter.
* **Finite State Machine (FSM):** Accurately tracks workout phases (start, peak, finish) to prevent "cheat reps" and logically counts valid repetitions.
* **Continuous Learning AI Coach:** Stores workout data in a local **Hive NoSQL** database to calculate muscle asymmetry (Legs, Core, Arms, Back). It autonomously generates a daily adaptive workout prescription based on the user's weakest muscle group.
* **Voice Assistant (TTS):** Real-time audio feedback corrects the user's posture instantly (e.g., "You are bending too much!").
* **Gamification & Analytics:** Includes an EXP/Leveling system, achievement badges, and a custom Radar Chart to visualize physical development. Detailed session line-charts are rendered via `fl_chart`.
* **100% Privacy-First:** No camera data or personal health metrics are sent to the cloud. Everything runs strictly on the edge (device).

---

## 📸 Application Gallery

### 🤖 1. AI Camera & Real-Time Tracking
*Real-time skeletal mapping and posture correction via Edge AI.*
<p align="center">
  <img src="https://github.com/user-attachments/assets/5d8346b7-c936-4bb9-bef0-e2252576e758" width="19%">
  <img src="https://github.com/user-attachments/assets/1d98bb3e-da88-4e6a-a1f1-48a16e689c61" width="19%">
  <img src="https://github.com/user-attachments/assets/9ca574be-c5c1-499d-bfd8-36fe411bbd57" width="19%">
  <img src="https://github.com/user-attachments/assets/a3d404bc-5d33-4c23-9e15-b6612f767155" width="19%">
  <img src="https://github.com/user-attachments/assets/f3a1b17e-3907-4f1a-b6ca-37e7775391f4" width="19%">
</p>

### 📊 2. Biomechanical Reports & Analytics
*Detailed post-workout reports, calorie tracking, and form analysis charts.*
<p align="center">
  <img src="https://github.com/user-attachments/assets/3870e1b5-d858-4c67-984e-2f0238e7f65d" width="19%">
  <img src="https://github.com/user-attachments/assets/49cfae76-1e00-4c70-9a6a-e6a187a117f6" width="19%">
  <img src="https://github.com/user-attachments/assets/12abd363-b6ff-4f53-bf46-03861c2c5758" width="19%">
</p>

### 🎯 3. AI Coach & Gamification
*Muscle asymmetry radar charts, daily dynamic AI prescriptions, and EXP systems.*
<p align="center">
  <img src="https://github.com/user-attachments/assets/ff0d0195-acae-4732-bfb4-15bd26701978" width="19%">
  <img src="https://github.com/user-attachments/assets/7e9a5925-2d4c-4bab-9e26-594b93ea2809" width="19%">
  <img src="https://github.com/user-attachments/assets/3771c1df-4ef9-4c10-b9bd-4afceb06e88f" width="19%">
  <img src="https://github.com/user-attachments/assets/14a6cc7f-1cb5-4a37-9a93-5d9eb02e09bd" width="19%">
</p>

---

## 🛠️ Technical Architecture & Tech Stack

* **Frontend Framework:** Flutter (Dart)
* **Machine Learning:** Google ML Kit Pose Detection API
* **Local Database:** Hive (NoSQL, blazing fast offline storage)
* **Charting:** fl_chart (for interactive biomechanical line charts)
* **Audio:** flutter_tts (Text-to-Speech)

### The Mathematical Model
To translate 2D camera pixels into 3D biomechanical understanding, the system extracts X and Y coordinates of specific joints and calculates the internal relative angle using Euclidean geometry:

$$\theta=\left|\text{atan2}(y_3-y_2,x_3-x_2)-\text{atan2}(y_1-y_2,x_1-x_2)\right|\times\frac{180}{\pi}$$

### Academic Validation
The core posture-correction logic has been tested and validated against the **UI-PRMD** (University of Idaho Physical Rehabilitation Movement Data) dataset to ensure clinical relevance in detecting flawed movement patterns.

---

## 🧠 How the AI Logic Works (The Feedback Loop)

1. **Perception:** User performs an exercise. ML Kit tracks the skeleton.
2. **Analysis:** The FSM scores the rep. If the angle breaches the safe threshold, the TTS engine warns the user and the success rate drops.
3. **Storage:** Session data (reps, errors, calories, duration) is stored locally via Hive.
4. **Adaptation:** The AI algorithm reads the cumulative historical data, plots it on a radar chart, detects the weakest quadrant, and updates the "Daily AI Goal" on the Home Screen.

---

## 🚀 Getting Started

### Prerequisites
* Flutter SDK (latest stable version)
* Android Studio / Xcode
* A physical device (Real-time ML Kit processing performs poorly on emulators)

### Installation

1. Clone the repository:
   ```bash
   git clone [https://github.com/mustafaatunc/Fizik-Tedavi-Asistan-.git](https://github.com/mustafaatunc/Fizik-Tedavi-Asistan-.git)
   ```

2. Navigate to the project directory:
   ```bash
   cd Fizik-Tedavi-Asistan-
   ```

3. Get the dependencies:
   ```bash
   flutter pub get
   ```

4. Run the app on your physical device:
   ```bash
   flutter run
   ```

---

## 🤝 Contributing

Contributions, issues, and feature requests are welcome! Feel free to check the [issues page](https://github.com/mustafaatunc/Fizik-Tedavi-Asistan-/issues).

---

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
