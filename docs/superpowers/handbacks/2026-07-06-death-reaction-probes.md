# Hand Back: 死因+反應+征服 winner 探針補強

branch `feat/probes` · 3 commits · 純 debug/probe，零行為變。

## 實作摘要

| 檔案 | 改動 |
|---|---|
| `resource_system.gd` | `_apply_famine_attrition`：`death.starve_minor`(+md)、`death.starve_anon`(+actually) |
| `npc_combat_system.gd` | 敗方結算真陣亡點 `death.combat_pop`(+loser_dead)；`_kill_named_npc` 單點 `death.combat_named` |
| `reaction_system.gd` | `_evaluate_person` winner → `reaction.<name>`；`P5_breed` → `reaction.breed`；N1_flee/N3_defect 離隊 → `death.defect_leave` |
| `faction_ai_system.gd` | `_on_team_extinct` 滅團分類 `extinct.starve/combat/other` |
| `warring_harness.gd` | `PROBE_KEYS` 擴收 winner funnel + 死因 + 反應（多為既有 bump 點，純擴收 subset） |

**與 plan 差異（1 處，蓄意）**：`death.combat_pop` 掛**真陣亡點**（`npc_combat:284` `kill_random(loser_dead)`）而非 plan 寫的 `_apply_casualties`。後者只 `wound_random`（傷非死），計進去會把「死因 pop 佔比」污染成傷亡量。真陣亡點才給藍圖要的 pop-loss-by-cause。

## ★ full-probe baseline 結果（8 seed × 6 月）交藍圖判

### 1. 死因 = 幾乎 100% 餓死（確認「死亡沒從餓→征服位移」）

| seed | attrition% | starve_anon | combat_pop | combat_named | defect_leave | extinct starve/combat/other |
|---|---|---|---|---|---|---|
| 1337 | 56.4 | 152 | 0 | 0 | 0 | 34/0/12 |
| 42 | 57.4 | 173 | 0 | 0 | 0 | 36/0/12 |
| 7 | 2.2 | 0 | 0 | 0 | 0 | 0/0/0 |
| 100 | 68.1 | 175 | 0 | 0 | 0 | 45/0/8 |
| 2024 | 0.5 | 0 | 0 | 0 | 0 | 0/0/0 |
| 555 | 68.4 | 184 | 0 | 0 | 0 | 35/0/8 |
| 88 | 65.4 | 180 | 0 | 0 | 0 | 39/0/6 |
| 314 | 60.9 | 160 | 0 | 0 | 0 | 43/0/4 |

- **pop 死亡 100% = 餓死 anon**。`combat_pop=0`、`combat_named=0`、`defect_leave=0` **全 seed**。
- **滅團 extinct.starve 碾壓**（34-45）、`extinct.combat=0` 全 seed、`extinct.other` 少數（4-12）。
- **征服/戰鬥致死 ≈ 0**。死亡潮 = 純餓死機制，與征服無關。
- `starve_minor=0` 全 seed = famine 先殺 minor 但隊 minor 池已空（見 §3：bed 全-far → reaction.breed 不跑 → 無新 minor 補充）。

### 2. 征服 winner funnel = 名實斷點（隊想征服但從不打）

| seed | conq.intent | winner_loot | winner_prosperity | winner_other | member_atk_eligible | member_atk_dispatch | combat_decisive |
|---|---|---|---|---|---|---|---|
| 1337 | 164 | 0 | 0 | 164 | 0 | 0 | 1 |
| 100 | 210 | 0 | 0 | 210 | 2232 | 185 | 3 |
| 555 | 592 | 0 | 0 | 592 | 1134 | 0 | 0 |
| 88 | 204 | 0 | 0 | 204 | 1083 | 15 | 1 |
| 314 | 1 | 0 | 0 | 1 | 474 | 5 | 0 |

- **winner 100% = "other"**（=建設/survival 等非攻擊非掠奪 option 勝出）。`winner_loot=0`、`winner_prosperity=0`、`winner_none=0` **全 seed**。
- `conq.prosperity_reached=0` **全 seed**（吻合先前 gen 圖）。
- `conq.declared` 數千次/seed，但 `member_atk_dispatch` 個位到百位、`win_absorbed=0` 全 seed。
- **征服純名義**：隊 argmax 出「征服意圖」，但引擎實選的 winner option 永遠不是 loot 也不是 attack → 征服從不執行成掠奪或攻擊。**藍圖要的「teams 真選 loot?」答案 = 否，兩者都不選。**

### 3. 反應在 warring bed 不可觀測（LOD 盲區，非 probe miss）

- `reaction.*` **全 0**：`seeded_warring_bed` 跑**全-far**（無 player → `_get_near_teams` 空），反應系統 **near-only**（`sim_runner:220 _step7_person_reactions` 只跑 near_teams，far 分支無此 step）。
- **probe 接線已證正確**（`force_full_hd` 1 seed 1 月）：`comply=65374`、`expand=12878`、`flee=2490`、`riot=426`、`breed=34`、`defect_leave=57`；`N3_defect/N4_shirk/N5_extort=0`（該 seed 未勝出，score 不敵 comply/expand）。
- **要量反應須 full-HD bed 或 player context**。warring bed 天生量不到反應/生育 → 也連帶 minor 池空 → starve_minor=0。

## 零行為變證

- seeded warring 逐點守恆：**49/8/1/381**（headless `seeded warring reproducible OK`）
- framework **PASS=7 DORMANT=0**
- 憲法 site-freeze 閘 **PASS（sites=31, removed=0）**
- dissolution 融合驗 **ALL PASS**：reaction / threat / prosperity / faction-dispatch

## 連動風險

- `sim_runner`：無改。反應 near-only 是既有 LOD 架構，本 arc 只揭示非引入。
- Probe：`Probe.enabled` 預設 false → 一般跑全 no-op，零 RNG 擾動。
- 無其他系統受影響。

## 待主 session 確認（建議後續，非本 task 範圍）

1. **征服名實斷點**（§2）= 最強訊號：隊大量宣告征服 intent，winner 永遠是 other、從不 loot/attack。藍圖 gen-direction 序① probe 已補；**序② readiness 調校方向 = 讓 winner 真落到 attack/loot**（現 readiness 太重→攻擊 util 壓不過建設，見 prosperity_dissolution `低readiness 攻擊util 0.130 < 建設`）。
2. **反應量測缺 bed**：若藍圖要多 seed 反應分布，需一個 `force_full_hd` warring bed 變體（perf 換觀測）。本 task 未建（超範圍），列 backlog。
3. **死因單一（純餓死）**：確認世界目前唯一致死機制 = 餓死；征服/戰鬥/叛離致死 ≈0。是否符合願景（大戲該有戰死/叛離）= 藍圖裁。
