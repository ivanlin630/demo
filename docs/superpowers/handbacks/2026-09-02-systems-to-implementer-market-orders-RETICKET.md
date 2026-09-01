---
from: systems
to: implementer
status: consumed
slice: market-orders-dangling（★改票，取代前一封）
topic: ★★★停下我上一封那張票,框架錯了:我叫你修「拆除不清看板」,而【所有讀者都守 outpost_level > 0】⇒ 拆除後那份看板根本讀不到,是惰性資料不是洩漏;★★真根在別的地方:訂單生命週期是【owner 驅動】的(order_system:88 白紙黑字「他隊 entry 不動,由各自 tick_team_orders 維護」),而 erase_teams 不清死隊的單 ⇒ 死隊的單在任何活市集上【永久掛著】;★這比原條目框的寬得多,且不需要拆除或易主就會發生
---

# ★★★①先停：我上一封那張票的框架是錯的
```
我寫：「outpost 被拆 ⇒ 宿主沒了看板還在 ⇒ 隊站上去 read_market_board 會讀到不存在市集的單」
★而我【沒有查完讀者端】就派了票。查完的結果：
  order_system.gd:241        read_market_board          → if tile.outpost_level <= 0: return   ✅守
  interaction_system.gd:749  _resolve_market_at_outpost → if tile.outpost_level <= 0: return   ✅守
  faction_ai_system.gd:1828  _deliver_letter_to_board   → if tile.outpost_level <= 0: return   ✅守
⇒ ★★拆除後那份看板【讀不到】= 惰性資料,不是洩漏
⇒ ★★★我叫你去修一個【行為上觀測不到】的東西。抱歉,已改票。
```
★**唯一還算真的殘留**：**同一格【重建】outpost 之後，舊看板會復活**（`outpost_level` 又 > 0）。
★★**而那是下面那個真根的一個症狀，不是獨立的病** ⇒ 修了真根它自然消失。

# ★★②真根（我坐實了，file:line）
```
order_system.gd:88（原文註解）：「他隊 entry 不動（由各自 tick_team_orders 維護）」
faction_ai_system.gd:1027    ：OrderSystem.new().tick_team_orders(state, team)   ←★只對【活著的隊】跑
world_state.gd:475 erase_teams：★★★【不清】死隊的單；全站也沒有任何「隊消失 ⇒ 清單」的路
⇒ ★死隊的 board entry 在【任何活市集 tile 上永久掛著】,而那些 tile 的 outpost_level > 0 ⇒ 讀得到
⇒ ★★不需要拆除、也不需要易主就會發生 —— 原條目把它框成 capture/demolish,框窄了
```

# ★③要做什麼（★藍圖已裁「零特例」，所以修在窄口不是特判）
```
★掛點 = `world_state.gd erase_teams`(★★A#14 已經證明它是「所有死法」的唯一窄口 —— 同一個窄口,不要另找)
★★做的事 = 死隊的 board entry 隨它一起走(它的 order_id 在 active_orders 裡,以此為準)
★★★這【不是】capture 特判 —— 藍圖禁的是「易主時特別清空」;
   而「實體消失時清掉它留下的懸空引用」是通則,不是特例
★易主那半【什麼都不做】= 藍圖裁定:看板隨據點轉手,舊單依一般生命週期自然清
```

# ★④驗收（★沿用「指標=0 三讀法」）
```
①★erase 路徑 entry counter：本窗有幾隊被 erase —— ★★否則「殘留 0」與「沒隊死」長得一樣
②★★清掉幾筆 + 清之前該 tile 上有幾筆（★沒有「之前 > 0」就證不到是你清的）
③★★★使用端證明：死隊的單清掉後,`_resolve_market_at_outpost` 不該再撮合到它
④`fp` 會變(行為修正)⇒ 差在哪要說得出來
```

# ★⑤順帶（★不是你的票，但你會看到）
`erase_teams` **沒有任何「懸空引用清理」契約** —— ★**而 `known_issues` 已經有一條同型的**：
「人死了，關係不會消失：`relations`／`relation_edges` 全樹零清理」。
★★**兩條是同一個病的兩個實例** ⇒ 我已標記，**但要不要做一個通則性的清理契約是架構決定，不在本票。**
