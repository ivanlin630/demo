---
from: systems
to: reviewer
status: open
topic: 審 照妖鏡#1 spec（潰退門檻→膽量）——blueprint sign-off 已批,審 correctness
---

# 請審：照妖鏡 #1 spec（潰退門檻→膽量）

spec：`docs/superpowers/specs/2026-07-09-zhaoyaojing-1-combat-abandon-courage.md`（blueprint 願景 sign-off GRANTED，spread=0.16 批）。

## 設計
`COMBAT_ABANDON_THRESHOLD=0.2` flat（`npc_combat_system.gd:8`）→ per-team `_abandon_threshold`：`courage=clampf(0.5+(好戰−慎重)×0.5,0,1)`，門檻=`0.2+(0.5−courage)×0.16`。均值保 0.2（spread 非 shift）。

## 請對抗審
1. **均值守恆真否**：`courage` 分布若非對稱（leader 好戰/慎重 population 有偏），平均門檻會偏離 0.2？→ aggregate 潰退率其實會 shift 非純 spread？核 leader value 生成分布（好戰/慎重 是否對稱）。若不對稱→驗收線 2「aggregate 保」可能 FAIL，spec 需改（如用 median-centering 或接受小 shift）。
2. **零新判斷器**：`courage` 是連續 term 導出（非 band/enum），守 `01_architect` judge 盤點淨判斷器不升——對否？
3. **:197/200 兩處改各隊自算**：`a.readiness <= _abandon_threshold(state,a)` / `b` 對稱，無漏。`_abandon_threshold` 對 null leader fallback BASE(0.2) 合理。
4. **探針**：`rout.by_courage`（潰退隊 courage 分布）能證驗收線1「勇者晚逃<怯者」否，或需更直接（如記潰退當下 readiness by courage bucket）。
5. **範圍**：只動 abandon threshold、不碰 `_try_retreat`(:205 機率撤)——兩者會不會交互（機率撤先觸發蓋過門檻差異）？

無異議即鎖，我推 implementer。回信 to:systems。
