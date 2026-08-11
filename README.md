# LEDGRR

A personal finance clarity app built for students, using Flutter.

## About

LEDGRR is not a traditional budgeting app. Most finance apps that already exist are built for salaried professionals who are dealing with EMIs, investments, tax planning, and long term financial goals. None of that actually reflects how a student handles money on a daily basis. A student is usually managing a monthly allowance, small UPI payments, occasional part time income, and informal money owed between friends, none of which mainstream finance apps are designed around.

LEDGRR is built around a much simpler idea. Only a small percentage of users, roughly around twenty percent, genuinely want to sit down and engage deeply with their finances every single day. Instead of forcing every user into a rigid budgeting system that most people will abandon within a week, LEDGRR is designed to reduce friction specifically for that group of users who do want to engage, while still remaining useful and non intrusive for everyone else. The result is an app that feels light, honest, and easy to stick with, instead of another finance app that gets deleted after three days.

## Features

Below is a full list of everything LEDGRR currently supports.

- **Savings Jars**, which allow goal based saving that is kept separate from everyday spending money, so a user can save for something specific like a trip or a gadget without that money getting mixed into daily spending calculations.

- **Dues Tracker**, which keeps track of money owed to the user and money the user owes to others. When a due is marked as settled, it creates a real transaction behind the scenes so the balance always stays accurate.

- **Spend List**, which lets a user plan a shopping trip ahead of time with a fixed budget cap, and then check off items with their actual price as they shop, showing remaining budget in real time.

- **Ghost Money Detector**, which automatically scans transaction history and detects forgotten recurring expenses, such as subscriptions the user may not even remember signing up for.

- **AI Daily Sentence**, which generates one short and honest sentence about the user's recent financial behaviour every single day, using an AI model, instead of showing complicated charts or reports.

- **Receipt Scanner**, which uses Optical Character Recognition to read a photographed receipt and automatically extract the total amount, removing the need for manual entry.

- **Money Memory**, which automatically writes a short daily summary of financial activity, even on days where the user made zero transactions, so the record always stays complete and honest.

- **Event Wallet**, which lets a user set aside money specifically for an event or occasion, separate from regular spending, with clear warnings if a withdrawal would affect their overall balance.

- **Quick Add**, which allows a user to log a transaction in just two taps, keeping daily logging fast enough that it actually becomes a habit.

- **Ask Your Money**, which lets a user ask direct questions about their own spending and get answers generated from their real transaction data, instead of generic financial advice.

- **Statistics**, which shows visual charts of spending across the last seven days as well as a broader six month view, helping the user notice both short term habits and longer term trends.

- **Learn Finance**, which contains forty four short lessons split across three tiers, Foundation, Clarity, and Mastery, covering practical topics a student is actually likely to face.

- **Streak Counter**, which quietly tracks how many consecutive days a user has logged at least one transaction, encouraging consistency without any guilt based notifications or pressure.

- **CSV Export**, which allows a user to export their entire transaction history as a CSV file, giving them a portable backup of their own financial data at any time.

## Tech Stack

This section lists every major technology used to build LEDGRR.

**Frontend**
- Flutter, using Dart as the programming language, for building a single codebase that works across devices
- Provider package, used for state management throughout the app
- Google Fonts package, specifically Syne and DM Serif Display, used to give the app a distinct visual identity instead of relying on default system fonts

**Backend**
- Firebase Authentication, used for secure user login and signup
- Cloud Firestore, used as the primary real time database for storing all user data

**APIs and SDKs**
- Groq API, using the LLaMA 3.3 model with seventy billion parameters, used specifically to generate the AI Daily Sentence feature
- Google ML Kit, used for Optical Character Recognition inside the Receipt Scanner feature

## Getting Started

Follow these steps if you want to run this project locally on your own machine.

1. Clone the repository to your local machine using git.
2. Run the command `flutter pub get` inside the project folder to install all required dependencies.
3. Create your own Firebase project through the Firebase console, and add your own `google-services.json` file for Android under the `android/app/` folder of this project.
4. Inside your Firebase project, set up Firebase Authentication and enable Cloud Firestore as the database.
5. Once everything is configured correctly, run the command `flutter run` to launch the app on a connected device or emulator.

## Current Status

LEDGRR is currently under active development. All the core features listed above in the Features section are already built and working correctly. The next major feature planned is message parsing, which will automatically detect transactions directly from bank SMS messages, starting with support for Canara Bank, before expanding to other banks over time.

## Author

Kamaleswari S, BE CSE, Chennai Institute of Technology