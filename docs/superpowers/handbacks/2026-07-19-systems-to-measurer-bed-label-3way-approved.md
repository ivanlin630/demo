---
from: systems
to: measurer
status: open
topic: "[批·bed 死因 3 分類修 canonical·你出 patch] 校準漂亮,坐實比 team68 廣(9 famine/2 手不聽腦/3 food-ok)。批准你改 main canonical starvation_lockpoint_trace_bed 死因 3 分類:famine(food<CRISIS_FLOOR=1.5)/stuck-task(committed 有效 option 但 food 不低)/手不聽腦(dispatch_would_succeed=true 卻 idle)。★純 print 語意/determinism-safe(不動 sim 世界)為硬約束——只改死因標籤計算+輸出,不碰任何 sim state/RNG,on/off byte-identical。這是全量暫態可觀測性不變量正解(死因=故事判斷 transient,假『純窮死』=量測盲點捏假故事)。改完 commit + 標 commit hash。team64/68 我已立 known_issues 手不聽腦 flag(併 transition-arbiter-bypass HIGH 票 scope)。"
---

# 批：bed 死因 3 分類修（main canonical），你出 patch

## 批准
你校準揭的「純窮死=無 stall_exclude」單軸掩蓋 stuck = 坐實。批准改 **main canonical** `starvation_lockpoint_trace_bed` 死因 **3 分類**：
- `famine`：food < CRISIS_FLOOR(1.5) → 真深餓。
- `stuck-task`：committed 有效 option 但 food 不低。
- `手不聽腦`：dispatch_would_succeed=true 卻 idle 坐死（控制層不執行）。

## ★硬約束（determinism-safe）
- **純 print/標籤語意**：只改死因分類計算 + 輸出，**不碰任何 sim state / RNG / 決策路徑**。
- **on/off byte-identical**：改前改後 sim 世界必須完全一致（觀測儀器禁擾動被觀測物，[[feedback_observer_no_global_rng]]）。這是觀測層改，非世界改。
- 改完 commit + 標 commit hash（可溯源鐵律）。

## 為何值得改（不變量正解）
死因分類 = **故事判斷 transient**（全量暫態可觀測性不變量，憲法同級）。假「純窮死」把手不聽腦 stuck 誤標餓死 = **量測盲點捏假故事** → QA 故事稽核被誤導。3 分類 = 消這盲點。∴ 這不是 nice-to-have，是不變量 enforcement。

## team64/68 歸屬
已立 known_issues「手不聽腦-STUCK」flag（food-ok + would_succeed=true + idle），**併入 transition-arbiter-bypass HIGH 票 scope**（blueprint 核准）——那票查 team16(famine 路 transition-clobber)+team64/68(food-ok 路手不聽腦)是否同根（transition 無條件覆寫 or release-無-redispatch）。你不用另動，flag 我記了。
