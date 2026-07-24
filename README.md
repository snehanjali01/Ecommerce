ShopEase — Full-Stack E-Commerce Platform

A full-stack e-commerce application built with a Spring Boot microservices backend and a Flutter frontend, supporting product browsing, cart management, wishlist, order tracking, and online payments via Razorpay.

Overview

ShopEase lets users browse products across multiple categories, manage a cart and wishlist, place orders (Cash on Delivery or online via Razorpay), and track order status in real time — from "Order Placed" through to "Delivered," updated automatically by a scheduled backend job.

The backend follows a microservices architecture with service discovery and centralized routing, so each domain (users, products, cart, orders, payments, wishlist) is independently deployable and scalable.

Tech Stack
Layer	Technology
Frontend	Flutter (Dart) — Web & Android
Backend	Java, Spring Boot
Service Discovery	Netflix Eureka
API Gateway	Spring Cloud Gateway
Database	MongoDB (MongoDB Atlas)
Authentication	JWT (JSON Web Tokens)
Payments	Razorpay (Test Mode)
State Management	Provider (Flutter)
Build Tools	Maven (backend), Gradle (Android)
Version Control	Git & GitHub

Project Structure
ecommerce/
├── eureka-server/         
├── api-gateway/           
├── user-service/          
├── product-service/       
├── cart-service/          
├── order-service/         
├── payment-service/       
├── wishlist-service/      
└── ecommerce_app/   

Flutter app layout
ecommerce_app/
├── lib/
│   ├── main.dart              
│   ├── models/                
│   ├── screens/                
│   └── services/
│       ├── api_service.dart    
│       └── razorpay_web/       
├── android/                    
├── ios/                        
├── web/                        
└── pubspec.yaml

Getting Started
Prerequisites
Java 17+
Maven
Flutter SDK
MongoDB (local or Atlas connection string)
A free Razorpay test account (for payment testing)
Backend Setup
Clone the repository:
   git clone https://github.com/snehareddyvari/ecommerce.git
   cd ecommerce
For each backend service, copy the config template and fill in your own values:
   cp payment-service/src/main/resources/application.properties.example \
      payment-service/src/main/resources/application.properties

Repeat for any other service with a .example config file. Add your MongoDB connection string, JWT secret, and Razorpay test keys.

Start services in this order (each in its own terminal):
   eureka-server → api-gateway → user-service → product-service →
   cart-service → order-service → payment-service → wishlist-service
Frontend Setup
cd ecommerce_app
flutter pub get
flutter run -d chrome      * for web
flutter run                * for a connected Android device/emulator

Note: Android emulators must reach the backend via 10.0.2.2 instead of localhost — this is already handled automatically in api_service.dart based on platform.

Security
application.properties files (containing database credentials, JWT secrets, and Razorpay keys) are excluded from version control via .gitignore.
.example template files are committed instead, documenting required configuration without exposing real values.
Razorpay test keys are used throughout — no real payments are processed.
License

This project was built for educational purposes as part of a personal learning project.
