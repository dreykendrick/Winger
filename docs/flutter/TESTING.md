# Testing Strategy & Foundation

## Test Hierarchy

- `test/unit/`: Unit tests for config, error handling, logging, formatting.
- `test/widget/`: Widget component tests for design tokens & M3 widgets.
- `test/repository/`: Data layer & network repository tests using `mocktail`.
- `test/provider/`: Riverpod provider initialization & state notifier tests.

## Execution

```bash
flutter test
```
