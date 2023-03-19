
// Turn off Password Manager
user_pref("signon.rememberSignons", false);

// Check for userChrome at startup
// https://bugzilla.mozilla.org/show_bug.cgi?id=1541233
user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);

// (show button to) Make UI smaller
// https://support.mozilla.org/en-US/kb/compact-mode-workaround-firefox
user_pref("browser.compactmode.show", true);
