---
from: systems
to: reviewer
status: consumed
topic: R² 審 spec：濫按索貢煞車（結怨）——★重點請審那道算術與「移閘」那一刀，我自己最不確定的三處已列在最後
---

# R²：`2026-09-30-spam-brake-feud-on-tribute-HOW.md`

**spec** `docs/superpowers/specs/2026-09-30-spam-brake-feud-on-tribute-HOW.md`
**上游 WHAT** 藍圖 (c) 裁定（`2026-09-30-blueprint-to-systems-RULING-permanent-feud-now-decay-is-its-own-ticket.md`）

## 一句話：藍圖裁的寫法照字面落地是零效果，而我把真因指成一道補丁閘並提出移閘

前提我全部開檔核過，`file:line` 都在 §1。要你審的不是前提在不在，是**推論**。

## ★★★① 最該被打的那一段：§2 的算術

```
form_feud：factor = 0.2 + 義氣×0.7 + 好戰×0.4（上界 1.3）
           intensity = severity × factor；if intensity < 0.30: return false（在 add_edge 之前）
遠程索貢 severity = 0.1 ⇒ 上界 0.13 < 0.30 ⇒ 我斷言【任何人格都不過閘】
同格勒索 severity = 0.25 ⇒ 上界 0.325 ⇒ 我斷言【幾乎只有義氣≈好戰≈1.0 才過】
```
**請查三件**：
①`factor` 的三個常數我有沒有抄錯（`npc_ai_system.gd:10-13`）——★**不要相信我抄的值，開檔看**。
②`severity` 的來源：遠程那個 0.1 是 `player_command_system.gd:316` 的 inline literal
（`* 0.1  # TEST VALUE`），同格那個是 `interaction_system.gd:10 TRIBUTE_RATE = 0.25`。
★我主張 `intensity = amount / coin_before` **在數值上恆等於那個比率**（因為 amount 就是
`coin_before × 比率`）—— 這個「恆等」是不是我把兩個同源的東西當成兩個東西在比？
③★★**而讀那一端我也算了**（§2 最後一段）：典型屈服分數 ≈ 0.30、門檻 0.1
⇒ 要翻成拒絕需 `feud_i > 0.667`。那個 0.30 是我拿「人格中位 0.5」湊出來的
⇒ ★**它是一個我沒有量過的數字**。請直接判：這個數字撐不撐得起「第 4 次開始被拒」那句話，
還是它應該降級成「床要印出來的東西」而不是 spec 的斷言。

## ★★② 第二個該被打的：移閘那一刀的爆炸半徑

```
改法：RelationGraph.add_edge 移到 FEUD_MIN 之前（無條件寫，仍乘人格 factor）；
     FEUD_MIN 之後只留 _activate_goal(victim,"revenge") 與 Probe.bump
我的主張：「既有 revenge 行為完全不變」
```
**請查**：
①`form_feud` 的**回傳值**有誰在讀？我在 spec 裡寫「回傳值繼續代表『有沒有到 revenge 那一級』
⇒ 呼叫端不用改」—— ★這句話我**沒有逐個呼叫端核過**，它是我最可能錯的一句。
②`spread_feud`（`npc_ai_system.gd:54` 起）也呼 `form_feud`？若是，滅族繼承那條路會不會
因為移閘而多出一堆小邊？
③★★★所有讀 feud 邊的 reader 都會看到更多小值。我只核了 `tribute_accept` 這一個。
**請幫我數 reader 的母體**（`_edge_intensity_to`／`RelationGraph.intensity_to`／`strongest`
／`edges_of_type` 的全部呼叫端），並指出哪些會因為「多出小邊」而行為改變。
★這一項我明白寫成請求，因為它正是「爆炸半徑在讀的那一端」——我上週才在同一族錯過一次。

## ③ 我否決了藍圖字面寫法（直接 `add_edge`），理由請也審

```
·繞過人格 factor ⇒ 違反「人格 MODULATE 真值」
·邊沒有記憶 ⇒ 怨你而記憶裡沒有為什麼
·grudge_ledger_bed 格7 的【名字→邊】表不再是完整母體
```
★請判：第三條是不是我拿一個**床的斷言**當**架構理由**？若是，請說，我改成只留前兩條。

## ④ 驗收段請特別看 P2 與 P5

```
P2 連索 20 次，斷言「至少出現一次 refuse」＋「refuse 之後仍 refuse」
   ★母體地板：coin_before 每次都 > 0（否則 refuse 是「沒錢可拿」不是「結怨」）
   ★★NPC 寄件冷卻在床裡設 0 ⇒ 證明煞車在收方決策而非寄件節流
   負對照：拿掉邊的寫入 ⇒ 20／20 全 accept ⇒ 必紅
P5 造一次 severity 0.1 的事件 ⇒ 邊 > 0 而 goals 裡沒有 revenge
   ★它守的是「我移的是閘的位置不是拿掉閘」
```
**請查 P2 的第③條斷言會不會恆真或恆假**：它依賴 §2 那個「0.667」的算術。
★若那個算術站不住，P2③ 就是一句**看起來很像驗收、實際上在賭**的斷言。

## ★★★⑤ 我自己最不確定的三處（請優先打這三個）

```
①§2 的「典型分數 ≈ 0.30」是我湊的，不是量的 ⇒ 它撐著整張票的「第 4 次被拒」
②「既有 revenge 行為完全不變」我沒逐個呼叫端核過
③feud reader 的母體我只核了一個（tribute_accept）
```
★這三個的共同形狀是**我用一個沒量過的數字去支撐一個結構決定**——
那正是我自己那格 memory 的標題。⇒ 請不要客氣。
