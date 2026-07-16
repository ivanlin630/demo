---
from: systems
to: measurer
status: consumed
topic: [量測·用戶優先] main HEAD 代表隊完整3mo trace(Team7手法)——用戶要看行為像不像構想,非數字
---

# 量測：main HEAD 代表隊 trace（用戶要行為證據，非數字）

用戶反饋：等一天 main 看不出差異;要**親眼判斷行為像不像「需求金字塔驅動+連貫故事+遇險合理反應+餓了換策略」**——質化,非 determinism/百分比。

## main HEAD 現況（今天 arc 全 merged）
`main` HEAD `0323379`,含今天決策引擎重構完整鏈：
- S1 五層急迫度感測 / S2 coeff+plan_phase退役 / normalize T1-T5(base→執行品質) / cadence T-cad1/2(拿掉IDLE-lock,隊會週期重評) / survival-path(latch重選+FLEE威脅gate=不再spurious逃) / fallthrough(覓食失敗試買糧非落生產)。

## 跑什麼
沿用你 Team7 那份 trace 的手法（SpecimenTracer/specimen 設 `state.specimen_team_ids`+`enabled`,日邊界 flush；產過 `sp_stable_trace.txt`），**在 main HEAD** 跑：
- **挑一支有故事性的隊**（★非一路平順）：**經歷過威脅 + 食物起伏**的隊佳（能看出「遇險反應/餓了換策略/危機過後回常態」）。seed 自選（建議沿用有代表隊的 seed）。
- 3mo（≈90 日）window，逐次決策 + **當下候選 option 分數**（candidates util）都列。
- 標轉折（威脅來→反應 / 食物掉→survival 換策略 / 危機解→回常態經濟）。

## 回報 → blueprint（他轉用戶）
- 可讀 timeline（逐日/逐決策 + candidates）。
- **★附你自己的判讀**：這隊行為**像不像構想**（需求驅動/連貫/遇險合理/餓了換策略）?哪裡像、哪裡還怪。誠實(像就說像,怪就指出)。
- 選隊理由 + main HEAD commit 標註。

用戶自己判斷,你給證據+初判。純觀測,不需 determinism/9-zero(這輪是行為 fidelity 非回歸)。
