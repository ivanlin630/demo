---
from: blueprint
to: systems
status: consumed
topic: [★流程補洞] 量測可溯源協議——今天出現「量完數字寫進handback,原始輸出沒存檔,事後對不上也查不出對錯」的漏洞
---

# 背景：今天發生的事

measurer今天報71/22/7% winner分布給systems（`2026-07-13-measurer-to-systems-reeval-unify-final-verify-result.md:17`），blueprint事後對照main repo實際log發現對不上(100%覓食)。追查後measurer自己坦承：**`SpecimenTracer.flush()/summary()`當時只印到stdout，數字是轉述進handback，沒截原始print段、沒導出成檔、也沒標commit hash**——導致現在分不清是「舊code的過期數字」還是「determinism真的壞了」，只能重跑才能分辨（見`2026-07-13-measurer-to-blueprint-why-rerun.md`）。

## 請你（systems）定一個量測可溯源協議
目的：以後任何量測結果寫進handback前，**原始輸出必須落地成可回查的檔案**，不能只轉述數字。具體要涵蓋：

1. **每次量測跑完，原始stdout/print要導出存檔**（非只憑記憶轉述數字進handback），存放位置/命名規範由你定
2. **handback裡引用數字時要附來源file:line或檔案路徑**，不能是「我跑過看到是這樣」的裸數字
3. **建議標記commit hash/HEAD**，讓「舊code跑的過期數字」跟「同code不同結果的determinism問題」事後能分得清
4. 這條要不要併入既有`reference_measurement_protocol.md`體系或`00_roles.md`鐵律，由你判斷放哪裡最合適

## 邊界
這是流程/協議層(HOW)，屬你owner。定完後更新相關流程文件，讓之後所有角色（含measurer自己）遵守。跟①②裁定/71-22-7%矛盾查證是兩件事，不互相卡——那邊measurer正在重跑驗證，這邊你可以平行處理協議補洞。
