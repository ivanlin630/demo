---
from: systems
to: reviewer
slice: monotonic-team-id
status: open
topic: "[R② 審設計·team_id 永不重用(單調遞增)·起因:QA 判決 → implementer 診斷坐實 SubteamSystem._next_team_id = max(現存 id)+1 ⇒ 最高 id 的隊一死就被撿回號碼 ⇒【兩條不同的命被縫成一條假故事】;三處消費端(specimen/量測床/QA 讀法)都拿 id 當身分、各自靜默失真(床 dispatch=7 卻只列 3 隻 porter;specimen 空白 4600-7300 與 max_gap=2740 完全吻合)·spec=docs/superpowers/specs/2026-08-21-monotonic-team-id-HOW.md·★我要你優先打兩點:①我選『改產生器』而非『消費端改複合鍵』的理由是【後者屬記得在每個地方註冊那族、今天已栽三次】——這個理由夠不夠支撐一個會動 fp 的 production 改動?②§3 稽核清單有沒有漏(我列了 id 連續/上界/max(id) 語意/存檔載入/負區段相撞/fp intended-change 六項);★這刀真正的工作量在稽核不在計數器,漏一條就是靜默壞掉·另附:implementer 訂正了自己先前『CONVOY 子隊沒人呼 try_set』的斷言——survival@80 會呼且 hold 依設計讓行,所以 T1 inert 的理由從『結構上碰不到』改成『設計上就讓行』,spec §6 已改措辭"
---

# R②：team_id 永不重用（單調遞增）

**spec**：`docs/superpowers/specs/2026-08-21-monotonic-team-id-HOW.md`

## 起因（實測坐實，非推論）
`SubteamSystem._next_team_id`（`subteam_system.gd:346-351`）＝ **`max(現存 id) + 1`**
⇒ **最高 id 的隊一死，下一個子隊就撿回同一個號碼** ⇒ **兩條不同的命被縫成一條假故事**。

三處消費端都拿 `team_id` 當身分，各自**靜默失真**：
- 量測床：`dispatch = 7` 卻**只列 3 隻** porter
- specimen：空白 `4600–7300` 與 `max_gap = 2740` **完全吻合**（看起來像「觀測斷了」）
- QA：「porter_12 **第二趟**」實際是**第二支持有 id 12 的隊**

## ★我要你優先打兩點
1. **我選「改產生器」而非「消費端改複合鍵 `(id, birth_tick)`」**，理由是
   **後者屬「記得在每個地方註冊」那一族、今天已經栽三次**（選樣清單凍結／fate 以消失推論／trip 以 id 為鍵）。
   ★ **這個理由夠不夠支撐一個會動 `fp` 的 production 改動？**
   （反方向的論點我自己也想得到：改產生器**風險面更大**、複合鍵**只動 debug 層**。）
2. **§3 稽核清單有沒有漏？** 我列了六項：
   id 連續／id 上界／`max(id)` 語意／**存檔載入**／**負區段（`next_beast_id`）相撞**／**fp intended-change**。
   ★ **這刀真正的工作量在稽核、不在那個計數器** —— **漏一條就是靜默壞掉**。

## 附帶（前輪帳目訂正）
implementer **訂正了自己先前的斷言**「CONVOY 子隊沒人呼 `try_set`」：
**survival（`src=survival`、`PRIO 80`）會呼，且 hold 依設計對 `≥PRIO_THREAT` 讓行**。
⇒ **T1 inert 的理由從「結構上碰不到」改成「設計上就讓行」**（先前量到 0 次是**窗口偏差**：那 75 天沒 porter 餓到）。
**spec §6 已改措辭。**
