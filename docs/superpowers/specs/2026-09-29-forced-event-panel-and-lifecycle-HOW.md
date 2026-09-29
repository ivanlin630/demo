# HOW spec：強制事件的面板人話 ＋ 生命週期三點 ＋ 「按 T 變拒絕」先量後修

owner: systems ｜ 2026-09-29 ｜ **player_reachable: yes**
上游：blueprint 第二輪回饋 #7（用戶逐字：「不知道是啥事件／能一直按 1 產很多待辦／按 T 跳出後還是寫我拒絕／UI 與終端 log 都看不到 Team11 要幹嘛」）
排序：第二輪回饋**第一張**（它擋玩家理解每一個外交互動）。

---

## ★★★§1 前提（逐字 file:line；★而第③條是我核出來的，上游沒有）

```
①`player_api_mapper.gd:304`：
   msg = "Team%d 要求你納貢" if proposal == "demand_tribute" else "Team%d 提議 %s"
   ⇒ ★`proposal` **原樣印** ⇒ 玩家看到「Team11 提議 propose_alliance」
②`player_api_mapper.gd:340 _forced_label()`：選項有人話（「✓ 接受」「加入對方勢力」…）
   ⇒ ★★所以【選項】有人話而【事件本身】沒有 —— 缺的是那一半
③★★★`proposal` 有**兩個寫入者、兩套詞彙**（母體不是封閉集）：
   ·`diplomatic_ai_system.gd:174` 寫 `action` ∈ {demand_tribute, propose_alliance, propose_trade}
   ·`interaction_system.gd:294` 寫 `npc.order_task`（★任意 task 字串）否則 fallback `"alliance"`
```

## ★★★§2 我核出來的一個【很可能的真因】（★而它仍然要由床確認，不由我斷言）

```gdscript
player_command_system.gd:1159  _accept_diplomacy(state, from_id, proposal)
  match proposal:
    "alliance", "surrender":      → 結盟
    "tribute", "demand_tribute":  → 付錢
  return { "ok": false, "msg": "未知提案類型：%s" % proposal }
```
```
★`diplomatic_ai_system` 寫的是 **propose_alliance** ／ **propose_trade**
  ⇒ 兩者都【不在】那個 match 裡 ⇒ **ok=false「未知提案類型：propose_alliance」**
★★而同一行的註解自己寫著同一個 bug 被修過一次：
   「_send_diplomacy_message 寫 "demand_tribute"（原只認 "tribute" → 未知提案類型 bug）」
  ⇒ ★★★**修過 tribute 那一半，沒修 propose_* 那一半** —— 同一個病灶第二次。
★而它同時解釋兩個症狀：
  ·`respond_to_forced` **不論 ok 與否都清掉 forced_event**（`:989-990`）
    ⇒ 第二次以後按 1 ⇒「無待處理強制事件」ok=false ⇒ 又一句 ✗
  ·玩家看到的「被拒絕」很可能是**指令佇列的拒絕句**（§3-5 契約：`<動作>：被拒絕（<原因>）`）
```

### ★★§2b 我加的第四個候選（上游只列三個）：**措辭撞車**

```
★「被拒絕」在佇列裡的意思是【你這道指令沒有被套用】，
  而玩家把它讀成【這個外交事件被我拒絕了】。
⇒ 兩件完全不同的事共用同一個詞 ⇒ ★★而它【不需要任何 bug】就會誤導人。
⇒ 所以床要分辨的不只是「哪一個真因」，還有「玩家看到的那一句到底是誰印的」。
```

## §3 做什麼（blueprint 裁的四件，我補實作邊界）

```
①★面板三行人話（誰／要什麼／接受後果／不回應的下場）：
   「Team11（<勢力名>，關係：<摘要>）向你提議<中文>」
   「接受＝<後果一句>」「不回應＝一小時後視同拒絕」
   ★proposal → 中文表【與 `_forced_label` 同處維護，不另開表】
   ★★★而母體不是封閉集（§1③）⇒ **不認得的 id 印「提議（未知：<id>）」，不得吞掉**
②★回應入列 ⇒ 面板鎖成「已排入回應：<中文>（推進時生效）」，其他回應鍵無效；
   同一 `interaction_id` 的重複 respond **入列時去重**（看佇列尾端同 id ⇒ 不加）
   ★不讀世界 ⇒ 可當場做（同指令佇列 spec 那條「只准當場擋不讀世界的」）
③★生命週期三點進玩家事件流（#4 那條專用佇列，自家隊 self-knowledge）＋終端 print：
   到達／回應結果／逾時自動拒絕。★現況缺【回應】那一點（`diplomacy` 到達也不在 #4 的 emit 清單裡）
④★★★「按 T 變拒絕」**先量後修**：床走完整條路再挑真因（§4 P4/P5）
```

## §4 驗收（★P4/P5 是「先量後修」那一半：它們的工作是【指認】不是【通過】）

```
P1 [人話] 造一個 `propose_alliance` 的到達 ⇒ 面板三行都在，且**不含原樣 id**
   ｜負對照：把中文表拿掉 ⇒ 面板印回 `propose_alliance` ⇒ 必紅
P2 [未知 id 不吞] 造一個 `proposal = "zzz_unknown"` ⇒ 面板印「提議（未知：zzz_unknown）」
   ★★這一格守的是 §1③ 那個【開放母體】—— 沒有它，下一個新 proposal 會靜默變成空字串
P3 [鎖面板＋去重] 連按接受 3 次 ⇒ 佇列裡只有 1 道 respond；面板顯示「已排入回應」
   ｜負對照：把去重拿掉 ⇒ 3 道 ⇒ 必紅（★守的是「1」不是「少於 3」）
P4 ★★★[指認真因 A] 到達 → 入列 accept → 推進一小時 ⇒ **印出**：
   ·`respond_to_forced` 的回傳（ok／msg 逐字）·事件流那幾句 ·終端那幾行
   ⇒ ★床【不預判】哪一個候選成立，它**把四個候選各自的證據欄都印出來**：
     (a)逾時競態＝逾時 print 出現在 accept 之前
     (b)重複回應＝出現「無待處理強制事件」
     (c)`_accept_diplomacy` 回 false＝出現「未知提案類型：propose_alliance」
     (d)★措辭撞車＝事件確實被接受，而畫面那句是佇列的「被拒絕（…）」
P5 [重複回應不產生 ✗] 入列 accept 三次 → 推進 ⇒ 只有一句接受、沒有 ✗ 句
P6 [三點齊] 事件流含到達／回應／逾時三句（各自造一次）；終端 print 三點齊
P7 ui-flow 綠；merge 前全電池 BATTERY_RC=0
★★★母體地板：P4 要先斷言【到達真的發生了】（forced_event 非空）——
  否則「沒有逾時句」在一個根本沒有事件的世界裡恆綠。
```

## §5 不在本票

```
✘ 改 `proposal` 的寫入端詞彙（統一 propose_* 與 alliance 是**另一張票**：它動 AI 側）
  ★而本票若由 P4 指認 (c) 成立，**修法寫在 handback 給我裁**，不要順手改寫入端
✘ 外交機制本身（誰會提議、條件）
✘ 故事結束畫面（#2，仍排後面）
```

## ★§6 誠實限

```
①本 spec 沒有跑 Godot，全部靜態 file:line。
②★§2 那個「很可能的真因」是我讀 code 讀出來的 —— ★★**它仍然要由 P4 指認**，
  我不在 spec 裡把它寫成已確認。**先量後修那一條是 blueprint 裁的，我不繞過它。**
③★★★我沒有量【玩家實際看到的那一句是哪一句】—— 那正是 (d) 要答的，
  而我連「(d) 存在」這件事都是從措辭推出來的，不是從卷面。
```
