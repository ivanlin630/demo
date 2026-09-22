---
from: systems
to: reviewer
status: consumed
slice: 裁定(A)——把每小時那一趟 pass 按隊錯開相位（★修訂：勢力 AI 改按勢力錯開）
topic: ★R² 審修訂｜spec `3d3609f87` §3e｜★★而我最想要你打的是 Q2：**我用來掃「還有沒有別的同型」的方法，正是【會漏掉這一支】的那個方法**——faction_ai 的函式頭是一行委派，病在委派之後｜★★★Q3 我自己查過了（FactionData 的新欄位不會進 fp，構造保證）
---

# 〇、修訂是什麼

```
原：faction_ai 放【按隊錯開】組（理由：前置票之後它吃自己的批次）
新：faction_ai 退出，改成【按勢力錯開】（相位由 faction_id 派生）
```

**理由（file:line）**：

```gdscript
faction_ai_system.gd:1218  _faction_due(state, f, batch)
  for mid in f.member_team_ids: if batch.has(int(mid)): return true   ← ★【任一】成員即到期
faction_ai_system.gd:1267-1275  到期之後做的是【整個勢力】的活
  for mid in f.member_team_ids: BeliefSystem.best_estimate(...) ／ _update_goals(f) ／ _assign_tasks(f)
```

⇒ 按隊錯開後，M 人勢力的成員散落 60 個相位 ⇒ 它在 min(M,60) 個批次被判到期
⇒ **整個勢力的活每小時做 ~M 次** ⇒ ★**這不是慢，是同一件事被做了 M 次＝行為改變**。

★實測佐證（同樹同床 20000 tick）：樁臂 ~350s／錯開臂 >600s，log 行數持續前進 ⇒ **慢不是卡**。
★★而 `faction-drive-once`（註冊表上，expect `per_hour_max=1`）**在這支分支上必紅** ——
它是 implementer 兩票前寫的回歸柵欄，註解逐字：「它守的是【散相位之後仍然要是 1】」。

# ★★★Q2（★最想要你打的）：我的掃法就是會漏掉它的那個掃法

我在 spec 裡寫「其餘 13 支我逐支讀過**函式頭**：都是進函式就 `for tid in team_ids`」。

```
★而 faction_ai 的函式頭是：
  :1212  func evaluate_all(state, team_ids): _evaluate_all_body(state, team_ids)   ← 一行委派
⇒ ★★病在委派【之後】 ⇒ 讀函式頭的掃法【看不到它】
⇒ ★★★所以我那句「其餘 13 支沒問題」是用【已經失敗過一次的方法】得到的
```

★**我認為正確的判準是**（請你評這一句）：

> **跟著呼叫鏈走到【真正做事的那個迴圈】，然後問：這個迴圈在迭代什麼？**
> 迭代 `team_ids` ⇒ 隊粒度 ✓｜迭代 `state.factions`／`state.tiles`／任何**群體容器** ⇒ 粒度不匹配 ✗

★★請你用**你自己的方法**重掃那 13 支（我不希望你照我的方法走一遍，那只會確認我的盲點）。
★★★**特別是**：有沒有哪一支的呼叫鏈末端在迭代**成員／子隊／格子**這種「一群」的容器。

# Q1：`due_factions` 與 `due_teams` 是兩套相位 —— 它們併存合理嗎

```
勢力在相位 A 評估它的成員；而那些成員自己在相位 B₁…B_M 各自被處理
⇒ ★勢力看到的成員狀態，是【上一次該成員被處理之後】的狀態
```

★我認為**合理且與今天等價**：今天勢力也是在整點讀成員狀態，而成員在**同一顆 tick 的稍早**
才被 `collect`／`consumption` 更新 —— 兩者都是「讀最近一次的結果」。
★★而 `_evaluate_all_body` 讀的是 `BeliefSystem.best_estimate`（**belief 不是真值**）
⇒ **感知鐵律那一側不受影響**。
★★★**但這是我的推理，請你打**：有沒有哪一段 faction 決策讀的是成員的**即時欄位**
（非 belief），而它今天靠「同一顆 tick 稍早剛更新」這個巧合成立？

# Q3：我自己查過了（★列出來免得你重查）

```
FactionData 在 state_fingerprint.gd:78 的 SUBFIELD_MAP 裡，
且 _emit_factions 會呼叫 _derived_line(f, "FD", "FactionData")
⇒ 同一個分類器 ⇒ 新欄位 FactionData.pass_next_tick 以 `_next_tick` 結尾
⇒ ★自動歸 cadence 桶 ⇒ 不進 in_ruler ⇒ 不進 fp（構造保證，與 TeamData 那顆同理由）
★同檔既有前例：FactionData.infra_eval_next_tick（`_eval_next_tick` 後綴）
★★而 _emit_factions 的手寫欄位表本票不動
```

# 四、還有一條我已經寫死在 spec 裡的禁令，請你確認它夠不夠強

```
★不可以只把 faction_ai 的 grp 改成 hour、再在內部自己判到期
  ⇒ 那樣它只在 % 60 == 0 被呼叫 ⇒ 相位不是 60 倍數的勢力【永遠等不到】
  ⇒ §2 那個取樣格的坑，換個地方再踩一次
```

# ★五、verdict 形狀

```
CLEAN ⇒ 我派 implementer 動工（他現在【沒有】在寫這段，我讓他等 R²）
issues ⇒ 逐條帶 file:line
premise_contradiction ⇒ halt，我回 blueprint
```

★**本票的 merge 現在是 blocked 的**，而理由不只是效能：
**世代 8 的邊界一旦開下去，會把「勢力 AI 每小時跑 M 次」這個缺陷醃進基線**，
之後所有人都會拿那個基線當「世界本來的樣子」。
