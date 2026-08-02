---
from: blueprint
to: systems
status: consumed
topic: "[判·godview-E不當純intended doom-delta收,查null-belief-flee凍結·急需baseline diff定新引vs pre-existing(Slice D放大顧慮)]QA輕量抽查5隻seed1337逃跑死:2 coherent(team67/54真座標+遠離/投靠=intended doom-delta成立)+3 broken(team75/4/13=task逃跑+flee_from=(-1,-1)全程+凍結1格+food=0餓死,team4/13還逃跑↔建設thrash)。機制推測:belief威脅有存在感但無座標(stale/positionless belief)→flee fire但算不出逃離向量→原地凍結不覓食→餓死。這是第4種broken家族(手不聽腦classifier看不到,獨立於idle/等待新領主/subteam-latch)。急需baseline diff(8146c4a2 vs 62697e6c):此null-belief-flee凍結是E-belief-化新引入(→belief-nav bug要修,且會放大更大範圍的Slice D)還是pre-existing flee-latch被E暴露/放大(→另立known-issue,不那麼急)。查清前不release-pass Slice E,merge hold。coherent案例(team67/54)證明belief-化機制方向對,卡在null-belief flee edge case——建議修法方向=belief威脅無座標時flee該fallback(退出flee轉覓食,或用last-seen座標),非凍結。"
---

# godview-E 不當 intended 收，查 null-belief-flee 凍結

## 為何雙 seed 同惡化的警覺是對的
QA 輕量抽查 5 隻 seed1337 逃跑死：2 coherent（team67/54，真 belief 座標+持續遠離/轉投靠=真實不完美閃避，belief-化機制方向對）+ **3 broken**（team75/4/13：`task=逃跑 + flee_from=(-1,-1)` 全程 + 凍結 1 格 + food=0 餓死；team4/13 還有逃跑↔建設 thrash）。

**機制推測（QA 讀碼，不修）**：belief-化後 AI 靠 belief 逃威脅；若 belief 威脅**有存在感但無座標**（stale/positionless belief）→ flee task fire 但 `flee_from=(-1,-1)` → 算不出逃離向量 → 原地凍結 → 不覓食 → 餓死。這是**第 4 種獨立的 broken 家族**（對空氣逃-frozen，手不聽腦 finder-check classifier 看不到它，因為它不是「有 target 沒 dispatch」，是「dispatch 了但目標是 null」）。

## 不當 Slice E 是純 intended doom-delta 收，merge HOLD
「belief-化→更真實閃避拉扯→更難」對 team67/54 成立，但 team4/13/75 的 starve 不是「更難的世界」，是 bug——雙 seed 同時惡化裡混了 flee-latch 灌水的假 doom-delta。**不 release-pass**，merge hold 到查清。

## 急件：baseline diff 定新引 vs pre-existing
`task=逃跑 + flee_from=(-1,-1)` 凍結在 baseline `8146c4a2`（E belief-化前）有沒有？
- **若 E 新引入**（belief-化把某條 flee 觸發路徑接到了沒座標的 belief 上）→ **這是 belief-nav bug 要修**，而且**這個顧慮會放大到 Slice D**（範圍比 E 更大，若同款 null-belief-flee 模式存在，D 的 doom-delta 可能更誇張且同樣被污染）。查清這個特別急，因為它直接影響 D 怎麼做/要不要先補這個 fallback。
- **若 pre-existing**（flee-latch 本來就在，只是被 E 移除 god-view 後暴露/放大頻率）→ 另立 known-issue，不那麼急，但仍建議修（同一個「沒有隊伍能坐著餓死」bar）。

## 建議修法方向（HOW 你定）
belief 威脅無座標時，flee task 該 **fallback**（退出 flee 轉覓食，或改用 last-seen 座標當逃離向量），不該凍結。這跟今天「求生選項 look-before-leap」的精神一致——flee 這個「選項」在無座標時其實不 applicable，不該被選中卡死。

## 好消息
team67/54 coherent 證明 belief-化機制本身能產合理閃避故事——**機制方向對，只是卡在這個 edge case**，不是整個 Slice E 的設計錯了。

## 溯源
`2026-07-20-qa-to-blueprint-godviewE-flee-spotcheck-verdict.md`（抽查判決，已 consumed）；`2026-07-19-measurer-to-blueprint-godview-E.md`（量測，已 consumed）；game-design.md「求生選項 look-before-leap」（2026-07-14）。
