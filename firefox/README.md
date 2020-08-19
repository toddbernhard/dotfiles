## Firefox setup

#### Extensions & Themes

On FF v79.0, one cannot install Mozilla-hosted addons from CLI. To get updates, install these by hand:

- Tree Style Tab: https://addons.mozilla.org/en-US/firefox/addon/tree-style-tab/
- Firefox Multi-Account Containers: https://addons.mozilla.org/en-US/firefox/addon/multi-account-containers/
- Arc Dark Theme: https://addons.mozilla.org/en-US/firefox/addon/arc-dark-theme-we/

#### userChrome.css

- open [`about:config`](about:config)
- search for `toolkit.legacyUserProfileCustomizations.stylesheets`
- set to true

#### Toolbar customization

- open [`about:config`](about:config)
- search for `browser.uiCustomization.state`
- set to
  ```
  {"placements":{"widget-overflow-fixed-list":[],"nav-bar":["sidebar-button","_testpilot-containers-browser-action","new-tab-button","customizableui-special-spring18","back-button","forward-button","stop-reload-button","urlbar-container","onepassword4_agilebits_com-browser-action","customizableui-special-spring14","_d634138d-c276-4fc8-924b-40a0ea21d284_-browser-action","downloads-button","_react-devtools-browser-action","support_lastpass_com-browser-action","_bf855ead-d7c3-4c7b-9f88-9a7e75c0efdf_-browser-action"],"TabsToolbar":["tabbrowser-tabs","alltabs-button"],"PersonalToolbar":["personal-bookmarks"]},"seen":["developer-button","treestyletab_piro_sakura_ne_jp-browser-action","onepassword4_agilebits_com-browser-action","_testpilot-containers-browser-action","webide-button","_react-devtools-browser-action","feed-button","_c2c003ee-bd69-42a2-b0e9-6f34222cb046_-browser-action","support_lastpass_com-browser-action","_d634138d-c276-4fc8-924b-40a0ea21d284_-browser-action","_bf855ead-d7c3-4c7b-9f88-9a7e75c0efdf_-browser-action"],"dirtyAreaCache":["PersonalToolbar","nav-bar","TabsToolbar","widget-overflow-fixed-list"],"currentVersion":16,"newElementCount":24}
  ```
