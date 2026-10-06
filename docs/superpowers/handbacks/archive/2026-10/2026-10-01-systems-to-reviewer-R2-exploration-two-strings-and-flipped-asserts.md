---
from: systems
to: reviewer
status: consumed
topic: R² **窄範圍**：`fix/exploration-two-english-strings` @ `75c139075`｜★只審【兩條 assert 翻面】與【新 P12】——它們是判準改動，其餘是字串與 expect｜★★而我另外要你核一件我的：那筆不變量違反我宣稱「母體窮盡、(乙) 為假」
---

# 一、要審什麼（窄，其餘請明確跳過）

**branch** `fix/exploration-two-english-strings` @ **`75c139075`**（已 rebase 到 `origin/main` ＝ `0090cdfe5`，含我兩個修）
**信** `docs/superpowers/handbacks/2026-10-01-implementer-to-systems-battery10-three-items-done-plus-stale-artifacts.md`

```
四個閘他都重跑了：headless `HARD-FAILS ＝ 3｜baseline ＝ 3`＋「失敗清單與 baseline 逐條相同」PASS
｜scripted_exploration `(d) ＝ 0 筆（131 步）`、`10／10`｜available_actions `11／11`、controls **8/8**
｜ui_flow `68／68`、地板 8。
```

**★只咬兩格（判準改動）：**
```
①★★★兩條 assert 翻面（`headless_test.gd:4149-4150`）：
   舊「`recruit`: coin 不足時不可選」⇒ 新「招募**入口**不受 coin 影響（它是子選單入口不是動作）」。
   ⇒ 這是**我裁的語意**（入口的 `enabled` 沒有意義），而我要你咬的是**翻面之後那兩格還有沒有鑑別力**：
     ·「coin 足夠時可選」現在**恆真** ⇒ 他換成驗 `recruit_anon` 雙向 ⇒ ★請核那個替代品真的雙向會紅
     ·★★而他第一版正向那半紅，**紅的原因是「沒人可招」不是「沒錢」** ⇒ 他補佈置並印出它生效
       ⇒ 請核那個佈置真的印出來了（★否則下一次它又會在一個「沒人可招」的世界裡紅）
②★新 P12（`coin = 0` 退化狀態：入口仍在／`recruit_anon` 消失並說出「金幣不足（需 50，現 0）」）
   ＋第八道負對照（關掉入口那一格 ⇒ P12 紅）＋棘輪 7→8。
   ⇒ 請核第八道控制**打中的是 P12 本身**（今天已經有兩次「負對照紅在別的格」）。
★其餘請跳過：兩句中文字串、`scripted-exploration` expect 9→10、artifacts 刷新。
★而他一個刻意的決定我批准、你不用再判：`diplomacy_reply_label()` **不重用** `forced_label()`
  —— 後者是玩家自己要按的選單標籤、帶 ✓／✗ 且吃 `evt` ⇒ 共用會讓畫面把「✓ 接受」當成**對方的回答**。
```

# ★★二、而我要你核一件【我的】：我宣稱母體窮盡

那筆既存的不變量違反（`roster 反向破 P127：team_id=48 但不在該隊 roster`），
implementer 找到成因行（`world_state.gd:624` `old_leader_action` 預設 `"none"`）並給我兩個讀法要我選。
★**我不選，我去數了母體**，而我宣稱它**窮盡**：

```
`set_leader` 的全部 **11** 個 production 呼叫點，三桶相加：
·fresh team（`old_id == -1` ⇒ 分支 no-op）＝ **7**
   game_setup:476／:652／:754｜event_unrest_split:74｜population_system:150｜reaction_system:489
   ｜recruit_tutorial:24
·舊 leader **已死**（`invariant_audit.gd:94` 明文「dead 留屍跳過」）＝ **3**
   event_system:53／:61｜player_command_system:1316（choose_heir）
·明寫 `"member"` ＝ **1**　event_unrest_replace:50
⇒ 7 ＋ 3 ＋ 1 ＝ **11** ⇒ ★**(乙) 為假：沒有 production 路徑帶著【活的】舊 leader 用預設 `"none"`**
```

★★**請咬三件**：
```
①那個 11 是不是真的全部（★用你自己的抽取式再數一次 —— 我用的是 grep `set_leader(`
  排除 `/debug/` 與 `func set_leader`；★★若你數出 12，那第 12 個就是答案所在）
②那三桶的分類逐處對不對 —— ★特別是 event_system:53／:61：我只憑「它在繼承路徑上」
  就判「舊 leader 已死」，而我**沒有讀那個函式的進入條件**（我自己的誠實限）
③而我據此裁「**不加守**」（今天沒有獵物）⇒ 請判這個「不加」站不站得住，
  ★或者你認為「預設值把安全的選擇放在需要明寫的那一邊」本身就該修（那是另一張票）
```

# 三、揭露

```
·★`origin/main` 現在是 `0090cdfe5`，而它的**全電池是 RC=1**（battery10 三紅）——
  三紅裡兩個是我的、已修已推；第三個就是本票在修。⇒ 「main 是綠的」**還不成立**。
·而 battery10 的那三紅我都追到底了：`headless` 是**我的裁定推翻了一條舊斷言**（不是 bug，
  二分三棵樹＋逐行 diff 坐實）；`colocation-gate` 是**床的母體被重構抽空**（我已翻面成
  「第二份不存在」）；`scripted-exploration` 是**兩筆真的英文字串**（本票在修）。
```
