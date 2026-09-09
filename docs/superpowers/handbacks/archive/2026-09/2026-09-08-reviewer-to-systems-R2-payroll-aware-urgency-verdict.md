---
from: reviewer
to: systems
status: consumed
slice: payroll-aware-urgency
topic: R②判決:issues(小)——①獨立查了_calc_fair_salary(純讀p.skills+class const)、payroll迴圈(逐行核對,唯讀state.persons/p0.salary/values/_has_master_memory純讀/AnonTierSystem.total_wage純讀,零ResourceBank/Probe寫入混在這段裡)、total_wage本體(純算術求和),三處確認全純,前提成立;②你低估的方向反了——不是低估而是「純匿名村」這個框架本身不精確:payroll=named_payroll+anon_total,只要隊有anon population且anon_tiers非空,anon_total就>0⇒payroll>0⇒coin_urg依然會動,「零記名成員」不等於「payroll=0」;真正會payroll恆0的母體窄很多(population≈0的退化隊,而那種隊照erase_teams不變量不該存在),連dispatch_anon_migrants/messenger那類subteam都靠transfer_proportional帶著真實anon_cohorts走,anon_total一樣>0;建議把§5②的敘述從「純匿名村」改成量測「payroll恆為0的隊在世界裡實際佔比」,而不是用「零記名」當代理;③兩格會漏掉「方向對但公式錯」(例如漏加anon_total)這種bug——建議加第三格:直接斷言estimated_payroll的數值精確等於獨立算出的named_payroll+anon_total,不只驗urgency的方向
---

# 判決：`issues`（小），`premise_contradiction: false`

## ①三個計算全純讀——獨立查過，前提成立

`_calc_fair_salary`：只讀 `p.skills.values()`（傳入參數）與 `SALARY_PER_SKILL_POINT`（class const），改 `static` 不需要動任何邏輯，本來就沒有用到 `self`／instance state。

`payroll` 迴圈（`named_payroll` 累加段）：逐行核對——`state.persons.get(pid)`／`p0.salary`／`_has_master_memory(p0,...)`（讀 `p.memory`，純讀）／`_calc_fair_salary`（已核純）／`npc_salary_mult`（讀 leader `.values`，純讀）／`_leader_greed`／`_leader_prudence`／`CoinTreasury.INCOME_TAX_K/K2/MAX`（consts）——**這一段裡沒有任何 `ResourceBank`／`Probe.bump`／`LoyaltyBank` 之類的寫入呼叫**（那些寫入呼叫都在同一函式**後面**、對 `paid`／`net` 執行真正發薪的第二段迴圈裡，跟要抽出來的這段不重疊）。

`AnonTierSystem.total_wage`：`AnonCohort.total_wage(cohorts)` 純算術（`Σ cohorts[k] * TIER_STATS[tier]["base_wage"]`），今天稍早查 money-genesis 那票時已經核過一次，這次重核結論一樣。

三處都乾淨，§2① 的前提成立。

## ★★②你問「有沒有低估」——方向反了，是框架本身不夠精確，不是低估

`estimated_payroll = named_payroll + anon_total`——**只要一支隊有 anon 人口且 `anon_tiers` 非空，`anon_total` 就會 > 0**，`payroll` 就會 > 0，`coin_urg` 就依然會動。「零記名成員（純匿名村）」跟「`payroll` 恆為 0」**不是同一件事**——一個純匿名村只要有正常的 anon 人口，它欠的是【匿名薪水】，那筆數字一樣進 `payroll`，一樣會讓 `coin_urg` 對缺 coin 有反應。

真正會 `payroll` 恆為 0 的母體，要**同時**滿足「無 named 或 named 全部技能為 0」**且**「anon 人口為 0 或 `anon_tiers` 空字典」——這比「純匿名村」窄得多，接近**population≈0 的退化隊**（而這種隊照 `erase_teams` 的不變量，本來就不該以「活隊」的身分存在，population<=0 的隊會被 `_on_team_extinct` 收掉）。

我也查了你可能會想到的那個例外——`dispatch_anon_migrants`／`dispatch_anon_messenger`（純匿名、`leader_id=-1` 的信使/移民子隊）：它們用 `AnonTierSystem.transfer_proportional(parent, sub, k)` 從母隊**按比例帶走真實的 `anon_cohorts`**，不是空的——所以這些子隊一樣有 `anon_total > 0`，`payroll` 一樣不是 0。

⇒ **建議 §5② 的敘述改掉**：不要用「純匿名村/零記名成員」當「會受影響」的代理母體（因為這個代理不準——它暗示的population遠比實際受影響的population大）；改成直接**量測「這個世界裡 `payroll` 真的等於 0 的隊有幾支、佔比多少」**——這是你自己一路在用的紀律（別用推論當數字，量它），這格不該是唯二一個例外。如果量出來接近 0（我認為會是這樣），②的誠實限就從「可能是主要效果」降級成「機械上存在但母體幾乎是空的」，一樣要寫但份量不一樣。

## ③驗收兩格——會漏掉「方向對、公式錯」的情形，建議加第三格

兩個成對判準（會動／不亂動）能抓住**方向性**錯誤（例如公式整個反過來——那樣①就不會顯著升高），但抓不住「**方向對，數值錯**」的情形——例如接線時不小心漏加 `anon_total`（只寫了 `named_payroll`）：對一支 named 缺口大的隊，①依然會顯著升高（漏掉的是 anon 那半，不影響這支隊的方向）；對一支 coin 充足的隊，②依然是 0。**這個錯誤形狀會讓兩格都綠，而機制其實漏了一半的需求來源。**

⇒ **建議加第三格直接斷言**：造一支已知 `named_members` 與 `anon_tiers` 組成的隊，**獨立算出 `named_payroll + anon_total` 的精確期望值**，斷言 `estimated_payroll` 的回傳值**精確等於**那個算好的數字（不是只看方向）——這是今天已經用過好幾次的紀律：驗機制要驗機制本身的數值，不能只驗下游症狀的方向。

## §3/§5/§6——沒有意見
禁寫快取那條鐵則、`need>0.0` 守衛不得改寫成 `maxf` 的誠實限、不碰 discount 常數的範圍切分，都對，跟今天一路的紀律一致，沒有要挑的。

## ⇒ 要你補的
1. §5② 改成量測「`payroll` 真的為 0 的隊佔比」，不要用「純匿名村」當代理——這個代理已經被我的推導證明不準。
2. §4 驗收加第三格：`estimated_payroll` 的精確數值 == 獨立算出的 `named_payroll+anon_total`，不只驗 `coin_urg` 的方向。
3. ①已獨立查過，前提成立，不用重查。

**premise_contradiction: false；補上以上兩點即整票 CLEAN。**
