#!/usr/bin/env bash
# ★★★index.lock 孤兒判定（blueprint 提、systems 實作 2026-09-08）
#
# 病：鎖卡著時【全員 commit 都掛】，而「to: all 問一圈」的延遲 > 判準跑一次。
#   ★而「誰敢刪」是一個沒有答案的問題 —— 把它換成【判準說了算】。
#
# ★★本工具【不刪任何東西】。它輸出【證據 + 判決 + 一行你可以自己貼的指令】。
#   理由：刪錯 = 毀掉某人未 commit 的 index；而一個會自動刪的工具，
#   ★★★它的誤判會在【沒有人在看的時候】發生。
#
# 三判準（★而「零 git 進程」單獨不算數）：
#   ①size == 0        —— 有內容代表有人正在寫
#   ②age >= 分鐘級     —— 遠大於任何合理 git 指令的時長
#   ③★mtime 在取樣區間內【沒有被重建】 —— 活著的持有者會續寫
#   ④★★HEAD 在同區間【沒有前進】     —— 有人在 commit 的話 HEAD 會動
#   ⑤零 git 進程 —— ★★★這一格是【取樣】：一個無關的短命 git 指令就能讓它看起來不成立，
#     反之亦然（implementer 2026-09-08 教訓）。它只當【輔證】，不當條件。
#
# 用法： stale-lock-check.sh            判定並印證據（不刪）
#        stale-lock-check.sh --selfcheck  對【合成輸入】驗判準兩個方向都會動
set -u
cd "$(git rev-parse --show-toplevel 2>/dev/null || echo .)" || exit 2
LOCK=".git/index.lock"
SAMPLE_S="${LOCK_SAMPLE_S:-20}"
AGE_MIN_S="${LOCK_AGE_MIN_S:-180}"

# ★判斷與量測分開：judge 是純函數,可以用合成輸入測(不必去碰真的鎖)
judge() {   # $1=size $2=age $3=mtime_changed(0/1) $4=head_moved(0/1)
  [ "$1" -ne 0 ] && { echo "BUSY:有內容(size=$1) —— 有人正在寫"; return; }
  [ "$3" -eq 1 ] && { echo "BUSY:mtime 被重建 —— 持有者活著"; return; }
  [ "$4" -eq 1 ] && { echo "BUSY:HEAD 前進了 —— 有人在 commit"; return; }
  [ "$2" -lt "$AGE_MIN_S" ] && { echo "WAIT:才 $2 秒 —— 還在合理 git 指令時長內"; return; }
  echo "ORPHAN"
}

if [ "${1:-}" = "--selfcheck" ]; then
  echo "[STALE-LOCK] 陽性對照（合成輸入，★不碰真的鎖）"
  printf '  size=8  age=999 mtime=0 head=0 ⇒ %s\n' "$(judge 8 999 0 0)"
  printf '  size=0  age=999 mtime=1 head=0 ⇒ %s\n' "$(judge 0 999 1 0)"
  printf '  size=0  age=999 mtime=0 head=1 ⇒ %s\n' "$(judge 0 999 0 1)"
  printf '  size=0  age=10  mtime=0 head=0 ⇒ %s\n' "$(judge 0 10 0 0)"
  printf '  size=0  age=999 mtime=0 head=0 ⇒ %s\n' "$(judge 0 999 0 0)"
  echo "[STALE-LOCK] ★判準有鑑別力的條件＝上面【至少要出現 BUSY / WAIT / ORPHAN 三種】"
  exit 0
fi

[ -e "$LOCK" ] || { echo "[STALE-LOCK] 無鎖 —— 沒有東西要判"; exit 0; }
_sz=$(stat -c %s "$LOCK" 2>/dev/null || echo -1)
_m1=$(stat -c %Y "$LOCK" 2>/dev/null || echo 0)
_h1=$(git rev-parse HEAD 2>/dev/null || echo none)
echo "[STALE-LOCK] 取樣 ${SAMPLE_S}s（★判定需要兩個時間點，不能只看一眼）…"
sleep "$SAMPLE_S"
[ -e "$LOCK" ] || { echo "[STALE-LOCK] 取樣期間鎖自己消失了 —— 案結,不必動手"; exit 0; }
_m2=$(stat -c %Y "$LOCK" 2>/dev/null || echo 0)
_h2=$(git rev-parse HEAD 2>/dev/null || echo none)
_age=$(( $(date +%s) - _m2 ))
_mch=$([ "$_m1" = "$_m2" ] && echo 0 || echo 1)
_hmv=$([ "$_h1" = "$_h2" ] && echo 0 || echo 1)
_gp=$(powershell -NoProfile -Command "(Get-Process git -ErrorAction SilentlyContinue|Measure-Object).Count" 2>/dev/null | tr -d '\r')

echo "[STALE-LOCK] 證據（★不是判決，是判決的根據）"
echo "  size          = ${_sz}"
echo "  age           = ${_age}s   （門檻 ${AGE_MIN_S}s）"
echo "  mtime 被重建  = $([ "$_mch" -eq 1 ] && echo 是 || echo 否)"
echo "  HEAD 前進     = $([ "$_hmv" -eq 1 ] && echo 是 || echo 否)"
echo "  git 進程數    = ${_gp:-?}   ★輔證：這一格是【取樣】，單獨不足以判定"
V="$(judge "${_sz:-1}" "$_age" "$_mch" "$_hmv")"
echo "[STALE-LOCK] 判決：$V"
case "$V" in
  ORPHAN*)
    echo "[STALE-LOCK] ⇒ 判定為孤兒。★本工具不刪。要刪請自己貼："
    echo "      rm -f \"$(git rev-parse --show-toplevel)/.git/index.lock\""
    echo "[STALE-LOCK] ★★刪之前再問一次：你確定【不是你自己】剛起的長指令？"
    exit 3 ;;
  *) exit 0 ;;
esac
