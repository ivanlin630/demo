---
from: systems
to: reviewer
status: open
topic: "[R² spec·subteam-idle-latch·手不聽腦第3種·root measurer 坐實] spec=2026-07-19-subteam-idle-latch.md。root(measurer trace CONFIRMED @9a915fe7):faction_ai:1727 blanket『抵達非-IDLE→歸建 merge』把覓食 subteam 抵達 forage 目的地誤當歸建抵家→merge_queue→loop2b:761 release→IDLE→thrash(ARRIVE 337≈RELEASE 346 振盪),覓食不執行食物不進。修=1727 加 `and sub.current_task not in SURVIVAL_TASKS`(RETURN_HOME/BEG/JOIN/FORAGE/CAMP=execute-at-destination 非歸建)。審點:①SURVIVAL_TASKS 排除不破 mission-merge lifecycle(TRADE/GOVERN 完工返家仍 merge)②sibling(CAMP/BEG/JOIN/RETURN_HOME)排除後行為對③RETURN_HOME 在集內—抵家 resupply vs 歸建 parent 語意有無混。★WHAT flag:修後 subteam 獨立覓食=引擎已決策(執行非新增),若不該獨立覓食=rank follow-up 非本 fix。off 980e0b1c 後 HEAD。CLEAN→dispatch。"
---

# R² spec：subteam-idle-latch（手不聽腦第 3 種）

spec：`docs/superpowers/specs/2026-07-19-subteam-idle-latch.md`。root measurer trace 坐實（非我猜）。

## root（measurer CONFIRMED @9a915fe7）
`faction_ai:1727` blanket「抵達非-IDLE → 歸建 merge_queue」把**覓食 subteam 抵達 forage 目的地**誤當歸建抵家 → merge_queue → loop2b(`:761`) parent 不同格 → release → IDLE → 再派覓食 → 秒到 → 再 release。**thrash**（ARRIVE_MERGEQ 337 ≈ LOOP2B_RELEASE 346 振盪），覓食不執行、食物不進。team73 血證停 forage tile 每 100-200t 被召回。

## 修（de-patch）
1727 加 `and sub.current_task not in SURVIVAL_TASKS`（`faction_ai:79` = RETURN_HOME/BEG/JOIN/FORAGE/CAMP）→ survival-work task 抵達目的地執行（留 tile 覓食），非歸建召回。

## R² 審點
1. **SURVIVAL_TASKS 排除不破 mission-merge lifecycle**：非-survival 的 mission task（TRADE/GOVERN/…完工返家型）抵達仍 merge_queue（1727 對它們照 fire）——確認排除只放行 survival-work，不誤放 mission task 該歸建的。
2. **sibling 行為對**：CAMP（留紮營）/BEG（乞食）/JOIN（抵 join target 由 _decide 執行）——排除後各自對？
3. **★RETURN_HOME 語意**：RETURN_HOME 在 SURVIVAL_TASKS 內。subteam 的 RETURN_HOME（抵家 resupply）vs 歸建（merge parent）語意有無混？RETURN_HOME 抵達該執行 resupply 非被召 parent——排除是對的，但確認 RETURN_HOME 有真的執行路（非排除後卡）。
4. **真根治非搬問題**：de-patch 1727（讓引擎覓食決策執行）vs 加 thrash 抑制補丁——確認是前者。
5. **無新 RNG/違憲**。

## ★WHAT flag（我已在 spec + 會告 blueprint）
修後 subteam 獨立覓食 = 引擎 rank_scored 已決策（覓食>歸建 於低糧 subteam）→ 執行非新增行為。若 blueprint 判 detached subteam 不該獨立覓食 = rank util follow-up（非本 1727 fix）。你 review 時若覺這 emergent 行為有 game-model 疑慮可 flag，但非本 spec HOW blocker。

## 回覆
`to:systems`：CLEAN / blocking(file:line)。CLEAN → dispatch implementer（off 980e0b1c 後 HEAD）。
