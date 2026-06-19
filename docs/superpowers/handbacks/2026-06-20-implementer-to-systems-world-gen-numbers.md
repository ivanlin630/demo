---
from: implementer
to: systems
status: consumed
topic: world-gen 戲劇尾巴實作完成 — generate outlier 尾巴 + config 種子狂人 + 2 年 world_sim emergent 0→非零對照
plan: 2026-06-20-world-gen-dramatic-tail.md
branch: feat/world-gen-tail
---

# Hand Back: world-gen 戲劇性尾巴

## 實作摘要

- `scripts/simulation/person_generator.gd`：`generate` values 從均勻 [0.2,0.8] → 凡人窄帶 [0.35,0.65]；
  加 per-person outlier roll（member 0.18 / leader 0.45）命中 → 隨機 archetype（霸主/屠夫/謀士/懦夫）
  簇推連貫極端 trait（hi_v→[0.85,1.0]、lo_v→[0,0.15]）+ 高 skill 尾巴（hi_s→[0.5,0.9]）。
  全 const = TEST VALUE。只改生成值，不碰 state 流 / 守恆。
- `scripts/debug/headless_test.gd`：加 `_test_world_gen_dramatic_tail`（200 人分佈：有極端高/低 value、有高 skill、多數野心仍窄帶），註冊進 `_initialize`。
- `config/world_sim.json`：種 3 個極端 leader 讓量測重量立即見狂人——
  Team0 統領城→霸主（野心0.95/好戰0.85/統領0.8）、Team2 敵對軍隊→屠夫（殘忍0.9/好戰0.9/信義0.2/戰鬥0.7）、
  Team5 流亡狼軍→謀士（慎重0.85/計謀0.85/偵查0.75）。其餘隊 leader 不動（凡人對照）。只動既有 values/skills 鍵。

與 spec/plan 差異：無。三 Task 全照 plan。

## 驗收結果

### 分佈測試（headless）
`dramatic tail OK (normal=182/200)` — 200 個 member：182 野心落窄帶（凡人），~18 outlier 推極端。
有極端高 value、有極端低 value、有高 skill 尾巴，全斷言通過。

### 回歸守恆
- headless：SCRIPT ERROR 0、Assertion failed 0、`=== DONE ===`、coin_eq（投靠守恆整合 OK）、InvariantAudit population/faction/subteam 全 OK。
- 全綠，極端值不破守恆。

### world_sim 2 年重量（172800 tick / 24 月跑滿，0 SCRIPT ERROR，0 TIMEOUT）

逐鍵對照前次 2 年 baseline（`2026-06-20-systems-to-blueprint-2yr-measurement.md`，6 條魂全 0）：

| 訊號 | 2yr baseline | 戲劇尾巴 2yr | 判讀 |
|---|---|---|---|
| **g2.faction_found 立國** | **0** | **1** | ✅ 0→非零（狂人驅動立國冒出） |
| **g3.detect_裁決 識破** | **0** | **7** | ✅ 0→非零（高計謀謀士 → 識破裁決出現） |
| g3.detect_生疑 | 2 | 5 | 隨技能 spread 升 |
| g3.detect_信假 | 31 | 61 | scale |
| g2.ambition promote/demote | (動) | 37 / 29 | 階梯持續動 |
| g1.order_placed / shortage_buy | scale | 4206 / 3163 | 經濟持續發單 |
| g3.trust down/up | 5578/3228 | 6245 / 4988 | 仍爆量（pre-existing #4） |
| vendetta | 0 | 0 | ❌ 仍 0 |
| feud_formed | 0 | 0 | ❌ 仍 0（無 bump = 0） |
| scout_dispatch | 0 | 0 | ❌ 仍 0（scout 收斂率 n/a） |
| ambush 誘殺 | 0 | 0 | ❌ 仍 0 |
| mint 鑄幣 | 0 | 0 | ❌ 仍 0 |

**核心結論：#0（戲劇尾巴）確證為部分 root。** 前次 6 條魂全 0、跑再久不長出；種狂人後 **faction_found（立國）+ detect_裁決（識破）即刻 0→非零**，無新場景、純改人格生成值。藍圖「人人平庸 → 魂沒燃料」預測成立。

### 哪些魂仍 0（回報藍圖：可能要場景或門檻，非生成值能解）
- **feud_formed / vendetta**：血仇邊由戰鬥 looted/betrayal/extorted 記憶 populate。2 年有戰有立國有滅團，但 feud 邊仍恆 0 → 戰鬥結算未寫 feud 記憶，或門檻沒命中。vendetta 讀 feud → 連帶 0。**可能需血仇 populate 路徑檢查或預置血仇對場景**（呼應 spine-measurement #3）。
- **scout_dispatch / ambush**：G3d 查證/誘殺需「攻擊性 commit 不確定 + 偽裝弱目標」。謀士有高計謀但無「被偽裝低報 armed 的弱目標誘莽者」對局 → gate 沒被咬。**需偽裝誘殺對局場景**。
- **mint**：需 outpost + mint facility 經濟路徑，預設 config 無 → 0。**需鑄幣經濟場景**。

## 連動風險
- `world_generator` / 任何走 `PersonGenerator.generate` 的晉升路徑（`generate_for_team` anon→named）：現在晉升出的 named 也帶 0.18 outlier 機率 → 長期世界會持續冒新狂人（預期，維持尾巴）。非 bug，但行為較前激烈（更多脫軌/戰/裂）= 預期戲劇，留意平衡 feel。
- `config/world_sim.json` 與 `config/game_sim.json` 等其他 config 的 leader 值**未動**——只改 world_sim.json 量測台。若其他量測台也要狂人需另種。
- 既有測試無依賴 generate 中庸精確值者破裂（0 Assertion failed）。

## 待主 session（系統）確認
- **world_sim 不變量違反 2701 全為 pre-existing `known_reputations 含死 Team` 懸空噪**（2yr-measurement handback 已列為良性 audit 噪 / systematic-debug 待修）。本次無新增 coin_eq / cohort / faction-bidir 違反。狂人世界滅團更多（baseline ~2380 → 2701）→ 懸空噪同比增，同源非新 bug。**建議：known_reputations 死隊清理修並非本 plan 範圍，呈報系統排期。**
- **仍 0 的 4 條魂（feud/vendetta/scout/ambush/mint）呈報藍圖**：生成值已不是 blocker（立國/識破證明燃料夠），剩下是「血仇 populate 路徑」+「誘殺/鑄幣場景」問題（spine-measurement #3 場景待裁 + feud 寫入鏈檢查）。
- 全 outlier 機率/帶值 / config 極端值 = TEST VALUE，待正式平衡 pass 調。

## Commits
- `feat(world-gen): generate 戲劇尾巴(多數凡人+少數 archetype 狂人)`
- `feat(world-gen): world_sim.json 種子極端 leader(霸主/屠夫/謀士)`
- `docs(world-gen): 戲劇尾巴 world_sim 重量回報(emergent 0→非零)`
