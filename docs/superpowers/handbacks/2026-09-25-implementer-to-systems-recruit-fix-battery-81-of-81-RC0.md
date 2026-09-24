---
from: implementer
to: systems
status: consumed
topic: 招募對不存在的交易收費 —— 修完、電池 81／81 BATTERY_RC=0，含負對照複製用戶原症狀
---

# 招募那張：綠了。而卷面的綠是【指名】驗過的，不是數出來的

**branch** `fix/recruit-charges-for-nothing`　**commit** `7cc393e92`（已 push）
**電池** `BATTERY_RC=0`　**81 ✓／0 ✗**　run-id `63489-184621`　runner-self `93c2c6fd`　lines 458
**卷面** `C:/Users/I12/AppData/Local/Temp/claude/A--GDS-demo/440df8b3-945b-4cc6-bd63-9750aeb25aee/scratchpad/bat_rc.log`
（★scratchpad 不是 repo ⇒ 這份卷面**不耐久**。要留證的話說一聲，我把它複製到 `docs/measurements/`。）

## ★★★①「綠」是怎麼驗的 —— 三道，而每一道都擋一種「看起來綠」

```
①run-id 唯一          grep -o 'run-id=' ⇒ 只有 63489-184621 一個
  ⇒ ★兩個 run-id ＝ 兩輪的輸出疊在一起 ⇒ 不可判（runner 自己在卷面上警告這件事）
②閘 id【集合】相等     comm 兩個方向都是空集合，81／81
  ⇒ ★★不是比數量：2026-09-23 那次「行數 ≥ 兩邊」被 77 滿足而少一支閘
    ⇒ 判準是【指名】不是【數數】（計數是有損投影，缺陷活在它丟掉的那一維）
③電池期間 HEAD 沒動    reflog：7cc393e92 之後沒有任何 checkout／commit
  ⇒ ★★★「跑的是哪一棵樹」必須可證，而共用 main dir 的那棵 20 分鐘內一定會動
```

**★而②那一道第一版報「2 格沒綠」（`gateA`／`gateA-hysteresis`）—— 那是【我的比對器】的缺陷**：
抽取用 `[a-z0-9-]+`，**大寫 `A` 不在字集裡** ⇒ `gateA` 被截成 `gate` ⇒ 對不上。
⇒ ★誤差方向是**多報**（吵，不漏）⇒ 可以拿來排查。★★但它值得記，因為**閘 id 含大寫這件事沒有任何東西在守**，下一個寫比對器的人會再踩一次。

**★★本票【改的就是閘】那一格是新檔的綠**：`ui-flow （10s）`，而它的 `expect` 是這次重算的（46 格）。

## ②修了什麼（三個獨立的錯，玩家只看得到第三個）

| # | 錯 | 修法 | file |
|---|---|---|---|
| ① | 用**代理量**代替真正的量：`population > 1` 問「人夠多嗎」而不是「真的有匿名嗎」⇒ 對方全具名時照樣回 true | 改問 `AnonTierSystem.total_pop()`。★**不自己算「人口減具名數」**——那會是第二份真相 | `player_command_system.gd` |
| ② | `transfer_proportional` 的回傳**沒有人看**（它回逐 tier 搬運量） | 先搬、數真的搬了幾個。★`share` 必須用**搬之前**的人數算 ⇒ 它排在 transfer 之前 | 同上 |
| ③ | `moved == 0` 仍然扣錢、仍然印「招募成功」 | 不扣錢、`ok:false`、說得出原因。★★**先搬再收費**比「收了再退」強：搬 0 人走不到收費那一行 ⇒ **不需要退款路徑** | 同上 |

成功訊息改「招到 N 人」＋ `moved` 進 payload ⇒ ★★★玩家從此分辨得出「招到 0 人」與「沒招成」，**而今天這兩者是同一句話**。

## ★★★③守它的那一格，以及它為什麼不是恆真

新增一格 `_test_recruit_pay_matches_delivery`，母體地板三道（照 spec 指名）：
找得到兩支非玩家隊／招得到那支**真的有**匿名／**招不到那支真的【沒有】匿名**。
⇒ ★最後那一道是關鍵：**「收費與交付成對」在【全部都招得到】的樣本上恆真** ⇒ 沒有那一道，這一格會是恆綠。

**實測（陽性）**：招得到 `ok=true coin_delta=-50 anon_delta=+1`；招不到 `ok=false coin_delta=0 anon_delta=0`。
**★★負對照（陰性）**：還原代理量 ＋ 不看 `moved` ⇒ 招不到那支變成 `ok=true coin_delta=-50 anon_delta=0`，**兩格紅**。
⇒ ★★★那**完整複製了用戶報的那個 bug**（扣 50、搬 0、說成功）—— **不是類似的樣本，是【那一個】樣本。**

## ④爆炸半徑（數過的，不是猜的）

- `_target_has_anon` 與 `_recruit_anon_internal` **全庫只有玩家路徑呼叫**（`:57` 可用性、`:386` 玩家動作）⇒ **無 NPC 呼叫端** ⇒ 無玩家世界的 fp 不受影響。
- `headless_test:12427` 直呼它，而那支把目標 seed 成有 7 個匿名 ⇒ 仍然成功、不受影響。

## ⑤不在本票（★留著，否則下一個人會以為它做完了）

「**花錢買人而對方沒有意願**」那件事本身 —— `player_command_system.gd:38` 自書 STUB，**WHAT 待裁**。
⇒ 本票只保證它**不再對不存在的交易收費**。

## ⑥下一站與待辦（★你那三件＋我這三件，落點都釘好了）

**我的下一張＝游標真值那張**（`feat/cursor-hover-truth`，HEAD `5f093cab9`，★**部分驗證**，P1/P2/P5 負對照與整份電池**都還沒跑**）。它要帶的東西：

1. **X 鍵＝推進一小時** ——★**那一行還不存在**（`KEY_X` 零命中）⇒ 順序是**先寫產品碼、再寫兩格**。形狀照抄 `text_ui_main.gd:353`（`request_advance(WorldState.TICKS_PER_DAY)`，SPACE 那一支），不發明。
2. **靜態格 ＋ 行為格成對**：靜態格斷言那一行寫 `TICKS_PER_HOUR` 而非字面量（★**母體地板：先斷言「抓到了那一行」，找不到＝不可判不是綠**）；行為格（你信裡稱 P8）斷言按 X ⇒ `current_tick` 增加 `TICKS_PER_HOUR`。★★**衝突時行為格贏**，而 **P8 現在不存在**（見下）。
3. **併入本票的兩個缺陷修正**（我自己床上抓到的，你裁併入這一張）：
   - `command_replay_bed.gd:361` `msg.contains("3") and msg.contains("4")` ⇒ 任何位置的數字都餵得飽（「第 34 筆」就綠）。**換成被守的性質本身**：`move_to(3,4)` 與 `move_to(5,6)` 斷言**兩句話不相同**。
   - `command_replay_bed.gd:392-397` `has_reason` 在迴圈裡**被覆寫**⇒ 只有最後一筆被拒的算。改**累積**＋**斷言那一輪被拒筆數 ≥2**。
4. **單位統一**：頁腳要說「1 小時」不是「60 tick」。

**★★而有兩個【事實】要進你那份 spec，它們現在不是既有的**（`git show` 驗過）：
- **`P8`／P9–P12 不存在**。hover 分支上只有四個 hover 格：`_test_hover_p1_live`／`_test_hover_p2_title`／`_test_hover_p3_no_state_write`／`_test_hover_p5_empty_and_crowded`。
  ⇒ ★★★spec 若寫成「已有 P8」⇒ **下一個人不會去做它，而靜態格會被當成守衛** ⇒ **spec 會親手造出它自己禁止的東西**（你自己那條：沒有行為層孿生的靜態格只是早期警報）。
- **X 鍵不存在**（同上）。

**★`bare-tick` 那條 defer 的代價（算過的）**：擴符號表加 `request_advance`／`advance_ticks`／`tick_step` ⇒ **新增候選 12**（不是我先前口頭說的 44 —— 掃描器的 `EXCLUDE_DIRS` 已排除 `scripts/debug`，**床本來就不在母體裡**）。12 個之中 5 個帶字面數字、**2 個是註解行**（純噪音）。

**★★`ADVANCE_UNTIL_EVENT` 那條**（你(a)現在、(b)登 defer）：(b) 的解除條件是**我數出 `is_advancing()` 呼叫端**。★我這一輪沒數（紀律：電池期間不碰檔）—— **下一輪數給你，不猜**。

## ★⑦一件要你決定的（不是技術微決策，是留證政策）

這份卷面在 **scratchpad**，它**不耐久**（session 目錄）。而它是 `BATTERY_RC=0` 的唯一證據。
⇒ 要不要立一條「**電池卷面必須複製進 `docs/measurements/`**」？★我傾向**要**，理由：今天我們兩個人一整輪的判斷都建在「卷面上那個秒數」上（`world-fp 254s` 坐實了我那支守衛的假紅），而**那份卷面現在隨 session 消失**。★★但它會讓 repo 長大 ⇒ 是你的格，我不自己立。
