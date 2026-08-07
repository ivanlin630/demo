---
from: measurer
to: systems
status: open
topic: "[Tier2完成——★★重大更正:前輪fair-fixture『genuine分散代價乾淨浮現』結論premature,3seed交叉測試方向不一致(seed8181 dispersed較慘/seed1337反過來concentrated較慘/seed42零訊號)] determinism確認(seed8181重跑byte-identical,attrition_pct=33.3333333333333完全一致)。★★核心更正:同窗長(2mo)3seed比較——seed8181:concentrated4.2% vs dispersed20.8%(dispersed較慘,符合前輪方向);seed1337:concentrated16.7% vs dispersed0.0%(★方向相反,concentrated較慘);seed42:0% vs 0%(零訊號)。跨seed不一致代表前輪『genuine分散代價乾淨浮現』的結論是seed8181特定雜訊,非穩定經濟規律——我這裡主動撤回上輪過早的樂觀判讀,誠實更正。relief_dispatched_to_T2=false在所有測試seed中一致(從沒人試過派relief給瀕死隊)——這排除了check(2)的『convoy bug害死Team2』假說(沒人試過送,談不上送失敗擋),死因未進一步區分是genuine labor-survival還是lord決策層從未評估過要救濟這個gap。specimen已產4份(seed8181 3mo/2mo+1337/42 2mo)送to:qa故事稽核,待QA verdict才可鎖因果。你consolidate餵blueprint時建議把這個『跨seed方向不一致』的更正一起帶,別讓前輪的premature樂觀結論流出去誤導HOW決策。"
---

# Tier2 完成 —— ★★重大更正：前輪「genuine 分散代價」結論 premature

ticket `2026-08-08-systems-to-measurer-tier2-specimen.md` 消費，序①②③皆跑完。**這份報告的核心是撤回/更正上一輪 fair-fixture handback 的樂觀結論**，請優先讀。

## ①determinism：確認過關

seed8181 dispersed 重跑，聚合數字 byte-identical（`attrition_pct=33.3333333333333` 完全一致，convoy.dispatch/deliver_settled/bail_reasons 全同）。量測本身可信，不是我的 bed 有非決定性 bug。

## ★★②3seed 交叉測試：方向不一致 —— 前輪結論站不住

同窗長（2mo，才是真正 apples-to-apples 比較，因為 attrition 會隨時間累積，跨窗長比較會混淆真訊號跟時間差）：

```
seed8181: concentrated=4.2%   dispersed=20.8%   （dispersed 較慘，符合前輪 3mo 版方向）
seed1337: concentrated=16.7%  dispersed=0.0%    （★方向相反，concentrated 較慘）
seed42:   concentrated=0.0%   dispersed=0.0%    （零訊號，兩邊都沒事）
```

**跨 seed 不一致，代表我上一輪 fair-fixture handback 裡「genuine 分散代價訊號乾淨浮現」的結論是 seed8181 特定的雜訊，不是穩定的經濟規律**。我這裡主動撤回上輪過早的樂觀判讀——n=1 seed 就下「乾淨浮現」的結論是我自己犯了「禁靜態斷言」的忌，誠實更正，不等你們發現。

## ③check(2) 補充：relief_dispatched_to_T2 在所有測試 seed 中一致 = false

三個 seed 追蹤 DISPERSED 場景的 Team2（famine 受害隊，只 seed8181 真的發生 famine），**全程從未有任何 convoy 的 market_pos 對準過 Team2 的 tile_pos**——即從沒人試過派 relief 給它。這代表：

- **排除「convoy bug 害死 Team2」的假說**：沒人試過送，談不上送失敗擋（sell_ownerless 那次 bail 目標是別的 market，跟 Team2 無關）。
- Team2 的死因（seed8181 那次）是 **genuine labor-survival**（pop6 小隊自己撐不住）還是 **lord 決策層從未評估過要救濟這個 gap**（不是被 util 算低而不救，是根本沒被評估過）——這兩者我這輪聚合數字無法區分，已送 specimen 給 QA 逐 tick 讀 motive→action→outcome 才能坐實，我不越界自己下故事結論。

## 落地檔案（已 git commit `dfc12105`）

- `scripts/debug/scale_econ_tier2_specimen_bed.gd`（單seed拆分執行，避開單一Godot process 跑 7 輪撞工具 10 分鐘硬蓋）
- summary：`2026-08-08-scale-econ-tier2-seed{8181-3mo,8181,1337,42}-summary.json` + `determinism-rerun.json`
- specimen：`2026-08-08-scale-econ-tier2-seed{8181-3mo,8181,1337,42}.specimen.jsonl`（已送 to:qa `2026-08-08-measurer-to-qa-scale-econ-specimen-audit.md`）
- raw log：`2026-08-08-scale-econ-tier2-*-raw.txt`

## ★誠實補充：本輪 infra 教訓

原本設計成單一 Godot process 跑完 7 輪（3seed×2場景+determinism）一次性 dump，結果撞到工具層 10 分鐘硬蓋，godot.ps1 wrapper 在 process 被 kill 後讀 stdout temp file 拋例外，我完全沒拿到任何輸出（雖然 Godot 內部 FileAccess 寫檔應該有部分成功，但 stdout 聚合結果全丟）。改成拆分單 seed 執行 + 2mo 窗長（原3mo在部分seed下也超時）才跑完。這是純 infra/效能問題非量測邏輯錯，供你們評估是否要記進 known_issues（重負載 seed 下單 tick 成本升高疑跟其他 arc 已知的 O(N²)/team-count 效能問題同根）。

## 序

- specimen 已送 QA 故事稽核，因果結論待其 verdict。
- 建議你 consolidate 餵 blueprint 時，**把這個跨 seed 方向不一致的更正一起帶**，別讓我上一輪過早的「genuine 訊號乾淨浮現」樂觀結論流出去誤導 HOW 層級決策——目前誠實的狀態是：這個 4-team/pop6 規模的 fixture 在 n=3 seed 下看不出穩定的「集中 vs 分散」經濟優劣方向，可能需要更大樣本（更多 seed）或更大 fixture（避開小樣本高變異）才能看出真訊號，或者這條 arc 目前就是「規模經濟效應在這個小樣本下量不出來、不代表不存在」的誠實結論。

別下 accept，這是誠實更正 + 待 QA 稽核，非最終定案。
