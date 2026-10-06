# 打聽：說了什麼就記下什麼，記下幾筆就說幾筆（HOW）

```
票源 ＝ 量測員打聽普查（`docs/superpowers/handbacks/2026-10-07-measurer-to-blueprint-inquiry-write-census.md`，276 次，四個題目四種命運）
     ＋藍圖裁（記下 0 筆而對方有說 ⇒ 改說「他說的你早就知道了」，第四種結果句）＋藍圖裁 `1518bddaa`（四題四修）
基準樹 ＝ 當下 origin/main｜玩家可見 ⇒ 已知問題清單「打聽」那列同 commit 更新｜E2E KNOWN K2／K3 修好後刪
```

## §0 現況（file:line）

```
`message_system.gd:_exchange_intel`：want_msgs ＝ ["", "ask_recent_events"]｜want_claims ＝ ["", "ask_team_location", "ask_enemy_movement"]
  written 只在 claims 那段 record_claim 後 +1（`:319`）
I1 `inquiry_system.gd:76` 對 MessageData（RefCounted）呼 `.duplicate()` ⇒ SCRIPT ERROR（276 次撞 24 次）⇒ NPC 該說謊時靜默失敗
I2 ask_food_source：不在任一名單 ⇒ 玩家畫面看到 food_tiles，但從沒寫進 belief（結構性 written＝0）
I3 ask_recent_events：訊息真的複製進 team_known（`:262-274`），但 written 沒算 ⇒ 結果句印「記下 0 筆」＝說謊
I4 ask_faction_status：只在玩家有勢力時列出（`inquiry_system.gd` faction_id != -1）⇒ 普查世界玩家無勢力 ⇒ 0 次＝**正確**，不修
```

## §1 做什麼

```
I1 偽造訊息改用 MessageData 既有的建構方式產生一份新的（先找既有 copy／建構入口；沒有就照欄位建一份，寫在 message_data.gd 一支函式裡，不在 inquiry 裡手抄）
I2 ask_food_source 接進寫入路：寫進**決策層讀糧源的那個 belief 來源**（`decision_context.gd:1063 _find_food_seek_target` 讀的那一份）
   ★先查它讀什麼；用那份既有的寫入口寫，不新開儲存；若決策層的糧源根本不讀 belief（只讀真值或只讀賣單）⇒ 停、回報（那是感知鐵律的另一題）
I3 written 在 msgs 那段也計（每複製一則新訊息 +1；已知的不算）
I5 結果句：mode＝told 而 written＝0 而 payload 非空 ⇒「他說的你早就知道了」（藍圖第四句）；三句既有的不動
   ★被拒字樣詞表（介面修正 U1 那份）不受影響：這四句都不是拒絕
```

## §2 驗收

```
P0 [藍圖點名] 觸發 I1 的組合（不誠實關係＋有近期事件＋那 30% 擲骰成立）佈置成**探索床的陽性對照**：
   探索床「無 SCRIPT ERROR」那一格的母體從沒走到這條 ⇒ 加一步固定走到它（擲骰用佈置控制，不靠運氣）；修前必紅、修後綠
   ★I2 與修正同票落地 ⇒ 不需要「修前灰掉」的中間版；若 I2 因 §1 的停止條件拆出去，本票就把 ask_food_source 不列或灰掉帶原因（列的條件＝做的條件）
P1 普查床重跑（量測員那支，`scripts/debug/inquiry_write_census.gd`）：SCRIPT ERROR ＝ 0；ask_food_source written>0 比例 > 0；ask_recent_events 的 written ＝ 實際新增訊息數（逐筆對）
P2 I5：佈置玩家已知對方所說的那一筆 ⇒ 結果句＝「他說的你早就知道了」；★反向：未知 ⇒「他說了些事情（記下 N 筆）」N>0
P3 I1：不誠實＋有近期事件 ⇒ 偽造訊息 is_distorted＝true 出現在 result（固定 seed 下找一例印出）
P4 I2：打聽 ask_food_source 之後，決策層讀到的糧源目標可以來自這次打聽（印前後）
P5 E2E：K2／K3 從 KNOWN 刪掉後綠；已知紅數下降
P6 fp 量（打聽只在玩家下令時跑 ⇒ fp 床設 player_id=-1 ⇒ 應不變；變了就量歸因）
```
