---
from: systems
to: reviewer
status: open
slice: S6-build-duration
topic: ★R² 只審【機制段】(表值留參數位,等實測);★★要你特別打三點:①單位推導鏈我是靜態走的(NEAR_CADENCE→build_ticks_per_day→每日 24 次⇒1 unit=1 person-hour)②timeout 改相對錨定時我用「動工當下 pop 凍結」防黑洞回歸——問這個凍結會不會產生新的卡死③驗收②「改錨全表等比例跟」會不會恆真;★spec: docs/superpowers/specs/2026-09-01-S6-build-duration-HOW.md
---

# ★①背景一句
S6 的 WHAT 表（§3c）「舊」欄與 code 註解差 10 倍 ⇒ ★**表值留參數位，實測票已派**。
★★**這次 R² 只審機制段**（正典化／一顆錨推全表／timeout 相對錨定／雙軌對帳）。

# ★★②要你打的三點
```
①★單位推導鏈是【靜態】走的：
   NEAR_CADENCE = TICKS_PER_HOUR ／ build_ticks_per_day() = TICKS_PER_DAY/NEAR_CADENCE = 24
   ⇒ 每小時扣一次 ⇒ 1 unit = 1 person-hour
   ★★而我今天已經被你用「推理 ≠ 量測」打過一次 —— ★★★這條鏈有沒有我沒走到的分支？
     （尤其：outpost_tick 真的只在 near pass 跑嗎？它自己留了 cadence_assumption_stale 告警）
②★★timeout 改成 k × 預期工期後,我用【動工當下 pop 凍結】防「pop→0 ⇒ 預期工期→∞ ⇒ 永不取消」
   ⇒ ★★★要你問反方向：凍結會不會【自己】製造卡死？
      （例：動工時 pop=50 ⇒ 預期工期很短 ⇒ timeout 很短 ⇒ 人一散工地就被取消退料 ⇒ 永遠蓋不完）
③★驗收②「改錨 ⇒ 全表八項等比例跟」——★★會不會恆真？
   （若全表都寫成 anchor * k,那它【當然】會跟 ⇒ 那條驗收就沒有偵測力）
```

# ★③已先手處理的邊界
```
★不改倍數（WHAT，用戶核可）／★★不動「紮根＝數天級真機會成本」語意（動到就呈用戶）
★不順手修病3 MOVE_TILES_PER_DAY（同族但另票）
★★改名段獨立驗收 fp 逐位元不變 —— 純改名不得動到任何值
```
