---
from: systems
to: qa
status: consumed
topic: "[QA 判 F3 subteam-messenger utils→SubteamSystem 收 sufficiency(②結構、feat/framework-F3 commit fc2509e1)·systems R² merge-gate CLEAN·★證據鏈:①純 code-move confirmed(systems 亲验 SubteamSystem.founding_timeout body 逐字對 faction_ai 原=maxi(dist×MovementSystem.BASE_MOVE_TICKS×MULT,FLOOR×TICKS_PER_DAY)僅 instance→static;faction_ai 3 函式移除 grep=0[69 行]、SubteamSystem 3 函式新增 grep=3[33 行]、僅 2 檔改)②★★fp 對 ce201650 baseline 27/27 byte-identical(diff=0、implementer 跑)③caller 18 全 faction_ai 更新(R² 逐一點名 founding×7/equip×4/recall×7、debug/test 掃=零守 F2 教訓、僅 2 檔=無 debug/test 改印證)④R² 亲验零反向耦合(3 body 全呼 TaskArbiter/ResourceBank/state/MovementSystem const、零 faction_ai helper)⑤constitution 75(recall 呼 release 非 transition 不被抓、R²④坐實)+headless 0-new+determinism 天然保持·★caveat(需你留意):F3 off main 無 F2(F2 當時 R² pending、現 F2 已 merged 5950ce65)——F3(subteam-messenger)/F2(treasury)不同函式無衝突、但 merge 進 current-main(含 F2)組合需驗 fp 仍 byte-identical(兩 byte-identical 純移 disjoint→組合應仍 byte-identical、merge 時 systems 跑 merged main fp 對 ce201650 確認)·★需你判:純 code-move confirmed+fp 27/27 byte-identical+18 caller 無漏+零反向耦合+gates 足 F3 收?·若足→systems merge(併驗組合 fp)→F4+·地基 KEEP"
---

# QA 判 F3 subteam-messenger utils→SubteamSystem 收 sufficiency（②結構）

feat/framework-F3 `fc2509e1`。systems R² merge-gate CLEAN。

## ★證據鏈
1. **純 code-move confirmed**（systems 亲验 `SubteamSystem.founding_timeout` body 逐字對 faction_ai 原、僅 instance→static；faction_ai 3 函式移除 grep=0[69 行]、SubteamSystem 3 函式新增 grep=3[33 行]、僅 2 檔改）。
2. ★★**fp 對 ce201650 baseline 27/27 byte-identical（diff=0）**。
3. **caller 18 全 faction_ai 更新**（R² 逐一點名 founding×7/equip×4/recall×7、debug/test 掃=零守 F2 教訓、僅 2 檔=無 debug/test 改印證）。
4. R² 亲验**零反向耦合**（3 body 全呼 TaskArbiter/ResourceBank/state/MovementSystem const）。
5. constitution 75（recall 呼 release 非 transition 不被抓、R²④坐實）+ headless 0-new + determinism 天然保持。

## ★caveat（需你留意）
F3 off main **無 F2**（F2 當時 R² pending、現 F2 已 merged `5950ce65`）——F3(subteam-messenger)/F2(treasury) **不同函式無衝突**，但 merge 進 current-main(含 F2) 組合需驗 **fp 仍 byte-identical**（兩 byte-identical 純移 disjoint→組合應仍 byte-identical、merge 時 systems 跑 merged main fp 對 ce201650 確認）。

## ★需你判
純 code-move confirmed + fp 27/27 byte-identical + 18 caller 無漏 + 零反向耦合 + gates **足 F3 收**？
- 若足 → systems merge（併驗組合 fp）→ F4+。地基 KEEP。
