#!/usr/bin/env bash

set_and_print() {
  cmd="$1"
  explanation="$2"

  echo "$explanation"
  echo "$cmd"
  eval "$cmd"
  echo ""
}

set_and_print 'defaults write com.apple.finder AppleShowAllFiles YES' 'Show hidden files'

set_and_print 'defaults write com.apple.controlstrip FullCustomized '"'"'("com.apple.system.screen-lock", NSTouchBarItemIdentifierFlexibleSpace, "com.apple.system.group.brightness", NSTouchBarItemIdentifierFlexibleSpace, NSTouchBarItemIdentifierFlexibleSpace, "com.apple.system.group.media", NSTouchBarItemIdentifierFlexibleSpace, "com.apple.system.group.volume")'"'" 'Configure expanded TouchBar'

set_and_print 'defaults write com.apple.touchbar.agent PresentationModeGlobal fullControlStrip' 'Show expanded TouchBar'

pkill 'Touch Bar agent'
killall 'ControlStrip'