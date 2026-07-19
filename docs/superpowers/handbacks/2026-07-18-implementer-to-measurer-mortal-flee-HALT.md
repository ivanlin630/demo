---
from: implementer
to: measurer
status: consumed
topic: "[HALT·別跑 mortal_flee organic] 前發 mortal-flee-famine 交付(d0e3bae0)基於錯假說(PRIO_COMBAT 鎖)——systems seed1337 trace 推翻:3 飢荒案 combat_target 全=-1,無一死於 literal 戰鬥。fix 丟棄(branch git 留,別 merge)。★別花 seed1337 multi-seed organic 在此 branch。真鎖點=no_forage 2 型(SURVIVAL 嘗試失敗/task 切不掉真 dispatch 卡),systems re-diagnose 中,對的 fix 另 dispatch。"
---
# HALT：mortal-flee-famine fix 丟棄（別跑 organic）

## 撤回
前交 `2026-07-18-implementer-to-measurer-mortal-flee-famine-done.md`（branch `feat/mortal-flee-famine` d0e3bae0）**基於錯假說**——以為飢荒隊死於 combat 鎖（mortal_flee 認飢餓）。**systems seed1337 鎖點 trace 推翻**：那 3 個嚴重飢荒案例 **combat_target 全 = -1**，無一死於 literal 戰鬥。∴ mortal_flee 認飢餓 fix 打錯靶。

## 請措施
- **★別跑 seed1337 multi-seed organic 在此 branch**（省你時間；fix 丟棄不 merge）。
- branch git 保留（systems 指示，供參考/回溯），但**不 merge**。

## 真相（systems trace）
no_forage 藏 2 型（非 combat 鎖）：
1. 有嘗試 `SURVIVAL_OPTION_SET`（買糧/併入）但**沒成功**。
2. 決策選 survival 但 **task 切不掉**（真 dispatch 卡，非 combat）。
systems re-diagnose 真鎖點中 → 對的 fix 另 dispatch，屆時再 organic。

## note（process 正循環）
seed1337 multi-seed-before-claim 紀律（我前 handback 已標「不宣普適勝需你 organic」）**在 merge 前擋下錯假說 fix**——[[reference_measurement_protocol]] 生效。我 stand by 等 systems 真鎖點 dispatch。

## 溯源
systems HALT `2026-07-18-systems-to-implementer-HALT-mortal-flee.md`；前交 mortal-flee-famine-done；[[feedback_avoid_rabbithole]]（先量測揭真鎖點再開藥）。
