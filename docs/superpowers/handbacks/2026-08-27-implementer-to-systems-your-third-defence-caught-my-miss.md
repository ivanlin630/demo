---
from: implementer
to: systems
status: open
slice: S1b-bare-tick-closure
tier: infra
topic: ★★★★你加的第三條防線第一次跑就抓到我漏的東西：★(a) 不是 0 是 1 —— `player_trade_system.gd:103` 的 `current_tick - 1000` 是真裸 tick,被寬規則安靜吃掉;★★而症狀只有一個【專用規則命中 0】,肉眼審清單一輩子看不到;★★★S1b 已 merged 的那份結論要改,新分類 143=(a)1+(b)1+(c)49+(d)92,commit 6586bc39
---

# ★★★★①你那條防線抓到的東西 —— **而它抓到的是【我的結論錯了】**

**第一次跑就吐出**：**2 條「已死」（命中 0）＋ 3 條「太寬」（≥20）。**
★**而「已死」不是那些規則沒用 —— 是【被遮蔽】。**

**規則順序即優先序，而我把寬規則排在專用規則前面** ⇒ **寬的先命中、`break`，專用的永遠輪不到**：

| 被吃掉的 | 吃它的寬規則 | 原判 | ★真相 |
|---|---|---|---|
| `sim_runner.gd:294/340` `TICKS_PER_DAY / 4`（註解寫「**每 6 小時**」） | `% … == 0` | (d) 不是時間量 | **是時間量**（已隨根縮放 ⇒ (c)） |
| `player_trade_system.gd:103` **`current_tick - 1000`** | `get("event_id", 0)` | (d) 不是時間量 | ★★★**真的裸 tick ⇒ (a)** |

## ★★⇒ **我上一輪的頭條結論「(a) ＝ 0」是錯的。正確是 (a) ＝ 1。**
★**而 S1b 已經 merged 了** —— **那份「證明了不用改」的結論要跟著改成「只有一顆要改，已修」。**

## ★★★而這件事的重點不是「我漏了一顆」，是【症狀只有一個】
> **專用規則命中 0。**
★**清單本身長得完全正常**：**143 筆、對帳一致、`NEEDS_HUMAN=0`、每筆都有理由。**
★★**肉眼審那份清單一輩子也看不到這個病** —— **因為被吃掉的那筆【有一個看起來很合理的理由】**
（`sentinel_default：get(k, 0/-1) 的預設值是哨兵` —— 那句話對那一行來說是真的，只是不是全部）。
⇒ ★★★**你要的不是「多一欄資訊」，是【唯一一個能看見遮蔽的訊號】。**

# ★②一併訂正的誤標：`N * TICKS_PER_*` 我判錯桶了
```
BETRAY_CHECK_INTERVAL = 50 * TICKS_PER_HOUR   # 每 50 小時
"expire_tick": spawn_tick + 2 * TICKS_PER_DAY
```
**我原本判 (d) 不是時間量。★它們【是】時間量** —— 只是**已由具名常數導出、會隨根自動縮放**。
⇒ ★★**「不需要改」是 (c)；「不是時間量」是 (d)。是兩件事，我把它們混了。**
★**而混掉的後果剛好是你在意的那個方向**：**被判進 (d) 的東西不會再被人看到。**

# ★③還修了一個計數虛胖（★不影響結論，但會誤導下一個人）
**規則是逐【行】比對，而列是逐【字面量】** ⇒ **`current_tick - 1000` 那行的 `get(k, 0)` 的 `0` 也被報成 (a)**
⇒ **1 個站點虛胖成 2 列。** ★**修法**：`a_change` 加 `lit_bound` —— **捕捉到的數字必須就是該列的字面量。**

# ★④那顆 (a) 已修（★等價性靠算術，不靠 fp）
```gdscript
- if int(mem.get("event_id", 0)) < state.world.current_tick - 1000:
+ if int(mem.get("event_id", 0)) < state.world.current_tick - TimeScale.hours(100):
```
★**證明**：`hours(100) = 100 * 240 / 24 = 1000`，**整數除法無餘 ⇒ 逐值相同。**

## ★★而 `fp` 對這顆是【沉默】的 —— 我不拿它當證據
**callers 窮盡**（`grep -rn 'PlayerTradeSystem' scripts/ --include=*.gd`，排除 `scripts/debug/` 與自身定義檔）：
```
player_api_mapper.gd:882      player_command_system.gd:426      player_query_api.gd:102
⇒ ★三個全是 player-facing，headless 世界迴圈【不驅動】它
```
⇒ ★★**`fp` 不變不是這顆的證據**，只是「沒有別的東西被我改壞」的證據。
★★★**我本來可以直接寫「fp 逐位元不變 ⇒ 等價」——那句話會是真的，但它證的不是這件事。**

# ★⑤新分類（★可重跑，commit `6586bc39` 已 push）
```
143 ＝ (a) 改 1 ＋ (b) 延後 1 ＋ (c) 白名單 49 ＋ (d) 不是時間量 92
NEEDS_HUMAN = 0｜★已死規則 0（遮蔽解掉後全部復活）
★剩兩條「太寬」：derived_mult 22 ／ zero_compare 24
  —— ★★我逐筆掃過，這兩條現在的標籤是對的（22 筆全是 N × 具名常數；24 筆全是餘數判準的 0）
```
★**(c) 從 8 漲到 49**：**多出來的全是原本被吃進 (d) 的「已由具名常數導出」那族。**
★★**這不是白名單灌水** —— **它們每一條都有同一個理由：「是時間量，但分母/因子已是具名常數，改根會自動跟著動」。**

## 落地 exact path
```
A:\GDS\demo\.worktrees\old-growth\scripts\debug\bare_tick_triage.gd
A:\GDS\demo\.worktrees\old-growth\docs\measurements\2026-08-27-bare-tick-triage.txt
A:\GDS\demo\.worktrees\old-growth\scripts\simulation\player_trade_system.gd:103
```

# ⑥閘（★守衛自己也重跑過）
```
fp warring=06580e7f… ／ peaceful=533ebf68…（逐位元不變）
headless Q1 跑完 ＋ Q2 baseline 7 / 實測 7｜憲法閘 PASS (74)｜裸 tick 守衛 PASS (143, NEEDS_HUMAN=0)
```

# ★⑦對 S2 的影響（★一句，因為你在寫 spec）
**S1b 交給 S2 的 (b) 仍然只有一顆**（`sim_bridge.gd:7 TICKS_PER_TURN = 24`）——**這點沒變。**
★**變的是**：**S2 不必再處理 `player_trade_system:103`，它已經在 S1b 收掉了。**
