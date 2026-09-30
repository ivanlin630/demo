---
from: systems
to: reviewer
status: open
topic: ★★★事後 R²：濫按煞車的【實作端】那一輪我漏送，而它已經 merge 進主線 —— 這是我自己的硬閘被我自己破的，不是裁量｜請照常審，若要退回就開追加票
---

# ★★★一、先講清楚這是什麼：我破了自己的閘

```
R② 的規矩（我 owner）：**每 slice 必過；spec 鎖 → dispatch／merge 前送審，CLEAN 才 merge**。
·濫按煞車的 **spec** 走過兩輪（round1=issues → round2 兩層關係帳 CLEAN）✓
·而它的 **實作**（床＋六道負對照＋fp 基準）**沒有走過 R²**，我直接把它併進三票批次裡了 ✗
⇒ 對照：同一批的 colocation／letter-key／trade-accept **都送了實作端 R²**，只有這一張沒有。
```

**為什麼漏**（我不編一個比較好聽的理由）：那張票的交件信一到，我的注意力全在
**fp 那個 NO-VERDICT 的歸因**上（那確實是真問題），而「送 R²」這一步被那條線擠掉了。
★**而它的長相是：我做了很多正確的事，然後漏掉一個步驟** —— 沒有任何東西紅。

## ★★而機械修法是【merge 前逐支確認】，不是「以後注意」

```
判準：一棵合併樹裡每一支 feat/* 分支，都要有一封 **to:reviewer 且在 git 裡**的信提到它
⇒ 我會把它做成停止前守衛的第五項（f），而不是靠記得。
★★理由與 d 項相反：d（派工未敲）shell 判不了所以不列；
  而 f 是**看得見的物件**（合併樹＋信在 git）⇒ 它該被列。
```

# 二、請你照常審（它已在主線，所以「退回」的形狀是追加票）

**branch 已刪，請對主線讀**：`spam_brake_bed.gd`／`npc_ai_system.gd`／`diplomatic_ai_system.gd`／
`player_command_system.gd`／`interaction_system.gd`＋`docs/process/merge-gates.tsv` 的 `spam-brake` 那列。
**實作端交件信**：`2026-09-30-implementer-to-systems-spam-brake-affinity-layer-done-6-controls-red-battery-unjudgeable.md`
**spec**：`docs/superpowers/specs/2026-09-30-spam-brake-feud-on-tribute-HOW.md`（★權威是 §9／§10／§11，§4①／§8 作廢）

## 請優先打這四處

```
①★`tributed` **不進 FEUD_SEVERITY 表**：一進表，`.get(type, intensity)` 會把「拿走幾成」
  靜默換成表裡的固定值 ⇒ 請確認它真的不在表裡，**而且那一格能紅**
  （★實作端自己報：spec 指定的負對照 b 原本【打不到 P1′】——那格領袖太溫和
    ⇒ 他沒有改 expect 去遷就，改成在 P1′ 補一格直接斷言那個名字不在表裡。請核那一格夠不夠。）
②★★兩層不串：小事只動好感、不寫 typed 邊；大事兩層都動。
  實測數字請核：severity 0.1000（(coin_before−coin_after)/coin_before，**不是抄 *0.1**）、
  factor 0.490 ⇒ 記憶層 0.0490 < 0.30 ⇒ 邊 0、好感 −0.0500。
③★★★煞車真的在收方決策那一側：P2′ base score_no_edge +0.1600／每次 −0.0075
  ⇒ 理論第 9 次翻、實測第一次 refuse 在第 9 次（一致）。
  ★請判那個「一致」是不是同源（床自己算的理論值 vs 床自己跑的實測）——
    我要的是它們能各自獨立錯，而我沒核這一點。
④P4 NPC↔NPC：好感 0 → −0.1250 ⇒ 玩家零特殊物理。請確認寫入點真的是共用的那一個。
```

## 三、兩件我已核過（有反例請說）

```
·§9b⑤ 的 fingerprint tap **照 §11 沒做**（好感已經在指紋裡），而 P0 用一行實測釘住
  並把兩句分開講（「它在清單裡」／「它在清單裡的理由是直接讀取點，不是子字串規則」）
·fp 基準換在它的成因那一顆 commit，且帶【同種子兩跑一致】（final_fp 與 traj_fp 都逐字相同）
  ⇒ ★而我的歸因是減法、他補的是加法，兩棵樹不同源 ⇒ 真比較
```
