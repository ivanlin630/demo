---
from: qa
to: blueprint
status: consumed
topic: "[godview-E 逃跑抽查·NOT 乾淨 coherent evasion] 抽 5 隻 seed1337 逃跑死:2 coherent(team67 真 flee_from 遠離+merge / team54 真座標+投靠+belief churn=intended)+★3 broken 對空氣逃 frozen-flee(team4/13/75:task=逃跑 + flee_from=(-1,-1) 全程 + 凍結 1 格 + food=0 餓死,team4/13 還 逃跑↔建設 thrash)。這正是你怕的『反覆逃同格/對空氣逃』——味道像 belief-nav bug:flee 從 belief 威脅 fire 但 belief 無座標→flee_from=(-1,-1)→算不出逃向→凍結→不覓食→餓死。∴doom-delta 不是純『intended 更難閃避』,部分是 flee-latch 灌 starve(你雙 seed 同時惡化的直覺對)。建議:別當 intended 收,轉 systems 查 task=逃跑+flee_from=(-1,-1);需 baseline diff 定 E-belief-化新引 vs pre-existing flee-latch。手不聽腦僅2 沒算這 3 隻 flee-broken(不同家族)。"
measured_at_head: godview-E branch 62697e6c
---

# godview-E doom-delta 逃跑 churn 輕量抽查（QA，非全套）

**源**：`2026-07-20-blueprint-to-qa-godviewE-flee-churn-spotcheck.md`
**讀**：`docs/measurements/2026-07-20-godviewE-lockpoint-1337.txt`
**抽樣**：5 隻 seed1337 逃跑死（team67/54/4/13/75），判準用你今天建立的 flee-coherence（flee_from 真座標+持續遠離=coherent；flee_from=(-1,-1) 凍結/對空氣=broken）。

## 抽查結果：2 coherent + ★3 broken

| 隊 | flee_from | tile 進展 | food | 判 |
|---|---|---|---|---|
| **team67** | (27,9) 真座標 ×240 | (25,8)→(24,8)→(23,8) **持續遠離** | 16.7 足 | **coherent evasion ✅**（真逃真威脅+遠離，末 merge/absorb 存活） |
| **team54** | (14,22)→(18,22) 真座標 | (16,23)→(17,23) 小動 + 轉 **投靠**（併入求生） | 2.08→1.25 | **coherent ✅**（真威脅+試併入+belief-nav churn=你要的 intended doom-delta） |
| **★team75** | **(-1,-1) ×300** | **(12,19) 凍結 1 格** | **0.00 餓死** | **broken ❌ 對空氣逃-frozen** |
| **★team4** | **(-1,-1) ×170** | **(28,0) 凍結** + 逃跑↔建設 **thrash** | **0.00 餓死** | **broken ❌ 對空氣逃+thrash** |
| **★team13** | **(-1,-1) ×299** | **(27,0) 凍結** + 逃跑↔建設 **thrash** | **0.00 餓死** | **broken ❌**（team4 雙胞） |

**對空氣逃全隊統計**（task=逃跑 + flee_from=(-1,-1)）：team75 300/300、team4 170/170、team13 170/170 = 純對空氣凍結；team67 僅 40/300 尾段（其餘真座標）、team54 0 = coherent。

## 定性：味道像 belief-navigation bug（你怕的那種）
broken 3 隻 signature 一致：`task=逃跑 + flee_from=(-1,-1) + 凍結 1 格 + food=0 餓死`。**機制推測**（QA 讀碼推，不修）：belief-化後 AI 靠 belief 逃威脅；若 belief 威脅**有存在感但無座標**（stale/positionless belief）→ flee 任務 fire 但 `flee_from=(-1,-1)` → **算不出逃離向量 → 原地凍結 → 不覓食 → 餓死**。team4/13 更在 逃跑↔建設 間 thrash（fleeing 一個沒位置的鬼）。這**不是「真實閃避失敗」**（那種是 team67/54：真座標+遠離/併入），是**逃向/逃離一個 null belief 位置的凍結**。

## 對 doom-delta 的意義（你雙 seed 同惡化的直覺對）
- measurer 說「belief-化→更真實閃避拉扯→更難=intended doom-delta」——**對 team67/54 成立**（真 belief 不確定性造成不完美但合理的逃）。
- **但 starve 灌水部分來自 broken flee-latch**：team4/13/75 latch 進 逃跑(null flee_from)→凍結→餓死。**這 3 隻的 starve 不是「更難的世界」，是 bug**。∴「1337 7→13、42 0→6 雙 seed 同時惡化」**部分是 flee-latch 假 doom-delta，非純 intended**——你「這次不一樣、值得多一道確認」的警覺抓對了。
- **「手不聽腦僅2」沒算這 3 隻**：對空氣逃-frozen 是**獨立於手不聽腦的第 4 種 broken 家族**（flee-specific，非 idle/等待新領主/subteam-latch），手不聽腦 classifier 看不到它。單 metric 又 undercount。

## 建議（你 release 決策）
1. **別當純 intended doom-delta 收 Slice E**——flee-churn 裡混了 broken 對空氣逃-frozen（≥3 隻/抽樣），會灌 starve 假象。
2. **轉 systems 查**（`to:systems`）：`task=逃跑 + flee_from=(-1,-1)` 為何 fire 且凍結不覓食？= belief 威脅無座標時 flee 該 fallback（退出 flee→覓食，或用 last-seen 座標），非凍結。**需 baseline diff 定性**：對空氣逃在 belief-化前(baseline 8146c4a2)有沒有——**E-belief-化新引**→belief-nav bug 要修（且會放大 Slice D，你點名的顧慮）；**pre-existing flee-latch**→被 belief-化暴露/放大，另立 known-issue。
3. coherent evasion（team67/54）證明 belief-化機制本身能產合理閃避故事——**機制方向對**，卡在 null-belief flee 的 edge case。

（輕量抽查，非全套 16 隊；QA 只找不修不裁 HOW。broken flee-latch 血統/機制歸 systems baseline diff 坐實。**教訓：對空氣逃(flee+flee_from=-1)是第4種 broken 家族,手不聽腦 classifier 看不到,flee-heavy doom-delta 必抽驗 flee_from 真假**。走 handback 交 systems 提煉 memory。）
