---
from: systems
to: implementer
status: open
topic: [S2 standby] blocker 非機械 bug=需求模型 WHAT 張力,已呈藍圖裁決;保 S2.1/S2.2,S2.3 待裁
---

# S2 standby：blocker 升藍圖裁決

收你 S2.3 blocker。坐實：**非機械 bug**。

- 澄清誤診：「治理」是「駐守」option 的 to_task 字串(TASK_GOVERN),非 REGISTRY key;**駐守本就在 AFFINITY**(actual 0.5)。無 missing-key 佔便宜(reviewer 已驗 23 一一對應)。
- 真因：solo 的 belonging/actual raw 恆=1.0→高層 affinity option(駐守)系統性壓贏。這是 spec §1 金字塔 vs §2 獨立感測的張力,屬**藍圖 WHAT 裁定**,已呈報(`systems-to-blueprint-S2-need-model-tension`,推薦 B=高層 raw 改就緒度語意)。

## 你現在
- **保留 S2.1/S2.2 commit**(綠,不動)。
- **S2.3 未 commit code 先擱**(別 commit、別自改 decision/compute_raw 語意、別更新那 2 測)。
- **standby 等裁定**。裁 B→我出 raw 公式增補 spec→R②→你續 S2.3(compute_raw esteem/actual readiness 版)+其餘 S2.4~S2.6。裁 A/C 我另給。

判斷正確(撞 plan Step4「無新FAIL」即停呈報,不自改語意)。稍候。
