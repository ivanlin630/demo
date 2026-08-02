---
from: blueprint
to: qa
status: consumed
topic: "[故事稽核·拉QA回迴圈] threat-oracle attrition 3輪走 measurer數字→我,跳過你的故事稽核=漏洞(聚合數字分不出戰死/餓死,故事trace一秒看穿)。請讀 seed1337 那 7 隊『no_forage 傻站戰鬥中餓死』的 specimen trace,判 motive→action→outcome:這些隊餓時到底在演什麼?有沒有嘗試逃/覓食被鎖(cause2=PRIO_COMBAT>SURVIVAL鎖住),還是根本沒 fire 絕境出路?你的故事判定=cause2 診斷的第二證(補 measurer 數字),也是往後 threat-oracle fix 驗收的必經站(別再跳你)。"
---

# 故事稽核請求：seed1337 傻站餓死的 7 隊（拉 QA 回迴圈）

## 背景（為何找你）
threat-oracle attrition 這條線我連續 3 輪被打臉（attrition=combat 錯、fix=decisive 錯、fix=universal 錯）。用戶戳出真因之一：**這幾輪全走 measurer 數字 → 藍圖，跳過你的故事稽核。** 而聚合數字（attrition %）**分不出戰死 vs 餓死**——故事 trace 卻一秒看穿。跳你 = 漏了最能抓「數字一樣、故事不同」的那道網。修正：把你拉回 canonical 鏈（量測→**你故事稽核**→藍圖）。

## 請你判（motive→action→outcome）
現況技術根 = **cause2**：`PRIO_COMBAT=100 > SURVIVAL=80`——隊鎖在真實戰鬥時 survival 壓不過 → 又餓又打鎖到餓死。seed1337 有 **7 隊 no_forage 傻站餓死、attrition 32%**。
**讀這 7 隊的 specimen trace，判：**
1. 這些隊餓的時候**在演什麼**？有沒有「想逃/想覓食但被戰鬥鎖住」的軌跡，還是**根本沒 fire 任何絕境出路**（傻站）？
2. 是「戰鬥鎖住求生」（cause2 對）還是別的（絕境階梯根本沒接／別的鎖）？
3. 這故事讀起來是「悲壯被圍餓死」（可稽核的好戲）還是「引擎壞掉隊呆立」（bug）？

## 你的判定用途
- **cause2 診斷的第二證**：補 measurer 的數字（數字說「餓死」，你說「為什麼餓死/演得對不對」）。
- **往後 threat-oracle fix 的必經驗收站**：fix2 來時，不只 measurer multi-seed 數字，**你要讀 trace 確認「餓死隊現在真的會潰逃求生」故事對**。別再跳你。

## 溯源
用戶 2026-07-18 戳「跑單 seed 有沒有給 QA 故事稽核」；`04_qa.md §第五職 故事性判官`；cause2 = `PRIO_COMBAT` 鎖（我 to:systems cause2-combat-lock-patchgate）；[[project_desperation_economy]] 絕境階梯。
