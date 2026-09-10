---
from: implementer
to: systems
status: consumed
slice: registry-anchor ④a ｜ `.worktrees/reganchor` / `feat/registry-anchor` / commit `2d1fbe34d`
topic: ★三件都做了（欄位／讀者／遷移）＋一跳謂詞＋棘輪＋順手兩件｜★★而 **shadow 把兩個前提打掉了**：①`_team_works_tile` 搬移**不是行為中性**（warring 1500t **322/489 不一致**，舊軸【沒有 TAG_PRODUCE 要求】）②**遷移單次＋無動詞 ⇒ t=0 之後才成為居民的隊永遠不登記**（peaceful `Team0` 現形）｜★★★兩件都是**設計判斷**，我沒有自己改 —— 而 R² 那條誠實限（跨函式漏網要靠跑起來的世界逼出來）**今天兌現了**
---

# ① 做完的（commit `2d1fbe34d`）

```
①`TeamData.work_outpost: Vector2i`（單一座標 ⇒ 「一隊一登記」寫進型別）
②`WorldState.registered_at / registered_or_parent_at(ctx) / is_registered_resident`
  ＋ `migrate_registry_anchor()`（旗擋重入；★兩個入口：`GameSetup.setup` 尾 ＋ `advance_tick` 首 tick
    —— 不經 setup 的世界（載檔／床自組）否則會以「全世界都不是居民」開跑）
③讀者切換：`is_resident_static` 換讀登記欄（★簽名不動）＋ `_team_works_tile` 一起搬
  ＋ 舊判定各自保留為**具名對照**（`legacy_resident_by_position` ／ `_legacy_works_tile_by_position`）
  ⇒ ★理由寫在 code 旁：**沒有名字的舊判定會被下一個人當「重複邏輯」刪掉，而對照消失不會有任何一格紅**
④`_unload_excess_material`／`_faction_owns` 的手寫 `owner == parent_team_id` 改走一跳謂詞，
  ctx＝`unload`／`construct`／`food_rescue` ⇒ ★實測 denied 有主詞（warring 1500t：unload 399／food_rescue 209／construct 3）
⑤順手兩件：`invariant_audit` 加「孫代 parent ⇒ 具名紅」；`world_state.gd` tags chokepoint 那句假話逐字訂正
⑥棘輪 `.claude/hooks/registry-axis-ratchet.sh`（自檢 4/4 綠：會紅／不得亂紅／進 baseline 變綠／baseline 走味也紅）
  ★判準**先裸掃再分類**：`outpost_owner ==` 全庫 **33 處**，其中多數是【所有權問句】
  ⇒ 咬的是【複合軸】那一族（parent 軸 ／ 同函式體內 owner＋faction）＝ **7 命中／6 key** 進 baseline
  ⇒ ★★若把 33 處全咬，baseline 會變成一份沒有人看的清單（＝閘等於不存在）
```

# ② ★★★前提一被打掉：`_team_works_tile` 搬移**不是行為中性**

```
spec §⑦(3) 的理由是「它與 `is_resident_static` 的識別軸**完全相同** ⇒ 真值集合逐隊相同」。
★實測（shadow 逐次比對，新 vs 舊）：
   warring_states 1500t：works 比對 489 次 ⇒ **不一致 322 次（66%）**
   peaceful_economy 1500t：279 次 ⇒ 1 次
   peaceful_economy_factioned 1500t：295 次 ⇒ 17 次
★★不一致的形狀**全部同一種**：`was=true now=false`，樣本：
   {team 0,  tile_owner 0,  reg -1,-1}     ← 自己擁有那格，但它【沒有 TAG_PRODUCE】
   {team 12, tile_owner 0,  reg -1,-1}     ← 同 faction 代工（它不是那格的居民）
★★★根因（讀 code＋樣本一致）：**舊 works 軸 ＝ owner OR 同 faction，而它【不要求 TAG_PRODUCE】**；
  登記軸 ＝ PRODUCE ＋ 站位（遷移的來源就是 `legacy_resident_by_position`）
  ⇒ 兩者從一開始就不是同一個集合 —— ★而「識別軸完全相同」這句在 code 上看起來成立，
    是因為兩支函式**都寫著 owner-or-faction**；差別在**呼叫它們之前的那一個條件**（PRODUCE）。
⇒ ★★這正是 R² 誠實限講的那件事：裸掃只到同函式體粒度，**跨函式的漏網要靠跑起來的世界逼出來**。
```

**要你裁（我沒有自己選）**：

```
(i) 遷移放寬：把「站在自己擁有的據點上」的隊**也登記**（含非 PRODUCE）⇒ works 中性，
    ★但那會改變【居民】的語意（居民數會變多）⇒ 它其實是在改世界。
(ii) `_team_works_tile` 寫成 `registered_at(...) OR owner OR 同 faction` ⇒ 行為嚴格中性，
    ★但那等於**承認它是第五種軸**（本票的目的正是不要再長一種）。
(iii) `_team_works_tile` **退出本票**（回到舊實作），生產權的統一另開一張。
★我的觀察（不是建議）：三個選項的差別**不在實作難度，在「生產權是不是居住權」這個問題**，
  而那不是我能答的。
```

# ③ ★★★前提二被打掉：**遷移單次 ＋ 無動詞 ⇒ 新居民永遠不登記**

```
★spec §① 自己寫過：「本票之後，登記**只會由遷移產生**、只會因據點消失而失效」
  ⇒ ★★而實測顯示【t=0 的快照抓不到大部分居民】：
     `warring_states`：t=0 居民 **0 支**（★★★而跑完 1500t，**舊判定也還是 0 支**
        ⇒ 這個 config 對本票的驗收①②**不可判**，不是「遷移壞了」）
     `peaceful_economy`：t=0 登記 11/12；跑 1500t 後 resident 不一致 **2 次，全是 `Team0`**
        （`was=true now=false, pos=7,6, reg=-1,-1`）
        ⇒ ★它在 t=0 【還沒站上】自己的據點，之後才站上去 ⇒ **沒有動詞，它永遠不會登記**
⇒ ★★所以驗收⑥「行為未變」在【t=0 之後成為居民的隊】上**不成立**，
  而它**隨窗長變多**（1500t 才 2 次，是因為窗短、且 peaceful 的隊很少移動）。
⇒ ★★★而房客那一格更直接：三個 config 在 t=0 的**房客都是 0**
  ⇒ 驗收② 的房客那半**在現有 config 上不可判** —— ★而房客本來就是**動態產生**的，
    **而動態產生正是遷移抓不到的那一類** ⇒ 這不是挑錯 config，是遷移的形狀決定的。
```

**要你裁**：

```
(a) 本票就到這裡：接受「登記＝t=0 快照」，驗收②③改成「不可判就明寫不可判」，動詞（④b）補上之後才真的能用；
(b) 或本票補一顆**最小的登記維護點**（例如：某隊在自己/同 faction 據點上、且是 PRODUCE ⇒ 自動登記），
    ★而那實質上是**動詞的一半** ⇒ 需要你確認它不算越界進 ④b。
★我沒有做 (b) —— spec §⑤ 明文「不加動詞」。
```

# ④ 其餘驗收現況

```
①遷移逐隊相同：**PASS**（peaceful 12/12、factioned 12/12、warring 49/49，不一致 0 筆）
②母體地板：**部分不可判**（見 §③：房客 0；warring 居民 0）
③讀者逐站點名：**PASS**（清空 `Team0` 登記 ⇒ `is_resident_static`／`is_registered_resident`／
  `DecisionContext.is_resident`／`_team_works_tile` **四站全變非居民**；★清空【前】的值也印出來
  ⇒ 否則分不出「本來就是 false」）
④shadow：母體 > 0（resident 1239–2313 次／works 279–489 次），**不一致見 §②**
⑤fp：**變了**（`work_outpost` 入 `_emit_teams` ⇒ 預期）；★同 seed 兩跑相同 `f20d311e1e610c8b1db99a54ec7969a4`
⑥行為未變：`headless_test` 全套**在跑**（結果回來若有紅我另報）；★而 §③ 已知的行為差異不是它能抓的
```

# ⑤ 誠實限

```
①shadow 的窗是 1500 tick（≈1.04 遊戲天）＋三個 config ⇒ 它證明了【不一致存在】，
  ★沒有證明【不一致的上限】——長窗會更多（尤其 §③ 那一類隨時間累積）。
②`is_resident_static` 我實作成「登記 ∧ 站在登記那格 ∧ PRODUCE」——★保守（貼近舊行為）；
  ★★若語意是「登記了就算居民（人走開也算）」，那是另一種世界，**要你裁**（本信 §③ 的 (b) 會一起變）。
③本票沒動 `own_granary_tile`／`_home_granary_food`／勞力池／`tax_rate`／借宿門禁（照 spec §⑤）。
```
