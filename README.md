# ForeverXPHide

A tiny, dependency-free addon for **World of Warcraft: Forever** that hides the native experience bar for a cleaner, more immersive interface.

It targets the **Camelot interface (16001)** and the tracking-bar structure observed in WoW Forever client build **1.60.1.70862**.

## Features

- Hides only the native XP bar's outer frame; it does not hide the whole tracking-bar manager.
- Remembers the enabled/disabled preference across reloads and logins using a SavedVariable.
- Hooks the XP bar frame's `OnShow` script so it is hidden again if the UI tries to show it.
- Retries briefly after login while the tracking bar is being created.
- No libraries, dependencies, configuration panel, or ongoing update loop after successful initialisation.

Hiding is **enabled by default** on first install.

## Installation

1. Download the repository using **Code → Download ZIP**.
2. Extract the ZIP.
3. Place the folder containing `ForeverXPHide_Camelot.toc` and `ForeverXPHide.lua` inside your WoW Forever `Interface\AddOns` directory.
4. The installed folder can be named `ForeverXPHide`, for example:

   ```text
   Interface/
   └── AddOns/
       └── ForeverXPHide/
           ├── ForeverXPHide_Camelot.toc
           └── ForeverXPHide.lua
   ```

5. Start the game and make sure **Forever XP Hide** is enabled in the AddOns list at character select.
6. Log in. The XP bar should hide automatically.

## Slash commands

| Command | Action |
| --- | --- |
| `/xphide` | Toggle hiding on/off |
| `/xphide on` | Hide the XP bar |
| `/xphide off` | Show the XP bar |
| `/xphide status` | Show the saved setting |
| `/xphide help` | Show available commands |
| `/fxphide` | Alias for `/xphide` |

The preference is account-wide through `ForeverXPHideDB`.

## Compatibility

- **Target:** WoW Forever, Camelot interface 16001.
- **Observed client build:** 1.60.1.70862.
- **Dependencies:** None.

The frame path was identified and manually verified in a live WoW Forever client. The addon uses that exact UI structure. Client updates may change the structure and require an addon update.

**Testing status:** The underlying frame path is confirmed in-game. Please test v1.1.0 across `/reload` and a full relog and report any errors or compatibility problems through GitHub Issues.

## Contributing / bug reports

Bug reports and pull requests are welcome. Please include:

- WoW Forever client build and interface version.
- Whether the issue occurs on login, after `/reload`, or after a full restart.
- Any Lua error text (or a screenshot of it).

## Disclaimer

This is an independent community addon. It is not affiliated with or endorsed by Blizzard Entertainment or the WoW Forever developers.
