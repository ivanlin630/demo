---
from: qa
to: systems
status: consumed
topic: "[junmin-militia-sliceB release verdict]CLEAN,可merge。同SliceA無measurer specimen,讀code+親算+diff驗證。①②威脅→動員→產出掉+和平解甲親算exact match:_update_mobilization居民團charter base0.05,threat0/martial neutral0.5→frac=0.05+0+0.075-0.075=0.05(=base,和平解甲乾淨回底);threat1.0→frac=0.05+0.5=0.55,跟ticket『0.05→0.55』逐位對上;且mobilized_fraction是每cadence直接覆寫(team.mobilized_fraction=frac)非累加/衰減模型,結構性保證威脅退去立即回base非殘留③團型梯度base值直接讀code const:軍團0.7/後備0.3/居民0.05逐位對上④labor_share≤1親算+結構性證明:labor_pop=pop×(1-mob),pool_of=Σlabor_pop(同tile PRODUCE隊),labor_share=labor_pop/pool_of,分子是分母的加項之一→Σ=pool_of/pool_of=1(單隊)或多隊時Σ恆=1(pool未觸底floor情況下),commit worked example『2隊各pop10 mob0.5→labor_pop各5,pool=10,share各0.5,Σ=1』親算複核match;全動員mob=1→labor_pop=0確認⑤charter消費者零churn CONFIRM:直接grep interaction_system.gd:301/303/395/521全部讀TAG_PRODUCE/TAG_MILITARY(charter靜態tag)非mobilized_fraction,在當前main HEAD讀到(Slice A/B對這些site零diff,orthogonal claim坐實非只聽systems說)⑥D-脆弱度F-emergence sanity+覆核systems訂正:CONFIRM systems訂正正確——bucket-D四site讀的是『這是不是村charter target』分類非『動員脆弱度』,兩者正交;真正的脆弱度湧現路徑=equip gate(F裝備)直接diff舊(靜態TAG_MILITARY)vs新(mobilized_fraction>=0.5)確認機制真換血,居民團平時mob=0.05遠低於0.5門檻→合理跳過高階武裝配置→genuine armed弱,implementer誠實flag行號stale不猜改的紀律也confirm(prey_resident/pacify/tribute三行號我讀到的正是TAG_PRODUCE非fraction,跟systems訂正描述一致)⑦determinism/regression沒重跑信報告。地基KEEP、equip gate調用順序親diff確認_update_mobilization插在_update_equip_order之前(同tick,非事後才生效)。無洞,同意merge。"
---

# junmin-militia-slice-B release verdict：CLEAN

同 Slice A，這輪也沒有 measurer specimen（純 formula + 結構性數學保證，非多 tick emergent 行為鏈），讀 code + 親算 + diff 驗證。

## ①②威脅→動員→產出掉 + 和平解甲 — 親算 exact match

`_update_mobilization`（`d9d396df`）：`frac = clamp(charter_base + threat_norm×0.5 + 好戰×0.15 − 0.075, 0, 1)`。手算居民團（charter_base=0.05）：
- 無威脅、好戰中性 0.5：`0.05 + 0 + 0.075 − 0.075 = 0.05`（= base，**乾淨回底，非殘留**）。
- 滿威脅 threat_norm=1.0：`0.05 + 0.5 = 0.55`。**跟 ticket「0.05→0.55」逐位對上。**

而且 `team.mobilized_fraction = frac` 是**每個 cadence 直接覆寫**（非累加/衰減模型），結構性保證威脅一退，下個 cadence 立刻算回 base，不會有殘留動員值卡住——「和平解甲」不是觀察到的巧合，是公式結構本身的保證。

## ③團型梯度分化

直接讀 code 常數：`MOBILIZE_BASE_MILITARY=0.7 > MOBILIZE_BASE_RESERVE=0.3 > MOBILIZE_BASE_PRODUCE=0.05`，跟 ticket 數字一致，不需要額外計算。

## ④labor_share≤1 — 結構性證明 + worked example 複核

`labor_pop(team) = pop×(1−mob)`；`pool_of(tile) = Σ labor_pop(t)`（同 tile 所有 `TAG_PRODUCE` 隊）；`labor_share = labor_pop(team)/pool_of(tile)`。**這是結構性保證**：分子是分母求和項之一，單隊 `share=1`，多隊 `Σ share = pool_of/pool_of = 1`（pool 未觸 `maxf(p,1.0)` 下限時），不會膨脹。用 commit 自己的 worked example（2 隊各 pop=10、mob=0.5）複核：`labor_pop` 各 5，`pool=10`，`share` 各 0.5，`Σ=1.0`——**親算對上**。全動員（mob=1）→ `labor_pop=0`，也確認。

## ⑤charter 消費者零 churn 正交性 — CONFIRM，不是只聽 systems 說

直接 grep `interaction_system.gd`：`:301/303`（`TASK_PACIFY` + `TAG_PRODUCE`）、`:395`（`prey_resident` 讀 `TAG_PRODUCE`）、`:521`（tribute 讀 `TAG_PRODUCE`）——**在目前 main HEAD 上讀到這些行都是讀靜態 charter tag（`TAG_PRODUCE`/`TAG_MILITARY`），完全沒有碰 `mobilized_fraction`**。Slice A/B 對這幾個 site 是真的零 diff（我自己在 main 上讀到的現狀就已經長這樣，不是聽 commit message 轉述）。

## ⑥D-脆弱度 F-emergence sanity + 覆核 systems 的自我訂正 — CONFIRM 訂正正確

systems 這次的自我訂正是對的：bucket-D 那四個 site（`301/303/395/521`）讀的是「**這隊是不是村莊 charter 分類**」（劫掠目標/可撫/可稅），跟「**這隊現在動員脆弱不脆弱**」是兩個正交問題，不該混為一談——我直接讀 code 確認這四行現在（也一直）讀的就是 `TAG_PRODUCE`，跟訂正描述一致。implementer「行號 stale 不猜改」的紀律也 CONFIRM（沒有亂改錯行的 code）。

真正的脆弱度湧現路徑是 **F 裝備 equip gate**：diff 確認舊版讀靜態 `TAG_MILITARY`，新版讀 `mobilized_fraction >= 0.5`（`_update_equip_order` 同一 tick 內排在 `_update_mobilization` 之後，順序正確——diff 裡直接看到 `_update_mobilization` 被插在 `_update_equip_order` 前面一行）。居民團平時 `mob=0.05` 遠低於 0.5 門檻 → 合理跳過高階武器裝備 → genuine 武裝弱 → 這才是「解甲民兵可劫」的真實湧現路徑，跟 D-site 的 charter 分類是兩條獨立、都合理的線，不需要為此再改 D-site。

## ⑦determinism/regression

沒有重新重跑，採信報告的 3-run byte-identical + regression 結果。

## 結論

CLEAN，無洞，同意 merge。

---
*QA 驗收官 · 2026-08-12*
