# دفتر الأسعار — Prix Book

**Wholesale Price Comparison App for Algerian Stationery Merchants**

> Built to spec: Prix Book Master Specification v1.1 | Flutter 3.19+ | Material 3 | RTL Arabic

---

## Overview

Prix Book is an **offline-first** Android app that helps Algerian stationery shop owners compare wholesale prices across multiple suppliers during market visits. Key features:

- Record prices from multiple suppliers in a single shopping session
- Instant best-price comparison with colour-coded freshness indicators
- Per-unit price normalization across different pack sizes
- Full price history with append-only audit trail
- Arabic RTL UI with Tajawal font
- Export SQLite backup via device share sheet

---

## Architecture

```
lib/
├── core/
│   ├── constants/       # AppColors, AppSizes, AppStrings, UnitTypes
│   ├── errors/          # Failure classes, AppException
│   ├── providers/       # Riverpod dependency injection (DI root)
│   ├── router/          # GoRouter configuration
│   ├── theme/           # Material 3 theme (AppTheme)
│   └── utils/           # DB helper, formatters, validators, image compressor
│
├── features/
│   ├── brands/          # Brand management (CRUD)
│   │   ├── data/        # BrandModel, BrandRepositoryImpl
│   │   ├── domain/      # Brand entity, IBrandRepository, use cases
│   │   └── presentation/# BrandsScreen, BrandsProvider
│   │
│   ├── products/        # Product catalogue
│   │   ├── data/        # ProductModel, ProductRepositoryImpl
│   │   ├── domain/      # Product entity, IProductRepository, use cases
│   │   └── presentation/# ProductsScreen, ProductDetailScreen, ProductFormScreen
│   │
│   ├── suppliers/       # Supplier management
│   │   ├── data/        # SupplierModel, SupplierRepositoryImpl
│   │   ├── domain/      # Supplier entity, ISupplierRepository, use cases
│   │   └── presentation/# SuppliersScreen, SupplierDetailScreen, SupplierFormScreen
│   │
│   ├── prices/          # Price history (append-only)
│   │   ├── data/        # PriceHistoryModel, PriceRepositoryImpl
│   │   ├── domain/      # PriceRecord entity, IPriceRepository, use cases
│   │   └── presentation/# Price providers (FutureProvider.family)
│   │
│   ├── sessions/        # Shopping session state machine
│   │   ├── data/        # SessionModel, SessionRepositoryImpl
│   │   ├── domain/      # ShoppingSession entity, ISessionRepository, use cases
│   │   └── presentation/# SessionScreen, SessionSummaryScreen, SessionProvider
│   │
│   └── settings/        # App settings + backup export
│
└── shared/
    └── widgets/         # EmptyState, ConfirmDialog, SearchBar, PriceAgeDot, etc.
```

### State Management

| Layer         | Library             |
|---------------|---------------------|
| UI state      | Riverpod `StateNotifierProvider` |
| Async data    | Riverpod `FutureProvider.family` |
| Navigation    | GoRouter `ShellRoute` |
| Persistence   | sqflite SQLite       |
| DI            | Riverpod `Provider`  |

---

## Database Schema

```sql
brands          (id, name UNIQUE NOCASE, notes, created_at, updated_at)
products        (id, name UNIQUE NOCASE, brand_id→brands, unit_type, pack_size, barcode UNIQUE, image_path, notes, created_at, updated_at)
suppliers       (id, name UNIQUE NOCASE, phone, address, notes, last_visit_date, created_at, updated_at)
shopping_sessions (id, started_at, finished_at, notes, created_at)
price_history   (id, product_id→products CASCADE, supplier_id→suppliers CASCADE, session_id→sessions SET NULL, price>0, unit_type_snapshot, pack_size_snapshot, recorded_at, created_at)
```

Price records are **append-only** — never updated in place (full audit trail).

---

## Prerequisites

| Tool    | Version     |
|---------|-------------|
| Flutter | ≥ 3.19.0    |
| Dart    | ≥ 3.3.0     |
| Java    | 17          |
| Android SDK | API 26+ |

---

## Setup & Run

### 1. Clone and install fonts

Place Tajawal font files in `assets/fonts/`:
- `Tajawal-Regular.ttf`
- `Tajawal-Medium.ttf`
- `Tajawal-SemiBold.ttf`
- `Tajawal-Bold.ttf`

Download from: https://fonts.google.com/specimen/Tajawal

> **Note:** The app uses `google_fonts` package as primary font loader, so even without local font files the app will download Tajawal automatically on first run. Local files provide offline fallback.

### 2. Create placeholder image asset

```bash
mkdir -p assets/images
touch assets/images/.gitkeep
```

### 3. Get dependencies

```bash
flutter pub get
```

### 4. Run on device / emulator

```bash
flutter run
```

### 5. Build release APK

```bash
flutter build apk --release
```

APK output: `build/app/outputs/flutter-apk/app-release.apk`

---

## Running Tests

```bash
# All tests
flutter test

# With coverage
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

### Test files

| File | Tests |
|------|-------|
| `test/core/validators_test.dart` | Input validation rules |
| `test/core/dzd_formatter_test.dart` | DZD currency formatting |
| `test/core/date_formatter_test.dart` | Date/age utilities |
| `test/features/brands/brand_model_test.dart` | DB serialization |
| `test/features/prices/price_record_test.dart` | Unit price computation |

---

## Business Rules Implemented

| Rule | Description |
|------|-------------|
| BR-P01 | Product names unique (case-insensitive) |
| BR-P02 | Barcodes globally unique |
| BR-P03 | Pack size must be > 0 |
| BR-P04 | Product deletion cascades price history |
| BR-P08 | Product images compressed to 150×150 JPEG |
| BR-B01 | Brand names unique (case-insensitive) |
| BR-B02 | Brand deletion sets products.brand_id = NULL |
| BR-S01 | Supplier names unique (case-insensitive) |
| BR-S04 | Phone validation (Algerian format) |
| BR-S05 | Last visit date cannot be in the future |
| BR-PR01 | Price > 0, ≤ 9,999,999 DZD |
| BR-PR03 | Price records are append-only (never overwritten) |
| BR-C04 | Unit price normalization for pack size comparison |
| BR-SS01 | Only one active session at a time |
| BR-SS02 | Active session restored on app restart |
| BR-SS04 | Empty sessions are abandoned on exit |
| BR-SS05 | All session suppliers marked visited on session end |

---

## Key UX Flows

### Shopping Session Flow
1. Tap **جلسة تسوق** tab → select a supplier
2. For each product, enter the wholesale price (previous price shown as hint)
3. Tap **تغيير المورد** to switch to next supplier without ending session
4. Tap **إنهاء** → view session summary with best prices per product

### Price Comparison
- Open any product → **مقارنة الأسعار** section
- Suppliers ranked cheapest first
- Best price highlighted in green with border accent
- Freshness dot: 🟢 < 7 days, 🟡 7–30 days, 🔴 > 30 days

---

## Colour Palette

| Token | Hex | Usage |
|-------|-----|-------|
| Primary Navy | `#1A3C5E` | AppBar, buttons, nav |
| Emerald Green | `#2ECC71` | Best price, success |
| Amber Orange | `#E67E22` | Session banner, aging prices |
| Danger Red | `#E74C3C` | Delete, stale prices |
| Background | `#F2F4F8` | Scaffold background |
| Alt Row | `#EBF5FF` | Zebra rows, chips |

---

## Project Info

- **Package:** `com.dzigner31.prix_book`
- **Min SDK:** API 26 (Android 8.0)
- **Target SDK:** API 34 (Android 14)
- **Spec Version:** Prix Book Master Spec v1.1
- **Locale:** Arabic `ar_DZ` (RTL primary)
- **Currency:** DZD (Algerian Dinar, دج)
