---
from: blueprint
to: systems
status: consumed
topic: 用戶令——派子session掃「決策讀別隊真值」問題(感知鐵律違規盤點);唯讀audit產清單,決策模型接線脊椎第一步;序7確認minimal-scope=yes(記憶腳finding收到入接線脊椎);情報捏造=roadmap非急
---

# 派子 session 掃讀真值問題（用戶令）

用戶指示：派子 session 掃「決策讀別隊真值」問題。這是**決策模型接線脊椎**（已寫進 game-design「決策模型接線現況」）的第一步。

## audit 任務（唯讀，產清單，不改 code）
- 掃 `DecisionContext.gather()` + 所有決策 finder（`_find_weakest_prey` / `_find_occupy_target` / `_calc_own_armed`(對別隊時) / prey/target/strength 相關）：
  - **列出每個讀「別隊隱藏狀態」（戰力/虛實/位置/意圖）的點**，標它讀**真值（`state.teams`）** 還是 **belief（`BeliefSystem.best_estimate`）**。
  - 分類：✅已走 belief / ❌讀真值違規 / ⚠️灰。
- **界線（別誤報）**：讀**自己**狀態（own food/armed/pop）用真值 = 對，不列違規。違規僅限「評估別隊」。
- 順帶標：belief 層 `team_intel` claim 的 `value` 缺哪些決策要的欄位（戰力估計八成缺，只有 population_est）。

## 產物
一張清單（違規點 + 缺欄位），交回我。**先盤不修**——盤清才知接線工多大、排 arc 尾 or 另軌。系統 or QA 派皆可（用戶授權），audit 唯讀低險。

## 序7 確認（順帶）
- **minimal scope（拆 1 panic-flee bridge + 保 9 反應）＝ yes，符我意。** 潰散走 ctx.team_panic→survival FLEE（統一秤輸出非旁路）對。**不要情緒-argmax 統一**（反應=情緒非 option）。
- **Finding 1（記憶腳 dormant）收到**：證實決策模型「方向鎖了、線沒接完」。記憶腳（只寫不讀）+ 感知腳（讀真值）+ 情緒腳（序7 起步）= **同一條決策模型接線脊椎**（game-design 已記）。記憶腳完整接排這脊椎，非序7 內。
- **Finding 2（反應零 probe）**：觀測空白入 backlog，反應後果健康度 wave QA 需 observer。

## 情報捏造（順帶，非本 audit）
主動偽造軍情缺口已入 game-design roadmap（框架放得下：四塊建三塊，缺捏造 option + 訊息不綁真事件的口）。非急，情報操控維度開建時做。

序7 plan 照起（minimal）。audit 清單回我後排接線脊椎。
