---
from: qa
to: systems
status: open
topic: "★★★k校驗判決:症狀(非genuine),兩個不同層的病疊在一起——①herb/gem/ore_gold/ore_iron/ore_steel五種資源在113205行specimen裡逐字0次出現(候選生成層完全缺席,但manufacturing_system.gd確認它們都有真實下游recipe),weapon_melee_low的上游ore_iron缺席可解釋(S2買路徑maintain_weapons:resource持續生成2070次⇒means-end從未被逼下探ore_iron),herb/gem/ore_gold缺席更深層原因沒查到②weapon_melee_low候選正常生成(2334次)但util系統性偏低(avg0.174 vs maintain_tools約1.0)0次贏過argmax——這不是finder_miss/try_set_noop家族(贏了沒執行),是根本沒贏過;★誠實限:material是warring_states/30日/49隊,不是原始0.1395那輪的peaceful_economy/90日/18隊,是跨world機制級佐證非直接復現;GATE-B同格嫌疑沒查(不是排除);verdict json已落地docs/process/verdicts/genesis-turnover-story-audit.measure.json,token genesis-k-calibration"
---

# k 校驗故事稽核判決 —— 症狀，兩層病因

## 判決：★症狀（非 genuine），交付檔已落地
`docs/process/verdicts/genesis-turnover-story-audit.measure.json`（token `genesis-k-calibration`）

## ★一句話結論
**低週轉不是「世界本來就這樣」——是決策層有兩個不同的病：一批資源連候選都沒生成過，另一批資源生成了候選但估值系統性輸給別的選項，從未贏過 argmax。**

## 發現一：五種資源（herb/gem/ore_gold/ore_iron/ore_steel）——候選生成層缺席
**113,205 行 specimen 逐字 grep，這五個資源名稱「0 次出現」**——不是沒贏，是連候選都沒被提議過，跨 14,975 個決策、49 隊。**而 `manufacturing_system.gd` 確認這五種資源都有真實下游 recipe**（herb→醫藥、gem→工藝品、ore_iron→ore_steel/weapon_melee_low/armor_low…）——不是世界裡真的沒用。

**weapon_melee_low 的上游 ore_iron 為何缺席，我讀出一個站得住的解釋**：`maintain_weapons:resource`（直接買）候選持續生成 2070 次，means-end 遞迴只在買/採路徑失敗時才會下探原料——買候選一直「有手段」，從未逼它去問「那我該去弄 ore_iron」。**herb/gem/ore_gold 缺席的更深層原因我沒查到**（連買候選觸發條件那段 code 都沒讀），這格老實標「查不到」。

## 發現二：weapon_melee_low——候選生成正常，估值層系統性輸
候選出現 2334 次，**但 `winner_opt` 統計裡 0 次真的贏過 argmax**。util 樣本 avg=0.174（min0/max0.61），同時期 `maintain_tools:resource`/`build_workshop:resource` 穩定在 0.96~1.10——**武器候選穩定輸給工具/工坊候選約 5~6 倍**。**這不是 finder_miss/try_set_noop 那個「贏了沒執行」的家族——這是從未贏過**。是 genuine（世界裡工具真的比武器值錢）還是估值公式結構性低估武器，我沒查那段 payoff 公式，這格留判不了。

## ★材料誠實限（很重要，判讀前先看）
**measurer 這輪產的 specimen 是 `warring_states`／30 日／49 隊，不是原始「0.1395」那個數字的 `peaceful_economy`／90 日／18 隊那一輪。** 我把這份材料當**跨 world 的機制級佐證**（同一套候選生成/估值機制在不同 config 都表現同型缺陷，比只在一個 world 出現更有力排除「這個 config 特有巧合」），**但不能宣稱這就是 0.1395 精確數字的成因分解**——若要精確解釋那個數字，需要同款配置的 specimen，本輪材料不夠格。

## ★沒查的（誠實列，不是排除）
- **GATE-B 同格嫌疑**：完全沒查（時間關係沒做 tile_pos 逐筆追蹤）——不是查了說沒有。
- **weapon_melee_low 估值公式**：沒讀 code，不知道 5~6 倍差距是設計常數還是公式錯。
- **herb/gem/ore_gold 候選觸發條件**：沒讀 goal_resolver 那段。

## 建議下一步（不裁決，供你/measurer/implementer 選）
①查 S2 買路徑對 herb/gem/ore_gold 的觸發條件，為何連買候選都不生成
②查 payoff 公式裡 maintain_weapons vs maintain_tools 的係數差異
③若要精確解釋 0.1395，需要 peaceful_economy/90日/18隊 同款 specimen

已讀完信+動工完成，consume。
