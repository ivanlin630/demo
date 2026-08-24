#!/usr/bin/env bash
# decision-entry-scan.sh -- commitment stall-detector coverage over decision entries.
#
# WHY (systems, 2026-08-25): the same ticket used two different standards.
#   Commitment FIELDS were audited mechanically (16/16). Decision ENTRIES were
#   counted by hand ("3 of them"), and a hand count is not an enumeration:
#     "before writing all / N / only, ask where the number came from.
#      If the answer is 'I listed them' rather than 'the scan found them',
#      it is not exhaustive."
#   So entries get the same treatment: derive them, then require each to be covered.
#
# DERIVATION: an entry is a production call to DecisionEngine.rank_scored /
#   rank_survival in the AI driver. Each must have _detect_commitment_stall for the
#   same subject within a short window above it, or be listed in EXEMPT with a reason.
#   A new decision entry with no detector => FAIL.
#
# usage: bash .claude/hooks/decision-entry-scan.sh
# exit:  0 = every entry covered / 1 = uncovered entry found
set -u
ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$ROOT" || exit 1
SRC="scripts/simulation/faction_ai_system.gd"
[ -f "$SRC" ] || { echo "[entry-scan] missing $SRC"; exit 1; }

# Entries that legitimately need no detector; keep the reason with the line marker.
# (empty for now -- if one is added, it must say why)
EXEMPT=""

# Scope, not proximity: the detector must appear inside the SAME function, anywhere
# above the entry. A line-distance window would fail the moment someone adds a
# comment block, which is a property of the formatting rather than of the coverage.
TOTAL=0; MISSING=0

while IFS= read -r hit; do
  ln="${hit%%:*}"
  body="$(sed -n "${ln}p" "$SRC")"
  case "$(printf '%s' "$body" | sed 's/^[[:space:]]*//')" in \#*) continue ;; esac
  TOTAL=$((TOTAL+1))
  # enclosing function start = last "func " at or above this line
  fstart="$(awk -v L="$ln" 'NR<=L && /^(static )?func /{n=NR} END{print n+0}' "$SRC")"
  [ "$fstart" -lt 1 ] && fstart=1
  if sed -n "${fstart},${ln}p" "$SRC" | grep -q "_detect_commitment_stall("; then
    continue
  fi
  case "$EXEMPT" in *"$ln"*) continue ;; esac
  fname="$(sed -n "${fstart}p" "$SRC" | sed 's/(.*//')"
  echo "[entry-scan] UNCOVERED decision entry at $SRC:$ln  (in $fname)"
  echo "    $(printf '%s' "$body" | sed 's/^[[:space:]]*//')"
  echo "    -> call _detect_commitment_stall(state, <subject>) inside that function, or add it to EXEMPT with a reason"
  MISSING=$((MISSING+1))
done < <(grep -n "DecisionEngine.rank_scored(\|DecisionEngine.rank_survival(" "$SRC")

echo "-- decision entry coverage: $((TOTAL-MISSING))/$TOTAL covered"
if [ "$MISSING" -gt 0 ]; then
  echo "FAIL decision-entry-scan: $MISSING uncovered entry(ies)"
  exit 1
fi
echo "PASS decision-entry-scan"
exit 0
