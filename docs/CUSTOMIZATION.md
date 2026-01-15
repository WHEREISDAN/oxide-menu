# UI Customization Guide

Customize the look and feel of Oxide Menu.

---

## Table of Contents

- [File Structure](#file-structure)
- [CSS Variables](#css-variables)
- [Quick Theme Changes](#quick-theme-changes)
- [Color Customization](#color-customization)
- [Typography](#typography)
- [Spacing & Dimensions](#spacing--dimensions)
- [Animations](#animations)
- [Creating Custom Themes](#creating-custom-themes)
- [Advanced Customization](#advanced-customization)

---

## File Structure

CSS files are organized in `html/css/`:

```
html/
└── css/
    ├── variables.css   # Design tokens & themes
    ├── animations.css  # Keyframe animations
    └── main.css        # Component styles
```

| File | Purpose |
|------|---------|
| `variables.css` | Colors, typography, spacing, shadows - the design system |
| `animations.css` | Menu enter/exit animations, hover effects |
| `main.css` | Component styles (menu, items, inputs) |

---

## CSS Variables

Oxide Menu uses CSS custom properties (variables) for easy theming. All variables are defined in `variables.css`.

### Viewing Current Variables

Open `html/css/variables.css` to see all available variables. Key categories:

- Backgrounds (`--bg-*`)
- Text colors (`--text-*`)
- Borders (`--border-*`)
- Accent colors (`--accent*`)
- Typography (`--font-*`)
- Spacing (`--space-*`)
- Shadows (`--shadow-*`)
- Transitions (`--transition-*`)

---

## Quick Theme Changes

### Changing Accent Color

The accent color (emerald green by default) is used for highlights, checkboxes, sliders, and focus states.

```css
:root {
    /* Change from emerald to blue */
    --accent: #3b82f6;
    --accent-light: #60a5fa;
    --accent-dark: #2563eb;
    --accent-bg: rgba(59, 130, 246, 0.1);
    --accent-border: rgba(59, 130, 246, 0.2);
}
```

Common accent colors:

| Color | Value | Preview |
|-------|-------|---------|
| Emerald (default) | `#34d399` | Green |
| Blue | `#3b82f6` | Blue |
| Purple | `#a855f7` | Purple |
| Red | `#ef4444` | Red |
| Orange | `#f97316` | Orange |
| Pink | `#ec4899` | Pink |

### Changing Background Opacity

Adjust the glassmorphic transparency:

```css
:root {
    /* More transparent */
    --bg-primary: rgba(10, 10, 12, 0.85);

    /* More opaque */
    --bg-primary: rgba(10, 10, 12, 0.98);

    /* Solid (no transparency) */
    --bg-primary: rgb(10, 10, 12);
}
```

---

## Color Customization

### Background Colors

```css
:root {
    --bg-primary: rgba(10, 10, 12, 0.95);    /* Main menu background */
    --bg-secondary: rgba(255, 255, 255, 0.03); /* Subtle backgrounds */
    --bg-tertiary: rgba(255, 255, 255, 0.06);  /* Slider tracks, etc */
    --bg-hover: rgba(255, 255, 255, 0.08);     /* Item hover state */
    --bg-active: rgba(255, 255, 255, 0.10);    /* Item active/selected */
    --bg-input: rgba(255, 255, 255, 0.04);     /* Input fields */
}
```

### Text Colors

```css
:root {
    --text-primary: rgba(255, 255, 255, 0.95);   /* Main text */
    --text-secondary: rgba(255, 255, 255, 0.6);  /* Descriptions */
    --text-tertiary: rgba(255, 255, 255, 0.4);   /* Subtle text */
    --text-muted: rgba(255, 255, 255, 0.3);      /* Very subtle */
    --text-disabled: rgba(255, 255, 255, 0.2);   /* Disabled items */
}
```

### Border Colors

```css
:root {
    --border-primary: rgba(255, 255, 255, 0.08);   /* Main borders */
    --border-secondary: rgba(255, 255, 255, 0.04); /* Subtle borders */
    --border-focus: rgba(255, 255, 255, 0.15);     /* Focus rings */
}
```

### Semantic Colors

```css
:root {
    --success: #34d399;
    --success-bg: rgba(52, 211, 153, 0.1);
    --error: #f87171;
    --error-bg: rgba(248, 113, 113, 0.1);
    --warning: #fbbf24;
    --warning-bg: rgba(251, 191, 36, 0.1);
    --info: #22d3ee;
    --info-bg: rgba(34, 211, 238, 0.1);
}
```

---

## Typography

### Font Family

```css
:root {
    --font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
}
```

To use a different font:

```css
:root {
    --font-family: 'Roboto', sans-serif;
}
```

Remember to update the font import in `index.html` if changing fonts.

### Font Sizes

```css
:root {
    --font-size-xs: 10px;
    --font-size-sm: 11px;
    --font-size-base: 13px;   /* Default */
    --font-size-md: 14px;
    --font-size-lg: 16px;
    --font-size-xl: 18px;
}
```

### Font Weights

```css
:root {
    --font-weight-normal: 400;
    --font-weight-medium: 500;
    --font-weight-semibold: 600;
}
```

---

## Spacing & Dimensions

### Spacing Scale

```css
:root {
    --space-1: 4px;
    --space-2: 8px;
    --space-3: 12px;
    --space-4: 16px;
    --space-5: 20px;
    --space-6: 24px;
    --space-8: 32px;
}
```

### Menu Dimensions

```css
:root {
    --menu-width: 320px;
    --menu-max-height: 70vh;
    --menu-icon-size: 32px;
}
```

### Border Radius

```css
:root {
    --radius-xs: 4px;
    --radius-sm: 8px;
    --radius-md: 12px;   /* Menu corners */
    --radius-lg: 16px;
    --radius-full: 9999px;  /* Pills, circles */
}
```

---

## Animations

### Animation Duration

In `config.lua`:

```lua
Config.Animation = {
    duration = 150,  -- milliseconds
}
```

In CSS (for hover effects):

```css
:root {
    --transition-fast: 0.15s ease;
    --transition-normal: 0.25s ease;
    --transition-slow: 0.35s ease;
}
```

### Animation Types

Defined in `animations.css`:

#### Slide Animation

```css
@keyframes slideInRight {
    from {
        opacity: 0;
        transform: translateX(20px);
    }
    to {
        opacity: 1;
        transform: translateX(0);
    }
}
```

#### Fade Animation

```css
@keyframes fadeIn {
    from { opacity: 0; }
    to { opacity: 1; }
}
```

#### Scale Animation

```css
@keyframes scaleIn {
    from {
        opacity: 0;
        transform: scale(0.95);
    }
    to {
        opacity: 1;
        transform: scale(1);
    }
}
```

### Custom Animation

Add to `animations.css`:

```css
@keyframes bounceIn {
    0% {
        opacity: 0;
        transform: scale(0.3);
    }
    50% {
        transform: scale(1.05);
    }
    70% {
        transform: scale(0.9);
    }
    100% {
        opacity: 1;
        transform: scale(1);
    }
}

.animate-bounce-in {
    animation: bounceIn 0.4s ease-out;
}
```

---

## Creating Custom Themes

### Theme Structure

Themes are defined as `[data-theme="name"]` selectors in `variables.css`:

```css
/* Custom theme */
[data-theme="custom"] {
    --bg-primary: rgba(20, 20, 40, 0.95);
    --accent: #8b5cf6;
    --accent-light: #a78bfa;
    /* ... more overrides */
}
```

### Example: Cyberpunk Theme

```css
[data-theme="cyberpunk"] {
    /* Backgrounds */
    --bg-primary: rgba(15, 10, 25, 0.95);
    --bg-secondary: rgba(255, 0, 128, 0.05);
    --bg-hover: rgba(255, 0, 128, 0.1);
    --bg-active: rgba(255, 0, 128, 0.15);

    /* Accent - Hot pink */
    --accent: #ff0080;
    --accent-light: #ff4da6;
    --accent-dark: #cc0066;
    --accent-bg: rgba(255, 0, 128, 0.1);
    --accent-border: rgba(255, 0, 128, 0.3);

    /* Text */
    --text-primary: #00ffff;
    --text-secondary: rgba(0, 255, 255, 0.7);

    /* Borders */
    --border-primary: rgba(255, 0, 128, 0.2);
}
```

### Using Custom Theme

In `config.lua`:

```lua
Config.Theme = 'cyberpunk'
```

---

## Advanced Customization

### Menu Card Styling

In `main.css`, the `.menu-card` class controls the main container:

```css
.menu-card {
    background: var(--bg-primary);
    border: 1px solid var(--border-primary);
    border-radius: var(--radius-md);
    backdrop-filter: blur(20px);
    box-shadow: var(--shadow-menu);
}
```

### Removing Glassmorphic Effect

For a solid, non-transparent menu:

```css
.menu-card {
    backdrop-filter: none;
    background: rgb(20, 20, 25);
}
```

### Custom Scrollbar

```css
.menu-items::-webkit-scrollbar {
    width: 6px;
}

.menu-items::-webkit-scrollbar-track {
    background: transparent;
}

.menu-items::-webkit-scrollbar-thumb {
    background: var(--border-primary);
    border-radius: var(--radius-full);
}
```

### Item Styling

```css
.menu-item {
    padding: var(--space-3) var(--space-4);
    border-radius: var(--radius-sm);
    transition: background var(--transition-fast);
}

.menu-item:hover {
    background: var(--bg-hover);
}

.menu-item--active {
    background: var(--bg-active);
}
```

### Header Styling

```css
.menu-header {
    padding: var(--space-4);
    border-bottom: 1px solid var(--border-primary);
}

.menu-header__title {
    font-size: var(--font-size-lg);
    font-weight: var(--font-weight-semibold);
    color: var(--text-primary);
}
```

---

## Tips

1. **Test all themes** - Check your changes in oxide, dark, and light themes
2. **Check hover states** - Ensure contrast is maintained on hover
3. **Test search** - Make sure search input is readable
4. **Verify accessibility** - Maintain sufficient color contrast
5. **Clear cache** - FiveM caches NUI assets, clear cache when testing

### Clearing FiveM Cache

```
%localappdata%/FiveM/FiveM.app/data/cache/
```

Delete the contents of this folder to see CSS changes.

---

*Oxide Menu - Modern menus for QBCore*
