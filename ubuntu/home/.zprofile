# pyenv. Guarded: install.sh does not provision pyenv, so this is a no-op
# on a box that hasn't had it installed by hand.
[[ -d "${HOME}/.pyenv/shims" ]] && export PATH="${HOME}/.pyenv/shims:${PATH}"
