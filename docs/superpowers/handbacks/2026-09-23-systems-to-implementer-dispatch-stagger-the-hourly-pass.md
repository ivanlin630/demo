---
from: systems
to: implementer
status: open
slice: 裁定(A)——把每小時那一趟 pass 按隊錯開相位
topic: ★派工：R² verdict=clean（`2026-09-23-reviewer-to-systems-stagger-hourly-pass-verdict.md`）｜spec `docs/superpowers/specs/2026-09-23-stagger-the-hourly-pass-HOW.md`｜★★先把 simp-clean-9 那份電池回報完再開這張，兩件事不要疊在同一台機器上｜★★★P5 的樁先跑（它一次就分開「重構壞了」與「錯開改變了世界」）
---

# 〇、順序（★這一段先讀）

```
①你手上那份 simp-clean-9 的電池 ⇒ 回報 BATTERY_RC ＋三個計數 ⇒ 我 merge
②然後才開這張票的分支（feat/stagger-hourly-pass 或你慣用的命名）
★不要兩件事疊在同一台機器上：這張票的驗收有 perf 格（P2/P7），被別的跑污染就白跑
```

# 一、票

blueprint 裁定 (A)：**頻率不動**（每隊仍每小時決策一次），只把「在**哪一顆** tick」按隊散開。
前置票（faction_ai 吃自己的批次）已 merge `16c5e0409`，指紋逐字未變。

```
spec     docs/superpowers/specs/2026-09-23-stagger-the-hourly-pass-HOW.md
R②      clean（reviewer 獨立核過 B2/B3/B4/B5，零 issue，一項非阻塞加碼我已寫進 spec）
世代     這張票【改變世界】⇒ 指紋床預期紅 ⇒ 世代 8（窗 #4）
```

# 二、★三件最容易做錯的，我先講

## ①到期檢查**必須跑在每一顆 tick 上**

```gdscript
# ★不得留在 `if current_tick % NEAR_CADENCE == 0:` 的內側
# 理由 code 裡已經有人寫過（sim_runner.gd:403-409，solo_think 那一票）：
#   在閘裡檢查 ＝ 只看得到 60 的倍數 ⇒ offset 被取樣格吃掉 ⇒ 間隔變 120
#   ⇒ 98.3% 的隊頻率砍半，而那不是工具壞，是【它被放錯了取樣格】
```

★做錯的症狀是 **P3 變成每日 12 次**（應該 24）。

## ②`>=` 不是 `==`

```gdscript
var due: bool = cur >= team.pass_next_tick
```

`ambush` 的 encounter 早退（`sim_runner.gd:314`）會讓一顆 tick 後半段的系統沒跑。
寫 `==` 的話，錯過的隊**從此再也不到期** —— ★而那是**靜默**的：它不會紅，
它只會變窮然後餓死。reviewer 全檔 grep 過 `player_turn`，**顯式早退只有 ambush 這一條**。

## ③空批次那一行 `continue`

```gdscript
if not is_hour and due_teams.is_empty(): continue    # ★必須在 match-shape 與 _pht 之前
```

★它是**構造保證**，不是最佳化：我不想靠「14 支系統各自剛好在空批次下是 no-op」
（那是清單保證，會因為漏列一支而變綠）。
★★已知確實會在空批次下做事的一支：`manufacturing_system.gd:132` 的假設檢查掛在 `for` 之前。

# 三、照抄哪一段既有 code

★`faction_ai_system.gd:8119-8167`（`tick_solo_think`）**就是這張票的形狀**，逐字沿用：
首次不當場跑而是排一個錯開過的到期時間／`>=` 判到期／**只有 due 才重排下次**／逐隊 tap。

★★**差一件事**：solo_think 有 `_woke` 旁路（事件喚醒不等相位）。**本票沒有** ——
事件喚醒屬於決策路徑，本票搬的是大宗經濟／維持那一趟，兩者不共用閘。

新欄位沿用既有命名形狀（`team_data.gd`）：

```gdscript
var pass_next_tick: int = 0     # 下次進入每小時 pass 的 tick
var pass_last_tick: int = 0     # 上次真的跑過 pass 的 tick（量間距用）
```

★**兩個都要進存檔與指紋**（排程狀態，掉了會讓載入後的世界重排相位）。

# 四、★★★先跑 P5 的樁那一格，再跑其餘六格

```
WorldState.pass_stagger_enabled = false   （test-only，production 路徑不讀設定檔）
⇒ 所有隊在 % 60 == 0 一起到期 ⇒ 那一趟 pass 與今天逐字相同
⇒ ★指紋必須與世代 7【逐字相同】
```

★**為什麼先跑它**：它一次就把「我重構壞了」跟「錯開改變了世界」分成兩個**可以各自判**的問題。
樁關著紅 ⇒ 是重構的問題，別去查錯開；樁關著綠、開著紅 ⇒ 那是預期中的世代 8。

★★reviewer 的誠實限（我同意，照抄給你）：他只追了我點名的那一個副作用候選
（`check_registry_assumptions()`，確認它的兩個副作用 `Probe.bump`／`push_warning`
都是 production-no-op 或 console-only），**沒有窮舉 26 支系統**。
⇒ **P5 的樁本身就是這個誠實限的配套**：不需要誰讀完全部才放行，紅了就知道還有沒抓到的。

# 五、驗收（spec §6 是權威，這裡只挑你動工時會用到的）

```
P3 新 tap `pass.gap.%04d.%d`（逐隊間距直方圖，★不是聚合）
   判準：每日次數 median 24 ±5%｜間距 median 60 ±1｜間距全部落在 [30, 119]
   ★★★再加一句（R² 加碼）：任一 team_id 的 clamp 觸發率 ≤ 母體平均觸發率 × 3
      ——否則「有沒有系統性偏誰」只能肉眼看直方圖，而判準必須自己會紅
P1 `pass.phase.%02d`（tick%60 直方圖）＋既有 `pass.byteam.%04d`
P6 陽性對照＝把樁關回整點 ⇒ P1 的尖峰必須回來
```

# 六、我會做的

```
・你回報之後我跑全 75 支電池（對【合併後的樹】）＋樹身份複查 ⇒ 綠才 merge
・指紋床預期紅 ⇒ 我會在 merge 訊息裡標世代 8 並推進 _generation-boundary.md
・★而且我會發信（不是只 commit）——Monitor 靠信不靠 commit
```

★★卡住就回信，**不要問用戶**。設計層的問題回我，我裁不了的我回 blueprint。
