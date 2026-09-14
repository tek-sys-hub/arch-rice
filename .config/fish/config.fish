if status is-interactive
    # Disable default fish welcome message
    set -g fish_greeting ""

    # Shortcuts / aliases
    alias ll="ls -lh"
    alias la="ls -la"
    alias c="clear"

    # Display system info on launch
    if type -q fastfetch
        fastfetch
    end
end
if type -q pyenv
    pyenv init - | source
end
if type -q pyenv
    pyenv init - | source
end
set -gx ELECTRON_OZONE_PLATFORM_HINT auto

# ─────────────────────────────────────────────────────────
# Flutter & Android Development Environment
# ─────────────────────────────────────────────────────────

# Brave as default browser (used by Flutter web dev tools)
set -gx CHROME_EXECUTABLE /usr/bin/brave
set -gx BROWSER /usr/bin/brave

# Android SDK
set -gx ANDROID_HOME $HOME/Android/Sdk
set -gx ANDROID_SDK_ROOT $HOME/Android/Sdk

# Java (system OpenJDK 21)
set -gx JAVA_HOME /usr/lib/jvm/java-21-openjdk

# PATH  -  Flutter, Android tools
fish_add_path $HOME/Android/Sdk/platform-tools
fish_add_path $HOME/Android/Sdk/cmdline-tools/latest/bin
fish_add_path $HOME/Android/Sdk/emulator

# Flutter  -  use all CPU cores for builds
set -gx FLUTTER_STORAGE_BASE_URL https://storage.googleapis.com
set -gx FLUTTER_SUPPRESS_ANALYTICS true

# Gradle  -  point to Android Studio's bundled JDK for builds
set -gx GRADLE_USER_HOME $HOME/.gradle
