#!/usr/bin/env bash
# commitment-field-scan.sh -- "unfinished commitment" field coverage audit.
#
# WHY (systems §M self-correction, 2026-08-25):
#   persist hold used to read `current_task`, a PROXY that `TaskArbiter.release()` wipes.
#   v2 makes hold read the FACT: does this team have work already started and not finished?
#   The first draft listed three signals by hand -- that is a manual whitelist, and the
#   whole point of this round was that manual whitelists go silently stale.
#
# WHAT:
#   Candidates are DERIVED from team_data.gd by structural naming patterns.
#   Every candidate must be classified in commitment_fields.gd, either as
#   READS (hold consults it) or NOT_COMMITMENT (with a stated reason).
#   A new commitment-looking field that is in neither => FAIL.
#   Coverage is therefore constructive: forgetting to classify is a hard error,
#   not a silent omission.
#
# usage: bash .claude/hooks/commitment-field-scan.sh
# exit:  0 = all classified / 1 = unclassified field(s) found
set -u
# NOTE: audit the tree we were invoked from (a worktree is a real tree), NOT the shared git dir.
# Deriving the root from --git-common-dir would land in the main checkout and audit the wrong files.
ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$ROOT" || exit 1

TEAM="scripts/data/team_data.gd"
REG="scripts/simulation/decision/commitment_fields.gd"
[ -f "$TEAM" ] || { echo "[commitment-scan] missing $TEAM"; exit 1; }
[ -f "$REG" ]  || { echo "[commitment-scan] missing $REG"; exit 1; }

# --- derive candidates: field names whose shape suggests "something started / something aimed at"
CAND="$(grep -oE '^var [a-z_0-9]+' "$TEAM" | sed 's/^var //' \
  | grep -E '(_site|_target|_target_id|_phase|committed_|corvee|pending_|_cache|_task)$|^(corvee_site|task_extra_data|goal_state)$' \
  | sort -u)"

TOTAL=0; MISSING=0
for f in $CAND; do
  TOTAL=$((TOTAL+1))
  # classified if it appears quoted in READS or as a key in NOT_COMMITMENT
  if grep -q "\"$f\"" "$REG"; then
    continue
  fi
  echo "[commitment-scan] UNCLASSIFIED: $f"
  echo "    -> add it to READS (hold reads it, say how) or NOT_COMMITMENT (say why it is not)"
  MISSING=$((MISSING+1))
done

echo "-- commitment field coverage: $((TOTAL-MISSING))/$TOTAL classified"
if [ "$MISSING" -gt 0 ]; then
  echo "FAIL commitment-field-scan: $MISSING unclassified field(s)"
  exit 1
fi
echo "PASS commitment-field-scan"
exit 0
