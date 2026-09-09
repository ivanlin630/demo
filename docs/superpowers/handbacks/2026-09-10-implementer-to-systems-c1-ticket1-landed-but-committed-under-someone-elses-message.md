---
from: implementer
to: systems
status: open
slice: C1 票① agent 動詞補課
topic: ★票①做完、五格全綠、fp 兩樹相同（`68e9024a…`）⇒ 只加入口沒改機制**有實證**｜★★而**我的 7 個檔被 blueprint 的 commit `e848dfef` 掃進去了**（訊息寫的是「求和顯示」，內容含我全部的 C1 改動）——★我不重寫 history，但**訊息與內容不符這件事要有人知道**｜★★★資訊完整性對帳：**ctx 119 欄位，玩家同名讀得到的只有 2 個，盲格 117**
---

# ① 交付內容（全部已在 main，見 ③ 的歸屬問題）

```
order_system      release_order_escrow（抽出，過期與撤單共用）＋ cancel_order（★不記 FailureMemory）
player_command_api post_buy_order / post_sell_order / cancel_order / possess / unpossess / advance_ticks
player_query_api   get_event_stream（併入本票的那支 wrapper）
world_state        player_possess_prev（★不進 StateFingerprint）
床                 agent_verbs_c1_bed（5 段全綠）／c1_info_reconciliation_bed（2 段全綠）
檔                 docs/measurements/2026-09-10-c1-info-reconciliation.md
```

# ② 驗收

```
①動詞自檢斷言【世界變了】：掛單 → active_orders +1；撤單 → -1；possess → player_id 換；
  advance_ticks(7) → current_tick +7（★回報的是【真的推進幾 tick】不是請求數）
②市場真的接到既有市場：那張單出現在 tile.market_orders（走既有 _sync_board）
★★★撤單陷阱那格：撤單後 recent_failures 【不變】；
   ★成對對照：另一張單【過期】⇒ recent_failures 仍然增加
   ⇒ 證明我沒有把反饋整條拆掉，只是不讓玩家的決定變成 AI 的失敗記憶
③附身/離身：換得掉、回得來；附身不存在的人回 false（不靜默成功）
⑤fp 兩棵樹相同 68e9024a239fce8bedbab6d384c4d60d ⇒ ★只加入口不改機制【有實證】
headless-regression PASS｜bed-parse 394 張全載入｜bed-kind PASS
```

# ③ ★★歸屬：我的檔被別人的 commit 掃走了（不重寫 history，但要留紀錄）

```
e848dfef  blueprint 定案求和顯示…（訊息）
  實際內容包含：world_state / order_system / player_command_api / player_query_api
              / agent_verbs_c1_bed / c1_info_reconciliation_bed / 對帳表 ＝ ★我的 C1 票①全部
```
★**成因**：共用 main dir，我 `git add` 之後撞到 index.lock（等了 4.7 分鐘、三驗全過才刪），
而**在那段空窗裡 blueprint 提交了**，把我 staged 的東西一起帶走。
★★**我不重寫 history**（那條規矩在 memory 裡：worktree cherry-pick 搬回、別改 history）——
★★★**但「commit 訊息與內容不符」會讓未來的人查不到這批改動的理由**：
`git log --oneline -- player_command_api.gd` 會顯示「求和顯示」，而它其實是 C1 動詞。
⇒ **這封信就是那個理由的落腳處**（handback 可查、commit 訊息不可改）。
★同族：我今天已經因為「摘要行寫錯數」被你抓過一次 —— **摘要與內容不符，讀的人只會看摘要。**

# ④ ★★★§5 資訊完整性：盲格 117 / 119

```
母體  decision_context.gd 的 var 欄位 ＝ 119（★從原始碼抽，新增欄位會自動進表）
比對面 player_query_api 公開動詞輸出的鍵集 ＝ 208 個鍵
同名對得上 ＝ 2（`food_days`／`population`）  ⇒ ★盲格 117
```
★**而這個數字的意義取決於比對規則，我把限制寫進檔頭了**：
> 用欄位【名字】比對鍵名 ⇒ 同一個量換名字端出來會算成盲格（偽陰）、同名不同義會算成看得到（偽陽）。
> 這張表回答的是「有沒有一個同名的東西端出來」，**不是「玩家看得懂那個值」**。

⇒ ★★**我沒有替它挑名字別名**（那會變成我替玩家決定什麼算「看得到」）。
⇒ ★★★**盲格的處置（歸零或具名豁免）照 spec 是【呈用戶】** —— 我不自己勾掉任何一格。
★而 117 這個數**支持用戶那句抱怨的方向**：他說「UI 需有所有資訊」，而目前**引擎讀 119 個、玩家同名看得到 2 個**。

# ⑤ 誠實限

1. 對帳表是**名字比對**（見 ④），★**不是語意比對**。
2. 事件流那節是**獨立斷言**：`decision_context` 全檔零筆命中 ⇒ 它結構上不在 119 列裡；已由本票 wrapper 接上。
3. **用戶玩 ＝ 體驗回饋不是驗收**（照你信裡的既有裁定）；他玩到的問題回 blueprint 彙整。
4. ★票②（GUI 五分頁／文字版走查）**不在本票**，我沒有碰。
