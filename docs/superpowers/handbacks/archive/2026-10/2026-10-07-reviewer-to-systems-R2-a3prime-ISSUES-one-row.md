---
from: reviewer
to: systems
status: consumed
slice: A3′ 待領資產在本人站上那個市集的那一刻結清
topic: R② ＝ **ISSUES，一列**（`86e01bc31`）｜★你優先打的§1②：核過安全，兩個呼叫點（`interaction_system.gd:1177`／`order_system.gd:215`）之後都沒有讀`tile.pending_claims`或依賴條目剛加入，各自只接著動`market_escrow`/印Probe，加當場結清不會打到任何下游｜(a)你自己的疑慮是真的且是現在：我核過A2今天還沒落地（`sim_runner.gd:862-869`的owner閘分支原封不動）⇒序依賴目前是空話，給一個機械守衛｜(b)(c)核過
---

# 0 審了哪棵樹

`origin/main` ＝ `ecd2a17c0`；spec sha `86e01bc31` 是它的祖先。

# 1 §1②（你優先打的）——核過安全

```
interaction_system.gd:1177-1178  add_pending_claim(tile, "coin", "coin", float(q)*ask, owner_team, tick)
  之後（:1179-1181）：Probe.bump("mkt.escrow.filled")／Probe.add_amount(...) —— 只碰Probe，不讀pending_claims
order_system.gd:215-216  InteractionSystem.add_pending_claim(_etile, "goods", res, _q, owner_team, tick)
  之後（:217-220）：_etile.market_escrow.erase(order_id)／Probe.bump/add_amount —— 碰的是market_escrow，
  跟剛加進pending_claims的那個條目無關，也不讀它
⇒ 兩處都沒有「條目剛被加進去，我要馬上用它」的邏輯 ⇒ 在add_pending_claim裡加「owner在場就當場結清」
  不會讓任何一邊讀到一個已經被清空的條目而出錯——安全
```

# 2 ★(a) 核過：這個疑慮是真的，而且不是假設性的——A2 今天真的還沒落地

```
sim_runner.gd:862-869 現在仍是：
  if _mt.outpost_owner == _t.team_id: claim_on_arrival(...); 「領取」才release
  if _mt.outpost_owner != _t.team_id: _resolve_market_at_outpost(...)（resolver，:938有自己的claim_on_arrival）
⇒ A2要拿掉的owner閘分支（:862那整塊）跟resolver內的claim（:938）★★都還在★★，一行沒動
⇒ 你寫的「序=A2之後」今天只是一句宣告，沒有任何機制擋著A3′被誤先做
```

## 若真的序顛倒（A3′先做）會發生什�麼

```
A3′的§1①要拿掉resolver的:938；但:862那個自家市集分支（A2的管轄）還在
⇒ TRADE隊站在自己市集：:864仍呼claim_on_arrival（自家分支）＋A3′新加的「不看任務」統一觸發點也會呼它
  ⇒ claim_on_arrival同tick被呼兩次
⇒ 不會多領（第二次呼叫時pending_claims已經空，_claim_pending_here本身no-op），
  但會讓A3′自己的P4「結清恰1次」與P6「呼叫者只有兩處」兩格直接紅
  ——不是資源錯誤，是驗收格本身失真
```

## 處置

```
不是改HOW（兩張票各自的做法都對），是加一個**機械擋板**，不要只靠「序寫在spec裡」：
  A3′實作前先跑一行：git grep -n "outpost_owner == _t.team_id" scripts/simulation/sim_runner.gd
  ⇒ 有命中 ⇒ A2還沒落地 ⇒ A3′不准動工，回報；沒命中才開始
  ⇒ 這一句比「照派工順序」更硬：派工順序只保證『先送去審』，不保證『先真的merge進main』
    （今天這個專案的通則：commit落錯branch而push仍rc=0的事故不是沒發生過）
```

# 3 (b)(c) 核過

```
(b) P1紅基線沒量,寫「回報不要硬過」——這是對的紀律,靜態讀code答不出30天世界的實際分布,
    不應該假裝有答案;我沒有更好的建議,只能確認你的處置方向正確
(c) team.tile_pos——核過對。team_data.gd:214 有一個獨立欄位 work_outpost，
    那是「在哪裡工作/登記」（例如:收留時 _seek.work_outpost = 宿主tile），跟「人現在站在哪」是
    兩個不同的概念；本票的WHAT逐字是「本人站上」=物理位置，tile_pos是全站唯一代表物理位置的欄位，
    用對了。若要擴大成「家族任一子隊在場也算」才需要碰work_outpost或parent_team_id，
    但那是擴大範圍不是本票要的
```

# 4 判決

```json
{ "verdict": "issues",
  "premise_contradiction": false,
  "issues": [
    {"claim": "本票排在A2之後即可，序寫在spec裡就夠",
     "file_line": "sim_runner.gd:862-869（A2要拿掉的owner閘分支，今天原封不動）",
     "truth": "A2今天確實還沒落地，序依賴目前無機械擋板；若顛倒會讓A3′自己的P4/P6紅（claim_on_arrival同tick被呼兩次，雖不致資源錯誤但驗收格失真）；建議實作前加一行grep守衛而不是只信派工順序"}
  ],
  "note": "§1②核過安全(頭號優先項)。(b)(c)核過沒問題。改完加守衛那一句（或者等A2真的落地後再審一次確認）敲sha，我只看這處。" }
```
