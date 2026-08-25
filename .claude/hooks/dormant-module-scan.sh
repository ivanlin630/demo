#!/usr/bin/env bash
# ★休眠模組掃描：class_name 存在，但【零 production caller】(只有 debug/測試/自己在用)
# 血證家族：means-end A1 TASK_BUILD 無 consumer／candidate 生成≠真發生／AcquisitionPaths 零 caller
# 用法：bash .claude/hooks/dormant-module-scan.sh [--strict]
set -u
cd "$(git rev-parse --show-toplevel 2>/dev/null || echo .)" || exit 2
expect_min=20   # 母體地板：掃到的 class_name 少於此 ⇒ 掃描本身壞了，不是「都很健康」
tmp="$(mktemp)"; dormant=0; total=0
while IFS= read -r line; do
  f="${line%%:*}"; cn="$(printf '%s' "${line#*class_name }" | awk '{print $1}')"
  [ -z "$cn" ] && continue
  total=$((total+1))
  n="$(grep -rl "\b${cn}\b" scripts/ --include=*.gd 2>/dev/null \
        | grep -v '^scripts/debug/' | grep -v "^${f}$" | wc -l | tr -d ' ')"
  [ "$n" = "0" ] && { dormant=$((dormant+1)); printf '  DORMANT %-34s %s\n' "$cn" "$f" >> "$tmp"; }
done < <(grep -rn "^class_name " scripts/simulation/ scripts/data/ --include=*.gd 2>/dev/null | sed 's/^\([^:]*\):[0-9]*:/\1:/')
echo "[dormant-scan] class_name 母體=$total  休眠(零 production caller)=$dormant"
if [ "$total" -lt "$expect_min" ]; then
  echo "[dormant-scan] ★FAIL 母體 $total < 地板 $expect_min ⇒ 掃描壞了，不是都健康"; rm -f "$tmp"; exit 2
fi
[ -s "$tmp" ] && cat "$tmp"
rm -f "$tmp"
echo "[dormant-scan] ★休眠≠錯 —— 但每一個都必須有【明說的接線票】，否則是黑洞。"
exit 0
