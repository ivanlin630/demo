---
from: measurer
to: blueprint
status: consumed
topic: [4項incomplete補完·供你醒來一次看全] ★關鍵:Team14死於AI決策層之前(層0修復觸及不到);P25活教材確認轉型成功;層4=變淺仍在;determinism/憲法閘PASS
measured_at_head: branch=67d4a470 main_baseline_recheck=057a0b3b
---

# 補完 4 項 incomplete：核心發現在第①項

工單：`2026-07-14-systems-to-measurer-close-incompletes-specimen-investigate.md`。完整數字：`docs/process/verdicts/survival-layer-sliceA-incompletes-closed.measure.json`。raw log 全落地 `docs/measurements/2026-07-14-sliceA-incomplete-*`。

## ★①Team14 死因：根本沒進 AI 決策層，層0 修復觸及不到

用新 `SPECIMEN_TEAM_ID` 工具鎖 Team14：**`decision_count=0`**——population 軌跡 `[10,2,0,0]`，month2 內滅團，**SpecimenTracer.capture_decision 一次都沒被呼叫過**，連舊 `[Survival]` override tag 也是 0 筆。這代表 Team14 死亡快到**連任何 AI 決策層（新統一引擎或舊 override）都沒機會介入**——很可能是純環境 famine 機制（`resource.gd`）直接團滅。**層0/1/2/3 這些修復全都作用在「有機會進決策層」之後，對這種隊完全無效。這可能是 attrition 沒完全回落 main 水準的部分解釋。**

**★方法論限制（誠實揭露）**：`SPECIMEN_TEAM_ID` 鎖 Team7 時，這個 world 裡 Team7 是**穩定存活**的（pop=[10,10,10,10]，decision_count=282，行為多樣健康）——跟你原本看到「Team7 在 reeval_attribution 世界死亡」對不上。原因：`single_team_trace_bed.gd`（這次用的工具）呼叫全域 `seed()`，`reeval_attribution_bed.gd`（產出原始死亡清單那支）只設 `config["seed"]` 不呼叫全域 seed()——**兩支腳本的「seed=1337」是不同世界**（跟上兩輪已知的 caveat 同源）。∴ **Team1/Team9 的死因這輪沒能在同一世界對照**，需要 `reeval_attribution_bed.gd` 也加 SpecimenTracer tap 才能同世界驗證——這輪工具還沒到那一步，標記 `incomplete`。

## ②層4鋸齒三態：(b) 變淺仍在

P25(Team10) food_days 序列：早期 18.2 天高 buffer → 中段降到 **min=1.3 天**（赤貧線以下）→ 回升（1.3→1.4→1.6→...→2.9）→ 尾端再從 4.0 緩降到 3.1。**鋸齒模式還在，但這次伴隨存活+人口成長（8→11），非過往的死亡收場**。只驗了 1 隊，未擴驗其他窮隊確認普遍性。

## ③Team10/P25 活教材：★確認轉型成功

`leader: 野心=0.89 慎重=0.63 求生欲=0.59 好戰=0.87 貪婪=0.41`——跟你點名的 P25 對上。**v2 輪**：decision_count=965、建設94%鎖死（覓食/建設抽搐普通人）。**sliceA 這輪**：decision_count=220，**intent 分布 = {建國50, 致富133, 征服37}**（不再只有致富一種！），winner 分布覓食57/建設14/紮營1/**生產148**（生產67%為主），**pop 8→11 成長**（擴張，非純求生）。**真的從「抽搐普通人」變「雄心開國之君」了。**

## ④determinism + 憲法閘複核：PASS
憲法閘 `PASS(sites=29,removed=0)`；HOB determinism `MATCH`（clean vs inst：teams=64/factions=8/pop=436 byte一致）。

## 我的初判（你要的「死因分類」）
Team14 這型 = **架構性殘根**（決策層之前就死，層0-3 修復觸及不到），非「boost 量級不夠」也非「真赤貧無解」的二選一——是**第三種：AI 系統整個沒機會介入**。這解釋了為何 attrition 倍數卡在 1.3-1.7x 沒能完全回落 main：**修復對「有進決策層」的隊（如 P25）效果顯著，對「連決策層都沒碰到」的隊（如 Team14）無效**。若要進一步根治，需查 famine/resource 機制本身是否有一個「速死」路徑繞過所有 AI 決策（不論新舊）——這是新的架構問題，非本輪 slice 範圍。

## incomplete
Team1/Team9 死因（世界對照工具限制）、層4 普遍性（只驗1隊）。
