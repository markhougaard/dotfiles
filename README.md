# Setting up a new machine

Run this command:

```zsh
curl -Lks https://raw.githubusercontent.com/marksdk/dotfiles/master/install.sh | /bin/bash -x
```

This is what it does:

1. Install Homebrew
2. Add `mas` to Homebrew so it can install apps from the Mac App Store programatically
3. Install `taps`, `brews`, and `casks` from `Brewfile`
4. Install `oh-my-zsh`
5. Install `Pure` prompt
6. Source `dotfiles` and do the following:
   1. Add `dot` alias to `.zshrc`:
      - `echo "alias dot='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'" >> .zshrc`
   2. Ignore `.dotfiles` to avoid recursion issues:
      - `echo .dotfiles >> .gitignore`
   3. Clone dotfiles
      - `git clone --bare git@github.com:marksdk/dotfiles.git $HOME/.dotfiles`
   4. Define the alias in the current shell:
      - `alias dot='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'`
   5. Checkout the content from the bare repo to $HOME:
      - `dot checkout`
   6. This might cause an error because there are already conflicting dotfiles. One solution:
      - `mkdir -p .dotfiles-backup && \ dot checkout 2>&1 | egrep "\s+\." | awk {'print $1'} | \ xargs -I{} mv {} .dotfiles-backup/{}`
   7. Re-run the check if there are problems:
      - `dot checkout`
   8. Set the flag showUntrackedFiles to no on this specific (local) repository:
      - `dot config --local status.showUntrackedFiles no`
7. Install Visual Studio Code extension to sync all settings and extensions:
   - `code --install-extension shan.code-settings-sync`

## install.sh

```bash
/bin/zsh -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
brew install mas
brew bundle
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
source ~/.zshrc
mkdir -p "$HOME/.zsh" && git clone https://github.com/sindresorhus/pure.git "$HOME/.zsh/pure"
git clone --bare https://github.com/marksdk/dotfiles.git $HOME/.dotfiles
function dot {
   /usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME $@
}
mkdir -p .dotfiles-backup
dot checkout
if [ $? = 0 ]; then
  echo "Checked out dotfiles.";
  else
    echo "Backing up pre-existing dotfiles.";
    dot checkout 2>&1 | egrep "\s+\." | awk {'print $1'} | xargs -I{} mv {} .dotfiles-backup/{}
fi;
dot checkout
dot config status.showUntrackedFiles no
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/agkozak/zsh-z ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-z
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
source ~/.zshrc
code --install-extension Shan.code-settings-sync
sh $HOME/macos.sh
```

## Sources

### Using `$HOME` as the git repo

The idea of using the `$HOME` dir as a sort-of-but-not-really git repository comes from this article: 

- <https://www.atlassian.com/git/tutorials/dotfiles>. 

It removes the need for symlinking which was messed up for me, for some—still—unknown reason. This article is based on this comment on Hacker News: <https://news.ycombinator.com/item?id=11070797> and I read about it here first: <https://www.anand-iyer.com/blog/2018/a-simpler-way-to-manage-your-dotfiles.html>.

Throughout, my script refers to the directory `.dotfiles`, and the `git` command that works on that directory is aliased with `dot`. The articles refer to `.cfg` and `config`.

### Keyboard combinations

You can set keyboard combinations with the Terminal. The meta-keys are set as @ for Command, $ for Shift, ~ for Alt and ^ for Ctrl. For system-wide shortcuts, you can use -g instead of the app identifier, e.g.`defaults write -g NSUserKeyEquivalents -dict-add "Menu Item" -string "@$~^k"`. Find all current keyboard shortcuts with `defaults find NSUserKeyEquivalents`. More info at <https://apple.stackexchange.com/questions/123382/is-there-a-way-to-save-your-custom-keyboard-shortcuts-in-a-config-file> and <http://hints.macworld.com/article.php?story=20131123074223584> and <https://ryanmo.co/2017/01/05/setting-keyboard-shortcuts-from-terminal-in-macos/>

### Removing the underline from zsh-syntax-highlighting

- <https://github.com/zsh-users/zsh-syntax-highlighting/issues/573>
