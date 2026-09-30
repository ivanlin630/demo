#!/usr/bin/env bash
# ★★★停止前的【做到一半】守衛（用戶裁 2026-09-30：看狀態，不看字眼）
#
# 為什麼不是字眼式：blueprint 第一版提案是抓回合最後一段的「下一步／接著我」——
#   ★用戶逐字撤回它：**換個語氣就漏**。而它的失效是靜默的（漏掉的那次長得跟沒問題一樣）。
# ⇒ 本檔改成列舉【做到一半會留下物件的狀態】，任一存在就不准停，並**印出是哪一件**。
#
# ★★誠實限（寫在這裡，不寫在信裡）：
#   ·抓得到【留下物件的半途】（分支／摘要檔／信／旗）
#   ·★抓不到【純思考的半途】（我想到要做某件事但什麼都還沒動）—— 那一半仍然只能靠紀律
#   ·d 項「派工未敲」shell 判不了（敲門不留物件）⇒ **刻意不列**，而不是假裝有覆蓋
#
# ★★★每一項要能【各自獨立紅】⇒ --selfcheck 逐項餵一個假狀態。
set -u

ROOT=""
_resolve_root() {
  local gc; gc=$(git rev-parse --git-common-dir 2>/dev/null) || return 1
  ROOT=$(cd "$(dirname "$gc")" && pwd) || return 1
}

# ── 各項檢查：印一行「原因」＝紅；什麼都不印＝綠 ──
_chk_a_merge_in_flight() {   # 合併在飛：tmp/merge-* 領先 origin/main 而 origin 沒有它
  local b tip
  # ★母體＝【所有 tmp/* 分支】不是只有 tmp/merge-*：
  #   本檔第一版只掃 tmp/merge-*，而樹上實際存在 tmp/mrg-ten（同一種東西、不同命名）
  #   ⇒ 那是【母體太窄】，而窄掉的那一支長得跟「沒問題」一樣。
  for b in $(git -C "$ROOT" for-each-ref --format='%(refname:short)' 'refs/heads/tmp/*' 2>/dev/null); do
    tip=$(git -C "$ROOT" rev-parse "$b" 2>/dev/null) || continue
    git -C "$ROOT" merge-base --is-ancestor "$tip" origin/main 2>/dev/null && continue
    # ★把【它有沒有獨有的實作工作】一起印出來 ⇒ 讓輸出可行動，而不是只讓人緊張
    _uniq=$(git -C "$ROOT" log --oneline --no-merges "origin/main..$b" 2>/dev/null | wc -l | tr -d ' ')
    if [ "${_uniq:-0}" = "0" ]; then
      echo "a) 殘骸分支：$b @ ${tip:0:9} 不在 origin/main，但【零獨有實作 commit】⇒ 可安全刪（它只是沒清掉）"
    else
      # ★★★【第三格，2026-10-01 systems 立】：獨有 commit 可能【全部都在別的遠端 ref 上】。
      #   ★血證：`tmp/merge-lead` 是**電池 worktree 的分支**，我一直 `merge --ff-only main` 推它；
      #     某次 merge 被我 un-merge 之後它還指著那顆 ⇒ 本格報「8 顆獨有 commit ⇒ 那些工作沒推出去」
      #     ⇒ **而那 8 顆全都在 `origin/feat/text-ui-layout-v2` 上，一顆都沒遺失。**
      #   ⇒ ★★原本只有兩格（零獨有＝可刪／有獨有＝沒推出去），而我的情況是**第三格**
      #     —— 這正是「二分法的 else 吞掉第三格」那一族：一句**方向錯的警告**會讓人去找一個不存在的損失。
      #   ⇒ ★★★判準：**獨有 commit 的數量不是結論，它們【還在不在別的地方】才是。**
      _orphan=0
      for _c in $(git -C "$ROOT" log --format=%h --no-merges "origin/main..$b" 2>/dev/null); do
        _elsewhere=0
        for _r in $(git -C "$ROOT" for-each-ref --format='%(refname)' 'refs/remotes/origin/*' 2>/dev/null); do
          [ "$_r" = "refs/remotes/origin/main" ] && continue
          if git -C "$ROOT" merge-base --is-ancestor "$_c" "$_r" 2>/dev/null; then _elsewhere=1; break; fi
        done
        [ "$_elsewhere" = "0" ] && _orphan=$((_orphan+1))
      done
      if [ "$_orphan" = "0" ]; then
        echo "a) 本機殘留的 merge／ff：$b @ ${tip:0:9} 領先 origin/main ${_uniq} 顆，★而那 ${_uniq} 顆【全部都在別的遠端分支上】⇒ 工作沒有遺失，只有這個本機 ref 沒收回（把它 reset 回 origin/main 即可）"
      else
        echo "a) 合併在飛：$b @ ${tip:0:9} 不在 origin/main 且有 ${_orphan} 顆【只存在於本機】的 commit（共 ${_uniq} 顆獨有）⇒ 那些工作沒推出去"
      fi
    fi
  done
}

_chk_b_verdict_unconsumed() {  # 判決未消費：摘要檔記的樹還沒進 origin/main
  local f sha
  f=$(ls -t "$ROOT/docs/measurements/.battery/"*.txt 2>/dev/null | head -1) || return 0
  [ -n "${f:-}" ] || return 0
  sha=$(sed -n 's/.*HEAD-end=\([0-9a-f]\{7,\}\).*/\1/p' "$f" | head -1)
  [ -n "${sha:-}" ] || return 0
  git -C "$ROOT" cat-file -e "${sha}^{commit}" 2>/dev/null || return 0
  git -C "$ROOT" merge-base --is-ancestor "$sha" origin/main 2>/dev/null && return 0
  echo "b) 判決未消費：$(basename "$f") 的 HEAD-end=${sha:0:9} 還不在 origin/main ⇒ 有一份電池判決沒被用掉"
}

_chk_c_letter_not_in_git() {   # 我寫的 open 信只在磁碟上（耐久那一半沒做）
  local me="${SESSION_ROLE:-}" d="$ROOT/docs/superpowers/handbacks" f rel
  [ -n "$me" ] || return 0
  [ -d "$d" ] || return 0
  for f in "$d"/*-${me}-to-*.md; do
    [ -f "$f" ] || continue
    grep -qE '^status:[[:space:]]*open([[:space:]]|$)' "$f" 2>/dev/null || continue
    rel="docs/superpowers/handbacks/$(basename "$f")"
    git -C "$ROOT" cat-file -e "origin/main:$rel" 2>/dev/null && continue
    echo "c) 信只在磁碟上：$(basename "$f") 不在 origin/main ⇒ 寄信＝寫檔＋commit＋敲門，你少了 commit"
  done
}

_chk_e_my_battery_flag() {     # 我自己的電池旗還活著
  local fl="$ROOT/.claude/hooks/.merge-gates-running" pid role
  [ -f "$fl" ] || return 0
  role=$(sed -n 's/.*role=\([^ ]*\).*/\1/p' "$fl" | head -1 | tr -d '\r')
  [ "${role:-}" = "${SESSION_ROLE:-}" ] || return 0
  pid=$(sed -n 's/^\([0-9]*\) .*/\1/p' "$fl" | head -1)
  [ -n "${pid:-}" ] || return 0
  if kill -0 "$pid" 2>/dev/null || tasklist //NH //FI "PID eq $pid" 2>/dev/null | grep -qE "[[:space:]]${pid}[[:space:]]"; then
    echo "e) 你自己的電池還在跑（PID $pid）⇒ 它的判決還沒回來，這回合不是結束是等待"
  fi
}

_run_all() {
  _chk_a_merge_in_flight
  _chk_b_verdict_unconsumed
  _chk_c_letter_not_in_git
  _chk_e_my_battery_flag
}

# ── 自檢：每一項各自獨立紅（★造假狀態，跑完還原） ──
if [ "${1:-}" = "--selfcheck" ]; then
  _resolve_root || { echo "[half-done --selfcheck] ⚠ 解不到 repo 根 ⇒ ABORT（不是綠）"; exit 1; }
  fail=0
  _c() { if [ "$1" = "hit" ]; then
           if [ -n "$2" ]; then echo "  ✓ $3"; else echo "  ✗ $3（期望紅而它沒出聲）"; fail=1; fi
         else
           if [ -z "$2" ]; then echo "  ✓ $3"; else echo "  ✗ $3（期望不紅而它說：$2）"; fail=1; fi
         fi }
  echo "[half-done --selfcheck] 逐項成對對照（每一項要能【各自】紅）"

  # a) 造一個指向 HEAD 前一顆的 tmp/merge-* 是不夠的（那是祖先）⇒ 要一顆 origin 沒有的
  _tmpb="tmp/merge-selfcheck-$$"
  _c0=$(_chk_a_merge_in_flight); _c none "$_c0" "a 基線：現在沒有在飛的合併樹"
  if git -C "$ROOT" commit-tree -m selfcheck -p HEAD "$(git -C "$ROOT" rev-parse HEAD^{tree})" >/dev/null 2>&1; then
    _fake=$(git -C "$ROOT" commit-tree -m selfcheck -p HEAD "$(git -C "$ROOT" rev-parse HEAD^{tree})")
    git -C "$ROOT" update-ref "refs/heads/$_tmpb" "$_fake"
    _c1=$(_chk_a_merge_in_flight); _c hit "$_c1" "★a 陽性：造一顆 origin 沒有的 tmp/merge-* ⇒ 必須紅"
    git -C "$ROOT" update-ref -d "refs/heads/$_tmpb"
    _c2=$(_chk_a_merge_in_flight); _c none "$_c2" "a 還原後不再紅"
  else
    echo "  ⚠ a 陽性對照跳過（commit-tree 不可用）⇒ 本格不可判，不是綠"; fail=1
  fi

  # ★★★a 的【第三格】陽性對照（2026-10-01 加）：造一支指向【別的遠端分支 tip】的 tmp/ 分支
  #   ⇒ 它領先 origin/main，而那些 commit 全都在別的遠端 ref 上 ⇒ 必須報「本機殘留」不是「沒推出去」。
  #   ★沒有這一格的話，第三格就是【沒接電的分支】：它的沉默跟正確一模一樣。
  _other=$(git -C "$ROOT" for-each-ref --format='%(refname)' 'refs/remotes/origin/*' 2>/dev/null     | grep -v 'refs/remotes/origin/main$'     | while IFS= read -r _r; do
        if [ -n "$(git -C "$ROOT" log --format=%h --no-merges "origin/main..$_r" 2>/dev/null | head -1)" ]; then
          echo "$_r"; break
        fi
      done)
  if [ -n "${_other:-}" ]; then
    _tmpb3="tmp/merge-selfcheck3-$$"
    git -C "$ROOT" update-ref "refs/heads/$_tmpb3" "$(git -C "$ROOT" rev-parse "$_other")"
    _c8=$(_chk_a_merge_in_flight)
    if printf '%s' "$_c8" | grep -q "本機殘留的 merge"; then
      echo "  ✓ ★★★a 第三格：領先 origin/main 而那些 commit 都在別的遠端分支上 ⇒ 報【本機殘留】"
    else
      echo "  ✗ ★★★a 第三格：期望【本機殘留】而它說：$_c8"; fail=1
    fi
    git -C "$ROOT" update-ref -d "refs/heads/$_tmpb3"
  else
    echo "  ⚠ ★a 第三格對照跳過（此刻沒有一支 origin/* 領先 origin/main）⇒ 本格不可判，不是綠"; fail=1
  fi

  # c) 造一封只在磁碟上的 open 信
  _me="${SESSION_ROLE:-systems}"
  _lt="$ROOT/docs/superpowers/handbacks/2026-01-01-${_me}-to-qa-HALFDONE-selfcheck-delete-me.md"
  _c3=$(SESSION_ROLE="$_me" _chk_c_letter_not_in_git); _c none "$_c3" "c 基線：沒有只在磁碟上的 open 信"
  printf -- '---\nfrom: %s\nto: qa\nstatus: open\ntopic: selfcheck\n---\n' "$_me" > "$_lt"
  _c4=$(SESSION_ROLE="$_me" _chk_c_letter_not_in_git); _c hit "$_c4" "★c 陽性：一封沒 commit 的 open 信 ⇒ 必須紅"
  rm -f "$_lt"
  _c5=$(SESSION_ROLE="$_me" _chk_c_letter_not_in_git); _c none "$_c5" "c 還原後不再紅"

  # e) 造一面屬於自己且 pid 活著的旗
  _fl="$ROOT/.claude/hooks/.merge-gates-running"
  if [ -f "$_fl" ]; then
    echo "  ⚠ e 陽性對照跳過（現在真的有一面旗，不動它）⇒ 本格不可判，不是綠"; fail=1
  else
    _wp=$(cat /proc/$$/winpid 2>/dev/null || echo $$)
    printf '%s tree=%s role=%s since=%s\n' "$_wp" "$ROOT" "$_me" "selfcheck" > "$_fl"
    _c6=$(SESSION_ROLE="$_me" _chk_e_my_battery_flag); _c hit "$_c6" "★e 陽性：自己的旗且 pid 活著 ⇒ 必須紅"
    printf '%s tree=%s role=%s since=%s\n' "$_wp" "$ROOT" "someone-else" "selfcheck" > "$_fl"
    _c7=$(SESSION_ROLE="$_me" _chk_e_my_battery_flag); _c none "$_c7" "★★e 陰性：別人的旗 ⇒ 不該紅（只管自己的）"
    rm -f "$_fl"
  fi

  echo "  ★b 沒有造假對照：它的輸入是【真的摘要檔】＋ancestry，造一份假摘要會污染量測目錄"
  echo "    ⇒ 本格的極性靠現況（下面 main 那一行）與血證重放，而這一句就是它的誠實限。"
  [ "$fail" = 0 ] && echo "[half-done --selfcheck] ✅ 全綠" || echo "[half-done --selfcheck] ❌ 有格不符"
  exit $fail
fi

_resolve_root || exit 0
OUT=$(_run_all)
if [ -n "${OUT:-}" ]; then
  echo "[half-done] ⛔ 有做到一半的東西，這回合不該停："
  printf '%s\n' "$OUT" | sed 's/^/  /'
  echo "[half-done] ★誠實限：本守衛只看得到【留下物件的半途】；純思考的半途它看不到。"
  exit 1
fi
exit 0
