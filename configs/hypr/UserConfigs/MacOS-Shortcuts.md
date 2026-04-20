# macOS-like Shortcuts

This setup maps the **Super (Windows) key** as ⌘ Cmd, so muscle memory from macOS works on Hyprland.

Based on: https://satya164.page/posts/macos-like-shortcuts-in-hyprland

---

## How it works

Hyprland's `sendshortcut` dispatcher intercepts a key combo and sends a different one to the active window.
The `binde` flag (with `e`) enables key repeat — hold the key and it repeats, just like on macOS.

---

## Copy & Paste (terminal-safe)

Regular `Ctrl+C` is SIGINT in terminals, and `Ctrl+V` has special behavior too.
Instead, we use `Ctrl+Insert` for copy and `Shift+Insert` for paste — these work everywhere.

| Shortcut | Sends | Action |
|---|---|---|
| `Super+C` | `Ctrl+Insert` | Copy |
| `Super+V` | `Shift+Insert` | Paste |

---

## App shortcuts

| Shortcut | Sends | Action |
|---|---|---|
| `Super+X` | `Ctrl+X` | Cut |
| `Super+Z` | `Ctrl+Z` | Undo |
| `Super+Shift+Z` | `Ctrl+Y` | Redo |
| `Super+F` | `Ctrl+F` | Find |
| `Super+R` | `Ctrl+R` | Refresh |
| `Super+L` | `Ctrl+L` | Address bar / clear line |
| `Super+O` | `Ctrl+O` | Open file |
| `Super+K` | `Ctrl+K` | Link / command palette |
| `Super+J` | `Ctrl+J` | Downloads / misc |
| `Super+Y` | `Ctrl+Y` | Redo (alternative) |
| `Super+T` | `Ctrl+T` | New tab |
| `Super+W` | `Ctrl+W` | Close tab |

> **Note:** Letters already used by the window manager are intentionally skipped:
> `A` (overview), `B` (browser), `D` (launcher), `E` (files), `G` (group),
> `H` (help), `I` (master), `M` (split ratio), `N` (night light), `P` (pseudo),
> `Q` (smart close), `S` (web search), `U` (special workspace).

---

## Text editing shortcuts (Emacs-style navigation)

These remap `Ctrl+key` globally to cursor/editing keys, matching macOS terminal behavior.

| Shortcut | Sends | Action |
|---|---|---|
| `Ctrl+A` | `Home` | Beginning of line |
| `Ctrl+E` | `End` | End of line |
| `Ctrl+F` | `→` | Forward one character |
| `Ctrl+B` | `←` | Back one character |
| `Ctrl+P` | `↑` | Previous line |
| `Ctrl+N` | `↓` | Next line |
| `Ctrl+D` | `Delete` | Delete character forward |
| `Ctrl+H` | `Backspace` | Delete character backward |

---

## Window manager shortcuts (unchanged)

These were already Mac-like or kept as-is:

| Shortcut | Action |
|---|---|
| `Super+Q` | Close / hide window (SmartClose) |
| `Super+Shift+T` | Theme switcher (moved from Super+T) |
| `Super+Shift+W` | Wallpaper select (moved from Super+W) |
| `Super+Ctrl+W` | Wallpaper effects (moved from Super+Shift+W) |
