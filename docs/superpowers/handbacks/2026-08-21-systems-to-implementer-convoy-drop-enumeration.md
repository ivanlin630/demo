---
from: systems
to: implementer
status: open
topic: "[dispatch convoy dispatch-drop 結構列舉(★evidence-only、禁 fix、排在 owner-outpost 索引之後)·背景:訂單簿全量 Probe dump 顯示 peaceful 90 天【g1.seek_market=1、convoy.dispatch/fetch/deliver/return 各 1】,而 decision.opt_chosen.deliver_material=10、diag.deliver_material.appl_n=48 → 選項可用 48、被選 10、真派出 1 = 手不聽腦簽名·★我已逐行讀出 drop 點(faction_ai:3977-4006 _dispatch_convoy),【7 個 return false 全部靜默、零 tap】——這正是『全量暫態可觀測性』不變量要防的:①target==(-1,-1) 或 ==自己位置(無市場目標)②population < CONVOY_MIN_PARENT_POP(母隊太小)③cargo.is_empty()(沒東西可載)④已有 CONVOY 子隊(一次一支)⑤load < 1.0(母隊實無貨可載)⑥advisor_id==-1(沒人帶隊)⑦sub_id==-1(子隊生成失敗)·★要什麼:每個 drop 點加 Probe.bump('convoy.drop.<reason>')(七個具名 reason)+ 進入 _dispatch_convoy 的總次數(convoy.dispatch_attempt),跑 peaceful 短窗(2-4 週足夠,它 90 天才 1 次派出=低頻但 drop 應該很多)+warring 一段;報【七站各掉多少 + attempt 總數】·★★同時要答一個更前面的問題:attempt 總數 vs decision.opt_chosen.deliver_* 的差——若『被選 10 次』但 attempt 遠少於 10,表示斷點在【選中→呼叫 _dispatch_convoy】之間(更上游),那就再往上列舉一層;請一併報這個對照·★禁 fix:不要順手補守衛/放寬條件——我要先看分佈才知道是『世界真的沒貨』(⑤)還是『機制自己擋住』(②④⑥⑦);前者要修設施鏈、後者才是 de-patch·★便宜優先:temp tap、用完 revert;若 seek_market=1 這條也想順手量,同法加 g1.seek_market 的 drop 點(但別擴大到重寫)·完→handback to:systems·地基KEEP"
---

# dispatch：convoy dispatch-drop 結構列舉（★evidence-only、禁 fix；排在 owner-outpost 索引之後）

**背景**：訂單簿的**全量 Probe dump** 顯示 peaceful 90 天 **`g1.seek_market=1`、`convoy.dispatch/fetch/deliver/return` 各 1**，而 `decision.opt_chosen.deliver_material` **10**、`diag.deliver_material.appl_n` **48** → **選項可用 48、被選 10、真派出 1** ＝ **手不聽腦簽名**。

★**我已逐行讀出 drop 點**（`faction_ai:3977-4006` `_dispatch_convoy`）：**7 個 `return false` 全部靜默、零 tap**——這正是「全量暫態可觀測性」不變量要防的：
1. `target == (-1,-1)` 或 == 自己位置（**無市場目標**）
2. `population < CONVOY_MIN_PARENT_POP`（**母隊太小**）
3. `cargo.is_empty()`（**沒東西可載**）
4. 已有 CONVOY 子隊（**一次一支**）
5. `load < 1.0`（**母隊實無貨可載**）
6. `advisor_id == -1`（**沒人帶隊**）
7. `sub_id == -1`（**子隊生成失敗**）

**要什麼**：每個 drop 點加 `Probe.bump("convoy.drop.<reason>")`（**七個具名 reason**）＋ 進入 `_dispatch_convoy` 的**總次數**（`convoy.dispatch_attempt`）。跑 peaceful 短窗（**2–4 週足夠**——它 90 天才 1 次派出＝低頻，但 drop 應該很多）+ warring 一段；報**七站各掉多少 + attempt 總數**。

★★**同時要答一個更前面的問題**：`attempt` 總數 vs `decision.opt_chosen.deliver_*` 的**差**——若「被選 10 次」但 **attempt 遠少於 10**，表示斷點在**「選中 → 呼叫 `_dispatch_convoy`」之間（更上游）** → 那就**再往上列舉一層**。請一併報這個對照。

★**禁 fix**：不要順手補守衛/放寬條件——**我要先看分佈**才知道是「**世界真的沒貨**」（⑤）還是「**機制自己擋住**」（②④⑥⑦）；**前者要修設施鏈、後者才是 de-patch**。
★**便宜優先**：temp tap、用完 revert。若 `seek_market=1` 也想順手量，同法加它的 drop 點（**但別擴大到重寫**）。

完 → handback to:systems。地基 KEEP。
