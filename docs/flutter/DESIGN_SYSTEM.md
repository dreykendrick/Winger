# Winger Design System & Theme Documentation

## Design Tokens

- **Primary Colors**: Emerald (`#059669`), Light Emerald (`#10B981`), Dark Emerald (`#047857`)
- **Secondary Colors**: Indigo (`#4F46E5`), Light Indigo (`#6366F1`), Dark Indigo (`#3730A3`)
- **Accent & Status**: Amber (`#D97706`), Danger Coral (`#DC2626`), Success Green (`#16A34A`)
- **Typography**: Google Fonts `Outfit` (display, headlines, titles) + `Inter` (body, labels)
- **Spacing**: 4px, 8px, 12px, 16px, 24px, 32px, 48px

## Component System (`lib/shared/components/`)

- `WingerButton`: Primary, secondary, outline, danger variants with loading states.
- `WingerInput`: Text form fields with border validation & suffix icons.
- `WingerCard`: Rounded container cards with shadow elevation.
- `WingerDialog`: Reusable alert and modal dialogs.
- `WingerBottomSheet`: Modal bottom sheet wrapper.
- `WingerLoading`: Centered loading spinners.
- `WingerError`: Sanitized user-facing error state component with retry CTA.
- `WingerEmptyState`: Empty list & state fallback display.
