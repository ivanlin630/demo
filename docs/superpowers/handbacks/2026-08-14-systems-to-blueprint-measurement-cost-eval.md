---
from: systems
to: blueprint
status: open
topic: "[量測協議優化評估(systems process/measurement-protocol owner 裁、非憲法):①②④採、③掛用戶排序·①fp-checkpoint-verify=ADOPT最大招:床每月存 StateFingerprint→measurer 重跑前驗 branch 前1-2月 fp 吻合=證 determinism→實作全程數據可信免全重跑(fp不合or決策關鍵才全跑);★理論 sound:determinism byte-identical 從 tick0、prefix fp-match ⟹ 全程 reproducible(RNG stream 同)、只要 observer-neutral(前綴 env/RNG 汙染抓、[[feedback_observer_no_global_rng]]三跑 byte-identical 已是既有驗)·成本 7h→幾十分鐘、獨立性保(measurer 獨立驗 fp 非盲信)·②default-full-dump=ADOPT:story-audit 床預設全 dump(aggregate+specimen strided observer-neutral+守恆)、免我這輪 specimen-omission 白燒;launch-checklist 補『長局 launch 前確認 specimen env / 後驗 stdout enabled』入 measurement-protocol·③checkpoint-resume(world save/load)=DEFER 用戶排序:高值但大 build(world serialize/deserialize byte-identical-critical)、且雙用途(day301 崩從 day280 續跑診斷 + 未來玩家存檔地基)=值得但排序用戶裁·④parallel-detached=ADOPT as-available:已可(godot-detach WMI 可多開)、多 seed/窗時直用免協議變·★落地:協議層(①驗流程/②checklist/④practice)我更 reference_measurement_protocol memory+process doc;床 code 改(①每月 fp checkpoint/②default specimen-on)=小 implementer slice(下輪或順手)·序:你認可 ①②④採+③掛用戶→我更協議 memory、床改排下輪·地基KEEP"
---

# 量測協議優化評估（systems owner 裁、非憲法）

## ① fp-checkpoint-verify = ★ADOPT（最大招）
床每月存 `StateFingerprint` → measurer 重跑前驗 branch 前 **1-2 月 fp 吻合** = 證 determinism → **實作全程數據可信、免全重跑**（fp 不合 or 決策關鍵才全跑）。
- ★**理論 sound**：determinism byte-identical 從 tick0、**prefix fp-match ⟹ 全程 reproducible**（RNG stream 同）；只要 observer-neutral（前綴 env/RNG 汙染抓、[[feedback_observer_no_global_rng]] 三跑 byte-identical 已是既有驗）。
- 成本 **7h→幾十分鐘**、獨立性保（measurer 獨立驗 fp、非盲信實作數字）。

## ② default-full-dump = ADOPT
- story-audit 床**預設全 dump**（aggregate + specimen strided observer-neutral + 守恆）→ 免我這輪 specimen-omission 白燒。
- **launch-checklist** 補「長局 launch 前確認 specimen env / 後驗 stdout `enabled`」入 measurement-protocol。

## ③ checkpoint-resume（world save/load）= DEFER 用戶排序
高值但**大 build**（world serialize/deserialize、byte-identical-critical）；且**雙用途**（day301 崩從 day280 快照續跑診斷 + 未來玩家存檔地基）= 值得但**排序用戶裁**。

## ④ parallel-detached = ADOPT as-available
已可（godot-detach WMI 可多開）；多 seed/窗時直用、免協議變。

## 落地
- **協議層**（① 驗流程 / ② checklist / ④ practice）：我更 `reference_measurement_protocol` memory + process doc。
- **床 code 改**（① 每月 fp checkpoint / ② default specimen-on）= 小 implementer slice（下輪或順手）。

序：你認可 ①②④ 採 + ③ 掛用戶 → 我更協議 memory、床改排下輪。地基 KEEP。
