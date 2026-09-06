#!/usr/bin/env bash
# ★★★零產出偵測（2026-08-25 HOLD 批 #6）★v2：改用 decision:block（v1 只 echo ＝ 送不到）
#   ★我的唯讀診斷結論：現有三道防線【全都要求「已經有某種產出物存在」】——
#     implementer-cleanup 要有 [DONE] 信 / _promise_check 要有他寫的信 / watchdog COMMIT-NO-LETTER 看 main。
#   ★★沒有一道問：★★★「你這回合做了事，卻【什麼都沒送出去】嗎？」
#   ⇒ 本 hook 補那一格：本回合【有 commit】但【沒有新的 open 信】⇒ 提醒（不擋）。
#   ★注意：這條【偵測】只有在【送達層】也修好時才有意義——fire 給沒人聽等於沒 fire。
set -u
case "${SESSION_ROLE:-}" in ''|none) exit 0 ;; esac
IN=$(cat 2>/dev/null || echo '{}')
printf '%s' "$IN" | grep -q '"stop_hook_active":[[:space:]]*true' && exit 0
# ★★★worktree-safe 信箱解析（systems 修 2026-08-27，implementer 揭）：
#   `--show-toplevel` 在 worktree 裡回傳【worktree 根】⇒ 解到一個【空的】handbacks 目錄，
#   而唯一的信箱在 main。★zero-output-warn 因此對 worktree 角色【恆誤報】(他兩回合都寄了信卻都被判零產出)。
#   ★★`--git-common-dir` 在 worktree 裡回傳【main 的 .git】(`--git-dir` 不行，那是 worktree 私有的)
#   ⇒ 其父目錄＝main 工作樹根；★★★在 main 裡跑同樣正確 ⇒ 一份程式碼兩邊都對，不需角色分支。
_gc=$(git rev-parse --git-common-dir 2>/dev/null) || exit 0
cd "$(cd "$(dirname "$_gc")" && pwd)" || exit 0
D=docs/superpowers/handbacks
[ -d "$D" ] || exit 0
# 近 20 分鐘：★【我這個 session】有 commit 嗎？
# ★★2026-09-06 修恆誤報：原本這裡是 `git log --author="$(git config user.name)"`，
#   而★六個角色 session ＋ 影子 session【共用同一個 git 身分 ivanlin630】
#   ⇒ `--author` 篩不掉任何人 ⇒ 它數的是【全 repo 的 commit】
#   ⇒ ★★只要任何一個角色在 20 分鐘內 commit，其他所有角色回合結束時都會被警告
#   ⇒ ★★★在這個專案那幾乎是恆真 ⇒ 這支守衛天天喊狼，於是真斷鏈那次沒人會停下來看。
#   （血證：影子 session 本回合【一個 commit 都沒有】卻收到「近 20 分鐘有 3 個 commit」。）
# ★修法不是換篩選條件（`--committer` 一樣共用，沒救），是【記事實】：
#   commit-fact.sh（PostToolUse）在【HEAD 真的變了】時寫一筆到 .committed.<session_id>，
#   這裡只讀【自己那一份】。零猜測。
_sid="${CLAUDE_CODE_SESSION_ID:-}"
[ -z "$_sid" ] && exit 0        # fail-open：拿不到 session id 就不猜（寧可不報也不誤報）
_cf=".claude/hooks/.committed.${_sid}"
[ -f "$_cf" ] || exit 0
_cut=$(( $(date +%s) - 1200 ))
c=$(awk -v t="$_cut" '$1 >= t' "$_cf" 2>/dev/null | wc -l | tr -d ' ')
[ "${c:-0}" -eq 0 ] && exit 0
# 近 20 分鐘：有沒有新的 status:open 信（任何寄件者）
o=$(find "$D" -maxdepth 1 -name '*.md' -mmin -20 2>/dev/null | while read -r f; do grep -q '^status: open' "$f" 2>/dev/null && echo x; done | wc -l | tr -d ' ')
[ "${o:-0}" -gt 0 ] && exit 0
# ★★★輸出必須用 decision:block —— 純 echo 的 stdout【不會回到 agent 眼前】。
#   ★血證 2026-08-25：本 hook 第一版只 echo ⇒ 我做完整批工作沒回報，它「偵測到了」但沒人收到；
#   ★★是【用戶】抓到我沒回報，我才手動跑這支 hook，它才響 —— ★它是被叫出來的，不是它叫我。
#   ★★★而我在本檔檔頭自己寫過「fire 給沒人聽等於沒 fire」，然後做出一個 fire 給沒人聽的東西。
#   ⇒ 對照組：`implementer-cleanup.sh` 一直是用 `{"decision":"block"}` —— 那才送得到。
MSG="[零產出] 近 20 分鐘有 ${c} 個 commit，但沒有任何新的 status:open 信。★做了事卻沒送出去 ＝ 下游不會被喚醒（Monitor 靠信、不靠 commit）。⇒ 若這回合有成果要推下一站，現在寫那封信（含 exact path）；若本來就不需要推（純自檢／純整理），回一句「本回合無需推站」即可結束。"
python -c "import json,sys; print(json.dumps({'decision':'block','reason':sys.argv[1]}))" "$MSG"
exit 0
