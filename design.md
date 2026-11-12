# Design System & UI Engineering Guidelines (`design.md`)

> [!IMPORTANT]
> **Purpose**: This document establishes the authoritative visual design system, **Light/Dark Color Theme Architecture**, Single `src/styles/styles.scss` structure, Shared UI Component Library (`@ui`) rules, **e-Goods Storefront UI specifications**, and **Storybook** component design standards for the **Angular 22+ & Angular Material (M3)** personal portfolio and resume application.

---

## 1. Visual Identity & Design Principles

1. **First-Class Light & Dark Theme Support (M3 — Custom Catppuccin Spin)**:
   - **Dark Theme (`.dark-theme` — Default, _Catppuccin Mocha-Sapphire Spin_)**: Deep velvet midnight canvas (`#181825` mantle background, `#1e1e2e` Mocha base surface, `#313244` surface-variant, `#89b4fa` sapphire-blue primary, `#cba6f7` mauve secondary, and `#94e2d5` teal tertiary) with soft radial spotlight blooms and topographic SVG contours.
   - **Light Theme (`.light-theme` — _Catppuccin Latte-Sapphire Spin_)**: Warm daylight alabaster canvas (`#eff1f5` Latte base background, `#fafbfd` elevated paper surface, `#e6e9ef` surface-variant, `#1e66f5` cobalt-sapphire primary, `#8839ef` rich mauve secondary, and `#179299` teal tertiary) with calibrated slate-indigo text (`#4c4f69`) and border contrast (`rgba(76, 79, 105, 0.14)`).
   - Both themes switch instantaneously at runtime via CSS custom properties and Angular Signals (`ThemeService`) with zero page reload or layout shift.
2. **Tactile Micro-Interactions**:
   - Interactive cards (`.m3-card`) and pills use smooth `250ms cubic-bezier(0.4, 0, 0.2, 1)` transitions, lifting `translateY(-2px)` on hover with a theme-aware primary border highlight (`rgba(var(--theme-primary-rgb), 0.4)`).
3. **Single Stylesheet Source of Truth**:
   - **All styling resides in [`web/src/styles/styles.scss`](web/src/styles/styles.scss)**.
   - Individual Angular components **must not** define `styleUrl`, `styleUrls`, or inline `styles: [...]` metadata.
4. **Strict Material Encapsulation via `@ui`**:
   - Feature and page components **never import `@angular/material/*` directly**. All Material Design 3 primitives are wrapped inside `web/src/app/shared/ui/` (imported via `@ui`) and documented in **Storybook** across both Light and Dark themes.

---

## 2. Light & Dark Color Theme Architecture (Catppuccin Spin)

All components and styles must consume semantic CSS custom properties defined in [`web/src/styles/styles.scss`](web/src/styles/styles.scss)—never hardcoded hex values (except dynamic external brand colors from [`web/src/assets/skills.json`](web/src/assets/skills.json)).

### 2.1 Semantic Color Token Matrix (Catppuccin Mocha-Sapphire Dark vs. Latte-Sapphire Light)

| Semantic CSS Variable     | Dark Theme (`.dark-theme` — Mocha Spin)   | Light Theme (`.light-theme` — Latte Spin)  | Purpose & Usage                                                                         |
| :------------------------ | :---------------------------------------- | :----------------------------------------- | :-------------------------------------------------------------------------------------- |
| `--color-primary`         | `#89b4fa`                                 | `#1e66f5`                                  | Sapphire/Blue primary accents, active controls, section headings, timeline nodes        |
| `--theme-primary-rgb`     | `137, 180, 250`                           | `30, 102, 245`                             | RGB channels for alpha composition (`rgba(var(--theme-primary-rgb), 0.14)`)             |
| `--color-secondary`       | `#cba6f7`                                 | `#8839ef`                                  | Signature Catppuccin Mauve for secondary tonal chips, tech stack tags, spotlight blooms |
| `--theme-secondary-rgb`   | `203, 166, 247`                           | `136, 57, 239`                             | RGB channels for mauve spotlight blooms & tonal chip fills                              |
| `--color-tertiary`        | `#94e2d5`                                 | `#179299`                                  | Catppuccin Teal accent for subtle highlights & secondary badges                         |
| `--theme-tertiary-rgb`    | `148, 226, 213`                           | `23, 146, 153`                             | RGB channels for tertiary teal accents                                                  |
| `--color-background`      | `#181825`                                 | `#eff1f5`                                  | Root `<body>` / `<main>` page canvas (Mocha Mantle / Latte Base)                        |
| `--color-background-soft` | `#1e1e2e`                                 | `#e6e9ef`                                  | Secondary canvas step (Mocha Base / Latte Mantle)                                       |
| `--color-background-mute` | `#313244`                                 | `#dce0e8`                                  | Muted container fill (Mocha Surface0 / Latte Crust)                                     |
| `--color-surface`         | `#1e1e2e`                                 | `#fafbfd`                                  | Elevated card surfaces (`.m3-card`), app bar, navigation drawer                         |
| `--color-surface-variant` | `#313244`                                 | `#e6e9ef`                                  | Tonal chip backgrounds, subtle badge/code fills                                         |
| `--color-on-surface`      | `#cdd6f4`                                 | `#4c4f69`                                  | High-contrast foreground text on surfaces (Mocha Text / Latte Text)                     |
| `--theme-on-surface-rgb`  | `205, 214, 244`                           | `76, 79, 105`                              | RGB channels for text hierarchy opacity scales                                          |
| `--color-border`          | `rgba(205, 214, 244, 0.14)`               | `rgba(76, 79, 105, 0.14)`                  | Outlined card borders, section heading hairlines, dividers                              |
| `--color-text-main`       | `rgba(205, 214, 244, 0.94)`               | `rgba(76, 79, 105, 0.95)`                  | Primary headings, body copy, accomplishment bullets                                     |
| `--color-text-muted`      | `rgba(205, 214, 244, 0.72)`               | `rgba(76, 79, 105, 0.72)`                  | Subtitles, organization names, metadata labels, scroll hints (`#a6adc8` / `#6c6f85`)    |
| `--color-success`         | `#a6e3a1`                                 | `#40a02b`                                  | Status badge ("Open to Opportunities"), Paid/Verified badges                            |
| `--color-warning`         | `#fab387`                                 | `#fe640b`                                  | Expiring entitlement or warning indicators (Catppuccin Peach)                           |
| `--color-error`           | `#f38ba8`                                 | `#d20f39`                                  | Validation & error states (Catppuccin Red/Maroon)                                       |
| `--shadow-card-hover`     | `0 12px 30px -6px rgba(17, 17, 27, 0.55)` | `0 12px 28px -6px rgba(76, 79, 105, 0.14)` | Theme-tuned hover elevation shadow for `.m3-card`                                       |

### 2.2 Angular Material M3 + CSS Custom Property Implementation (`web/src/styles/styles.scss`)

In Layer 1 & Layer 2 of [`web/src/styles/styles.scss`](web/src/styles/styles.scss), Angular Material M3 themes and custom Catppuccin-spin tokens are bound to `html.dark-theme` and `html.light-theme`:

```scss
@use '@angular/material' as mat;

@include mat.core();

$dark-m3-theme: mat.define-theme(
  (
    color: (
      theme-type: dark,
      primary: mat.$azure-palette,
      tertiary: mat.$violet-palette,
      use-system-variables: true,
    ),
    typography: (
      brand-family: 'Roboto, sans-serif',
      plain-family: 'Roboto, sans-serif',
    ),
  )
);

$light-m3-theme: mat.define-theme(
  (
    color: (
      theme-type: light,
      primary: mat.$azure-palette,
      tertiary: mat.$violet-palette,
      use-system-variables: true,
    ),
    typography: (
      brand-family: 'Roboto, sans-serif',
      plain-family: 'Roboto, sans-serif',
    ),
  )
);

:root,
html.dark-theme {
  color-scheme: dark;
  @include mat.all-component-themes($dark-m3-theme);

  /* Catppuccin Mocha-Sapphire Spin */
  --theme-primary-rgb: 137, 180, 250;
  --theme-secondary-rgb: 203, 166, 247;
  --theme-tertiary-rgb: 148, 226, 213;
  --theme-on-surface-rgb: 205, 214, 244;
  --theme-border-rgb: 205, 214, 244;

  --color-primary: #89b4fa;
  --color-secondary: #cba6f7;
  --color-tertiary: #94e2d5;
  --color-background: #181825;
  --color-background-soft: #1e1e2e;
  --color-background-mute: #313244;
  --color-surface: #1e1e2e;
  --color-surface-variant: #313244;
  --color-on-surface: #cdd6f4;
  --color-on-background: #cdd6f4;
  --color-border: rgba(var(--theme-border-rgb), 0.14);
  --color-text-main: rgba(var(--theme-on-surface-rgb), 0.94);
  --color-text-muted: rgba(var(--theme-on-surface-rgb), 0.72);
  --color-success: #a6e3a1;
  --color-warning: #fab387;
  --color-error: #f38ba8;
  --shadow-card-hover: 0 12px 30px -6px rgba(17, 17, 27, 0.55);

  --v-theme-primary: var(--theme-primary-rgb);
  --v-theme-secondary: var(--theme-secondary-rgb);
  --v-theme-on-surface: var(--theme-on-surface-rgb);
  --v-border-color: var(--theme-border-rgb);
}

html.light-theme {
  color-scheme: light;
  @include mat.all-component-colors($light-m3-theme);

  /* Catppuccin Latte-Sapphire Spin */
  --theme-primary-rgb: 30, 102, 245;
  --theme-secondary-rgb: 136, 57, 239;
  --theme-tertiary-rgb: 23, 146, 153;
  --theme-on-surface-rgb: 76, 79, 105;
  --theme-border-rgb: 76, 79, 105;

  --color-primary: #1e66f5;
  --color-secondary: #8839ef;
  --color-tertiary: #179299;
  --color-background: #eff1f5;
  --color-background-soft: #e6e9ef;
  --color-background-mute: #dce0e8;
  --color-surface: #fafbfd;
  --color-surface-variant: #e6e9ef;
  --color-on-surface: #4c4f69;
  --color-on-background: #4c4f69;
  --color-border: rgba(var(--theme-border-rgb), 0.14);
  --color-text-main: rgba(var(--theme-on-surface-rgb), 0.95);
  --color-text-muted: rgba(var(--theme-on-surface-rgb), 0.72);
  --color-success: #40a02b;
  --color-warning: #fe640b;
  --color-error: #d20f39;
  --shadow-card-hover: 0 12px 28px -6px rgba(76, 79, 105, 0.14);

  --v-theme-primary: var(--theme-primary-rgb);
  --v-theme-secondary: var(--theme-secondary-rgb);
  --v-theme-on-surface: var(--theme-on-surface-rgb);
  --v-border-color: var(--theme-border-rgb);
}
```

### 2.3 Signal-Based `ThemeService` Specification (`src/app/core/services/theme.service.ts`)

1. **State Signals**:
   - `readonly themeMode = signal<'dark' | 'light'>('dark')`
   - `readonly isDark = computed(() => this.themeMode() === 'dark')`
2. **Initialization & Persistence**:
   - Reads `localStorage.getItem('nue-chaotic-dreams-theme')` on startup; defaults to `'dark'`.
   - An Angular `effect()` synchronizes `document.documentElement.classList` (`dark-theme` vs `light-theme`), sets `document.documentElement.style.colorScheme`, and persists changes to `localStorage`.

---

## 3. Typography, Spacing, Radius & Motion Tokens

### 3.1 Spacing Scale (4px Base Grid)

- `--space-1` (`4px`), `--space-2` (`8px`), `--space-3` (`12px`), `--space-4` (`16px`), `--space-5` (`24px`), `--space-6` (`32px`), `--space-8` (`48px`), `--space-10` (`64px`).

### 3.2 Border Radii (Material 3 Shape Scale)

- `--radius-xs` (`4px`), `--radius-sm` (`6px`), `--radius-md` (`8px`), `--radius-lg` (`12px`), `--radius-xl` (`16px`), `--radius-2xl` (`24px`), `--radius-pill` (`9999px`).

### 3.3 Motion & Elevation Tokens

- `--transition-fast`: `150ms cubic-bezier(0.4, 0, 0.2, 1)`
- `--transition-normal`: `250ms cubic-bezier(0.4, 0, 0.2, 1)`
- `--transition-slow`: `350ms cubic-bezier(0.4, 0, 0.2, 1)`

### 3.4 Typography Hierarchy

- **Font Family**: `'Roboto', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif`
- **Hero / Page Title (`.hero-title`, `.page-title`, `.poems-title`, `.store-title`)**: `2rem` (`32px`), `font-weight: 800`, `letter-spacing: -0.02em`, `line-height: 1.2`
- **Section Heading (`.section-heading`)**: `1.25rem` (`20px`), `font-weight: 700`, `uppercase`, `letter-spacing: 0.06em`, `color: var(--color-primary)`, with trailing `1px` `var(--color-border)` flex line (`::after`)
- **Card Role / Product Title (`.role-title`, `.product-title`)**: `1.15rem` (`18.4px`), `font-weight: 700`, `letter-spacing: -0.01em`
- **Entity Subtitle (`.entity-subtitle`)**: `0.95rem` (`15.2px`), `font-weight: 500`, `color: var(--color-text-muted)`
- **Body / Accomplishment Bullet (`.resume-bullet-list li`)**: `0.9375rem` (`15px`), `line-height: 1.65`, custom `5px` primary pill bullet (`::before`)

---

## 4. Single `styles.scss` Architecture

[`web/src/styles/styles.scss`](web/src/styles/styles.scss) is the **only** stylesheet in the application, structured into 7 ordered layers:

```scss
/* ==========================================================================
   1. ANGULAR MATERIAL M3 & MDI ICON INITIALIZATION
   ========================================================================== */
/* ==========================================================================
   2. DESIGN TOKENS & LIGHT/DARK THEME PALETTES (:root, html.dark-theme, html.light-theme)
   ========================================================================== */
/* ==========================================================================
   3. BASE RESET, GLOBAL TYPOGRAPHY & SHARED UTILITY CLASSES
   ========================================================================== */
/* ==========================================================================
   4. AMBIENT TOPOGRAPHIC BACKGROUND & APP SHELL / NAVIGATION
   ========================================================================== */
/* ==========================================================================
   5. SHARED UI COMPONENT LIBRARY (@ui) STYLES
   ========================================================================== */
/* ==========================================================================
   6. FEATURE & PAGE LAYOUT STYLES (Hero, Timeline, Cards, Skills, Poems, Store)
   ========================================================================== */
/* ==========================================================================
   7. PRINT STYLESHEET (@media print)
   ========================================================================== */
```

---

## 5. e-Goods Storefront & Navigation Tab Design (`/store`)

### 5.1 Navigation Tab Integration (`AppNavigationComponent`)

- Primary navigation tabs in the top app bar and mobile drawer:
  - **Resume / Home** (`/`, `mdi-home-outline`)
  - **Store** (`/store`, `mdi-storefront-outline`)
  - **Poems** (`/PoemsPage`, `mdi-feather`)
  - **Books** (`/BooksPage`, `mdi-book-open-outline`)
- Active route tab uses a primary tonal pill indicator (`color="primary"`, `variant="tonal"`).

### 5.2 Storefront Layout & Product Card (`<mes-product-card>`)

- **Category Filter Bar**: Horizontal row of `<mes-chip>` filter pills (`All`, `PDF Guides & eBooks`, `Architecture Templates`, `Poetry Collections`).
- **Product Grid (`.store-grid`)**: Responsive CSS Grid (`1fr` on mobile, `repeat(2, 1fr)` on tablet, `repeat(3, 1fr)` on desktop `>= 1024px`, `gap: var(--space-5)`).
- **`MesProductCardComponent` (`<mes-product-card>`)**:
  - Built on `<mes-card class="m3-card product-card">`.
  - **Cover Preview Header**: `16/10` aspect-ratio cover thumbnail with a floating format badge (`PDF • 42 Pages` or `ZIP Bundle`) and price pill (`$19.00`).
  - **Body**: Product title (`.product-title`), concise description, included feature bullets, and action bar (`Preview Sample` secondary button + `Buy Now` primary tonal button with `mdi-lock-check-outline` / `mdi-cart-arrow-right`).
- **Post-Purchase Fulfillment Card (`/store/success`)**:
  - Displays verified order status (`--color-success`), customer email confirmation, remaining download count badge (`3 of 3 downloads remaining`), expiration timer, and a primary `Download e-Good` button backed by the signed backend token.

---

## 6. Shared UI Component Library (`@ui`) & Storybook Standards

### 6.1 Architectural Boundary & `MesSharedComponent` Contract

- Feature components (`src/app/features/**`) **must never import `@angular/material/*` directly**. They only consume generic `@ui` components (`src/app/shared/ui/index.ts`), which are documented in **Storybook**.
- Every component in `src/app/shared/ui/` uses the `mes-*.component.ts` file naming, `<mes-*>` selector, and `Mes*Component` class convention, and directly implements [`MesSharedComponent`](web/src/app/shared/ui/contracts/shared_component.ts) (`id` & `testdataId` with `{ transform: trimmed }`, `disabled`, `hidden`, and `styleOverride`), starting its template with `@if (!hidden()) { ... }` and defining component-scoped `styles: \`...\`` where component-specific classes are needed.

### 6.2 Required Storybook Stories Catalog (`src/app/shared/ui/`)

| Component                                                          | Selector                                         | Story File                               | Key States / Variants Covered in Storybook                                                                    |
| :----------------------------------------------------------------- | :----------------------------------------------- | :--------------------------------------- | :------------------------------------------------------------------------------------------------------------ |
| `MesCardComponent`                                                 | `<mes-card>`                                     | `mes-card.component.stories.ts`          | Outlined M3 surface (Dark & Light), `interactive`, `accentBar`, `padding`, `disabled`/`hidden` states         |
| `MesChipComponent`                                                 | `<mes-chip>`                                     | `mes-chip.component.stories.ts`          | Variants (`primary`, `secondary`, `outline`, `custom` hex color), sizes (`sm`, `md`), `icon`, anchor `href`   |
| `MesButtonComponent`                                               | `<mes-button>`                                   | `mes-button.component.stories.ts`        | Variants (`flat`, `tonal`, `stroked`, `text`), `icon`, anchor `href`, `download` link                         |
| `MesIconButtonComponent`                                           | `<mes-icon-button>`                              | `mes-icon-button.component.stories.ts`   | Social icon links, theme toggle icon button (`mdi-weather-sunny` / `mdi-weather-night`), required `ariaLabel` |
| `MesIconComponent`                                                 | `<mes-icon>`                                     | `mes-icon.component.stories.ts`          | `mdi-*` icon gallery, custom pixel sizes (`14px`–`32px`), semantic colors                                     |
| `MesButtonToggleComponent`                                         | `<mes-button-toggle>`                            | `mes-button-toggle.component.stories.ts` | Timeline vs Cards switcher with two-way `model()` signal binding                                              |
| `MesTimelineComponent` & `MesTimelineItemComponent`                | `<mes-timeline>`, `<mes-timeline-item>`          | `mes-timeline.component.stories.ts`      | Vertical/horizontal timeline track, node dots, opposite date pills, body slots                                |
| `MesToolbarComponent` & `MesDrawerComponent`                       | `<mes-toolbar>`, `<mes-drawer>`                  | `mes-toolbar.component.stories.ts`       | App bar with sticky elevation, navigation tabs (`Home`, `Store`, `Poems`), slide-over drawer                  |
| `MesAvatarComponent`, `MesDividerComponent`, `MesSpinnerComponent` | `<mes-avatar>`, `<mes-divider>`, `<mes-spinner>` | `mes-primitives.stories.ts`              | Tonal avatar (`sm`–`xl`), subtle divider, indeterminate loading state                                         |
| `MesHeadingComponent`                                              | `<mes-heading>`                                  | `mes-heading.component.stories.ts`       | Semantic `h1`–`h6` scale with optional subtitle and primary accent underline                                  |
| `MesVideoPreviewComponent` & `MesIframeComponent`                  | `<mes-video-preview>`, `<mes-iframe>`            | `mes-video-preview.component.stories.ts` | Interactive media preview card, `DomSanitizer`-validated iframe container                                     |

---

## 7. Responsive Breakpoints & Print Fidelity

- **Mobile (`< 600px`)**: Single-column layouts; mobile drawer navigation; compact horizontal timeline columns (`290px` track, `340px` card width).
- **Tablet (`600px – 959px`)**: 2-column store grid; desktop navigation tabs; row-aligned `.hero-body` at `768px`.
- **Desktop (`>= 960px`)**: 2-column `.cards-grid`, 3-column `.store-grid`, full horizontal timeline (`462px` track, `740px` card width).
- **Print (`@media print`)**: Forces `#ffffff` background and `#111111` text at `12pt`; hides `.ambient-background`, `.no-print`, `.m3-app-bar`, `.mat-drawer`, `.view-toggle-row`, and `.edge-glow`.
