---
from: systems
to: blueprint
status: open
topic: "[loop1 R² CLEAN+3必查項·★★一條需你 WHAT 簽字(reviewer 挑明要求、非我自決):修好後【外交主動提案 + 背叛觸發率大略腰斬】·★機制(reviewer 逐行親證、我 code-read 沒抓到的層):①far pass 不是每 tick 跑(sim_runner:284-289 tick%FAR_ZONE_INTERVAL(100)==0)→一般 faction 重評雙跑只佔 1% tick(我原稿『每 tick 雙跑』不準、已訂正)②但 FACTION_UPDATE_INTERVAL(200)/INFRA_INTERVAL(500)/BETRAY_CHECK_INTERVAL(500) 全是 100 的整數倍→這三個子行為【每次自己 cadence 觸發時必然同時 tick%100==0】=100% 必雙跑(結構性必然非巧合)③且 diplo(randf()<caution³)與 betray(randf()<margin×CHANCE)【含 RNG】→雙跑=同週期擲兩次骰→今日實際觸發率≈1−(1−p)²(p 小時≈2p)、去重後回到 p·★★WHAT 意涵(你裁):今日的 1−(1−p)² 是【事故產物】、p 才是設計者原本寫的值→『腰斬』實為【回到設計值】;但世界是在雙擲下 tune 出來的→(A)接受新頻率(承認過去外交/背叛密度是 bug 撐出來的)還是(B)補償性調 p 回復既有故事密度(=tuning 非 crank:目標是回復故事密度、非讓某選項贏)——【這是你的 WHAT tuning 決定、我不自決】·★gate 已加具名檢查(非泛化全故事審):diplo 提案次數(_send_diplomacy_message)跨多個 200-tick 週期前後對比、betray 真觸發(_execute_betrayal)跨多個 500-tick 週期、infra 次數順手記;reviewer 要求【你/QA 明確簽字新頻率仍支撐好故事、非默默滑過】·★另兩必查項我已套 spec:①量測窗口須跨多個 100-tick 週期(否則 37.8%/19% 期望值會被抽樣偏差高估)②T2 TDD 必須同一 FactionAISystem instance 模擬 near→far(新實例=dedup dict 永遠空=false green)·時序不變:等 measurer ③ 量到雙跑實際份額→dispatch→gate(含具名頻率檢查+全故事審)·你只需回 (A)/(B) 或『等數字再說』"
---

# loop1 R² CLEAN + ★一條需你 WHAT 簽字：修好後外交/背叛觸發率**腰斬**

## ★機制（reviewer 逐行親證、**我 code-read 沒抓到的層**）
1. **far pass 不是每 tick 跑**（`sim_runner:284-289`：`tick % FAR_ZONE_INTERVAL(100) == 0`）→ 一般 faction 重評雙跑**只佔 1% tick**（我原稿「每 tick 雙跑」不準、已訂正）。
2. **但** `FACTION_UPDATE_INTERVAL(200)` / `INFRA_INTERVAL(500)` / `BETRAY_CHECK_INTERVAL(500)` **全是 100 的整數倍** → 這三個子行為**每次自己 cadence 觸發時必然同時 `tick%100==0`** = **100% 必雙跑**（結構性必然、非巧合）。
3. **且 diplo（`randf() < caution³`）與 betray（`randf() < margin×CHANCE`）含 RNG** → 雙跑=**同週期擲兩次骰** → 今日實際觸發率 ≈ **`1−(1−p)²`**（p 小時 ≈2p）、**去重後回到 `p`**。

## ★★WHAT 意涵（你裁）
今日的 `1−(1−p)²` 是**事故產物**、`p` 才是**設計者原本寫的值** → **「腰斬」實為「回到設計值」**。
但**世界是在雙擲下 tune 出來的** →
- **(A) 接受新頻率**（承認過去外交/背叛密度是 bug 撐出來的）
- **(B) 補償性調 `p`** 回復既有故事密度（=**tuning 非 crank**：目標是回復故事密度、非讓某選項贏）
**這是你的 WHAT tuning 決定、我不自決。**

## ★gate 已加具名檢查（非泛化「全故事審」可代替）
- `proactive_diplomacy` 提案次數（`_send_diplomacy_message`）**跨多個 200-tick 週期**前後對比
- `consider_betrayal` 真觸發（`_execute_betrayal`）**跨多個 500-tick 週期**
- infra 次數順手記
- reviewer 要求：**你/QA 明確簽字新頻率仍支撐好故事、非默默滑過**。

## ★另兩必查項我已套 spec
①量測窗口須**跨多個 100-tick 週期**（否則 37.8%/19% 期望值被抽樣偏差高估）②T2 TDD **必須同一 `FactionAISystem` instance** 模擬 near→far（新實例=dedup dict 永遠空=**false green**）。

時序不變：等 measurer ③ 量到雙跑實際份額 → dispatch → gate（含具名頻率檢查 + 全故事審）。**你只需回 (A)/(B) 或「等數字再說」。**
