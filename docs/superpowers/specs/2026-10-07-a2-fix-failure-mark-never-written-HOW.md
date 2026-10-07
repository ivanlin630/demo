# A2 修：「貿易到場沒成交」的失敗記號在世界裡幾乎從沒寫進去（HOW，小票，缺陷修）

```
證據（量測員 2defe2ec9，樹 afaf2bea1 已含 A2 713c86bd6，三 seed × 30 天）：
  option＝貿易、到場、當日零成交（C2′ 帳本判準）事件：9／5／110 ⇒ 同拍寫進 recent_failures「貿易|市集」：0／0／0
  production 計數器 trade.arrived_no_deal（與 FailureMemory.record 同一行，sim_runner.gd:928-929）：3／0／1
  重撞前折價值重算：全部 1.000 ⇒ A2 merge 進去的行為在世界裡等於沒有
★A2 的床全綠而世界沒變：a2_trade_no_deal 的 P3/P4 是【直接佈置抵達】，沒有走真的移動與到場名單 ⇒ 驗的是 record 那一行，不是「世界會走到那一行」
```

## 先查（實作端，唯讀，第一顆 commit）
```
在 fp 世界（seed 1337）把量測員那 110 類事件（option＝貿易、到場、當日零成交）逐筆歸到下列哪一條，印分佈：
 ①不在當拍 arrived_ids（例：派出時目標就是腳下那格 ⇒ 從沒「移動抵達」過；或遠程 LOD pass 的到場沒進 step3c 那份名單）
 ②在 arrived_ids，但 trade_arrived(_t) 為假
 ③_dealt 為真（當拍有成交，但當日帳本判準說沒有——判準落差）
 ④current_option 在那一拍已不是「貿易」
 ⑤以上皆非（並數它多大）
⇒ 修法依分佈定；不准先改再量
```

## 修法形狀（依 ① 最可能，先寫好；分佈不同再回我）
```
失敗記號不要掛在「本拍移動抵達的名單」上，掛在【到場判定成立且市集解算回 false】那一個唯一出口：
  sim_runner.gd:904-930 _step3c_read_market_board 的條件改成對【所有 current_task＝TRADE 且 trade_arrived 為真、人在市集格】的隊跑（不只 arrived_ids）
  ★同一隊同一市集同一拍只記一次（record 前查 recent_failures 該 key 的 last_tick ≠ now）
  ★放手照舊（A2 已有）
不改：OPTION_FAIL_KEY 形狀、折價曲線、只記 option「貿易」（其他 option 是 A2b 的事）
```

## 驗收
```
P1 先查的分佈表（逐筆可追）
P2 ★走真世界：fp 世界 seed 1337／7 各 30 天 ⇒ trade.arrived_no_deal 與量測員那支床的「貿易零成交事件數」比值 ≥ 0.9（同一份母體；量法用量測員床 a2b_recollision_rate.gd）
   ｜反向：把修法改回只跑 arrived_ids ⇒ 比值回到 ≈0 ⇒ 必紅
P3 seed 7「貿易」同市集 7 天內重撞率（C2′ 判準）：改前 87.3% ⇒ 改後印出（先量，不預測）
P4 a2_trade_no_deal 既有格全綠
P5 world-fp 會變 ⇒ 同 commit 換基準
```
