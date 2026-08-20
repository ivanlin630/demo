---
from: reviewer
to: systems
status: consumed
topic: "[R②結構審判決=CLEAN+1必查項(必補caller清單,非邊界問題)] F2 treasury模組切HOW——①反向耦合:親讀5域函式完整body(faction_ai_system.gd:3175-3273 _extract_treasury/_extract_buffer/_consider_extraction/coin_need/_collect_member_tax)確認零一處呼grary/extinction或任何faction_ai-only helper,呼的全是已模組化外部(AnonTreasuryBank/ResourceBank/LoyaltyBank/UnrestBank/TradeValuation/NeedOracle/ResourceSystem/DecisionTerms)——邊界比spec自己保留的疑慮還乾淨,零反向耦合;②介面/caller:production 3路caller親grep逐字對得上(loop:835consider/loop:836tax/player_command:248/resource_system:177,coin_need零外部production caller)——但★發現spec §2.3的caller更新清單完全漏列scripts/debug/*.gd裡直接對FactionAISystem instance呼這5個域函式的~10處(extraction_need_driven_test.gd全篇/material_hold_test.gd:97,107/unified_commerce_test.gd:224,260/headless_test.gd:8521)——GDScript底線_prefix只是命名慣例非強制private,這些call今天能過純因函式還在faction_ai_system.gd上,函式一移走這些call全部變Invalid-call runtime錯,其中headless_test.gd:8521是直接埋在CLAUDE.md交付標準指定的headless entrypoint本體裡(★非透過player_command的:8537/13491那條已被spec涵蓋的路徑),若caller清單不補這條,build後極可能當場炸掉這個專案的deliverable-standard測試;③純code-move零邏輯改:親讀完整body確認無隱藏邏輯(coin_need的material/food雙need計算、_extract_buffer的prudence-lerp、_collect_member_tax的greed/prudence稅率clamp皆逐字對得上現況,搬移不動這些);④shared helper留原處:同①確認正確,ResourceBank.adjust_person_gold已模組化用法對;判決=CLEAN+1必查項(非邊界瑕疵不用re-scope,只是caller清單漏了debug/test這一類非production caller、屬於機械可列舉的補完)——要求§2.3明確列入這批debug/*.gd call site且改呼CoinTreasury.xxx(靜態呼、非新增公開介面,GDScript不強制private本就可直接呼coin_need/_extract_buffer)才能過F0 fp驗(否則headless entrypoint先炸,fp根本跑不到)"
---

# R②判決：F2 treasury 域模組切 HOW — CLEAN + 1必查項

## ①邊界乾淨否（反向耦合）— 比 spec 自己擔心的還乾淨
親讀5個域函式完整 body（`faction_ai_system.gd:3175-3273`：`_extract_treasury`/`_extract_buffer`/`_consider_extraction`/`coin_need`/`_collect_member_tax`）逐行確認——**零一處**呼叫 granary/extinction 或任何 faction_ai-only helper。實際呼叫的全是已模組化的外部：`AnonTreasuryBank.withdraw`、`ResourceBank.add`/`adjust_person_coin`、`LoyaltyBank.adjust`、`UnrestBank.add`、`TradeValuation.leader_vals`/`local_value`、`NeedOracle._construction_facility_need`、`ResourceSystem.effective_food`/`effective_holding`、`DecisionTerms.DESPERATION_DAYS`。**零反向耦合**，邊界比 spec §2④自己保留的疑慮（「若呼 granary/extinction→經 static 呼」這條 hedge）還乾淨——這條 hedge 目前用不到，不代表寫錯，是保險寫法，正確。

## ②介面/caller — production 對得上，但★漏一類 caller（必查項）
親 grep production 3 路 caller，逐字對得上 spec 聲稱：
- `_consider_extraction` ← `faction_ai_system.gd:835`（loop cadence，唯一）
- `_collect_member_tax` ← `faction_ai_system.gd:836`（loop cadence，唯一）
- `_extract_treasury` ← `resource_system.gd:177`（飢餓緊急）+ `player_command_system.gd:248`（玩家）+ 內部 `_consider_extraction:3237`
- `coin_need` ← 零 production 外部 caller，只內部 `_consider_extraction:3233` 用

**★但親 grep 全 `scripts/` 發現 spec §2.3 caller 更新清單完全漏列一類 caller**——`scripts/debug/*.gd` 裡直接對 `FactionAISystem` instance 呼這 5 個域函式的約 10 處：
- `extraction_need_driven_test.gd`（整篇 TDD，`fai._consider_extraction`/`fai.coin_need`/`fai._extract_buffer`/`fai._extract_treasury` 反覆用，這個 arc 自己的 de-patch 回歸床）
- `material_hold_test.gd:97,107`（`fai.coin_need`/`FactionAISystem.new()._consider_extraction`）
- `unified_commerce_test.gd:224,260`（`FactionAISystem.new()._collect_member_tax`）
- **`headless_test.gd:8521`**（`fai._extract_treasury(state, team, 0.3, "貪婪驅動")`）——★這條**直接埋在 CLAUDE.md 交付標準指定的 headless entrypoint 本體裡**，跟 `:8537`/`:13491` 那條透過 `pcs._action_extract_treasury`（spec §2.3 已涵蓋的 player_command 路徑）**不是同一條**，是獨立的直接域函式呼叫。

GDScript 底線 `_` prefix 只是命名慣例、非強制 private——這些呼叫今天能過純粹因為函式還掛在 `FactionAISystem` 上。函式一移到 `CoinTreasury`、`faction_ai_system.gd` 上這 5 個名字消失，這些 call site 全部變 **Invalid call**（runtime 找不到方法）。`headless_test.gd:8521` 這條若不補，build 完 headless 極可能當場炸掉——連 F0 fp byte-identical 驗證都跑不到（entrypoint 先崩潰），交付標準（無 GDScript 錯誤）直接破。

## ③純 code-move 零邏輯改 — 坐實
親讀完整 body 確認搬移前無隱藏邏輯改動空間：`coin_need` 的 material/food 雙 need 計算式、`_extract_buffer` 的 prudence-lerp（`EXTRACT_BUFFER_MIN~MAX`）、`_collect_member_tax` 的 greed/prudence 稅率 clamp（`MEMBER_TAX_K/K2/MIN/MAX`），逐字對得上現況——這些常數/公式搬到 `CoinTreasury` 應逐字帶過去，非重寫。

## ④shared helper 留原處 — 坐實
同①，`ResourceBank.adjust_person_coin` 已模組化用法正確，5 域函式無一處需要留在 `faction_ai_system.gd` 內部呼的 shared helper——目前這批函式對外部依賴全部已經是「跨模組呼叫」形態，搬移本身不會製造新的跨模組耦合。

## 判決
**CLEAN + 1必查項 → 鎖 → build。** 非邊界瑕疵，不用 re-scope（①③④皆坐實乾淨）——問題純粹是②的 caller 清單漏列一整類非-production caller（debug/test 直接呼域函式），屬於可機械列舉補完的缺口，非設計問題。**要求** §2.3 caller 更新清單明確加入上述 debug/*.gd 這批 call site，改呼 `CoinTreasury.xxx(...)`（靜態呼，非新增公開介面——GDScript 不強制 private，`coin_need`/`_extract_buffer` 搬去 `CoinTreasury` 後本就可直接被外部呼，不需要額外在 §2②的「3 entry」介面清單裡加名目，只是 call site 要跟著改路徑）。這條不補，headless entrypoint（`headless_test.gd:8521`）會先炸，F0 fp 驗證根本跑不到起點。
