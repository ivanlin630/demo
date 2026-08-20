---
from: systems
to: reviewer
status: consumed
topic: "[R² settlement S2b(L0→L1工期=建點viability過濾)HOW審·spec=2026-08-18-settlement-S2b-L0-to-L1-corvee-HOW.md·R①免(前提file:line坐實)·審點:①★前提fact-check:_complete_construction已有『crude_camp』action分支(outpost_system:361-369)做L1-founding(set outpost_level=1+set_owner construct+food cap+tag)確認否?_tick_construction:272 ticks_left-=pop driver確認否?S2a後NPC無L0→L1路(establish_crude_camp:4711只建L0)確認否?②★★設計冗餘查(你R²命門):T1『建點/紮根』決策是延伸還是框架內冗餘求解器——in-place L0→L1(team站自己L0紮根升級)vs既有派子隊founding(_dispatch_builder goal_resolver:452遠方建新)是不同case?or重疊?若重疊要求收斂為一③補丁閘:複用_tick_construction/_complete_construction非新gate、完工擴充清camp_level非新機制④感知鐵律:L0→L1讀腳下自家L0(proximate站定合法)⑤機制意圖對照:mechanism-intents紮營vs建點row(L0臨時/建點=數天工期真機會成本/L1才居民勞力池)+守恆(food cap抬非送即時糧既有:362原則)·此slice待R²CLEAN→S2b plan→dispatch(base post-S2a main 8654dbf5)·地基KEEP"
---

# R² settlement S2b（L0→L1 工期）HOW 審

spec=`docs/superpowers/specs/2026-08-18-settlement-S2b-L0-to-L1-corvee-HOW.md`。R① 免（前提 file:line 坐實）。

## 審點
1. **★前提 fact-check**：`_complete_construction` 已有 `"crude_camp"` action 分支(outpost_system:361-369) 做 L1-founding（set outpost_level=1+set_owner "construct"+food cap+tag）確認否？`_tick_construction:272` `ticks_left-=pop` driver 確認否？S2a 後 NPC 無 L0→L1 路（establish_crude_camp:4711 只建 L0）確認否？
2. **★★設計冗餘查（你 R² 命門）**：T1「建點/紮根」決策 = **延伸** 還是**框架內冗餘求解器**？in-place L0→L1（team 站自己 L0 紮根升級）vs 既有派子隊 founding（`_dispatch_builder` goal_resolver:452 遠方建新）——**不同 case**（站定升級 vs 遠方建新）or 重疊？若重疊→要求收斂為一。
3. **補丁閘**：複用 `_tick_construction`/`_complete_construction` 非新 gate、完工擴充清 camp_level 非新機制。
4. **感知鐵律**：L0→L1 讀腳下自家 L0（proximate 站定合法）。
5. **機制意圖對照**：`mechanism-intents` 紮營 vs 建點 row（L0 臨時/建點=數天工期真機會成本/L1 才居民勞力池）+ 守恆（food cap 抬非送即時糧、既有 :362 原則）。

## 時序
待 R² CLEAN → S2b plan → dispatch implementer（base post-S2a main `8654dbf5`）。地基 KEEP。
