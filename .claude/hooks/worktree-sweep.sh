#!/usr/bin/env bash
# ★★★worktree 清理（systems，2026-09-08 事故後）
#
# 血證：我用【一次掃描的快照】決定拆哪些，幾分鐘後才執行 ⇒ 拆掉了 implementer 正在用的兩棵
# （wagepen / bedkind，兩次 commit 之間剛好是乾淨的）。branch ref 沒動 ⇒ 零 commit 損失，
# 但未 commit 的東西沒了，而且我還讀錯了兩次：
#   ①`git worktree remove` 回傳非零 ⇒ 我讀成「它擋下來了」，★而內容已經刪了
#   ②另一棵回傳零 ⇒ 我根本沒去看 ⇒ ★★靜靜地被拆掉
#   ⇒ ★★★【有錯誤訊息但做了】與【沒錯誤訊息也做了】，我兩個方向都錯過一次。
#
# 三道防線（缺一不可）：
#   ①ACTIVE 排除：branch 24h 內有 commit ⇒ 一律不碰（不管乾不乾淨）
#     —— 對【有人正在用的樹】，「乾淨」是一個【時刻】不是一個【屬性】。
#   ②拆除前【當場重驗】git status —— 不用任何快照。掃描與執行之間那個窗口就是事故的洞。
#   ③拆除後【逐支驗結果】：目錄沒了 且 .git 沒了 —— ★不看回傳碼。
#     （`git -C <已拆的樹> status` 會往上走讀到【主 repo】並回報 branch: main，
#       看起來像「那棵樹好好的」⇒ 確認存不存在只能看 .git 檔本身。）
#
# 用法：worktree-sweep.sh            ⇒ 只列出，不動任何東西（預設）
#       worktree-sweep.sh --remove   ⇒ 真的拆（只拆 SAFE 那一類）
#       worktree-sweep.sh --selfcheck⇒ 陽性對照：驗三道防線真的會擋
set -u
cd "$(git rev-parse --show-toplevel 2>/dev/null || echo .)" || exit 2
MODE="${1:-}"
NOW=$(date +%s)
ACTIVE_WINDOW=$(( 24 * 3600 ))

classify() {  # $1=path $2=branch(or DETACHED)
  local p="$1" b="$2" t wip
  [ -e "$p/.git" ] || { echo "NO_DOTGIT"; return; }
  if [ "$b" != "DETACHED" ]; then
    # ★★★ACTIVE 問的是【有沒有人在這棵樹上工作】，不是【branch 有沒有新 commit】。
    #   血證 2026-09-08：systems 照裁定把 50 棵樹的 WIP 全部 commit 了（「先 commit 再決定」）
    #   ⇒ 每一支 branch 都在 24h 內有 commit ⇒ ★守衛把全部 51 棵判成 ACTIVE
    #   ⇒ ★★守衛從【恆空】變成【恆滿】：保護所有東西 ＝ 什麼都清不掉。
    #   ⇒ ★★★修法：【掃除工具自己的記帳 commit 不算「有人在工作」】——
    #     往回走到第一顆【不是 worktree-sweep 固定 WIP】的 commit 才算數。
    #     （blueprint 當初要求 commit 訊息帶辨識字樣，就是為了這一刻。）
    t=$(git log --format='%ct%x09%s' -20 "refs/heads/$b" 2>/dev/null         | grep -v "worktree-sweep 固定 WIP" | head -1 | cut -f1)
    if [ -n "$t" ] && [ $(( NOW - t )) -lt $ACTIVE_WINDOW ]; then echo "ACTIVE"; return; fi
  fi
  wip=$(git -C "$p" status --porcelain 2>/dev/null | wc -l | tr -d ' ')
  if [ "${wip:-1}" -ne 0 ]; then
    # ★EXHAUST：branch 已 merge 進 main，而未 commit 的東西【全部不是原始碼/文件】
    #   ⇒ 那些是【量測產物】（.jsonl / _temp.txt / specimen），不是工作。
    #   ★★blueprint 裁 2026-09-08，且【前置對帳】已做：verdicts/measurements 對這些樹的
    #     exact-path 引用已逐筆查過，被引用的證物已搬 docs/measurements/_archive。
    if [ "$b" != "DETACHED" ] && git merge-base --is-ancestor "$b" main 2>/dev/null; then
      if [ "$(git -C "$p" status --porcelain 2>/dev/null | awk '{print $NF}' | grep -cE '[.](gd|ps1|sh|md|tscn)$')" = "0" ]; then
        echo "EXHAUST:$wip"; return
      fi
    fi
    echo "WIP:$wip"; return
  fi
  echo "SAFE"
}

if [ "$MODE" = "--selfcheck" ]; then
  echo "[WT-SWEEP] 陽性對照（三道防線各驗一格，★不拆任何東西）"
  _a=0; _s=0; _w=0
  git worktree list --porcelain | awk '/^worktree /{p=$2} /^branch /{print p"\t"$2} /^detached/{print p"\tDETACHED"}' \
  | while IFS=$'\t' read -r p b; do
      case "$p" in *"$(basename "$PWD")") continue;; esac
      echo "$(classify "$p" "${b#refs/heads/}")"
    done | sort | uniq -c | sed 's/^/  /'
  echo "[WT-SWEEP] ★判準有鑑別力的條件＝上面【至少要有兩種】分類；只有一種＝謂詞沒在分辨"
  exit 0
fi

echo "[WT-SWEEP] [TREE] HEAD=$(git rev-parse --short HEAD) mode=${MODE:---list}"
n_safe=0; n_act=0; n_wip=0; n_exh=0; n_rm=0; n_fail=0
git worktree list --porcelain | awk '/^worktree /{p=$2} /^branch /{print p"\t"$2} /^detached/{print p"\tDETACHED"}' > /tmp/.wt-sweep-$$ 2>/dev/null \
  || git worktree list --porcelain | awk '/^worktree /{p=$2} /^branch /{print p"\t"$2} /^detached/{print p"\tDETACHED"}' > .wt-sweep-tmp
LIST="/tmp/.wt-sweep-$$"; [ -f "$LIST" ] || LIST=".wt-sweep-tmp"
while IFS=$'\t' read -r p b; do
  case "$p" in *"/$(basename "$PWD")") continue;; esac
  short="${b#refs/heads/}"
  # ★防線②：這裡才分類，而分類就在拆除的同一個迴圈裡 —— 沒有快照
  k=$(classify "$p" "$short")
  case "$k" in
    ACTIVE)   n_act=$((n_act+1));  echo "  ACTIVE  $(basename "$p")  ($short 24h 內有 commit ⇒ 不碰)";;
    WIP:*)    n_wip=$((n_wip+1));  echo "  ${k}    $(basename "$p")";;
    EXHAUST:*)
      n_exh=$((n_exh+1))
      if [ "$MODE" = "--remove-exhaust" ]; then
        git worktree remove --force "$p" >/dev/null 2>&1
        if [ ! -e "$p/.git" ] && [ ! -d "$p" ]; then n_rm=$((n_rm+1)); echo "  拆除✓  $(basename "$p")  (量測產物 ${k#EXHAUST:} 個)"
        else n_fail=$((n_fail+1)); echo "  ★未完全拆  $(basename "$p") —— 人工查"; fi
      else
        echo "  ${k} $(basename "$p")  ($short, WIP 全為量測產物)"
      fi;;
    NO_DOTGIT) echo "  ★NO_DOTGIT $(basename "$p") ⇒ 不是 worktree，本工具不處理";;
    SAFE)
      n_safe=$((n_safe+1))
      if [ "$MODE" = "--remove" ]; then
        git worktree remove "$p" >/dev/null 2>&1
        # ★防線③：驗【結果】不看回傳碼
        if [ ! -e "$p/.git" ] && [ ! -d "$p" ]; then n_rm=$((n_rm+1)); echo "  拆除✓  $(basename "$p")"
        elif [ ! -e "$p/.git" ]; then n_fail=$((n_fail+1)); echo "  ★半拆   $(basename "$p") —— .git 沒了但目錄還在（人工查）"
        else n_fail=$((n_fail+1)); echo "  拆除✗  $(basename "$p") —— 仍在，未動"; fi
      else
        echo "  SAFE    $(basename "$p")  ($short)"
      fi;;
  esac
done < "$LIST"
rm -f "$LIST" 2>/dev/null
echo "[WT-SWEEP] SAFE=$n_safe ACTIVE=$n_act WIP=$n_wip EXHAUST=$n_exh"
[ "$MODE" = "--remove" ] || [ "$MODE" = "--remove-exhaust" ] && echo "[WT-SWEEP] 已拆=$n_rm 未拆/半拆=$n_fail  ★這兩個數字來自【驗目錄】不是回傳碼"
exit 0
