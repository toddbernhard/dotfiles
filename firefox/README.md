## Firefox setup

Most of the work is done by setup.py.

Contents:

- `create-firefox.py` - Creates an isolated profile for Firefox. Experimental.
- `recommended_extensions.json` - List of extensions, prompted by setup.py. Extensions and themes should be installed by hand, in order to get updates.
- `template-profile/user.js` - Permanent preferencese, setup by setup.py
- `template-profile/chrome/userChrome.css` - Hide the tab bar, setup by setup.py
- `treestyletab-all-configs-export.json` - Manually import this into Tree Style Tab settings
- `treestyletab-style-export.css` - Manually import this into Tree Style Tab settings. May be covered by the above.
