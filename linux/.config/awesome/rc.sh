
-- ░░░░░██╗░█████╗░██████╗░███████╗██████╗░███████╗░█████╗░███╗░░░███╗░█████╗░███╗░░██╗
-- ░░░░░██║██╔══██╗██╔══██╗██╔════╝██╔══██╗╚════██║██╔══██╗████╗░████║██╔══██╗████╗░██║
-- ░░░░░██║███████║██████╦╝█████╗░░██║░░██║░░███╔═╝███████║██╔████╔██║███████║██╔██╗██║
-- ██╗░░██║██╔══██║██╔══██╗██╔══╝░░██║░░██║██╔══╝░░██╔══██║██║╚██╔╝██║██╔══██║██║╚████║
-- ╚█████╔╝██║░░██║██████╦╝███████╗██████╔╝███████╗██║░░██║██║░╚═╝░██║██║░░██║██║░╚███║
-- ░╚════╝░╚═╝░░╚═╝╚═════╝░╚══════╝╚═════╝░╚══════╝╚═╝░░╚═╝╚═╝░░░░░╚═╝╚═╝░░╚═╝╚═╝░░╚══╝

pcall(require, "luarocks.loader")
local gears = require("gears")
local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local naughty = require("naughty")
local hotkeys_popup = require("awful.hotkeys_popup")

local lain = require("lain")

local battery_widget = require("awesome-wm-widgets.battery-widget.battery")

require("awful.hotkeys_popup.keys")
require("awful.autofocus")

-- {{{ Error handling
if awesome.startup_errors then
  naughty.notify({
    preset = naughty.config.presets.critical,
    title = "Oops, there were errors during startup!",
    text = awesome.startup_errors
  })
end
do
  local in_error = false
  awesome.connect_signal("debug::error", function(err)
    if in_error then return end
    in_error = true
    naughty.notify({
      preset = naughty.config.presets.critical,
      title = "Oops, an error happened!",
      text = tostring(err)
    })
    in_error = false
  end)
end
-- }}}

-- {{{ Variable definitions
beautiful.init(gears.filesystem.get_themes_dir() .. "default/theme.lua")
beautiful.useless_gap = 5
beautiful.border_width = 3
beautiful.font          = "Dank Mono Italic Bold 11"

beautiful.bg_normal     = "#222222C1"
beautiful.bg_focus      = "#2222227A"
beautiful.bg_urgent     = "#05ff0000"
beautiful.bg_minimize   = beautiful.bg_normal
beautiful.bg_systray    = beautiful.bg_normal

beautiful.fg_normal     = "#ffffff"
beautiful.fg_focus      = "#ffffff"
beautiful.fg_urgent     = "#ffffff"
beautiful.fg_minimize   = "#ffffff"
beautiful.border_normal = "#6272a4"
beautiful.border_focus  = "#bd93f9"
beautiful.border_marked = "#91231c"


local modkey = "Mod4"
local terminal = "wezterm"

awful.layout.layouts = {
  awful.layout.suit.tile,
}
-- }}}

-- {{{ wibar

local space = wibox.widget.textbox(" ")
local separator = wibox.widget.textbox(" | ")

local clock_widget = wibox.widget.textclock("%H:%M")


local cpu = lain.widget.cpu {
    settings = function()
        widget:set_markup(" " .. cpu_now.usage .. "%")
    end
}

local mypartition =  lain.widget.fs({
    settings  = function()
        widget:set_text(": " ..  fs_now["/home"].percentage .. "%")
    end
})

local mynet = lain.widget.net({
    settings = function()
        widget:set_markup(" " .. net_now.received .. "KB/s")
    end
})

local mymem = lain.widget.mem({
    settings = function()
        widget:set_markup(" " .. mem_now.used  .. "MB")
    end
})

local archSwag = wibox.widget.textbox(" ")

Mycal = lain.widget.cal(
  {
    attach_to = { clock_widget },
    notification_preset = {
      font = "Dank Mono Italic 10",
      fg = "#FFFFFF",
      bg = "#222222",
      position = "top_right",
      title = "Calendar",
      timeout = 0,
      margin = 10,
      hover_timeout = 0.5,
    },
  }
)

-- Create a wibox for each screen and add it
local taglist_buttons = gears.table.join(
  awful.button({}, 1, function(t) t:view_only() end),
  awful.button({ modkey }, 1, function(t)
    if client.focus then
      client.focus:move_to_tag(t)
    end
  end),
  awful.button({}, 3, awful.tag.viewtoggle),
  awful.button({ modkey }, 3, function(t)
    if client.focus then
      client.focus:toggle_tag(t)
    end
  end),
  awful.button({}, 4, function(t) awful.tag.viewnext(t.screen) end),
  awful.button({}, 5, function(t) awful.tag.viewprev(t.screen) end)
)


local function set_wallpaper()
  os.execute('nitrogen --restore')
end
screen.connect_signal("property::geometry", set_wallpaper)

awful.screen.connect_for_each_screen(function(s)
  set_wallpaper()

  awful.tag({ "1", "2", "3", "4", "5", "6" }, s, awful.layout.layouts[1])

  s.mylayoutbox = awful.widget.layoutbox(s)
  s.mylayoutbox:buttons(gears.table.join(
    awful.button({}, 1, function() awful.layout.inc(1) end),
    awful.button({}, 3, function() awful.layout.inc(-1) end),
    awful.button({}, 4, function() awful.layout.inc(1) end),
    awful.button({}, 5, function() awful.layout.inc(-1) end)))
  -- Create a taglist widget
  s.mytaglist = awful.widget.taglist {
    screen  = s,
    filter  = awful.widget.taglist.filter.all,
    buttons = taglist_buttons
  }

  -- Create the wibox
  s.mywibox = awful.wibar({ position = "top", screen = s })

  -- Add widgets to the wibox
  s.mywibox:setup {
    layout = wibox.layout.align.horizontal,
    {
      layout = wibox.layout.fixed.horizontal,
      space,
      archSwag,
      -- space,
      s.mytaglist,
    },
    {
      layout = wibox.layout.fixed.horizontal,
    },
    {
      layout = wibox.layout.fixed.horizontal,
      wibox.widget.systray(),
      space,
      mynet.widget,
      space,
      cpu.widget,
      space,
      mypartition.widget,
      space,
      mymem.widget,
      space,
      battery_widget(),
      space,
      clock_widget,
      space,
    },
  }
end)
-- }}}

-- {{{ Key bindings
local globalkeys = gears.table.join(
  awful.key({ modkey, }, "s", hotkeys_popup.show_help,
    { description = "show help", group = "awesome" }),
  awful.key({ modkey, }, "Left", awful.tag.viewprev,
    { description = "view previous", group = "tag" }),
  awful.key({ modkey, }, "Right", awful.tag.viewnext,
    { description = "view next", group = "tag" }),
  awful.key({ modkey, }, "Escape", awful.tag.history.restore,
    { description = "go back", group = "tag" }),

  awful.key({ modkey, }, "j",
    function()
      awful.client.focus.byidx(1)
    end,
    { description = "focus next by index", group = "client" }
  ),
  awful.key({ modkey, }, "k",
    function()
      awful.client.focus.byidx(-1)
    end,
    { description = "focus previous by index", group = "client" }
  ),

  awful.key({ modkey, "Shift" }, "j", function() awful.client.swap.byidx(1) end,
    { description = "swap with next client by index", group = "client" }),
  awful.key({ modkey, "Shift" }, "k", function() awful.client.swap.byidx(-1) end,
    { description = "swap with previous client by index", group = "client" }),
  awful.key({ modkey, "Control" }, "j", function() awful.screen.focus_relative(1) end,
    { description = "focus the next screen", group = "screen" }),
  awful.key({ modkey, "Control" }, "k", function() awful.screen.focus_relative(-1) end,
    { description = "focus the previous screen", group = "screen" }),
  awful.key({ modkey, }, "u", awful.client.urgent.jumpto,
    { description = "jump to urgent client", group = "client" }),
  awful.key({ modkey, }, "Tab",
    function()
      awful.client.focus.history.previous()
      if client.focus then
        client.focus:raise()
      end
    end,
    { description = "go back", group = "client" }),

  awful.key({ modkey }, "b", function()
    for s in screen do
      s.mywibox.visible = not s.mywibox.visible
      if s.mybottomwibox then
        s.mybottomwibox.visible = not s.mybottomwibox.visible
      end
    end
  end,
    { description = "toggle wibox", group = "awesome" }),

  awful.key({ modkey, }, "Return", function() awful.spawn(terminal) end,
    { description = "open a terminal", group = "launcher" }),
  awful.key({ modkey, "Control" }, "r", awesome.restart,
    { description = "reload awesome", group = "awesome" }),
  awful.key({ modkey, "Shift" }, "q", awesome.quit,
    { description = "quit awesome", group = "awesome" }),
  awful.key({ modkey, }, "l", function() awful.tag.incmwfact(0.05) end,
    { description = "increase master width factor", group = "layout" }),
  awful.key({ modkey, }, "h", function() awful.tag.incmwfact(-0.05) end,
    { description = "decrease master width factor", group = "layout" }),
  awful.key({ modkey, "Shift" }, "h", function() awful.tag.incnmaster(1, nil, true) end,
    { description = "increase the number of master clients", group = "layout" }),
  awful.key({ modkey, "Shift" }, "l", function() awful.tag.incnmaster(-1, nil, true) end,
    { description = "decrease the number of master clients", group = "layout" }),
  awful.key({ modkey, "Control" }, "h", function() awful.tag.incncol(1, nil, true) end,
    { description = "increase the number of columns", group = "layout" }),
  awful.key({ modkey, "Control" }, "l", function() awful.tag.incncol(-1, nil, true) end,
    { description = "decrease the number of columns", group = "layout" }),

  awful.key({ modkey, "Control" }, "n",
    function()
      local c = awful.client.restore()
      if c then
        c:emit_signal(
          "request::activate", "key.unminimize", { raise = true }
        )
      end
    end,
    { description = "restore minimized", group = "client" }),
  awful.key({ modkey }, "r", function() awful.util.spawn("rofi -show run") end,
    { description = "run prompt", group = "launcher" }),
  awful.key({ modkey }, "space", function() awful.util.spawn("rofi -show drun") end,
    { description = "run prompt", group = "launcher" }),
  awful.key({ modkey }, "w", function() awful.util.spawn("rofi -show window") end,
    { description = "run prompt", group = "launcher" }),
  awful.key({}, "XF86AudioRaiseVolume", function() awful.util.spawn("pamixer -i 5", false) end),
  awful.key({}, "XF86AudioLowerVolume", function() awful.util.spawn("pamixer -d 5", false) end),
  awful.key({}, "XF86AudioMute", function() awful.util.spawn("pamixer -t", false) end),
  awful.key({}, "XF86AudioPlay", function() awful.util.spawn("playerctl play-pause", false) end),
  awful.key({ modkey }, "XF86AudioRaiseVolume", function() awful.util.spawn("playerctl next", false) end),
  awful.key({ modkey }, "XF86AudioLowerVolume", function() awful.util.spawn("playerctl  previous", false) end),
  awful.key({ modkey }, "XF86AudioPlay", function() awful.util.spawn("playerctl -p spotify play-pause", false) end),
  awful.key({}, "XF86MonBrightnessUp", function() os.execute("light -A 5") end,
    { description = "+10%", group = "hotkeys" }),
  awful.key({}, "XF86MonBrightnessDown", function() os.execute("light -U 5") end,
    { description = "-10%", group = "hotkeys" }),
  awful.key({}, "Print", function() awful.util.spawn("flameshot gui") end,
    { description = "Take a screenshot with FlameShot", group = "Screenshots" }),
  awful.key({ modkey }, "y", function() awful.util.spawn("betterlockscreen -l", false) end),
  awful.key({ modkey }, "a", function() os.execute("nitrogen  --set-zoom-fill --random ~/.wallpapers --save") end)
)

local clientkeys = gears.table.join(
  awful.key({ modkey, }, "f",
    function(c)
      c.fullscreen = not c.fullscreen
      c:raise()
    end,
    { description = "toggle fullscreen", group = "client" }),
  awful.key({ modkey, "Shift" }, "c", function(c) c:kill() end,
    { description = "close", group = "client" }),
  awful.key({ modkey, "Control" }, "space", awful.client.floating.toggle,
    { description = "toggle floating", group = "client" }),
  awful.key({ modkey, "Control" }, "Return", function(c) c:swap(awful.client.getmaster()) end,
    { description = "move to master", group = "client" }),
  awful.key({ modkey, }, "o", function(c) c:move_to_screen() end,
    { description = "move to screen", group = "client" }),
  awful.key({ modkey, }, "t", function(c) c.ontop = not c.ontop end,
    { description = "toggle keep on top", group = "client" }),
  awful.key({ modkey, }, "n",
    function(c)
      c.minimized = true
    end,
    { description = "minimize", group = "client" }),
  awful.key({ modkey, }, "m",
    function(c)
      c.maximized = not c.maximized
      c:raise()
    end,
    { description = "(un)maximize", group = "client" }),
  awful.key({ modkey, "Control" }, "m",
    function(c)
      c.maximized_vertical = not c.maximized_vertical
      c:raise()
    end,
    { description = "(un)maximize vertically", group = "client" }),
  awful.key({ modkey, "Shift" }, "m",
    function(c)
      c.maximized_horizontal = not c.maximized_horizontal
      c:raise()
    end,
    { description = "(un)maximize horizontally", group = "client" }),
    awful.button({ }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
    end),
    awful.button({ modkey }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.move(c)
    end),
    -- modkey + Right Click drag to resize
    awful.button({ modkey }, 3, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.resize(c)
    end),
    -- modkey + Alt + Left Click drag to resize
    awful.button({ modkey, "Mod1" }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.resize(c)
    end)
)

-- Bind all key numbers to tags.
for i = 1, 9 do
  globalkeys = gears.table.join(globalkeys,
    awful.key({ modkey }, "#" .. i + 9,
      function()
        local screen = awful.screen.focused()
        local tag = screen.tags[i]
        if tag then
          tag:view_only()
        end
      end,
      { description = "view tag #" .. i, group = "tag" }),
    awful.key({ modkey, "Control" }, "#" .. i + 9,
      function()
        local screen = awful.screen.focused()
        local tag = screen.tags[i]
        if tag then
          awful.tag.viewtoggle(tag)
        end
      end,
      { description = "toggle tag #" .. i, group = "tag" }),
    awful.key({ modkey, "Shift" }, "#" .. i + 9,
      function()
        if client.focus then
          local tag = client.focus.screen.tags[i]
          if tag then
            client.focus:move_to_tag(tag)
          end
        end
      end,
      { description = "move focused client to tag #" .. i, group = "tag" }),
    awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
      function()
        if client.focus then
          local tag = client.focus.screen.tags[i]
          if tag then
            client.focus:toggle_tag(tag)
          end
        end
      end,
      { description = "toggle focused client on tag #" .. i, group = "tag" })
  )
end

local clientbuttons = gears.table.join(
  awful.button({}, 1, function(c)
    c:emit_signal("request::activate", "mouse_click", { raise = true })
  end),
  awful.button({ modkey }, 1, function(c)
    c:emit_signal("request::activate", "mouse_click", { raise = true })
    awful.mouse.client.move(c)
  end),
  awful.button({ modkey }, 3, function(c)
    c:emit_signal("request::activate", "mouse_click", { raise = true })
    awful.mouse.client.resize(c)
  end)
)

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
awful.rules.rules = {
  -- All clients will match this rule.
  {
    rule = {},
    properties = {
      border_width = beautiful.border_width,
      border_color = beautiful.border_normal,
      focus = awful.client.focus.filter,
      raise = true,
      keys = clientkeys,
      buttons = clientbuttons,
      screen = awful.screen.preferred,
      placement = awful.placement.no_overlap + awful.placement.no_offscreen
    }
  },
  -- Floating clients.
  {
    rule_any = {
      instance = {
        "DTA",   -- Firefox addon DownThemAll.
        "copyq", -- Includes session name in class.
        "pinentry",
      },
      class = {
        "Arandr",
        "Blueman-manager",
        "Gpick",
        "Kruler",
        "MessageWin",  -- kalarm.
        "Sxiv",
        "Tor Browser", -- Needs a fixed window size to avoid fingerprinting by screen size.
        "Wpa_gui",
        "veromix",
        "xtightvncviewer" },

      -- Note that the name property shown in xprop might be set slightly after creation of the client
      -- and the name shown there might not match defined rules here.
      name = {
        "Event Tester", -- xev.
      },
      role = {
        "AlarmWindow",   -- Thunderbird's calendar.
        "ConfigManager", -- Thunderbird's about:config.
        "pop-up",        -- e.g. Google Chrome's (detached) Developer Tools.
      }
    },
    properties = { floating = true }
  },
  {
    rule_any = { type = { "normal", "dialog" }
    },
    properties = { titlebars_enabled = true }
  },
  {
    rule = { class = "discord" },
    properties = { screen = 1, tag = "6", urgent = false , minimized = true }
  },
  {
    rule = { class = "Spotify" },
    properties = { screen = 1, tag = "6", urgent = false, minimized = true }
  },
}
-- }}}

-- {{{ Signals
client.connect_signal("manage", function(c)
  if awesome.startup
    and not c.size_hints.user_position
    and not c.size_hints.program_position then
    awful.placement.no_offscreen(c)
  end
end)
-- }}} 


awful.spawn.with_shell("~/.config/awesome/scripts/autostart.sh")
awful.spawn.with_shell("discord")
awful.spawn.with_shell("picom -b --config ~/.config/picom/picom.conf")
awful.spawn.with_shell("nm-applet")
awful.spawn.with_shell("blueman-applet")
awful.spawn.with_shell("spotify")
awful.spawn.with_shell("~/.dropbox-dist/dropboxd")
