# Configuration Reference

Complete configuration options for Oxide Menu.

---

## Table of Contents

- [config.lua Overview](#configlua-overview)
- [Theme Settings](#theme-settings)
- [Position Settings](#position-settings)
- [Dimension Settings](#dimension-settings)
- [Animation Settings](#animation-settings)
- [Search Settings](#search-settings)
- [Keyboard Settings](#keyboard-settings)
- [Sound Settings](#sound-settings)
- [Persist Settings](#persist-settings)
- [Security Settings](#security-settings)
- [Debug Mode](#debug-mode)

---

## config.lua Overview

All configuration is stored in `config.lua`. The file uses a global `Config` table that is shared between client scripts.

```lua
Config = {}

Config.Theme = 'oxide'
Config.Position = 'right'
Config.Width = 320
Config.MaxHeight = '70vh'
-- ... more options
```

---

## Theme Settings

### Config.Theme

Controls the visual theme of the menu.

| Value | Description |
|-------|-------------|
| `'oxide'` | Dark glassmorphic theme with emerald accent (default) |
| `'dark'` | Solid dark theme |
| `'light'` | Light theme with dark text |

```lua
Config.Theme = 'oxide'
```

Themes are defined in `html/css/variables.css`. See [CUSTOMIZATION.md](CUSTOMIZATION.md) for creating custom themes.

---

## Position Settings

### Config.Position

Default horizontal position for menus.

| Value | Description |
|-------|-------------|
| `'left'` | Aligned to left side of screen |
| `'center'` | Centered horizontally |
| `'right'` | Aligned to right side of screen (default) |

```lua
Config.Position = 'right'
```

> **Note:** Individual menus can override this using the `position` property when opening.

---

## Dimension Settings

### Config.Width

Menu width in pixels.

```lua
Config.Width = 320  -- Default: 320px
```

### Config.MaxHeight

Maximum menu height. Accepts any valid CSS value.

```lua
Config.MaxHeight = '70vh'  -- 70% of viewport height
```

Other examples:
- `'500px'` - Fixed pixel height
- `'80vh'` - 80% of viewport
- `'auto'` - Fit content (not recommended for long menus)

---

## Animation Settings

### Config.Animation

Controls menu open/close animations.

```lua
Config.Animation = {
    enabled = true,      -- Enable/disable animations
    duration = 150,      -- Duration in milliseconds
    type = 'slide'       -- Animation type
}
```

### Animation Types

| Value | Description |
|-------|-------------|
| `'slide'` | Slides in from the side (default) |
| `'fade'` | Fades in with opacity |
| `'scale'` | Scales up from smaller size |

### Disabling Animations

```lua
Config.Animation = {
    enabled = false,
    duration = 0,
    type = 'slide'
}
```

---

## Search Settings

### Config.Search

Controls the search bar functionality.

```lua
Config.Search = {
    enabled = true,       -- Enable search feature
    minItems = 6,         -- Minimum items to show search
    placeholder = 'Search...'  -- Placeholder text
}
```

### minItems

The search bar only appears when a menu has at least this many items. This prevents showing search on small menus where it's unnecessary.

```lua
Config.Search = {
    enabled = true,
    minItems = 10,  -- Only show search for menus with 10+ items
}
```

### Disabling Search

```lua
Config.Search = {
    enabled = false,
    minItems = 6,
}
```

> **Note:** Individual menus can override this using `searchable = false` in menu data.

---

## Keyboard Settings

### Config.Keyboard

Controls keyboard navigation.

```lua
Config.Keyboard = {
    enabled = true,       -- Enable keyboard navigation
    scrollAmount = 1      -- Items to scroll per keypress
}
```

### Keyboard Controls

When enabled, these keys work in the menu:

| Key | Action |
|-----|--------|
| Arrow Up | Select previous item |
| Arrow Down | Select next item |
| Enter | Activate selected item |
| Backspace | Go back (submenu navigation) |
| Escape | Close menu |

### Disabling Keyboard

```lua
Config.Keyboard = {
    enabled = false,
}
```

---

## Sound Settings

### Config.Sound

Controls menu sound effects.

```lua
Config.Sound = {
    enabled = true,   -- Master enable/disable
    hover = true,     -- Sound when hovering items
    select = true,    -- Sound when selecting items
    close = true      -- Sound when closing menu
}
```

### Sound Types

| Setting | Sound | Native |
|---------|-------|--------|
| `hover` | Navigation tick | `NAV_UP_DOWN` |
| `select` | Selection confirm | `SELECT` |
| `close` | Back/close | `BACK` |

### Disabling Sounds

```lua
-- Disable all sounds
Config.Sound = {
    enabled = false,
}

-- Or disable specific sounds
Config.Sound = {
    enabled = true,
    hover = false,    -- No hover sound
    select = true,
    close = true
}
```

---

## Persist Settings

### Config.Persist

Controls whether menus stay open after item selection by default.

```lua
Config.Persist = {
    enabled = false,  -- Global default for menu persistence
}
```

### How Persistence Works

By default, menus close after selecting an item. When persistence is enabled, the menu stays open, allowing multiple selections without reopening.

### Priority Order

Persistence is determined in this order (first match wins):

1. **Item-level** - `item.persist = true/false`
2. **Menu-level** - `menu.persist = true/false`
3. **Global config** - `Config.Persist.enabled`
4. **Default** - `false` (close after selection)

### Examples

```lua
-- Global default: menus stay open
Config.Persist = {
    enabled = true,
}
```

With this config:
- All menus stay open by default
- Individual menus can override with `persist = false`
- Individual items can override with `persist = false`

### Use Cases

| Scenario | Recommendation |
|----------|----------------|
| Shop menus | `persist = true` on menu |
| Settings/toggle menus | `persist = true` on specific items |
| One-time actions | Default (no persist) |
| Exit/close buttons | `persist = false` to override |

---

## Security Settings

### Config.Security

Controls event and command validation. Disabled by default for backward compatibility.

```lua
Config.Security = {
    ValidateEvents = false,     -- Enable validation
    AllowedServerEvents = {},   -- Whitelisted server events
    AllowedClientEvents = {},   -- Whitelisted client events
    AllowedCommands = {},       -- Whitelisted commands
}
```

### Enabling Security

When `ValidateEvents = true`, only whitelisted events/commands can be triggered:

```lua
Config.Security = {
    ValidateEvents = true,
    AllowedServerEvents = {
        'qb-shops:server:buy',
        'qb-clothing:server:save',
        'qb-inventory:server:useItem',
    },
    AllowedClientEvents = {
        'qb-clothing:client:openMenu',
        'qb-inventory:client:openInventory',
    },
    AllowedCommands = {
        'inventory',
        'clothing',
        'emotes',
    },
}
```

### How Validation Works

| Item Action | Validated Against |
|-------------|-------------------|
| `serverEvent` | `AllowedServerEvents` |
| `event` | `AllowedClientEvents` |
| `command` | `AllowedCommands` |
| `qbCommand` | `AllowedCommands` |

### Empty Whitelists

If a whitelist is empty, all events of that type are allowed:

```lua
Config.Security = {
    ValidateEvents = true,
    AllowedServerEvents = {},   -- Empty = allow all server events
    AllowedClientEvents = {'specific:event'},  -- Only this client event
    AllowedCommands = {},       -- Empty = allow all commands
}
```

> **Warning:** Enabling security may break existing menus if their events aren't whitelisted. Test thoroughly.

---

## Debug Mode

### Config.Debug

Enables debug logging and demo commands.

```lua
Config.Debug = false  -- Set to true for development
```

### When Enabled

1. **Console Logging**: Detailed logs of menu operations
2. **Demo Commands**: Test commands become available:
   - `/oxidemenu` - Basic menu
   - `/oxidemenu2` - Job menu
   - `/oxidemenu3` - Interactive elements
   - `/oxidemenu4` - Searchable shop
   - `/oxidemenu5` - Legacy format
   - `/oxidemenu6 [position]` - Position test
3. **Security Logs**: Blocked events are logged to console

### Production

Always set `Config.Debug = false` in production to:
- Reduce console spam
- Disable test commands
- Improve performance slightly

---

## Complete Default Configuration

```lua
Config = {}

-- Theme: 'oxide' (glassmorphic dark), 'dark', 'light'
Config.Theme = 'oxide'

-- Default position: 'left', 'center', 'right'
Config.Position = 'right'

-- Menu dimensions
Config.Width = 320
Config.MaxHeight = '70vh'

-- Animation settings
Config.Animation = {
    enabled = true,
    duration = 150,
    type = 'slide'
}

-- Search settings
Config.Search = {
    enabled = true,
    minItems = 6,
    placeholder = 'Search...'
}

-- Keyboard navigation
Config.Keyboard = {
    enabled = true,
    scrollAmount = 1
}

-- Sound effects
Config.Sound = {
    enabled = true,
    hover = true,
    select = true,
    close = true
}

-- Menu persistence
Config.Persist = {
    enabled = false,
}

-- Debug mode
Config.Debug = false

-- Security: Event/command validation
Config.Security = {
    ValidateEvents = false,
    AllowedServerEvents = {},
    AllowedClientEvents = {},
    AllowedCommands = {},
}
```

---

*Oxide Menu - Modern menus for QBCore*
