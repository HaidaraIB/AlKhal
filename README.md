# AlKhal
[![Ask DeepWiki](https://devin.ai/assets/askdeepwiki.png)](https://deepwiki.com/HaidaraIB/AlKhal)

AlKhal is a comprehensive, offline-first point-of-sale (POS) and inventory management application built with Flutter. Designed for small businesses, it provides a robust solution for tracking items, sales, purchases, and expenses with seamless background data synchronization capabilities. The application is primarily in Arabic.

## Key Features

*   **Inventory Management**: Easily add, update, and categorize items. Track stock levels, purchase prices, and selling prices. View the history of changes for each item.
*   **Transaction Processing**: Record both sales (فواتير زبون) and purchase (فواتير محل) transactions. The system automatically adjusts item quantities based on transactions.
*   **Financial Dashboard**: The "Cash" screen provides a real-time overview of key financial metrics, including total cash, profit, outstanding bills (purchases), customer debts (remainders), expenses, and discounts within a selected date range.
*   **Expense Tracking**: Log and manage business expenses, which are factored into the overall financial calculations.
*   **Data Visualization**: Interactive pie and bar charts provide a clear visual representation of your financial data, including the breakdown of cash, profit, debts, and discounts.
*   **Offline-First Architecture**: The app is fully functional without an internet connection. All data is stored locally in an SQLite database, ensuring reliability and speed.
*   **Cloud Synchronization**: Authenticated users can benefit from automatic background data synchronization. All local changes (inserts, updates, deletes) are queued and synced with a remote server, providing a reliable backup and enabling multi-device usage in the future.
*   **User Authentication**: Secure user registration and login system to protect business data.
*   **Data Management**:
    *   Local backup and restore of the database to the device's external storage.
    *   Restore data from the cloud upon logging into a new device.
    *   Share the database file directly from the app.

## Technology Stack & Architecture

AlKhal is built using a modern, scalable architecture centered around the Flutter framework.

*   **Framework**: Flutter
*   **State Management**: `flutter_bloc` (using Cubits) for predictable and maintainable state management across the application.
*   **Local Database**: `sqflite` for robust, on-device relational data storage. Database triggers are used to log all data modifications for synchronization.
*   **Background Processing**: `workmanager` for scheduling periodic background tasks to sync data with the remote server without interrupting the user.
*   **API Communication**: `http` package for communicating with the RESTful backend API for user authentication and data synchronization.
*   **Data Visualization**: `fl_chart` for creating responsive and informative charts.
*   **Connectivity**: `connectivity_plus` to check network status before attempting to sync data.

## Project Structure

The project's codebase is organized into logical layers to promote separation of concerns and maintainability.

```
lib/
├── cubit/        # State management logic for all features
├── models/       # Data models (Item, Transaction, Category, etc.)
├── screens/      # UI for each major screen/feature of the app
├── services/     # Business logic (database helper, API calls, DB syncer)
├── utils/        # Helper functions, constants, and validators
├── widgets/      # Reusable UI components (cards, charts, forms)
└── main.dart     # Application entry point and route configuration
```

## Setup and Installation

To run the project locally, follow these steps:

1.  **Clone the repository:**
    ```sh
    git clone https://github.com/HaidaraIB/AlKhal.git
    cd AlKhal
    ```

2.  **Get Flutter dependencies:**
    ```sh
    flutter pub get
    ```

3.  **Create `.env` file:**
    Create a file named `.env` in the root of the project and add the activation PIN. This is used for the initial application activation screen.
    ```
    PIN=YOUR_PIN_HERE
    ```

4.  **Run the application:**
    ```sh
    flutter run
