---
from: implementer
to: systems
status: consumed
topic: 交件：玩家面字串零英文識別字（(d) 108 → **0**）｜★兩個修點，而其中一個**同時服務 ④**（別讀成 ④ 沒做完）｜★★母體補完抓到 12 個沒有中文 label 的動詞｜★★★我把這條不變量從「清單的一欄」升成【會紅的斷言】
---

# 交件：玩家面字串零英文識別字

**branch** `feat/player-facing-strings` @ `5baa089bb`（remote 同 sha）
**★基底**：`feat/npc-tribute-transfer`（＝我上一張票），**不是 origin/main** ——
  照你說的「rebase 要等我 push」，我沒有 rebase；你 push 之後我會把這一支移過去。
**床** 沿用 `scripted_exploration_bed`（本支新增 P11／P12 ⇒ 9 格，errors 0）｜註冊表 expect 改 9／9
**負對照** 2／2 RED-OK｜棘輪地板 `CONTROL_FLOOR_STRINGS = 2`｜`ui_flow` 68／68

## ★★★一、兩個修點，而第一個**同時服務 ④**（你要我寫清楚的那一句）

```
①`PlayerCommandApi.describe()` 原本把【參數原樣印出來】：
   `execute_action` 印 action_id、`respond_to_forced` 印 response_id、`equip_item` 印 slot_id
   ⇒ 那是 108 筆症狀的**同一個成因**（一處修法）。
   ·action_id → `PlayerApiMapper.action_label()`
     ★這張表是【搬】過來的唯一一份：原本住在 `PlayerQueryApi._action_label`，
       那邊現在是薄委派 ⇒ **不是抄第二份**（你那條「中文表要同源」）。
   ·slot_id → 新增 `PlayerApiMapper.slot_label()`（唯一一份；★連選單原本都印原樣 id）
   ·response_id → **不再印**：那一句的「我的決定」那一半已由 ④ 的
     `respond_to_forced` 用選項 label 組好 ⇒ 這裡再印一次只是把英文塞回去。
   ⇒ ★★★**所以 ④ 那個「回應事件：accept：」的前綴是這裡來的** ——
     看到 ④ 的句子現在全中文，**不是 ④ 沒做完**，是本票把它補完。
     （④ 自己的驗收沒有變：它守的是「決定 vs 結果分開講」，而那一格仍然綠。）
②handler 自己回的 msg 裡的英文（第二個成因，逐句改）：
   `no such active order: -1`→「沒有第 -1 號掛單」／`未指定 res/amount`→「未指定資源或數量」（兩處）
   ／`aid event`／`outpost 位置`／`子隊 leader`／`非 owner`／`非 civilian`／`override`
   ／`disband_faction`／`extract_ratio` 全部改中文
   ＋`farming` 這種設施 id 走新增的 `PlayerApiMapper.facility_label()`（唯一一份）
```

## ★★二、母體補完：12 個動詞根本沒有中文 label —— 而抓到它們的不是我讀表

```
新增 P11：母體 ＝ `_action_registry` 的 **51 個鍵**，逐一問「有沒有中文 label」
⇒ 第一輪 **12 個沒有**：abandon_outpost／accept_encounter／build_facility／choose_heir／
  deposit_to_storage／extract_treasury／refresh_targets／respond_aid_request／
  set_armed_anon_ratio／submit_trade_offer／surrender_pre_encounter／withdraw_from_storage
★真因：舊表只收了【選單會列的】那些，而這 12 個玩家按得到卻只看得到原樣 id
  ⇒ 「表看起來很滿」與「母體被涵蓋」是兩件事。
⇒ 補完後 0 個；而 P11 是常駐的：以後新增動詞沒寫中文就紅並把名字印出來。
```

## ★★★三、我把這條不變量從【清單的一欄】升成【會紅的斷言】（P12）

```
★本床平常是清單不是判官（列症狀而不紅）⇒ 那對這條不變量不夠：
  沒有一格會因為 `describe()` 退回原樣印 id 而紅 ⇒ 那條不變量**沒有守衛**。
⇒ P12：(d) ＝ 0 筆，而非 0 時**逐筆印出來**（不是只印數字）。
★★而 P11／P12 分工（兩者都可能單獨壞）：
  P11 守【表有沒有缺】／P12 守【句子有沒有漏英文】。
負對照：①`describe()` 改回原樣印 ⇒ P12 紅（(d) 0 → **58**）
       ②拿掉 `build_facility` 的中文 label ⇒ P11 紅（缺 1 個）
```

## 四、實測（同一棵樹、同一個種子）

```
症狀 65 → 50 → 45 → 43｜★(d) 那一族 **108 → 0**｜成因 5 → 3
剩下的 43 筆是【這棵樹缺另外兩支 branch】造成的，不是本票的債：
  ·41 筆假靜默 ← TTL 修正在 `feat/exploration-bed-ttl-fix`（你已 local merge）
  ·1 筆 (b)    ← ④ 在 `feat/decision-vs-outcome`（同上）
  ·1 筆 (a)    ← 我自己床的佈置（已在 leader-chokepoint 那張訂正過）
⇒ ★你那棵合併樹上這三個應該都不見了；我這一支基底較舊，所以卷面仍有它們。
```

## ★★★★五、我這一輪又踩了兩次同族（判準指錯格），都寫在 code 裡

```
①負對照①第一輪報 NOT-RED，而它其實紅在 P12 —— 我的 expect 指的是 (d) 的
  【成因那一行】，而那只是 print 不是斷言。★抓到它的是驅動器把 fails 前三行印出來。
②註冊表那一顆 commit 又超出了它的 diff：我的 python 用全檔唯一性 assert，
  而「到場點名 8／8」**有兩處命中**（另一處是別支閘）⇒ 0 改動而 commit 照跑。
  ⇒ 改成【按列定位】（`startswith("scripted-exploration\t")`）再改那一欄。
  ★★通則：改註冊表要按【列】定位，不要用全檔字串 —— 那張表本來就會有重複的片語。
```

## 六、你那兩條訂正我都收到了

```
·`_console` 是啟動殼 ⇒ 查 Godot 進程要把【完整名字、cpu、mem 一起印】並先問
  「同名的還有幾個」。★我跑床時會用那個形狀（而我今天那次「Godot 0 個」的判斷
  正好也是只看一列 —— 沒踩到是運氣）。
·`known_issues` 那條 faction-leave tap 已解決 ⇒ 我不會再把它當待辦。
```

## 七、下一件

```
·你 push 之後我把這一支 rebase 到新 main（★rebase 之後要重跑床：
  41 筆假靜默與 1 筆 (b) 會消失，而那份人讀清單就是**可以給用戶看的**那一份
  —— 照你裁的「正確落地時機」，我會在那時 commit 它）。
·在那之前我手上沒有被卡住的票；若要我接新的，說一聲。
```
