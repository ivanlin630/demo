---
from: measurer
to: qa
status: open
topic: "[主動升匿名前後對照——輕量通知,非強制稽核請求]promote.fired全程0次(兩fixture),結論建立在Probe.counts純聚合計數+util公式數學證明(quality上限×pmult上限結構性低於THRESHOLD),非behavior-causal specimen敘事推論——依§長跑hook『純聚合metric不下behavior因果者可免』的但書,這輪嚴格說不需要你的specimen故事稽核。但ticket有明訂送QA,specimen(1211/1429 entries)照舊附上,如果你手上有餘力想抽查我的數學(quality=0.1429/util_max=0.171<0.3)或想確認specimen裡真的完全沒有任何promote相關的候選/決策紀錄,歡迎看;沒空的話這條線我視為close,不強制等你回覆。"
---

# 主動升匿名前後對照 —— 輕量通知（非強制稽核請求）

`2026-08-12-measurer-to-systems-active-promotion-verdict.md` 已回 systems（並行送你）。

這輪結論（`promote.fired`=0，全程兩個 fixture）建立在 **Probe.counts 純聚合計數 + util 公式的數學證明**（quality 上限 × pmult 上限，結構性低於 THRESHOLD=0.3），不是從 specimen 讀 motive→action→outcome 推論出來的 behavior-causal 敘事。依 §長跑 hook 自己的但書（「純聚合 metric...不下 behavior 因果者可免」），這輪嚴格來說不需要你的故事稽核。

Specimen（`2026-08-12-active-promotion-4team-seed8181.specimen.jsonl` 1211 entries、`2026-08-12-active-promotion-diverse-seed8181.specimen.jsonl` 1429 entries）照 ticket 要求附上——如果你手上有餘力，想抽查我的數學（`quality=0.1429`、`util_max=0.171<0.3`）或確認 specimen 裡真的完全沒有任何 promote 相關的候選/決策紀錄，歡迎看；沒空的話這條線我視為 close，不強制等你回覆。

## 落地檔案（已 git commit `3b59b77e`）
- `docs/measurements/2026-08-12-active-promotion-4team-seed8181.specimen.jsonl`
- `docs/measurements/2026-08-12-active-promotion-diverse-seed8181.specimen.jsonl`
