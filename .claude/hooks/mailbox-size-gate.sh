#!/usr/bin/env bash
# ★merge gate：信箱熱目錄超過硬上限 ⇒ 紅。
#
# ★★這道閘存在的理由【不是】「信箱大不好看」，是：
#   歸檔機制在 2026-08-27 就建好了，政策也對，★但它沒接任何觸發器 ⇒ 靠人記得跑 ⇒ 沒人跑
#   ⇒ ★★而它【沒跑】這件事【完全沒有症狀】,直到熱目錄長到 1997 封、
#      SessionStart 掃描超時被殺、所有角色【靜默】失去角色 context。
#   ⇒ ★★★所以真正要修的不是「再跑一次歸檔」,是【讓它停下來時會有人知道】。
#
# ★這是 memory「沒有人負責讓東西變少」的第四例（326 → 修一次 → 911 → 修一次 → 1997）——
#   ★★前兩次都「修好了」,而兩次都沒有人問「誰負責讓它不要再長回來」。
set -u
# ★★★拿不到 git 時【不准 SKIP 成功】——SKIP 會被讀成「查過了沒事」。
if ! _gc=$(git rev-parse --git-common-dir 2>/dev/null); then
  echo "[mailbox-size] ★git 不可用 ⇒ 本閘【沒有判過】(不是 PASS 也不是 FAIL)"
  echo "  ⇒ 多半是 detached/精簡 PATH 少了 mingw64\bin"
  exit 1
fi
cd "$(cd "$(dirname "$_gc")" && pwd)" || exit 0
HB="docs/superpowers/handbacks"
CEIL=600
n=$(ls "$HB"/*.md 2>/dev/null | wc -l | tr -d ' ')
if [ "${n:-0}" -gt "$CEIL" ]; then
  echo "[mailbox-size] FAIL：熱目錄 ${n} 封 > 上限 ${CEIL}"
  echo "  ⇒ 歸檔觸發器沒有在運作（.claude/hooks/.archive-last 的時戳說明上次跑是什麼時候）"
  echo "  ⇒ 手動跑一次：bash .claude/hooks/handback-archive.sh"
  echo "  ★不要改高這個上限 —— 上限就是【它停了會有人知道】的那個機制本身"
  exit 1
fi
last="(從未跑過)"
[ -f .claude/hooks/.archive-last ] && last=$(cat .claude/hooks/.archive-last)
echo "[mailbox-size] PASS：熱目錄 ${n} 封（上限 ${CEIL}）｜上次歸檔：${last}"
exit 0
