eval "$(/opt/homebrew/bin/brew shellenv)"

# No Obsidian PATH entry: the obsidian cask links obsidian-cli into
# /opt/homebrew/bin as `obsidian`, which brew shellenv above already puts on
# PATH. Adding the app's MacOS directory would also expose the `Obsidian`
# binary itself, which is not wanted.
