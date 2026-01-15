# Features Overview

Complete feature documentation for Oxide Menu.

---

## Table of Contents

- [Modern UI Design](#modern-ui-design)
- [Menu Positioning](#menu-positioning)
- [Interactive Elements](#interactive-elements)
- [Search Functionality](#search-functionality)
- [Keyboard Navigation](#keyboard-navigation)
- [Submenu System](#submenu-system)
- [Menu Persistence](#menu-persistence)
- [Live Updates](#live-updates)
- [QBCore Integration](#qbcore-integration)
- [Sound Effects](#sound-effects)
- [Security Features](#security-features)

---

## Modern UI Design

Oxide Menu features a professional, modern interface with glassmorphic styling.

### Themes

| Theme | Description |
|-------|-------------|
| **Oxide** | Dark glassmorphic with emerald green accent. Backdrop blur, subtle borders, gradient overlays. |
| **Dark** | Solid dark theme. Higher contrast, no blur effects. |
| **Light** | Light background with dark text. Good for bright environments. |

### Visual Elements

- **Backdrop Blur**: Glass-like transparency effect
- **Smooth Animations**: Slide, fade, or scale transitions
- **Hover Effects**: Subtle highlighting on item interaction
- **Focus States**: Clear visual feedback for keyboard navigation
- **Typography**: Inter font family for clean, readable text

### Icons

Oxide Menu supports multiple icon sources:

| Source | Example | Description |
|--------|---------|-------------|
| Font Awesome | `fas fa-star` | Font Awesome 6 icons |
| QBCore Items | `water` | Automatically resolves to inventory image |
| Custom Images | `nui://resource/image.png` | NUI protocol paths |

```lua
-- Font Awesome
{ label = 'Settings', icon = 'fas fa-cog' }

-- QBCore item (auto-resolves)
{ label = 'Water', icon = 'water' }

-- Custom image
{ label = 'Custom', icon = 'nui://my-resource/icon.png' }
```

---

## Menu Positioning

Menus can be positioned in three locations on the screen.

### Positions

| Position | Description |
|----------|-------------|
| `'left'` | Left side of screen with padding |
| `'center'` | Centered horizontally |
| `'right'` | Right side of screen with padding |

### Setting Position

```lua
-- Global default in config.lua
Config.Position = 'right'

-- Per-menu override
exports['oxide-menu']:open({
    title = 'Left Menu',
    position = 'left',
    items = { ... }
})
```

### Responsive Behavior

- Menus automatically adjust for different screen resolutions
- Mobile/small screens get full-width menus
- 4K displays scale appropriately

---

## Interactive Elements

Beyond standard buttons, Oxide Menu supports interactive form elements.

### Checkboxes

Toggle switches for boolean options.

```lua
{
    type = 'checkbox',
    label = 'Enable Notifications',
    description = 'Show alerts for events',
    checked = true,  -- Initial state
}
```

**Features:**
- Animated toggle switch
- Visual on/off states
- Real-time state updates
- Event callback on change

### Sliders

Range inputs for numeric values.

```lua
{
    type = 'slider',
    label = 'Volume',
    min = 0,
    max = 100,
    value = 75,
    step = 5,  -- Optional: increment amount
}
```

**Features:**
- Filled track indicator
- Live value display
- Configurable min/max/step
- Real-time value updates
- Theme-aware colors

### Text Inputs

Inline text entry fields.

```lua
{
    type = 'input',
    label = 'License Plate',
    placeholder = 'Enter plate...',
    value = '',  -- Optional: initial value
}
```

**Features:**
- Styled input field
- Placeholder text support
- Submit on Enter key
- Event callback with value

### Headers

Non-interactive section labels.

```lua
{
    label = 'VEHICLES',
    isHeader = true,
}
```

**Features:**
- Distinct styling
- Not selectable/clickable
- Skipped in keyboard navigation
- Preserved in search results

### Dividers

Visual separators between sections.

```lua
{
    type = 'divider',
}
```

---

## Search Functionality

Built-in search for filtering menu items.

### Configuration

```lua
Config.Search = {
    enabled = true,
    minItems = 6,  -- Show search when 6+ items
}
```

### Per-Menu Control

```lua
-- Force search on small menu
exports['oxide-menu']:open({
    searchable = true,  -- Always show search
    items = { ... }
})

-- Disable search on large menu
exports['oxide-menu']:open({
    searchable = false,  -- Never show search
    items = { ... }
})
```

### Search Behavior

- Filters by label and description
- Case-insensitive matching
- Headers and dividers always visible
- Maintains original item indices for callbacks
- Search input preserves focus during filtering

---

## Keyboard Navigation

Full keyboard support for menu interaction.

### Key Bindings

| Key | Action |
|-----|--------|
| Arrow Up | Select previous item |
| Arrow Down | Select next item |
| Enter | Activate selected item |
| Backspace | Go back (submenu) |
| Escape | Close menu |

### Configuration

```lua
Config.Keyboard = {
    enabled = true,
}
```

### Navigation Behavior

- Cycles through enabled items only
- Skips headers, dividers, disabled items
- Visual highlight on selected item
- Auto-scrolls to keep selection visible
- Works alongside mouse interaction

### Input Focus

When typing in an input field:
- Arrow keys type in field (not navigate)
- Escape blurs the input
- Enter submits the input

---

## Submenu System

Navigate between menus with history tracking.

### Using Submenus

```lua
-- Register submenus first
exports['oxide-menu']:register('sub-audio', {
    title = 'Audio Settings',
    items = {
        { type = 'slider', label = 'Volume', min = 0, max = 100, value = 50 },
    }
})

exports['oxide-menu']:register('sub-video', {
    title = 'Video Settings',
    items = {
        { type = 'checkbox', label = 'Fullscreen', checked = true },
    }
})

-- Main menu with submenu references
exports['oxide-menu']:open({
    title = 'Settings',
    items = {
        { label = 'Audio', submenu = 'sub-audio' },
        { label = 'Video', submenu = 'sub-video' },
    }
})
```

### Navigation

- Clicking submenu item opens the submenu
- Back button appears in submenu header
- Backspace key goes back
- History preserved for multiple levels
- Search resets on submenu navigation

---

## Menu Persistence

Keep menus open after item selection for improved UX in shops, settings, and toggle menus.

### Why Use Persistence?

By default, menus close after selecting an item. This can be frustrating when:
- Buying multiple items from a shop
- Toggling multiple settings
- Using quick-action vehicle controls

### Persist Levels

Persistence can be set at three levels, with item-level taking priority:

| Level | Property | Description |
|-------|----------|-------------|
| Global | `Config.Persist.enabled` | Default for all menus |
| Menu | `persist = true` | All items in this menu |
| Item | `persist = true/false` | Override for specific item |

### Menu-Level Persist

All items keep the menu open:

```lua
exports['oxide-menu']:open({
    title = 'Quick Shop',
    persist = true,  -- All items stay open
    items = {
        { label = 'Buy Water', serverEvent = 'shop:buy', args = { item = 'water' } },
        { label = 'Buy Bread', serverEvent = 'shop:buy', args = { item = 'bread' } },
        { label = 'Exit', persist = false },  -- Override: this closes
    }
})
```

### Item-Level Persist

Individual items stay open:

```lua
exports['oxide-menu']:open({
    title = 'Vehicle Controls',
    items = {
        -- These stay open
        { label = 'Toggle Engine', persist = true, event = 'vehicle:engine' },
        { label = 'Toggle Lights', persist = true, event = 'vehicle:lights' },
        -- These close (default)
        { label = 'Store Vehicle', serverEvent = 'vehicle:store' },
    }
})
```

### Legacy Format Support

Persist works with the legacy qb-menu format:

```lua
exports['oxide-menu']:openMenu({
    {
        header = 'Buy Item',
        txt = 'Stays open after purchase',
        persist = true,  -- Item-level
        params = { event = 'shop:buy' }
    },
    -- Or in params
    {
        header = 'Buy Item',
        params = {
            event = 'shop:buy',
            persist = true  -- Also works here
        }
    }
})
```

### onSelect Callback

The `onSelect` callback receives a third parameter indicating persist state:

```lua
exports['oxide-menu']:open({
    persist = true,
    items = { ... },
    onSelect = function(item, index, isPersisting)
        if isPersisting then
            -- Menu is still open, maybe update item labels
        else
            -- Menu closed normally
        end
    end
})
```

---

## Live Updates

Update menu data while the menu is open. Essential for persistent menus showing dynamic data.

### Why Live Updates?

When using `persist = true`, the menu stays open but displays stale data:
- Stock counts don't update after purchase
- Prices may change
- Items may become unavailable

### Update Methods

| Method | Use Case | Performance |
|--------|----------|-------------|
| `onSelect` return | Refresh after selection | Good |
| `update()` | Replace all items | Good |
| `updateItem()` | Update single item | Best |
| Server events | External triggers | Good |

### onSelect Return Value

Return new items from `onSelect` to auto-refresh:

```lua
exports['oxide-menu']:open({
    persist = true,
    items = getItems(),
    onSelect = function(item, index, isPersisting)
        if isPersisting then
            processSelection(item)
            return getItems()  -- Return refreshed items
        end
    end
})
```

### update() Export

Replace items or update title/subtitle:

```lua
-- After external event changes data
exports['oxide-menu']:update({
    items = getUpdatedItems(),
    subtitle = 'Last updated: ' .. os.date('%H:%M')
})
```

### updateItem() Export

Update a single item (most efficient):

```lua
-- Update just the item that changed
exports['oxide-menu']:updateItem(3, {
    description = 'Stock: ' .. newStock,
    disabled = newStock <= 0
})
```

### Server-Triggered Updates

Server can push updates to client menus:

```lua
-- Server-side
RegisterNetEvent('shop:stockChanged', function(itemIndex, newStock)
    TriggerClientEvent('oxide-menu:client:updateItem', source, itemIndex, {
        description = 'Stock: ' .. newStock,
        disabled = newStock <= 0
    })
end)
```

### Best Practices

1. **Use `updateItem()` when possible** - Only re-renders one item
2. **Return from `onSelect`** - Natural flow for selection-triggered updates
3. **Use `update()` for bulk changes** - When multiple items change at once
4. **Cache item generators** - Create functions that return fresh item arrays

---

## QBCore Integration

Seamless integration with QBCore framework.

### Item Icon Resolution

When you use a QBCore item name as an icon, it automatically resolves to the inventory image:

```lua
-- This:
{ label = 'Water', icon = 'water' }

-- Becomes:
{ label = 'Water', icon = 'nui://qb-inventory/html/images/water.png' }
```

### QBCore Commands

Execute QBCore commands with arguments:

```lua
{
    label = 'Give Item',
    qbCommand = 'giveitem',
    args = { item = 'water', amount = 5 }
}
```

### Legacy Event

The legacy event still fires for scripts that listen to it:

```lua
AddEventHandler('qb-menu:client:menuClosed', function()
    -- Still fires when menus close
end)
```

---

## Sound Effects

Native GTA V sounds for menu interaction.

### Configuration

```lua
Config.Sound = {
    enabled = true,
    hover = true,   -- NAV_UP_DOWN sound
    select = true,  -- SELECT sound
    close = true,   -- BACK sound
}
```

### Sound Events

| Action | Sound | Soundset |
|--------|-------|----------|
| Hover item | `NAV_UP_DOWN` | `HUD_FRONTEND_DEFAULT_SOUNDSET` |
| Select item | `SELECT` | `HUD_FRONTEND_DEFAULT_SOUNDSET` |
| Close menu | `BACK` | `HUD_FRONTEND_DEFAULT_SOUNDSET` |

### Disabling Sounds

```lua
-- All sounds
Config.Sound = { enabled = false }

-- Specific sounds
Config.Sound = {
    enabled = true,
    hover = false,  -- No hover sound
    select = true,
    close = true
}
```

---

## Security Features

Optional security controls for event validation.

### Event Whitelisting

When enabled, only whitelisted events can be triggered:

```lua
Config.Security = {
    ValidateEvents = true,
    AllowedServerEvents = {
        'shop:buyItem',
        'inventory:useItem',
    },
    AllowedClientEvents = {
        'menu:openSettings',
    },
    AllowedCommands = {
        'inventory',
        'emotes',
    },
}
```

### Icon URL Validation

External URLs are blocked from icon sources:

| Allowed | Blocked |
|---------|---------|
| `nui://resource/img.png` | `https://external.com/img.png` |
| `fas fa-icon` | `http://malicious.com/img.png` |
| `./local/path.png` | `//protocol-relative.com/img.png` |
| `itemname` (QBCore) | `data:image/png;base64,...` |

### Input Validation

All NUI callbacks validate input structure:
- Type checking on parameters
- Null/undefined handling
- Index validation

### Debug Logging

When `Config.Debug = true`, blocked events are logged:

```
[oxide-menu] Blocked server: malicious:event
```

---

## Comparison with qb-menu

| Feature | qb-menu | Oxide Menu |
|---------|---------|------------|
| Basic menus | Yes | Yes |
| Headers | Yes | Yes |
| Icons | Yes | Yes (enhanced) |
| Themes | No | 3 themes |
| Animations | No | 3 types |
| Search | No | Yes |
| Keyboard nav | No | Yes |
| Checkboxes | No | Yes |
| Sliders | No | Yes |
| Inputs | No | Yes |
| Submenus | Limited | Full support |
| Menu persistence | No | Yes |
| Live updates | No | Yes |
| Security | No | Optional whitelist |
| Callbacks | Limited | Full support |

---

*Oxide Menu - Modern menus for QBCore*
