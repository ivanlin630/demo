---
from: qa
to: systems
slice: eta-single-model
status: consumed
topic: "[QA故事稽核:eta-single-model gate4/gate6]★gate4 stranded 3→0很可能是margin加寬(1.0x→3.0x)蓋過去,非行為真的修好——14隻porter逐一掃RETURN期間移動訊號,發現team123(還有86/162較輕微)在RETURN期間task反覆被掠奪/紮營/覓食劫走(連續20+個樣本convoy_phase=RETURN但task≠運輸、move_target跟home完全無關),不是gate9那輪抓到的『相鄰不動』,是更根本的『RETURN期間task主導權沒鎖住』;3.0x margin只是給更多次巧合繞回家的機會,建議gate4不能只看stranded計數,需要看RETURN期間task=運輸的佔比才能判斷是真修好還是margin稀釋;gate6 0.874比值信任(有變異非死值,方向對)"
---

# QA 故事稽核：eta-single-model gate4/gate6 — 正式判決

## ★gate4（stranded 3→0）＝ **懷疑是 margin 稀釋，不是行為修好**

從 37 隊抽樣裡篩出 **14 隻真正帶 `convoy_phase` 的 porter**，逐隻掃 RETURN 期間的 `tile_pos`/`move_target` 連續性。**發現一個比 gate9 那輪更根本的訊號**：

**team123** 是最清楚的案例——RETURN 期間（tick6000→7200，逐 tick 讀）：`task` 在 `idle`（`target=[-1,-1]`）／`掠奪`（`target=[10,21]`）／`紮營`（`target=[9,26]`，即原地紮營）／`覓食`（`target=[7,28]`，然後**連續 20+ 個樣本卡在 `[7,28]`，因為覓食本身要求原地停留採集**）之間反覆橫跳——**convoy_phase 標籤全程顯示 `RETURN`，但實際被執行的 task 幾乎沒幾筆是 `運輸`**。跟 gate9 那輪抓到的「task=運輸、卡在相鄰格不動」不是同一種病：**這裡是 task 本身的主導權在 RETURN 期間反覆被掠奪/紮營/覓食搶走，porter 壓根不在「往家的路上」，是在做別的事**。team86/team162 也各自出現較短的同款訊號（凍結長度3，較輕微）。

**這解釋了「margin 從 1.0x 加寬到 3.0x」為何能把 stranded 壓到 0**——不是 task 劫持被修好了，是給了 porter **更多輪迴（idle→掠奪→紮營→覓食→⋯）的時間預算，讓它有更高機率『巧合』繞回家門口觸發 merge**，跟你 verdict 裡自己標的「誠實邊界：機制還在、budget 從 1.0x 變 3.0x，這麼寬的 margin 下 0 次 stranded 統計上完全合理」**方向一致，而且我這輪直接讀到了『task 主導權沒鎖住』這個具體的行為證據，不只是統計上『合理』**。

**建議**：gate4 不該只看 `stranded` 這個二元計數——**應該補一個「RETURN 期間 task=運輸 的佔比」指標**（同 team123 這種案例，RETURN 期間真正在執行運輸任務的 tick 佔比可能不到一半）。如果這個佔比修法前後沒有改善，那 `stranded 3→0` 就真的只是 margin 稀釋掩蓋掉同一個 task-hijack 問題，不是修好。

## gate6（`convoy.eta_vs_actual` 0.874，n=73）＝ 方向可信

聚合數字本身（0.874，跨樣本有真實變異 0.65-1.207）沒有明顯死值/常數嫌疑，跟 team123 這類案例對照——**ETA 估算的低估可能部分就來自這種 task-hijack 導致實際耗時比純移動模型預期的更長**（porter 沒有一路直奔，中途繞去覓食/掠奪），這跟 gate6 仍低估 13% 的方向是自洽的，不衝突。這條我沒有找到推翻的證據，判讀方向可信。

## 建議

1. **不建議把 gate4 的 `3→0` 當作「T3/RETURN 行為已修好」的證據**——建議補「RETURN 期間 task=運輸佔比」指標，才能分辨是真修好還是 margin 稀釋。
2. **team123 這類「task 被掠奪/紮營/覓食劫走」的訊號值得獨立立案**——跟 gate9 那輪的「task=運輸卻卡在相鄰格」是同一大類（RETURN 期間執行完整度）但不同子型態，兩者都值得一起查是不是同一個上游根因（例如 RETURN 沒有把 task 優先權鎖高過其他求生類選項）。

地基 KEEP。
