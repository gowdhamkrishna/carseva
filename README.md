🚗 CarSeva

CarSeva is an intelligent, automobile-focused mobile application built with Flutter that combines AI assistance, voice interaction, and modern mobile architecture to help users understand, explore, and make better decisions about cars.

The application is designed as a scalable automobile ecosystem, where AI is a powerful feature—not the entire product.

📌 Project Overview

CarSeva aims to simplify automobile interactions by providing:

Smart assistance for car-related queries

Voice-based interaction for hands-free usage

Secure authentication and personalization

Data-driven insights into the car market

The app follows Clean Architecture principles, ensuring long-term maintainability and easy feature expansion.

✨ Key Features
🔐 Authentication

Email & password login

Google Sign-In

Firebase-based secure authentication

State management using BLoC

🎙️ Voice-Enabled AI Assistant

Speech-to-text voice input

Real-time voice transcription

AI responses powered by Google Gemini

Strictly focused on automobile-related queries

The voice chatbot is implemented as a feature, not the core of the application.

🧠 AI Integration

Modular AI client using Google Gemini

Domain-restricted prompts for automotive assistance

Secure API key management using environment variables

Designed for future multimodal AI support (voice, text, vision)

🧱 Clean Architecture

The project is structured into:

Presentation Layer – UI & BLoC state management

Domain Layer – Business logic & use cases

Data Layer – Firebase, AI services, and repositories

This separation ensures testability, scalability, and clean code practices.

🎨 User Experience

Animated splash screen

Clean login & registration flow

Real-time feedback using loaders and snackbars

Smooth voice interaction UI

📊 Planned Features

Car market trend analysis

Location-based car recommendations

AI-powered car buying suggestions

Regional availability and demand prediction

Integration with in-car systems (future scope)
