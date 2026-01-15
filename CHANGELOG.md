# Changelog

All notable changes to Oxide Menu will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [1.1.0] - 2025-01-15

### Added

- **Menu Persistence**: Keep menus open after item selection for improved UX
  - `persist` property on menu data (applies to all items)
  - `persist` property on individual items (overrides menu-level)
  - `Config.Persist.enabled` global default setting
  - Legacy format support via `item.persist` or `params.persist`
  - Third parameter `isPersisting` added to `onSelect` callback

- **Demo Commands**: Two new demo commands for testing persistence
  - `/oxidemenu7` - Menu-level persist (shop example)
  - `/oxidemenu8` - Item-level persist (vehicle controls example)

### Changed

- `onSelect` callback now receives a third parameter indicating if menu persisted
- Updated all documentation with persistence examples and configuration

---

## [1.0.0] - 2025-01-15

### Added

- Initial release of Oxide Menu
- Modern glassmorphic UI with three themes (oxide, dark, light)
- Full compatibility with qb-menu data format
- Modern API with callbacks (`onSelect`, `onClose`)
- Legacy API (`openMenu`, `closeMenu`, `showHeader`)

#### Menu Features
- Three position options (left, center, right)
- Configurable animations (slide, fade, scale)
- Built-in search functionality
- Keyboard navigation (arrow keys, enter, escape, backspace)
- Submenu system with history navigation

#### Interactive Elements
- Buttons with icons (Font Awesome, QBCore items, custom images)
- Checkboxes with toggle state
- Sliders with real-time value updates
- Text inputs with submit on Enter
- Headers and dividers

#### Developer Features
- QBCore item icon auto-resolution
- Event/command security whitelist
- Action function support (legacy format)
- Client events for interactive element changes

#### Configuration
- Theme selection
- Position default
- Menu dimensions
- Animation settings
- Search settings
- Keyboard settings
- Sound settings
- Security settings
- Debug mode with demo commands

---

## Version History

| Version | Date | Description |
|---------|------|-------------|
| 1.1.0 | 2025-01-15 | Menu persistence feature |
| 1.0.0 | 2025-01-15 | Initial release |
