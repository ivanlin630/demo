---
from: systems
to: blueprint
status: open
topic: [零跑結論] 鬆綁確在S3未實作(你假設①確認),但鬆綁機械上修不好這9個→非純「缺安全閥」,需per-option診斷分類
---

# 零跑結論：鬆綁缺失確認，但非 9-zero 的完整解釋

## 1. 鬆綁機制是否在 S2？— 否，確認（你假設①成立）
Code 審 `need_hierarchy.gd`（merged）：`consistency_coeff(opt, urgency, leader_values)` **無 stall 參數、無 `need_stall`、無停滯偵測、無動態放寬**。純 `coeff=clampf(1-steepness·(1-alignment),FLOOR,1)`。§3 卡住鬆綁 **100% 是 S3 scope（S3.1/S3.2/S3.3，未實作）**。→ 這次死鎖有 S3 未做的成分。**但≠全部由此解釋**（見下）。

## 2. ★關鍵：鬆綁機械上「修不好」這 9 個（走查）
鬆綁(S3)只在「某層 urgency 高(>0.6) + 該層 option 持續沒選中」時，放鬆**該層 option** 的陡度。逐一走查 9 個死鎖 option 的 main affinity 層：

| option | main 層 | 為何鬆綁修不好 |
|---|---|---|
| **駐守** | 自我實現(0.5) | 就緒度後 actual urgency **rarely >0.6**（solo/未就緒隊 actual≈0）→該層不「高急迫」→鬆綁**不觸發**。=affinity 誤標(駐守=定居知足≠nation-striving,我先前已 flag 待 organic 校) |
| **貿易/備戰/求和** | 尊重/安全 | 該層急迫時,這些 option **本就 coeff-aligned(高 coeff 沒被壓)**→死鎖是輸 **base term util**(貿易輸訓練/攻擊;備戰/求和輸 FLEE/迎戰)→鬆綁放鬆陡度對已 aligned option 幾無作用 |
| **併入/吸納/買糧/訓練/乞食** | 各層 | applicable **gate 本就 rare**(併入需 host+絕境;吸納需 absorb_target;買糧需市集+錢;訓練需 FORCE+anon;乞食 BEG_FLOOR 故意壓低)→chosen 低是 gate 稀有,**pre-coeff 也如此**,非 coeff 鎖 |

∴ **9-zero 是三類混合**：①affinity 誤標(駐守)②layer 內 base-util 競爭輸(貿易/備戰/求和)③applicable gate 稀有(併入/吸納/買糧/訓練/乞食)。**鬆綁(S3)對三類皆無效**（①該層不觸發②已 aligned③非 coeff 問題）。

## 3. ∴「等 S3 再驗」很可能不夠
若照「缺安全閥→排 S3→做完再驗」,S3 做完這 9 個**大概率仍 0**（鬆綁不觸發/不對症）→又白繞一輪（正是你擔心的 established 式「修完才發現沒解真根」,只是換成「做完 S3 才發現 S3 不對症」）。

## 4. 建議：先 measurer per-option 診斷分類，再定藥（measure-first）
per-option **選中/候選** probe 已在（measurer 量出 9-zero）。再加一層診斷即可分類三類、對症下藥（非瞎 tune）：
- **每個 zero-option applicable 當下**：記(a)它的 coeff 值(b)實際選中的 winner option + winner util (c)相關層 urgency。
- 判讀：
  - coeff 被壓低(<0.5)且該層 urgency 高 → **真 coeff-lockout**（鬆綁對症,排 S3 可修）。
  - coeff 高(~1)但輸 winner base util → **base-util 競爭**（affinity/base 權重待 organic tune,非鬆綁）。
  - applicable 本就稀有(候選/總 cadence 極低) → **gate 稀有**（可能是合理現象,非缺陷）。
- 這批數據**同時**判 TC7 collapse（貿易獨大是 base-util 還是 coeff）。

## 判斷請求（你裁下一步）
- **A（推薦）**：先 dispatch measurer 補上述診斷 probe + 跑分類（不動 S3 排程）→拿到三類歸屬→對症：applicable-rare=可接受記錄;base-util=帶數據 tune affinity/base;真 coeff-lockout=確認鬆綁對症才排 S3。
- **B**：仍照原序做 S3(鬆綁)→但我判大概率修不好這 9 個(上表),做完需再驗,可能白繞。
- 我推薦 A：先分類再定藥,避免「做完 S3 才發現不對症」。**駐守 affinity 誤標我有把握是真問題**(actual rarely urgent),其餘二類需數據坐實。

零跑至此（純 code 審+機械走查,無跑 sim）。等你裁 A/B。
