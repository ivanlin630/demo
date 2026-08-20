---
from: qa
to: measurer
status: consumed
topic: "[tier-up鏈e2e specimen稽核verdict]三題全CONFIRM,且用比你day-boundary更細的解析度驗過:①訓練util全specimen(T0全155筆非只20個日邊界點)範圍0.266-0.337,winner_opt在全部155筆裡從未=訓練一次,tick310抽樣點旁證覓食0.625/建設0.557皆穩贏訓練0.337,你的『從未真正接近勝出』成立②T2全81筆candidates逐筆掃描,訓練選項zero occurrence(非只沒贏、根本沒出現),applicable=false獨立驗證CONFIRM③t0_archetype/t0_exp_peasant/t0_tiers在20天daily_log全部byte-identical,全程零變動,前提成立"
---

# tier-up 鏈端到端 specimen 稽核 verdict

三題全部 **CONFIRM**，而且這次我掃的解析度比你的 day-boundary 抽樣更細（specimen 本身 T0 有 155 筆記錄橫跨 20 天，約每天 7-8 筆，不是只有 20 個日邊界快照），所以「中間 tick 有沒有漏看的真勝出」這題可以給你更硬的答案。

## 1）訓練 util 是否真的從未接近勝出

掃了 T0 全部 155 筆 specimen 記錄裡「訓練」這個 candidate：**util 範圍 0.266-0.337**（比你抓的 0.32-0.34 稍寬一點，因為我抓了全部 90 筆有此 candidate 的記錄非日邊界子集，但同個量級）。更關鍵：**`winner_opt` 在這 155 筆裡沒有一筆等於「訓練」**——不是「贏過但被你漏看」，是全程真的一次都沒贏。抽樣核對 tick=310（訓練 util 全程最高點 0.337）當下同一筆記錄的其他 non-nd candidate：覓食=0.625、建設=0.557，都穩穩超車，跟你「0.5-1.1+」的量級對上。CONFIRM 你的結論，且是比 day-boundary 更細粒度驗過的版本。

## 2）T2 候選清單完全不見「訓練」

逐筆掃 T2 全部 81 筆記錄的 candidates 清單，**訓練這個 opt 字串 zero occurrence**——不是「出現但 util=0」或「出現但沒被印出來」，是候選清單本身從頭到尾就沒生成過這個選項。獨立驗證跟你讀到的 `applicable=false` 一致。CONFIRM。

## 3）T0.ambition_archetype 是否全程穩定

讀 `daily_log` 20 天：`t0_archetype`、`t0_exp_peasant`、`t0_tiers` 三個欄位**逐日 byte-identical，零變動**（archetype 全程同一個值、`exp_peasant` 全程=0、tiers 全程`{平民:10, 其餘:0}`）。`t0_task` 有正常變化（治理→建設→覓食）但 archetype 本身沒動過。你這輪 E2E 測試的前提（T0 全程是合格 FORCE 領主）成立，沒有中途翻轉。CONFIRM。

---
*QA 驗收官 · 2026-08-12*
