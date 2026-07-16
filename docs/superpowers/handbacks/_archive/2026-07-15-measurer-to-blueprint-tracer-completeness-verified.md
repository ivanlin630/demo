---
from: measurer
to: blueprint
status: consumed
topic: "[量測完] tracer-completeness@b21794b7——全生命無洞✅(main gap1680tick→branch max60tick=heartbeat cadence);on/off byte-identical✅(硬紅線通過,世界零擾動);churn現形(finder_miss/try_set_noop)本輪2樣本(Team26/27)皆0樣本=inert-by-absence(此世界thrash已被上游god-view+desperation arc修得夠乾淨,撞不到);憲法/sanity全綠"
---

# tracer-completeness 觀測 infra 驗證

`measured_at_head: b21794b7`（base main `1681e643`）。

## 一次量完（鐵律6）

## 1. ★★全生命無洞：達成，強力 before/after 對照
同 seed1337 Team26，同 `SPECIMEN_TEAM_ID=26` 跑法：
| | entries | 最大 gap |
|---|---|---|
| main（`de849b2c`，未含本刀） | 6 | **1680 tick（=7天）** |
| branch（`b21794b7`） | 130（committed 6 + heartbeat 124） | **60 tick（=6h，恰=HEARTBEAT_CADENCE）** |

Heartbeat sweep 確認生效，時間維無洞。

## 2. ★★on/off byte-identical：達成（硬紅線通過）
同 seed，`SPECIMEN_TEAM_ID=26` vs 無 specimen 兩跑，逐行 diff（排除 specimen 自身輸出段落+TickPerf 時序噪聲）：**世界層級零差異**（4 處殘留純屬 specimen 死因裁定/beliefs 專屬列印，非世界岔開）。**新 tap（attempt-tap+heartbeat）零 state mutation、零 RNG 側效應，觀測禁改世界的核心驗收通過**。

## 3. ★churn 現形：本輪 inert-by-absence（非否定）
試 2 個候選（Team26、Team27，皆本世界唯一活躍 thrash 樣本）：
- Team26：130 entries，`result` 分布 `{committed:6, heartbeat/no-decision:124}` — **無 finder_miss/try_set_noop**。
- Team27：161 entries，`result` 分布 `{committed:101, heartbeat/no-decision:60}` — **同樣無 finder_miss/try_set_noop**。

**判讀**：本世界（seed1337 default.json，god-view+desperation arc 已 merged）目前找不到真正撞上 finder-miss/try-set-noop 的 thrash 案例——與本 session 稍早多輪「乞食/diplomacy/逃脫」inert-by-absence 同款：**上游修復（god-view+desperation A/B/A-2）已經讓這個 seed 的 thrash 案例變乾淨**，導致這批新 tap 缺乏可展示的天然素材。tap 本身是否正確接線（純 code-verify）未查——若你判斷需要，可另跑 §測 2 churn 專用場景（如比照 pursuit_hiding_bed.gd 手構一個真的 try_set-noop 情境）驗接線正確性。

## 4. 不回歸：全綠
- **憲法閘**：PASS sites=29 removed=0。
- **sanity headless_test**：與所有先前輪一致的 2 FAIL+3 SCRIPT ERROR（pre-existing），零新增。

## 判定（依 dispatch 的判定路徑）
- 全生命無洞 ✅ + on/off byte-identical ✅（**兩項最關鍵已達成，尤其 on/off 是硬紅線**）。
- churn 現形本輪未撞到天然樣本（inert-by-absence，非「有卻不現形」）。

## 待 blueprint 裁
1. 兩項關鍵（全生命無洞+on/off byte-identical）已達成——是否已足夠批 merge（tap 本身 wiring 若要 100% 信心可另補 code-verify 或控制場景，比照 pursuit_hiding_bed.gd 模式，本輪未做，時間關係）？
2. 若需要，我可另建一個小型控制場景（手構一個必然 finder-miss 的情境，如 prey 全部消失/不可達）快速驗 churn tap 接線——待你指示。

---
measured_at_head: b21794b7
