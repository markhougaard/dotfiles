#!/usr/bin/env zsh
#
# Check macos/defaults.sh against this machine.
#
#   ./verify.sh            # report drift only
#   ./verify.sh --all      # also list settings that match
#   ./verify.sh --quiet    # print nothing, just set the exit status
#
# Exit status: 0 = no drift, 1 = at least one setting differs.
#
# Reads every `defaults write` and `PlistBuddy -c Set` in defaults.sh back off
# the system and compares. Where a key is written more than once only the last
# write is checked, since that is the one that survives. Commands that are
# neither (pmset, nvram, chflags) are listed as unchecked rather than silently
# ignored.

set -uo pipefail

REPO="${0:A:h:h}"
SCRIPT="$REPO/macos/defaults.sh"

VERBOSE=false
QUIET=false
for arg in "$@"; do
  case "$arg" in
    --all)     VERBOSE=true ;;
    --quiet)   QUIET=true ;;
    -h|--help) sed -n '2,15p' "$0"; exit 0 ;;
    *)         print -u2 "unknown argument: $arg"; exit 2 ;;
  esac
done

[[ -r "$SCRIPT" ]] || { print -u2 "cannot read $SCRIPT"; exit 2 }

say() { $QUIET || print -r -- "$@" }

# ---------------------------------------------------------------- collect

# Written values, keyed "<domain>\t<key>". Later writes overwrite earlier ones.
typeset -A w_type w_val w_host
typeset -a order manual unchecked
# PlistBuddy: parallel arrays of plist path and key path.
typeset -a pb_file pb_path pb_val

# Everything below runs at top level, so no `local` - in zsh a bare `local`
# outside a function re-declares and echoes the variable.
typeset line w domain key typ val host id parts clean

while IFS= read -r line; do
  [[ -z "${line// }" || "$line" == \#* ]] && continue

  # --- PlistBuddy: `PlistBuddy -c "Set <keypath> <value>" <plist>`
  if [[ "$line" == *PlistBuddy* ]]; then
    parts=(${(Q)${(z)${line%% \#*}}})
    # find the -c argument and the trailing plist path
    typeset pbc="" pbf=""
    for (( i = 1; i <= $#parts; i++ )); do
      [[ "${parts[i]}" == "-c" ]] && pbc="${parts[i+1]}"
    done
    pbf="${parts[-1]}"
    if [[ -n "$pbc" && "$pbc" == Set\ * ]]; then
      typeset rest="${pbc#Set }"
      pb_path+=("${rest%% *}")
      pb_val+=("${rest#* }")
      pb_file+=("${pbf/#\~/$HOME}")
    else
      unchecked+=("${line%% \#*}")
    fi
    continue
  fi

  if [[ "$line" != *"defaults"*"write"* ]]; then
    case "$line" in
      *pmset*|*nvram*|*chflags*|*systemsetup*) unchecked+=("${line%% \#*}") ;;
    esac
    continue
  fi

  # Quote-aware split, drop the trailing comment, then unquote.
  parts=(${(z)line})
  clean=()
  for w in $parts; do
    [[ "$w" == \#* ]] && break
    clean+=("$w")
  done
  parts=(${(Q)clean})
  (( $#parts >= 4 )) || continue

  [[ "${parts[1]}" == sudo ]] && parts=(${parts[2,-1]})
  [[ "${parts[1]}" == defaults ]] || continue

  host=false
  if [[ "${parts[2]}" == "-currentHost" ]]; then
    host=true
    parts=("${parts[1]}" ${parts[3,-1]})
  fi
  [[ "${parts[2]}" == write ]] || continue

  domain="${parts[3]}"; key="${parts[4]}"
  [[ "$domain" == "-globalDomain" ]] && domain=NSGlobalDomain

  typ=""; val=""
  if (( $#parts >= 5 )); then
    if [[ "${parts[5]}" == -* ]]; then
      typ="${parts[5]}"
      (( $#parts >= 6 )) && val="${parts[6,-1]}"
    else
      val="${parts[5,-1]}"
    fi
  fi

  # -dict-add and -array build up structures; compare those by hand.
  if [[ "$typ" == "-dict-add" || "$typ" == "-array" ]]; then
    manual+=("$domain $key $typ")
    continue
  fi

  val="${val//\$\{HOME\}/$HOME}"
  val="${val//\$HOME/$HOME}"

  id="${domain}"$'\t'"${key}"
  (( ${+w_type[$id]} )) || order+=("$id")
  w_type[$id]="$typ"; w_val[$id]="$val"; w_host[$id]="$host"
done < "$SCRIPT"

# ---------------------------------------------------------------- compare

# Booleans read back as 1/0; numbers may differ in formatting (0 vs 0.000000),
# so compare those arithmetically rather than as strings.
same() {  # $1 = actual, $2 = want, $3 = type
  case "$3" in
    -bool)
      local a b
      [[ "${1:l}" == (true|yes|1) ]] && a=1 || a=0
      [[ "${2:l}" == (true|yes|1) ]] && b=1 || b=0
      [[ "$a" == "$b" ]] ;;
    -int|-float)
      [[ "$1" == *[^0-9.eE+-]* || "$2" == *[^0-9.eE+-]* ]] && { [[ "$1" == "$2" ]]; return }
      (( $1 == $2 )) ;;
    *)
      [[ "$1" == "$2" ]] ;;
  esac
}

typeset -i n_match=0 n_drift=0 n_unset=0
typeset -a drift_rows unset_rows
typeset actual cmd

for id in $order; do
  domain="${id%%$'\t'*}"; key="${id##*$'\t'}"
  cmd=(defaults)
  [[ "${w_host[$id]}" == true ]] && cmd+=(-currentHost)
  cmd+=(read "$domain" "$key")

  if ! actual="$("${cmd[@]}" 2>/dev/null)"; then
    (( n_unset++ ))
    unset_rows+=("$domain $key  (want ${w_val[$id]}, never set here)")
    continue
  fi

  if same "$actual" "${w_val[$id]}" "${w_type[$id]}"; then
    (( n_match++ ))
    $VERBOSE && say "  ok       $domain $key = $actual"
  else
    (( n_drift++ ))
    drift_rows+=("$domain $key"$'\n'"           want=${w_val[$id]}  actual=${actual}")
  fi
done

# PlistBuddy entries
typeset -i i
for (( i = 1; i <= $#pb_path; i++ )); do
  if ! actual="$(/usr/libexec/PlistBuddy -c "Print ${pb_path[i]}" "${pb_file[i]}" 2>/dev/null)"; then
    (( n_unset++ ))
    unset_rows+=("${pb_file[i]:t} ${pb_path[i]}  (want ${pb_val[i]}, not present)")
    continue
  fi
  if same "$actual" "${pb_val[i]}" "-float" || [[ "$actual" == "${pb_val[i]}" ]]; then
    (( n_match++ ))
    $VERBOSE && say "  ok       ${pb_file[i]:t} ${pb_path[i]} = $actual"
  else
    (( n_drift++ ))
    drift_rows+=("${pb_file[i]:t} ${pb_path[i]}"$'\n'"           want=${pb_val[i]}  actual=${actual}")
  fi
done

# ---------------------------------------------------------------- report

typeset r
if (( n_drift )); then
  say "DRIFT ($n_drift):"
  for r in $drift_rows; do say "  differs  $r"; done
  say ""
fi

if (( n_unset )); then
  say "NOT SET ($n_unset) - defaults.sh sets these but the system has no value:"
  for r in $unset_rows; do say "  unset    $r"; done
  say ""
fi

if (( $#manual )); then
  say "CHECK BY HAND ($#manual) - dict/array values this script does not compare:"
  for r in $manual; do say "  manual   $r"; done
  say ""
fi

if (( $#unchecked )); then
  say "NOT COVERED ($#unchecked) - neither defaults nor PlistBuddy:"
  for r in $unchecked; do say "  skip     ${r##[[:space:]]##}"; done
  say ""
fi

say "$n_match match, $n_drift drift, $n_unset unset, $#manual manual, $#unchecked uncovered"
(( n_drift == 0 ))
