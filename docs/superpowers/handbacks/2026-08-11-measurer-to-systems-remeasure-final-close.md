---
from: measurer
to: systems
status: open
topic: "[QA CONFIRM真兇故事——genuine famine extinction非merge誤讀,checkpoint方法論徹底排除run-to-run不可比較疑慮,這條追問線收斂]QA裁定:raw log找到決定性事件(day64[Death]Person3005(team6)餓死緊接[Extinct]Team6滅團清除;day79[Death]Person3001(team8)餓死緊接[Extinct]Team7+Team8滅團清除)——這次是genuine famine extinction,非上輪Team2那種merge誤讀陷阱,翻轉真兇故事完全站得住。QA補充觀察(非裁定,供你/blueprint量測方法論參考):這些1人spinoff隊結構上幾乎注定餓死(pop=1無生產基礎,不像核心村落有勞力池分工),死亡驅動因素(純粹太小撐不住)可能跟concentrated/dispersed這個arc真正想測的『村落選址策略』無關,是population-overflow機制的副產品死亡率、非選址優劣造成——是否該filter/分開報告,交你/blueprint裁量。QA建議連同concentrated側等價spinoff隊命運一併查才能完整判斷是否公平比較(我已在上輪標註此為下一步)。★這條『re-measure scale』arc的量測面到此收斂,累積下來的完整圖像:①confound-clear首驗(propagation死角經iii清了大半)②方向反轉但非全面一致(2/3seed穩定dispersed較好)③seed8181自身翻轉的真兇=spinoff隊死亡非核心經濟故事。序②③(真淨值帳+size-blind lever判定)+spinoff隊算不算的方法論題,交你/blueprint整合判斷下一步。"
---

# QA CONFIRM 真兇故事 —— 這條追問線收斂

## QA 裁定

**genuine famine extinction，不是另一個 merge 誤讀陷阱**。raw log 決定性事件：

```
day64: [Death] Person3005(team6) 餓死 → [Extinct] Team6 滅團清除（遺財已路由）
day79: [Death] Person3001(team8) 餓死 → [Extinct] Team7 滅團清除 + [Extinct] Team8 滅團清除
```

跟上輪 Team2 那種「查無此隊=誤判死亡」的 sentinel 陷阱不同——這次是真的餓死。翻轉真兇故事完全站得住。

## QA 補充觀察（非裁定，供你/blueprint 量測方法論參考）

這些 1 人 spinoff 隊結構上幾乎注定餓死（pop=1 無生產基礎，不像核心村落有勞力池分工），死亡驅動因素（純粹「太小撐不住」）可能跟這個 arc 真正想測的「村落選址策略」無關，是 population-overflow 機制的**副產品死亡率**、非選址優劣造成。是否該 filter 掉這些死亡再重算 attrition、還是分開報告兩條線，**交你/blueprint 量測方法論裁量**。

QA 建議：連同 concentrated 側等價 spinoff 隊的命運一併查，才能完整判斷這是不是公平比較的一部分（我上輪已標註此為下一步，尚未執行）。

## ★這條 arc 量測面到此收斂 —— 累積完整圖像

1. **confound-clear 首驗**：原「分散慘」訊號證實是 propagation 死角/relief-execution confound artifact，經 iii（求援 hedge+叛離 consequence）清了大半。
2. **方向反轉但非全面一致**：iii 修後，2/3 seed（1337、42）在 2mo/3mo 兩種窗長下都穩定顯示 dispersed 較好；seed8181 本身跨窗長真實翻轉。
3. **seed8181 翻轉真兇已鎖定**：不是核心村落經濟故事本身的時變轉折，是 population-overflow spin-off 出來的邊緣單人隊 genuine 餓死拖動聚合 attrition。

## 序：交你/blueprint 整合判斷

- 序②（真淨值帳）+ 序③（3 size-blind lever 判定）要不要現在放行？
- spinoff 隊死亡算不算「規模經濟」比較的一部分——這題方法論決定會影響前面所有 attrition 數字的解讀方式，建議先定調再繼續量測，避免每輪都要重新分辨「核心村落故事」vs「population-overflow 雜訊」。

QA verdict 全文：`docs/superpowers/handbacks/2026-08-11-qa-to-measurer-remeasure-checkpoint-verdict.md`（已 consumed）。別下 accept，這是這條追問線的收斂回報，非最終定案。
