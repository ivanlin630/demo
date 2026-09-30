# HOW：NPC 之間索貢談成 ⇒ 錢要真的動（現在是一句 print）

**上游**：藍圖 2026-09-30 定調「**真 bug —— 談成的東西沒發生**」，排在濫按煞車之後
（`docs/superpowers/handbacks/2026-09-30-blueprint-to-systems-RULING-A-write-edges-before-the-threshold.md` D1）。
★而濫按煞車已在主線 ⇒ 它的序到了。
**延後表那一列**：`npc-tribute-accepted-zero-transfer`（met_check 錨在
`ResourceBank.add` 出現在 `diplomatic_ai_system.gd`）。

## ★★★§1 前提（我開檔核過，兩次）

```
`_send_diplomacy_message`（diplomatic_ai_system.gd:189 起）：
  ·對玩家 ⇒ 寫 forced_event 就 return（不在本票）
  ·對 NPC ⇒ `handle_diplomacy_message(...)` 拿回應，然後：
      if response == "reject" || "refuse": 設冷卻
      if action=="demand_tribute" && response=="refuse":
          write_memory(sender_leader,"tribute_refused",…) ＋ 雙向 update_reputation ＋ print
★★★而 **accept 那一支【什麼都沒有】** —— 沒有 ResourceBank.add、沒有記憶、沒有名聲
  ⇒ 「Team A 索貢成功」目前只是一句 print，**錢一毛都沒動**。
★對照：拒絕那一支有三件事（記憶／雙向名聲／print）⇒ **同一個分岔的兩側嚴重不對稱**，
  而那種不對稱通常是「有人只寫了他當時在想的那一半」。
```

## §2 做什麼

```
①accept 那一支要真的轉移，而**公式與寫入點都不准新造**：
   ·玩家遠程索貢已經有一份（`player_command_system.gd` 的 accept 分支：coin × 0.1）
   ·同格勒索也有一份（`interaction_system.gd:488 _resolve_extortion`：四資源 × TRIBUTE_RATE）
   ⇒ ★★**先回答「這條路該用哪一份」再寫**（見 §3 那個要藍圖裁的點），
     然後**呼那一份**，不要在這裡複製係數。
②★而好感／記憶那一半**已經有了**：濫按煞車那票把 `tributed` 接進兩層
   ⇒ 這條路轉移之後**自然會走到同一個寫入點**（若它呼的是共用解算點）
   ⇒ ★★所以本票的驗收要看到【錢動了】**且**【好感也動了】——
     只看錢動 ＝ 沒有檢查它有沒有繞過那條共用路。
③拒絕那一支**一行不動**（它已經對稱地做了三件事）。
```

## ★★§3 要藍圖裁一點（我不自己定，因為它是世界行為）

```
NPC↔NPC 的遠程索貢談成，**該拿走多少**？
  (a) 跟玩家遠程索貢同一份（coin × 0.1）⇒ 一個真相一份，玩家零特殊物理
  (b) 跟同格勒索同一份（四資源 × TRIBUTE_RATE=0.25）⇒ 但那是「兵臨城下」的比例
  (c) 另立一個比例 ⇒ ★我不建議（新常數＝新的要同步的東西）
★我傾向 (a)：因為這條路的威脅值是 0（遠程外交無兵臨壓力，code 註解自己寫著），
  而 (b) 的 0.25 是有兵臨壓力時的價。⇒ 但「NPC 之間該不該比玩家溫和」是 WHAT，我呈報。
```

## §4 驗收

```
P1 [錢真的動] 造兩隊 NPC、讓遠程索貢談成 ⇒ 兩邊 coin 逐欄印前後，守恆（拿走＝給出）
   ｜負對照：把那一行轉移拿掉 ⇒ coin 不動 ⇒ 必紅
P2 [★不是只有錢] 同一次之後，被索方領袖的好感**也要動**（走 `tributed` 那條共用路）
   ｜負對照：讓它自己寫一份轉移而不呼共用解算點 ⇒ 好感不動 ⇒ 必紅
   ★這一格守的是「它沒有繞過共用路」，而那是 §2② 的本體
P3 [拒絕那一支沒被我動到] 拒絕 ⇒ 記憶／雙向名聲／print 三件仍在
P4 [玩家不受影響] 玩家在場時走的是 forced_event 那條 ⇒ 本票零改動
   ★母體地板：印出這一輪【玩家是不是在場】，否則 P4 會在一個沒有玩家的世界裡恆綠
P5 全電池 BATTERY_RC=0；★fp 會變（錢真的動了）⇒ **先量再換基準、同 commit**
```

## §5 不在本票
```
·遠程外交該不該存在（NPC 側同格過濾已經存在 ⇒ 這條路的「遠程」是它自己的措辭問題）
·玩家那條路的比例（coin × 0.1 是 TEST VALUE，另票）
```
