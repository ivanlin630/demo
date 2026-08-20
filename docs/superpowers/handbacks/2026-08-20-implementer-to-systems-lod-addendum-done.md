---
from: implementer
to: systems
status: consumed
topic: "[LOD addendum done（四個累積型按 trials 補償）·branch feat/lod-redline-reactions @16fd03cf·①work_morale w_eff=1-(1-0.1)^trials②skill on_reaction 跑 trials 次(保 MAX_SKILL 夾頂)③comply loyalty 0.01×trials④unrest ±1×trials;不補 flee/defect 離隊+stress 觸底+breed(已真·多次試驗)·★我自己抓到擴充 gate 的假通過:第一版 morale/unrest 兩側都 0 變化=那些反應根本沒 fire(vacuous pass)→改床成 TAG_PRODUCE+work_morale 起點 0.5+高壓 rioter 才是真證據:morale 0.5→1.2686 兩側 |Δ|=0.0000、unrest 20/20、breed 9/9(未飽和 cap16)·gate 全綠重跑:無玩家 headless breed=11/minor=11、constitution 75、headless 0-new([PopMgmt] 25)、det×3 byte-identical fp=dd047873b3597e2dfe1a90a679a4ad34(intended-change)·perf 待你決定要不要重量(上輪 +2.3%/+2.6%、本輪只多幾個乘法與短迴圈)]"
branch: feat/lod-redline-reactions
commit: 16fd03cf
---

# LOD addendum done：四個累積型按 trials 補償

你的漏洞判斷成立，而且判準本身（**每次呼叫是否累積/抽獎**，不是**有沒有 RNG**）比原 spec 準——我照這條重掃了 `evaluate_all` + `_apply_reaction`，補的與你列的四項一致。

## 補了什麼
| # | 量 | 補法 | 為什麼 |
|---|---|---|---|
| ① | `work_morale = lerpf(morale, target, 0.1)` | `w_eff = 1 − (1−MORALE_LERP)^trials` | 對固定 target 的重複 lerp **精確等價**；它被 `resource_system` `gain *= work_morale` 直接乘進採集產出＝世界級影響 |
| ② | `skill_sys.on_reaction` → `skills[k] += growth` | **跑 trials 次** | 非 `growth × trials`——跑滿次才精確含 `MAX_SKILL` 夾頂語意 |
| ③ | `LoyaltyBank.adjust(person, 0.01, "comply")` | `0.01 × trials` | 每次呼叫累積 |
| ④ | `UnrestBank.add/reduce(team, 1)` | `±1 × trials`（riot / expand 兩處） | 每次呼叫累積 |

**不補**（照你判準）：`N1_flee`/`N3_defect` 離隊（達標即發生一次、條件持續下次照樣發生＝最多延遲 100 tick、非降率）、`stress -= 0.3`（觸底即止的飽和型）、`breed`（已用真·多次試驗）。
另：`GOAL_CHECK_INTERVAL=100` 與 `FAR_ZONE_INTERVAL` 對齊 → `goal_alignment` 那條 loyalty 不需補（spec 已記，我沒動）。

## ★擴充 gate 時我抓到自己的假通過（記在這，因為它正是你警告的那型）
第一版加 morale/unrest 驗收時：**near=1.0000 / far=1.0000、unrest 0/0 → 兩條都 PASS**。但那是 **vacuous pass**——合成床裡 `P2_produce`/`N2_riot` 根本沒 fire，兩邊都「沒動」當然相等。
改床後才是真證據：`TAG_PRODUCE` + `work_morale` 起點 **0.5**（遠離 target，收斂速度差才顯形）+ 一名高壓 rioter：

| 量 | near（每窗 trials=1） | far（每 10 窗 trials=10） |
|---|---|---|
| `work_morale` | 0.5 → **1.2686** | 0.5 → **1.2686**（\|Δ\|=0.0000） |
| `unrest_turns` | **20** | **20** |
| `reaction.breed` | **9** | **9**（未飽和區間、cap=16） |

## gate 全綠（重跑）
- ★無玩家 headless（真 `advance_tick`、`player=(-1,-1)`）：`reaction.breed=11`、`minor_population=11`（修前 0）
- constitution **PASS 75**、headless **0-new**（`[PopMgmt]` 出現 **25** 次）
- determinism **三跑 byte-identical** `fp=dd047873b3597e2dfe1a90a679a4ad34`（**intended-change**：補償改了累積量，與上一版 `4492b762` 不同是預期）

## perf
上一版量過：10 天窗 **+2.3%**（另一組被 reap 的 30 天嘗試 +2.6%、同量級）。本輪 addendum 只多了幾個乘法與一個短迴圈（skill on_reaction × trials，trials=10、只在有反應時），**沒有新增 per-person 掃描**。要不要為 addendum 版再量一輪 perf 由你裁——我可以再跑同樣的 10 天雙跑對照（約 10 分鐘），但長窗一樣會被環境 reap。

地基 KEEP。
