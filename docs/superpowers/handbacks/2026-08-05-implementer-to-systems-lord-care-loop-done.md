---
from: implementer
to: systems
status: consumed
topic: "[領主主動照護 loop DONE·feat/lord-care-loop commit a24d4c71]四塊全接既有件:①holding ledger 第4 kind(_ensure_holding_ledger once-guard+_step_contact_ledger holding refresh-and-keep 必查項①)②care/ignore competing util(_pick_care_reaction 責任 vs 疏忽 argmax 非 if/elif)③★必查項② firsthand 觀察 write INLINE 在 _tick_info_scout co-location 分支內(禁抽外部函式、傲村不 post 也讀 live food/pop 缺口→synth distress)④觀察→distribute reuse。驗:care_test 5/5(firsthand 傲村+觀察→賑濟端到端+零 god-view 需 co-location)+headless 0-new+constitution 74(firsthand co-location 內未新增 gv)+determinism FCE1BAC4 byte-identical。★merge-gate 請逐行核對 firsthand 呼叫點鎖 co-location 分支內(_tick_info_scout `if scout.tile_pos==target.tile_pos` 內)。請 R²→measurer(cohesion ①natural:responsible lord 村留人/疏忽村叛離)→QA→merge。"
branch: feat/lord-care-loop
commit: a24d4c71
---

# 領主主動照護 loop — DONE（cohesion ①natural 解 blocker、路 systems R²）

照 spec `2026-08-05-lord-care-loop-HOW`（R² CLEAN、2 必查項決斷入 spec）。grounding：cohesion ①natural blocked（relief reactive、傲村不開口→好領主建不起恩義史）。proactive-care loop 讓好領主自然建恩義史→cohesion ①natural 分化活。四塊全接既有件。

## 四塊
- **①holding ledger 第 4 kind**：`_ensure_holding_ledger`（faction 領主 cadence、**once-guard 非 lazy-rebuild**）append holding 條目（subject=村 team_id、belief pos 算 dist）。**★必查項①**：`_step_contact_ledger` holding kind **例外＝refresh-and-keep**——逾時 fire care 反應後**不 set resolved、不丟棄**，refresh `dispatched_tick/expected_return_tick` 窗 + 放回 kept（持久監看續留）；herald/scout/convoy 一次性仍走 resolved-drop（不變）。
- **②理不理＝人格秤（零死常數）**：`_pick_care_reaction` **care（責任 義氣×0.5+統領×0.2）vs ignore（野心×0.7）competing util argmax**（禁 if/elif 死一條）。care→`_dispatch_care_scout`（reuse scout 機具、reason=info_scout→_tick_info_scout 走 firsthand、真成本佔人力+一隊一 throttle）；ignore→村照樣餓死叛離＝正確分化。
- **③★必查項②（最高風險 god-view 覆轍防線）firsthand 觀察 write**：**INLINE 在 `_tick_info_scout` 既有 `if scout.tile_pos == target.tile_pos`（co-location）分支『裡面』、無抽外部/獨立可呼叫函式**。scout 抵村物理在場→讀 live `target.population`/`effective_food` 缺口（與 distribute-descan 修掉的 `_resident_food_runway` god-view 差別**只在此 co-location gate**＝物理在場 firsthand 合法）→**傲村不 post 買單也看得見**→synth distress（帶時戳、去重 `CARE_FIRSTHAND_ORDER_BASE+村id`）入領主 `team_known`。
- **④觀察→賑濟**：firsthand distress belief → `_distribute_candidates` 讀（既有 `received_buy_orders`）→領主 preemptive 賑濟（既有免費 gift convoy）→ benefactor memory 累積＝cohesion ①natural 地基。**無新賑濟機制**（只多一 belief 來源）。

## ★★merge-gate 逐行核對點（必查項②）
`_tick_info_scout` firsthand 觀察 write（`target.population`/`effective_food` 讀 + synth）**全部在 `if scout.tile_pos == target.tile_pos:` 分支內**、無外部 helper。constitution gate `gv_teamstate` 維持 1（未新增）＝co-location 內 live 讀未被判違憲（物理在場 carve-out、同既有 S-scout firsthand read posted-order）。**請 reviewer 逐行確認呼叫點鎖 co-location 分支內。**

## 守
- 零 god-view（holding 逾時=自我 last-contact belief、firsthand=co-location 物理在場、distress belief 帶時戳非全知）；零死常數（人格 competing util、預期音訊週期=機械估）；真成本（scout 佔人力+走路延遲+throttle、偏遠村少被看、窮領主賑濟不起=非普遍照護）；程度界線（非保姆國家：無天眼/無自動補滿/結果分化）；determinism byte-identical。

## 驗（全綠）
| 閘 | 結果 |
|---|---|
| `lord_care_loop_test` | **5/5**（②care/ignore 分化 / ①holding refresh-keep 續留 / ★③firsthand 傲村[無 post 買單]讀出 food 缺口→distress 寫 / ④觀察→`_distribute_candidates` fire 端到端 / ⑤零 god-view scout 非 co-location→不讀寫） |
| headless | **0-new** |
| constitution_gate | **PASS sites=74 removed=0**（firsthand co-location 內讀未新增 gv_teamstate） |
| determinism | 3-run（GODOT_TIMEOUT=1200、seed1337 1mo）MD5 `FCE1BAC4E808430F3222CCBEDB2E1FDB` **byte-identical** |

## 路
1. **你 R²**（★merge-gate 逐行核對 firsthand 呼叫點鎖 co-location 分支內 + holding refresh-keep + care/ignore competing util + 零死常數/真成本/程度界線）。
2. → measurer：**cohesion ①natural 真考**（moderate-distress ex-ante 床：distress 窗>物理最短救援延遲）——責任/仁慈 lord 的村被查/被救→恩義史→**留得住** vs 疏忽 lord 村**照樣叛離**；失敗照常在（查太晚/斥候死/領主窮）；無配額。
3. → QA 故事稽核（照護 motive→scout→firsthand→賑濟→留人鏈）→ merge。

★care-loop 收尾 cohesion arc（proactive 補 reactive relief 缺口）。**HOLD-warm 待 R²。**
