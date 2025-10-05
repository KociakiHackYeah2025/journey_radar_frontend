# Journey Radar - Przewodnik Testowania

## Szybki Start

### 1. Uruchomienie aplikacji
```bash
cd journey_radar_frontend
flutter run
```

### 2. Logowanie
- **Testowe konto**: test@example.com / password123
- Lub zarejestruj nowe konto

### 3. Funkcje do przetestowania

#### Autentykacja
- ✅ Rejestracja nowego użytkownika
- ✅ Logowanie istniejącym kontem
- ✅ Wylogowywanie

#### Mapa Demo (bez Google Maps API)
- ✅ Otwórz "Mapa Demo (bez API)" z ekranu głównego
- ✅ Dotknij obszar mapy aby dodać punkt
- ✅ Wypełnij formularz (tytuł, opis, kategoria)
- ✅ Sprawdź czy punkt pojawił się na mapie
- ✅ Dotknij marker aby zobaczyć szczegóły
- ✅ Usuń punkt przez szczegóły lub listę
- ✅ Sprawdź listę punktów (ikona list w AppBar)

#### Google Maps (wymaga konfiguracji API)
- 🔧 Skonfiguruj Google Maps API (patrz GOOGLE_MAPS_SETUP.md)
- ✅ Otwórz "Otwórz mapę (Google Maps)"
- ✅ Pozwól na dostęp do lokalizacji
- ✅ Testuj wszystkie funkcje jak w wersji demo

## Kategorie Punktów
1. 🍽️ Restauracja
2. 🏛️ Atrakcja
3. 🏨 Hotel
4. 🚌 Transport
5. 🛍️ Shopping
6. 🌳 Natura
7. 🎭 Kultura
8. 📍 Inne

## Testowanie API
API endpoint: https://kociaki-api.intuizm.com/docs

### Konta testowe:
- email: test@example.com, hasło: password123
- email: admin@example.com, hasło: admin123

### Sprawdzenie tokenów:
Otwórz DevTools -> Console w przeglądarce podczas logowania aby sprawdzić tokeny JWT.

## Oczekiwane zachowania

### ✅ Poprawne zachowania:
- Aplikacja uruchamia się bez błędów
- Logowanie zapisuje token i przekierowuje na główny ekran
- Punkty są zapisywane lokalnie (nie tracimy ich po restarcie)
- Mapa demo działa bez internetu
- Formularze mają walidację
- Wiadomości sukcesu/błędu są wyświetlane

### ❌ Możliwe problemy:
- SharedPreferences na Androidzie (używamy fallback na pamięć)
- Google Maps wymaga konfiguracji API key
- Lokalizacja wymaga pozwoleń użytkownika
- API może być czasowo niedostępne

## Debugowanie

### Logi w konsoli:
- API calls i odpowiedzi
- Błędy tokenu/autentykacji
- Status lokalizacji

### Resetowanie danych:
- Wyloguj się i zaloguj ponownie
- Lub wyművań dane aplikacji (Android)

## Struktura plików do testowania:
```
lib/
├── screens/
│   ├── login_page.dart      # Test logowania
│   ├── register_page.dart   # Test rejestracji  
│   ├── home_page.dart       # Menu główne
│   ├── map_screen.dart      # Google Maps
│   └── simple_map_screen.dart # Mapa demo
├── widgets/
│   ├── add_point_dialog.dart # Dialog dodawania punktu
│   └── custom_button.dart    # Przyciski
├── services/
│   ├── api_service.dart     # Komunikacja z API
│   └── location_service.dart # Lokalizacja
└── models/
    └── map_point.dart       # Model punktu
```

## Dodawanie funkcji
Jeśli chcesz dodać nowe funkcje, zacznij od:
1. Model danych (`models/`)
2. Service do komunikacji (`services/`)
3. Widget/Screen (`widgets/` lub `screens/`)
4. Integracja w `home_page.dart`