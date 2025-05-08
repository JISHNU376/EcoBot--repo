# 🌿 EcoBot - AI-Powered Carbon Footprint Assistant

[![Flutter](https://img.shields.io/badge/Flutter-3.16-blue)](https://flutter.dev)
[![FastAPI](https://img.shields.io/badge/FastAPI-0.103-green)](https://fastapi.tiangolo.com)
[![License](https://img.shields.io/badge/License-MIT-brightgreen)](LICENSE)

<img src="assets/ecobot_demo.gif" width="250" align="right">

An intelligent mobile application that tracks your daily carbon emissions and provides personalized sustainability recommendations using machine learning.

## ✨ Key Features

- **Automated Activity Tracking**
  - 🚗 Transport mode detection via GPS
  - 🍎 Food intake logging with image recognition
  - 💡 Energy usage integration with smart devices

- **AI Insights**
  - 📈 Weekly emission trend forecasts
  - 🔍 Anomaly detection in usage patterns
  - 🎯 Personalized reduction goals

- **Interactive Tools**
  - 💬 NLP-powered sustainability chatbot
  - 📊 Visual dashboard with emission breakdowns
  - 🏆 Gamification with achievement badges

## ✅ Prerequisites

- Flutter SDK **3.16+**  
- Python **3.10+**  
- Firebase project  
- Google Maps API key  

---

## 🛠️ Technical Architecture

```mermaid
graph LR
    A[Flutter UI] --> B[Firebase Auth]
    A --> C[Device Sensors]
    B --> D[(Firestore)]
    C --> E[Local ML Processing]
    D --> F[FastAPI Microservice]
    F --> G[(EPA Database)]
    F --> H[Python ML Models]

