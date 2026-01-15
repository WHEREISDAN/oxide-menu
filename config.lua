Config = {}

-- Theme: 'oxide' (glassmorphic dark), 'dark', 'light'
Config.Theme = 'oxide'

-- Default position: 'left', 'center', 'right'
Config.Position = 'right'

-- Menu dimensions
Config.Width = 320          -- Menu width in pixels
Config.MaxHeight = '70vh'   -- Max menu height (CSS value)

-- Animation settings
Config.Animation = {
    enabled = true,
    duration = 150,         -- Duration in milliseconds
    type = 'slide'          -- 'slide', 'fade', 'scale'
}

-- Search settings
Config.Search = {
    enabled = true,
    minItems = 6,           -- Only show search when menu has this many items or more
    placeholder = 'Search...'
}

-- Keyboard navigation
Config.Keyboard = {
    enabled = true,
    scrollAmount = 1        -- Number of items to scroll per keypress
}

-- Sound effects
Config.Sound = {
    enabled = true,
    hover = true,           -- Play sound on hover
    select = true,          -- Play sound on select
    close = true            -- Play sound on close
}

-- Menu persistence (keep menu open after item selection)
Config.Persist = {
    enabled = false,        -- Global default: false = close after selection, true = stay open
}

-- Debug mode
Config.Debug = false

-- Security: Event/command validation (backward compatible - disabled by default)
Config.Security = {
    ValidateEvents = false,     -- Set to true to enforce whitelist
    AllowedServerEvents = {},   -- e.g., {'qb-shops:server:buy', 'qb-clothing:server:save'}
    AllowedClientEvents = {},   -- e.g., {'qb-clothing:client:openMenu'}
    AllowedCommands = {},       -- e.g., {'inventory', 'clothing'}
}
