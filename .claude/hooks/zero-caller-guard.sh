#!/usr/bin/env bash
# ★★★零 caller 的守衛函式 —— 「複製了機制，卻沒有接線」。
#   ★血證兩次，同一天：
#     ①`PathSystem.clear_sssp()` —— 存在、而 production 零 caller（systems 挑出來，當天接上）
#     ②`OwnerCampIndex.shadow_check()` —— 從 `OwnerOutpostIndex` 抄過來，★零 caller（implementer 自己抓到）
#   ★★形狀：**函式在、名字對、內容也對 —— 而沒有任何東西呼叫它**
#     ⇒ ★★★它在 code review 裡看起來【完整】，在 grep 裡看起來【存在】，只有數 caller 才看得出來。
#
# ★涵蓋率（量過）：只看名字符合 `shadow_check|_reset_cross_run|verify_*|assert_*|clear_*` 的 static func。
# ★★誠實限：
#   ①名字不符這幾類的守衛 —— 本閘看不見（★而「守衛」沒有統一命名，這是真的缺口）
#   ②透過 `call("name")`／字串反射呼叫的 —— 本閘數不到，會誤報（⇒ 白名單）
#   ③★caller 在 `scripts/debug` 也算數（床把守衛跑起來是合法接線）
set -u
cd "$(git rev-parse --show-toplevel 2>/dev/null || echo .)" || exit 2
WL="docs/process/.zero-caller-whitelist.tsv"
PAT='^static func (shadow_check|_reset_cross_run|verify_[a-z_]*|assert_[a-z_]*|clear_[a-z_]*)'

scan() {
  for f in $(grep -rlE "$PAT" scripts/simulation scripts/data --include=*.gd 2>/dev/null | sort); do
    cls=$(grep -m1 "^class_name" "$f" | awk '{print $2}')
    [ -z "$cls" ] && continue
    grep -oE "$PAT" "$f" | sed 's/^static func //' | sort -u | while read -r fn; do
      [ -z "$fn" ] && continue
      # ★★★2026-09-03 修我自己的誤報：第一版把【整個定義檔】排除掉，
      #   ⇒ 同檔內的合法呼叫（`clear_sssp()` 被同檔的 `_reset_cross_run` 呼叫）也被濾掉 ⇒ 假陽性。
      #   ★正確做法：只排除【定義那一行】，不是整個檔；並同時數【限定呼叫】與【同檔裸呼叫】。
      qn=$(grep -rn "$cls\.$fn(" scripts/ --include=*.gd 2>/dev/null | wc -l | tr -d ' ')
      bn=$(grep -nE "(^|[^A-Za-z0-9_.])$fn\(" "$f" 2>/dev/null | grep -v "static func $fn(" | wc -l | tr -d ' ')
      n=$((qn + bn))
      echo "$n|$cls.$fn|$f"
    done
  done
}

if [ "${1:-}" = "--self-test" ]; then
  # ★陽性對照：本閘的判準是「數得到 caller」——用一個【一定有 caller】與一個【一定沒有】的合成名字驗計數邏輯
  a=$(grep -rn "OwnerOutpostIndex\.shadow_check(" scripts/ --include=*.gd | wc -l | tr -d ' ')
  b=$(grep -rn "NoSuchClass_zzz\.no_such_fn_zzz(" scripts/ --include=*.gd | wc -l | tr -d ' ')
  if [ "$a" -ge 1 ] && [ "$b" -eq 0 ]; then
    echo "[ZERO-CALLER] SELF-TEST PASS（陽性 OwnerOutpostIndex.shadow_check=$a／陰性 合成名=$b）"; exit 0
  fi
  echo "[ZERO-CALLER] SELF-TEST FAIL（陽性=$a 應 ≥1／陰性=$b 應 =0）——★先查那支是不是被改名/搬走"; exit 1
fi

TOTAL=0; BAD=""
while IFS='|' read -r n name file; do
  [ -z "$name" ] && continue
  TOTAL=$((TOTAL+1))
  [ "$n" -gt 0 ] && continue
  grep -v '^#' "$WL" 2>/dev/null | awk -F'\t' -v x="$name" '$1==x{f=1} END{exit f?0:1}' && continue
  BAD="$BAD
  · $name    （$file）"
done <<< "$(scan)"

echo "[ZERO-CALLER] 掃到守衛型 static func $TOTAL 支"
if [ -n "$BAD" ]; then
  echo "[ZERO-CALLER] ★★★下列守衛【零 caller】—— 機制複製了但沒接線：$BAD"
  echo "[ZERO-CALLER] ⇒ 二選一：①把它接上（床或 production 都算）②加進 $WL 並寫【為什麼現在還不接】"
  echo "[ZERO-CALLER] FAIL"
  exit 1
fi
echo "[ZERO-CALLER] ★誠實限①：只看名字符合 shadow_check/_reset_cross_run/verify_*/assert_*/clear_* 的——別的守衛看不見"
echo "[ZERO-CALLER] ★誠實限②：字串反射呼叫數不到（⇒ 白名單）｜★誠實限③：caller 在 scripts/debug 也算數"
echo "[ZERO-CALLER] PASS"
