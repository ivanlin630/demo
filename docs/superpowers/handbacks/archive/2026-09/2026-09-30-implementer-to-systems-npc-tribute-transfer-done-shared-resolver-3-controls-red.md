---
from: implementer
to: systems
status: consumed
topic: 交件：NPC↔NPC 索貢談成 ⇒ 錢真的動（共用解算點：金額與恩怨兩件事都與玩家同一支）｜★三道負對照全紅，而其中兩道【打不到它自己那一格】⇒ 我補了兩格而不是改 expect｜★★其中一道替我找到真缺口：那條分支原本沒有【行為】母體
---

# 交件：NPC↔NPC 索貢談成真轉移

**branch** `feat/npc-tribute-transfer` @ `6567595e6`（remote 同 sha，基底 origin/main `92222dae9`）
**床** `scripts/debug/npc_tribute_transfer_bed.gd`（7 格，errors 0）＋註冊表 `npc-tribute-transfer`（94 列）
**負對照** 3／3 RED-OK（共用驅動器，selfcheck 4／4 先跑）｜棘輪地板 `CONTROL_FLOOR_NPCTRIB = 3`
**權威** 照你標的順序：§1 → §2 → §6 → §9（§7 的 P6／P8 原文被 §9 取代、§3 是輸入不是指令）

## 一、做了什麼

```
新增共用解算點 `DiplomaticAiSystem.apply_tribute_accept(state, payer, taker)`：
  ·金額 ＝ `coin_before × TRIBUTE_TAKE_RATIO`（★常數宣告**恰好一處**）
  ·守恆走 `ResourceBank` 的 `demand_tribute_out`／`demand_tribute_in` 兩個 tag
  ·★恩怨走濫按煞車那票的 `write_memory("tributed", …)` —— 本支是它的**第三個**呼叫點
    （前兩個：玩家遠程索貢／`_resolve_extortion`）⇒ 呼同一支，不另外發明
玩家那條路改呼它（係數字面從那邊消失）；NPC↔NPC 的 accept 分支**新增**並呼它
⇒ 藍圖那句「缺這段＝NPC 之間濫索無煞車（只有玩家有）」因此成立。
```

## ★★二、七格的數（報數字不報狀態）

```
P6a 行為證：amount ＝ coin_before × ratio 的**精確值**（500 × 0.1 ＝ 50.000000，差 0.000000000）
P6b 靜態證：兩行原文都印出來 ——
    NPC ：`var amount: float = apply_tribute_accept(state, target, sender)`
    玩家：`var amount: float = DiplomaticAiSystem.apply_tribute_accept(state, tgt, pt)`
    ＋玩家端已無 `coin_before * 0.1` ＋`TRIBUTE_TAKE_RATIO` 宣告 1 處
P7  守恆：payer 400→360、taker 100→140、全域 coin 總量 40662.218 不變、兩個 tag 都在
P8a 小額：severity 0.1000（量出來的）⇒ 好感 0 → −0.0500（降幅 ≥ 預期下限 0.0500）、feud 邊 0
P8b 大額：同一支寫入者餵 severity 0.9 ⇒ 好感 −0.4500 且 feud 邊 1.0000（門檻是活的）
P9  連索 20 次：accept ×8 → 第 9 次起 refuse（★序列印出、不釘第幾次）
P10 ★走 NPC 分支端到端：payer coin 800→720 且好感 0→−0.0500
```

## ★★★三、兩道負對照【打不到它自己那一格】—— 我補格，沒改 expect

```
①控制「讓 NPC 分支自己寫一份轉移」原本我指 P8a 的好感那一格 ⇒ 它**沒紅**，
  而真正紅的是 P6b 的**靜態證**。★而那暴露一個真缺口：P6a／P7／P8a／P9
  **全都直呼共用解算點** ⇒ 沒有任何一格【行為上】走過那條分支
  ⇒ 「靜態證看得到、行為證看不到」＝那條分支沒有行為母體
  ⇒ ★補 P10（端到端）⇒ 現在那道控制紅在行為那一格。
②控制「把 `tributed` 塞進 FEUD_SEVERITY」在 P8a 上**照舊綠** ——
  那個被索方人格不夠極端（0.30 × factor 仍 < FEUD_MIN 0.30）⇒ 邊還是 0。
  ⇒ 補「名字不在表裡」那一格（★與 spam-brake 那次同一個坑、同一個處置）。
⇒ ★★★共同形狀：負對照打不到自己那一格 ⇒ **那一格對這個擾動沒有鑑別力**，
  處置是【補一格】或【把擾動移到判準真的在讀的地方】，不是改 expect 去遷就現況。
```

## ★★★★四、誠實限（三條，寫在床檔頭）

```
①P6a 讀的是 class 常數 ⇒ 係數被擾動時兩邊一起動、那一格仍綠
  ⇒ 擋「複製了一份係數」的是 P6b 的靜態證 ＋ 控制① ⇒ **兩證缺一不可**（你要的那條）
②★現行 ratio 0.1 這條路【到不了 FEUD_MIN 0.30】（0.1 × 人格上界 1.3 ＝ 0.13）
  ⇒ P8b 是對**同一支寫入者**餵大 severity，證門檻活著；
  ⇒ 它不是「這條路今天會寫邊」的證據，而 ratio 哪天調大這條路自己就會踩到。
③P9 第一版**沒釘領袖人格** ⇒ 20 次**全部 refuse** ⇒ 母體地板紅。
  ★那不是煞車生效，是這個被索方本來就不屈服（屈服公式 base 太低）⇒ 序列什麼都沒證。
  ⇒ 釘死（與 spam-brake 同一組值，不是這裡另挑的）之後才有東西可看。
```

## 五、我這一輪的兩顆 commit 訊息各超出一次 diff（都已就地訂正）

```
·`7a6d35ebb` 的訊息寫「棘輪地板 3」而 diff 裡沒有：我的 python 錨用了 `CONTROL_FLOOR_DVO`，
  而那個常數在【另一支 branch】（決定 vs 結果那張還沒 merge）⇒ 這棵樹找不到 ⇒ 0 命中。
  ⇒ ★★這一次的變體值得記：錨本身沒錯，錯的是我假設它在這棵樹上 ——
    多 branch 並行時「那個常數存在」是**分支相依**的事實，不是專案層的事實。
  ⇒ `6567595e6` 補上並把這段寫進訊息。
```

## 六、下一件

```
·⑤玩家面字串（108＋3 ⇒ 兩個修點：`describe()` 原樣印參數／handler 自己的 msg）
  ★它會順手把④那個「回應事件：accept：」的前綴變成中文，兩張票的修點是同一個。
·★而中文表要與既有那份**同源**（你信裡那條）：我會接 `PlayerApiMapper` 已有的那一份，
  不另開第二張表；不認得的 id 印「（未知動作：xxx）」而**不吞掉**。
·白名單不動（白名單變寬＝判準變鬆）。
```
