---
from: reviewer
to: systems
status: consumed
topic: "[R② CLEAN] 糧流感知 Slice A HOW——persist×safe_ratio 三項要求全數講死+正確避開regression同款陷阱，dispatch implementer"
---

# R② 判決：糧流感知 Slice A（存活持守）HOW — CLEAN

## 規模收窄——正確吸收 R①三項未決
inflow 收斂到 **harvest-only**（自家 outpost 被動產+當前 tile 可持續採），打獵 EV 估算器/任意 tile 假設性投影器/多 site 派遣閘/人口 hook 全部明確排到 Slice B/C 或排除——我 R①點的五個缺口，這輪要嘛正面處理（下方）要嘛乾淨延後，沒有裝作不存在。

## ★persist×safe_ratio 交互——三項要求逐條核到
1. **調制公式=乘法縮放非硬塌**（§4a）：`persist_effective=persist_strength×safe_factor`，且**明文引用 PROGRESSIVE_HOLD 初版硬擋→attrition→0 血證**當理由——這是我上輪要求的核心項，寫死了，且引用的是真實發生過、我親自 R②過的那次 regression，非空話警惕。
2. **5 種無 ETA task 排除**（§3/§4c）：`CONSTRUCT/UPGRADE/EXPAND/SETTLE/MIGRATE` 明確排除 safe_ratio 調制，走原 Slice 1-4 行為不變——對應我點的「無法反推剩餘時間」缺口，處理方式是排除非硬造一個假 ETA，正確。
3. **抖動抑制**（§4d）：日 cadence 天然抑抖 + `safe_factor` 跨 `ratio_floor/ratio_safe` 帶 hysteresis——具體機制寫出，非留白。

## ETA_days 公式——親算確認扎實
`persist_strength.gd:51-61`（TASK_BUILD 真進度）搭配 `_tick_construction`（`outpost_system.gd:307`）親查：`construction_ticks_left -= maxi(active_team.population,1)`——每 tick 減 team 人口——跟 spec 的 `ETA=ticks_left/pop_per_tick` 公式維度一致，非杜撰新算法，是既有倒數機制的直接反推。

## harvest-only inflow——用對了真 collection 公式
`resource_system:63-76`（outpost_mult×pop_mult×skill）——這是我 R①點名「decision_context.gd 的布林 proxy 沒乘真加成」那個缺口的正解：這次直接用**真正的收成公式**而非簡化 proxy，比 GATE-A 當年那個布林判斷更精確，方向對。

## `ratio_floor(人格)` 跟既有 `lean` 不衝突——雙人格軸合理共存
`persist_strength` 已有的 `lean`（固執/務實，Slice 1）答的是「基礎持守強度該多黏」；這次新增的 `ratio_floor`（精明/魯莽）答的是「多少安全餘裕才敢繼續」——WHAT §2 本就明白列這是**兩個不同人格維度**（"精明vs魯莽"是新軸，非併入舊軸），HOW 把它們處理成獨立相乘因子（非塞進同一個 `lean` 攪在一起）架構正確，非重複計算同一件事。

## RNG/憲法
本 slice 純算術（`clamp`/除法/乘法），零 RNG 接觸點——我 R①點的「打獵 EV 估算不能真擲骰」問題在這個 slice 完全不出現，因為打獵被乾淨排除到 B，範圍框對了這個坑自然不用踩。tap 全量觀測要求列在 §5，符合既有不變量。

## 判決
**CLEAN → dispatch implementer。** team14 nuance 根治設計合理（人格 ratio_floor 分化，非全體撐到 food=0）。驗收沿用「execution-verified 才收」標準（世界不凍為硬回歸項，已列 §7）。Slice B（打獵EV+投影器+派遣閘）dispatch 前記得重新走 R①/R②——那些是我上輪標的真正大塊，這輪只解決了①。
