# Oxide Menu

Modern Menu System for QBCore Framework - A sleek, glassmorphic menu with support for the legacy qb-menu data format.

## Features

### Modern UI Design
- Glassmorphic styling with backdrop blur effects
- Three theme variants: Oxide (dark glass), Dark, Light
- Smooth animations (slide, fade, scale)
- Responsive design for all resolutions
- Professional typography with Inter font

### Menu Functionality
- Multiple menu positions (left, center, right)
- Searchable menus with automatic filtering
- Keyboard navigation (arrow keys, enter, escape)
- Submenu support with history navigation
- Menu persistence (keep open after selection)
- Header sections and dividers

### Interactive Elements
- **Buttons** - Standard clickable items with icons
- **Checkboxes** - Toggle switches with state tracking
- **Sliders** - Range inputs with real-time updates
- **Text Inputs** - Inline text entry fields

### Developer Features
- Legacy qb-menu data format support
- Modern and legacy API
- Event/command security whitelist
- Callback system for menu events
- QBCore item icon resolution

### Security
- Optional event/command validation
- Server, client, and command whitelists
- Blocks external icon URLs
- Input validation on all callbacks

## Requirements

- [QBCore Framework](https://github.com/qbcore-framework/qb-core)

## Installation

1. Download and extract to your resources folder as `oxide-menu`
2. Add `ensure oxide-menu` to your server.cfg (after qb-core)
3. Remove or disable the original `qb-menu` resource
4. Configure settings in `config.lua`
5. Restart your server

> **Note:** Oxide Menu supports the legacy qb-menu data format. Existing scripts need to change the export name from `'qb-menu'` to `'oxide-menu'`, but the menu data structure remains the same.

## Configuration

### Main Config (`config.lua`)

```lua
Config.Theme = 'oxide'          -- 'oxide', 'dark', 'light'
Config.Position = 'right'       -- 'left', 'center', 'right'
Config.Width = 320              -- Menu width in pixels
Config.MaxHeight = '70vh'       -- Maximum menu height

Config.Animation = {
    enabled = true,
    duration = 150,             -- Duration in milliseconds
    type = 'slide'              -- 'slide', 'fade', 'scale'
}

Config.Search = {
    enabled = true,
    minItems = 6,               -- Show search when menu has 6+ items
}

Config.Keyboard = {
    enabled = true,
}

Config.Sound = {
    enabled = true,
    hover = true,
    select = true,
    close = true
}

Config.Persist = {
    enabled = false,            -- Global default for menu persistence
}

Config.Security = {
    ValidateEvents = false,     -- Enable to enforce whitelists
    AllowedServerEvents = {},
    AllowedClientEvents = {},
    AllowedCommands = {},
}

Config.Debug = false            -- Enable demo commands
```

## Exports

### Modern API (Recommended)

```lua
-- Open a menu
exports['oxide-menu']:open({
    id = 'my-menu',
    title = 'Menu Title',
    subtitle = 'Optional subtitle',
    position = 'right',
    searchable = true,
    persist = false,  -- Keep menu open after selection (default: false)
    items = {
        { label = 'Option 1', description = 'Description', icon = 'fas fa-star' },
        { label = 'Option 2', icon = 'fas fa-cog', event = 'my-event', args = { data = 'value' } },
        { type = 'divider' },
        { label = 'Server Action', serverEvent = 'my-server-event', args = {} },
        { label = 'Stay Open', persist = true, event = 'my-event' },  -- Item-level override
    },
    onSelect = function(item, index)
        print('Selected:', item.label)
    end,
    onClose = function()
        print('Menu closed')
    end
})

-- Close menu
exports['oxide-menu']:close()
exports['oxide-menu']:close('my-menu')  -- Close specific menu

-- Check if open
local isOpen = exports['oxide-menu']:isOpen()
local isMyMenuOpen = exports['oxide-menu']:isOpen('my-menu')

-- Register reusable menu
exports['oxide-menu']:register('my-menu', menuData)
```

### Legacy API (qb-menu Format)

```lua
-- Open menu using qb-menu data format
-- Note: Use 'oxide-menu' as the export name, not 'qb-menu'
exports['oxide-menu']:openMenu({
    {
        header = 'Menu Title',
        isMenuHeader = true,
    },
    {
        header = 'Option 1',
        txt = 'Description text',
        icon = 'fas fa-star',
        params = {
            event = 'my-event',
            args = { data = 'value' }
        }
    },
    {
        header = 'Server Action',
        txt = 'Triggers server event',
        params = {
            isServer = true,
            event = 'my-server-event',
            args = {}
        }
    },
})

-- Close menu
exports['oxide-menu']:closeMenu()

-- Show header (alias for openMenu)
exports['oxide-menu']:showHeader(menuData)
```

## Item Types

### Button (Default)

```lua
{
    label = 'Button Label',
    description = 'Optional description',
    icon = 'fas fa-icon',           -- Font Awesome or item image
    disabled = false,
    persist = false,                -- Keep menu open after selection

    -- Action (choose one):
    event = 'client:event',         -- Client event
    serverEvent = 'server:event',   -- Server event
    command = 'commandname',        -- Execute command
    qbCommand = 'qbcommand',        -- QBCore command
    args = {},                      -- Arguments for event/command
}
```

### Header

```lua
{
    label = 'Section Header',
    isHeader = true,
}
```

### Divider

```lua
{
    type = 'divider',
}
```

### Checkbox

```lua
{
    type = 'checkbox',
    label = 'Toggle Option',
    description = 'Enable or disable',
    checked = true,
}
```

### Slider

```lua
{
    type = 'slider',
    label = 'Volume',
    min = 0,
    max = 100,
    value = 50,
    step = 5,
}
```

### Input

```lua
{
    type = 'input',
    label = 'Enter Text',
    placeholder = 'Type here...',
    value = '',
}
```

## Events

### Client Events

```lua
-- Menu closed
AddEventHandler('oxide-menu:client:closed', function()
    print('Menu was closed')
end)

-- Checkbox changed
AddEventHandler('oxide-menu:client:checkboxChange', function(index, checked, item)
    print(item.label, 'is now', checked and 'enabled' or 'disabled')
end)

-- Slider changed
AddEventHandler('oxide-menu:client:sliderChange', function(index, value, item)
    print(item.label, 'set to', value)
end)

-- Input submitted
AddEventHandler('oxide-menu:client:inputSubmit', function(index, value, item)
    print(item.label, 'submitted:', value)
end)
```

### Legacy Event

```lua
-- This event still fires for scripts listening to it
AddEventHandler('qb-menu:client:menuClosed', function()
    print('Menu closed (legacy event)')
end)
```

## Keyboard Shortcuts

| Key | Action |
|-----|--------|
| Arrow Up | Previous item |
| Arrow Down | Next item |
| Enter | Select item |
| Backspace | Go back (submenu) |
| Escape | Close menu |

## Demo Commands

When `Config.Debug = true`, these test commands are available:

| Command | Description |
|---------|-------------|
| `/oxidemenu` | Basic menu demo |
| `/oxidemenu2` | Job menu with headers |
| `/oxidemenu3` | Interactive elements demo |
| `/oxidemenu4` | Searchable shop menu |
| `/oxidemenu5` | Legacy format showcase |
| `/oxidemenu6 [pos]` | Position testing (left/center/right) |
| `/oxidemenu7` | Menu-level persist (shop) |
| `/oxidemenu8` | Item-level persist (vehicle controls) |

## Documentation

- [Installation Guide](docs/INSTALLATION.md)
- [Configuration Reference](docs/CONFIGURATION.md)
- [Exports & API Reference](docs/EXPORTS.md)
- [Features Overview](docs/FEATURES.md)
- [UI Customization](docs/CUSTOMIZATION.md)
- [Legacy Compatibility](docs/LEGACY.md)
- [Troubleshooting](docs/TROUBLESHOOTING.md)

## Support

For issues and feature requests, please open an issue on the repository.

## License

This resource is provided as-is for use with QBCore Framework.

## Credits

- Oxide Studios - Development
- QBCore Framework team - Base framework
