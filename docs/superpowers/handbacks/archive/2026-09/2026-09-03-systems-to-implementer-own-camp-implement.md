---
from: systems
to: implementer
status: consumed
slice: own-camp-in-decision-model —— ★R² CLEAN（issues 已吸收），可以做
topic: ★★★這一刀是【兩半,缺一不可】:①給紮根「自己的營地」這個念頭 ②讓【紮營】在你已經有家時不要 fire——reviewer 查到紮營的 applicable 沒排除 own_camp_pos,半路被打斷會就地重紮 ⇒ ★只做前一半會【看起來沒效】;★索引是【姊妹表】不是塞進 _oo_map(欄位不同);★★距離 reviewer 查過【已經折進 util】(rooting_drive+settle_eta_days),不用另加
---

# ★①兩半（★缺一不可，先講死免得只做一半然後結論「沒效」）
```
半A：紮根拿到「自己的營地」——ctx `own_camp_pos` ＋ applicable 納入它 ＋ to_task 產生【移動到那裡】的腿
半B：★★紮營 `applicable` 加 `own_camp_pos == (-1,-1)`（★★★你已經有家就不該再紮一個）
     —— 與當日稍早 `recamp-candidate-exclusion` 是同一家族的延伸
⇒ ★只做半A：人走一段 → 被打斷 → 重秤 → 紮營贏 → 就地重紮 ⇒ 數字跟現在幾乎一樣
```

# ★★②索引（reviewer 訂正我的措辭）
```
★不是把 camp 塞進 `_oo_map` ——outpost 與 camp 是不同欄位（outpost_owner/level vs camp_team_id/level）
★★是【複製那套機制】：一張姊妹索引，自己的 epoch、自己的 3 個 chokepoint
   （寫：faction_ai_system.gd:5811／清：harvest_system.gd:67、outpost_system.gd:470）
★★★而 shadow/shadow_check 那套【要一起複製】—— 索引漂掉正是它要抓的病，白拿
```

# ★★★③不用做的（★免得你多做）
```
距離折扣：★reviewer 查過 `rooting_drive` + `settle_eta_days` ⇒ 【已經折進 util】
⇒ 「橫跨全圖走回家」被既有 feasibility 自然壓低 —— ★★本刀不加任何東西
```

# ④驗收（判讀表在 spec §④，★這裡只重申兩條硬的）
```
★腿B 重跑（母體 ≥30）：預期【走回去】——★★若仍 30/30 原地重紮，是修法沒生效，不是世界性質
★★★陽性對照：把 own_camp 欄位改成恆 (-1,-1) ⇒ 腿B 必須退回「30/30 原地重紮」
   ——★並寫明【你弄壞了什麼】
＋新增腿C：走到一半營地被衰敗清掉 ⇒ 必須【解承諾重秤】，不得卡在移動中
＋★★禁死旗：失效走既有 `survival_committed_option = ""` 那條出口（faction_ai_system.gd:6165/6170 同款）
```
★**camp churn 的比例變化列【觀察項】不列驗收**（我們只量到共存，沒量到因果）。
