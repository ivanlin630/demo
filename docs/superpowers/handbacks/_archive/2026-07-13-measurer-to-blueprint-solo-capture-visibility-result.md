---
from: measurer
to: blueprint
status: consumed
topic: solo capture可見性補丁+非餓穩態隊重trace——★cadence確實生效：decision_count從1(缺solo tap時代)暴增到2023(90天)，證實cadence機制本身work，前輪Team12「仍1次」是solo capture tap缺失造成的觀測盲區非cadence本身沒生效；★但發現新現象：該隊本started食足(食175+)最終卻餓死到pop10→4且90%決策是survival/逃跑——呼應T1-T5觀察項#1(FLEE-safe地板)，值得深查
---

# 量測回報：序① solo capture_decision 可見性 + 非餓穩態隊重trace

工單：`2026-07-13-implementer-to-measurer-solo-capture-visibility.md`。`.worktrees/reeval-cadence`（feat/reeval-cadence @e41cac0，含T-cad1/2+序①）。headless 0新增SCRIPT ERROR，determinism沿用前輪（純觀測patch，implementer信§已初驗CLEAN）。

## ★核心結論：cadence機制本身確實生效，前輪「仍1次」是觀測盲區非真bug

改用穩態選隊邏輯（`stability_score`偏好高存活pop+低波折=非crisis隊）選中**Team7**（月度快照population`[10,10,10,10]`，波折0，看似最穩）：

**`decision_count=2023`**（90天內），對比：
- 修cadence前（`term-scale-normalize`輪）：Team7 decision_count=1
- 修cadence但未補solo tap前（`reeval-cadence`前輪）：Team12 decision_count=1（**這次證實是solo capture tap缺失，不是cadence沒生效**——純solo路徑決策本來就不會被tracer看到，跟cadence機制是否運作是兩回事，前輪誤判方向）

**結論：implementer的T-cad1/T-cad2重評cadence修法確實有效**，前輪我報告的「主驗收未過」是**量測工具本身的盲區**（solo capture_decision tap缺失導致觀測不到，非cadence機制真的沒動）——本輪補上tap後真相大白，cadence機制運作正常甚至可能過於頻繁（2023次/90天遠超implementer信§預期的daily cadence~90次，可能crisis-gate重複觸發）。

## ★意外發現：食足隊最終餓死，90%決策是survival/逃跑（呼應觀察項#1）

Team7初期食物充足（tick10: food=180，tick390: food=167，穩定盈餘），但**decision分布裡`survival`winner佔1907/2023（94.3%）**，task多為「逃跑」——且最終population從10掉到4，food耗盡至0：

```
tick=10:    覓食(0.47) > 囤貨(0.34) > survival(0.28)   ← 食足期，覓食主導
tick=4270:  覓食(0.78) > survival(0.28) → 開始出現survival勝出
tick=21600（月3尾）: 覓食(0.95) > survival(0.65) → survival winner，task=逃跑，food=0，pop=4
```

這支隊**從食足穩態→逐漸被survival option主導→最終餓死縮編**，跟T1-T5 term-normalize交付信§「3 organic觀察項」的**觀察項#1「FLEE-safe地板：安全隊(safety urgency 0)是否spurious FLEE」**高度相關——本輪trace首次給出具體案例佐證：即使`覓食`utility持續領先（0.47→0.95），`survival`還是在某個時間點翻盤成為winner並持續主導，最終隊伍走向縮編死亡而非靠覓食自救。

## ★次要：pass1/pass2快照數字不一致（工具側小瑕疵，非本輪重點）
pass1（不開tracer找候選）記錄Team7月3快照pop=10，pass2（開tracer完整追蹤同seed同team）卻在最後一tick顯示pop=4——理論上同seed純觀測應完全一致。可能是我pop_history記錄時機或team識別有微小誤差，非本輪核心發現，未深究（timeboxed），供你參考。

## 產物
`.worktrees/reeval-cadence/scripts/debug/single_team_trace_bed.gd`（改良選隊邏輯，L3純觀測），`rc_stable_trace.txt`（完整trace）。

## 待你
- **cadence機制本身驗收通過**（前輪「未過」判斷撤回，是我工具盲區）——可繼續往T-cad3/T-cad4或9-zero方向走。
- 2023次/90天可能過於頻繁（crisis-gate疑似重複觸發），建議查是否符合預期節奏。
- survival option晚期主導食足隊直到餓死的現象，強烈建議深查（對應T1-T5已知觀察項#1），可能是決策引擎優先序層面的真根之一。
