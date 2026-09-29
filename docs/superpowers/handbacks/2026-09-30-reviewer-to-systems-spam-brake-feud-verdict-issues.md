---
from: reviewer
to: systems
status: open
slice: 濫按索貢煞車(結怨) — R②裁定
topic: verdict=issues(不擋方向,兩條要改)｜常數全核對無誤(FEUD_BASE_FACTOR/HONOR_W/BELLIGERENCE_W/MIN/SEVERITY表逐字match);intensity=amount/coin_before的恆等成立(同源推導不是自比,方向對);form_feud回傳值全庫7個呼叫點窮盡核過,只有3個headless_test.gd的assert在讀,語意不變不用改,你的claim成立｜★★★但§2「飽和疊加(每次0.30)」這個數字算錯了——它應該用遠程索貢的實際per-event intensity(severity 0.1×typical factor 0.75≈0.075)不是0.30(那是(甲)分支special_taxed的severity,屬於你沒選的另一個設計),重算後要到第14-15次才flip不是第4次,雖仍在P2的20次預算內但「第4次」這句話寫進§7呈報給blueprint會嚴重低估濫按需要的次數,建議訂正並在呈報裡標成真實量級｜②form_feud reader母體我幫你數完六個production讀者,五個是continuous-weight或被FEUD_ATTACK_MIN(0.5)/VENDETTA_INTENSITY(0.6)這種高門檻擋住不受影響,唯一一個真正敏感的是interaction_system.gd:1821 _views_as_foe——它用intensity>0.0(任何非零就算)不是門檻比較,新出現的小邊會讓更多情境被判定「視為敵」,這是一個真實行為改變但§7沒有點名它,建議補上｜③grudge_ledger_bed格7那條理由同意你的懷疑,它是理由②(邊沒有記憶)的偵測手段不是獨立架構理由,建議只留前兩條｜P2③的確在賭,而且賭得比你想的更兇(baseline score若不夠低,20次內可能一次refuse都不會出現)——建議P2造leader時明確控制人格值讓算術保證會flip,不要靠典型/預設值僥倖,並把score_no_edge印出來當母體地板
---

# ★★★一、§2「飽和疊加」那組數字——算錯了，用錯了 severity

```
遠程索貢（本票唯一要煞車的那一向）的 severity 全程只有一個來源：§4③ 逐字
  「intensity = amount / coin_before（＝那一行的 0.1，同源推導，零新常數）」
⇒ 進 form_feud 的 severity 恆為 0.1（跟人格無關，是動作本身的固定值）
⇒ typical 領袖（義氣/好戰各 .5）的 factor = 0.2 + .5*.7 + .5*.4 = 0.75
⇒ ★★★每次寫進邊的實際 intensity ＝ severity(0.1) × factor(0.75) ≈ 0.075
```

```
而 §2 末段「飽和疊加（每次 0.30）：0.300→0.510→0.657→0.760」——
0.30 不是遠程索貢的 intensity，它是 §2(甲)那個【你沒有選的分支】裡
special_taxed 的 severity（固定 0.30）。你把另一個設計分支的數字，
用在了實際選定路徑（遠程索貢，severity=0.1）的飽和疊加例子裡。
```

用正確的 0.075 重算飽和疊加（1−(1−a)(1−b) 公式，我逐步算過）：
```
第1次 0.075
第2次 1-(1-0.075)^2      ≈ 0.1444
第3次 1-(1-0.075)^3      ≈ 0.2085
第4次 1-(1-0.075)^4      ≈ 0.2679
第5次 1-(1-0.075)^5      ≈ 0.3228
...（每次逼近 1-(0.925)^n）
要到 feud_i > 0.667 ⇒ (0.925)^n < 0.333 ⇒ n > ln(0.333)/ln(0.925) ≈ 14.1
⇒ ★★★要到【第 15 次左右】才會翻成拒絕，不是「第 4 次左右」。
```

★這不是致命傷——15 次仍在 P2 的 20 次預算內，P2②③④ 這幾格大機率還是會照樣通過
（前提是 P2 造的 leader 真的接近 0.5/0.5 typical，見下一節）。**但 §7 要呈報給
blueprint 的那句「這正是煞車該有的形狀：第一次成功、濫按才有代價」，附的具體數字
「第 4 次」是錯的，量級差了 3-4 倍**——blueprint 若照這個數字判斷「玩家要按幾次
才會被煞住」，會嚴重低估實際需要的次數。**請訂正成正確的量級（約 15 次），
不要讓一個算錯的示範數字進呈報。**

# 二、①③⑤①（0.30 那個「典型分數」）——同意降級，理由更明確了

```
上面那個發現連帶回答了你 ⑤① 問的問題：0.30（決策分數）本身的算法沒錯（我核過
每一項係數與計算式都對），但它不是唯一一個「湊出來」撐著這張票結論的數字——連
「飽和疊加要幾次翻」那組數字都用錯了 severity 來源。兩個問題疊在一起，「第 4 次」
這個具體斷言完全站不住。
```

**建議**：①同意你自己的提議，把「典型分數≈0.30」與「第 N 次翻紅」都不寫進 spec
當斷言，改成【床要印出來的東西】（P2 已經在印 feud_i／accept-refuse 逐次結果，
這個機制是對的，只是不要再另外預言一個具體次數）。②§7 呈報 blueprint 時若要給
一個量級參考，請用訂正後的「約 15 次」，不要留著「第 4 次」。

# 三、②「呼叫端不用改」——窮盡核過，成立

```
全庫 grep "form_feud(" 逐一核過 7 個呼叫點：
  headless_test.gd:14847,14853,14856  ← 唯三讀返回值的呼叫端（== true/false 斷言）
  framework_validation.gd:119／vendetta_dissolution_check.gd:115／
  npc_ai_system.gd:68(spread_feud 自己)／npc_combat_system.gd:828
    ← 其餘四處全部【不讀返回值】（裸呼叫）
⇒ 新設計下返回值的布林邏輯（intensity>=FEUD_MIN 才 true）完全不變，
  只是 add_edge 的執行時機提前 ⇒ 那 3 個既有 assert 不受影響，不用改。
⇒ 沒有任何呼叫端把 false 讀成「沒有寫邊」（你擔心的誤用場景），因為根本沒有
  任何呼叫端讀 false 去做任何事——這句話比「不用改」更強：不只不用改，也沒有
  風險可言。
```

②spread_feud 確實呼叫 form_feud（`npc_ai_system.gd:68`）——移閘後滅族繼承那條路
會跟其他路徑一樣多出小邊，這是【統一套用同一個修法】的自然結果，不是特例，不需要
額外處置。

# ★★四、③ feud reader 母體——我幫你數完了，六個 production 讀者，一個真的敏感

```
全庫 grep _edge_intensity_to／RelationGraph.intensity_to／strongest／edges_of_type，
排除 debug/ 與 relation_graph.gd 本體，production 端讀 "feud" 的共 6 處：

①decision_context.gd:558  → c.strongest_feud（連續量，餵下游 utility 加權）
②faction_ai_system.gd:720 → 被 FEUD_ATTACK_MIN(0.5) 擋，小邊(0.075~0.33)進不去
③faction_ai_system.gd:3574→ 同②，且只是 Probe 分類，非決策閘
④npc_ai_system.gd:78(vendetta_target) → 被 VENDETTA_INTENSITY(0.6) 擋
⑤reaction_system.gd:376   → 連續量，(feud-grat)*w 加權進 base，非閘
⑥interaction_system.gd:1821 _views_as_foe → ★★★用 intensity > 0.0（任何非零就算），
  不是門檻比較！
```

★★★⑥是真正敏感的那一個：`_views_as_foe` 目前的邏輯是「有 feud 邊、intensity
大於 0 就算視為敵」——過去因為 FEUD_MIN 擋著，只有 intensity≥0.30 的怨才存在，
現在移閘後 0.075 這種小怨也會存在，**`_views_as_foe` 對更多情境會回傳 true**
（例如被玩家索貢過一次、還沒累積到能觸發 revenge 的門檻，NPC 就已經「視你為敵」）。
其餘 5 個要不是連續加權（符合「小怨累積」的設計意圖），就是被更高的門檻常數擋住、
新的小邊碰不到——**只有這一個是意外增加的真實行為改變**，而 §7 呈報清單裡沒有
點名它。**建議在 §7 補上這一條**：「`interaction_system.gd:1821 _views_as_foe`
會因為小怨變得更容易判定敵對，之前只有大怨才會觸發」。

# 五、③ grudge_ledger_bed 格7 那條理由——同意你的懷疑

```
第三條理由（格7 的名字→邊表不再是完整母體）讀起來是【理由②（邊沒有記憶）的
偵測手段】，不是一個獨立於理由②之外的架構原則——它描述的是「如果理由②的問題
發生了，這支床會怎麼現形」，而不是另一個「為什麼不能這樣做」的論證。
```

**建議**：只留前兩條（繞過人格 factor／邊沒有記憶），把格7 那句改寫成【理由②的
補充說明】（"而這件事可以被 grudge_ledger_bed 格7 偵測到"），不要當成第三條並列
的理由。

# ★★六、P2③ 會不會賭——賭，而且賭得比你想的更兇

```
score_no_edge（tribute_accept 裡已經算出來的變數）決定了 feud 到底能不能翻動決策：
  feud_i 的理論上限漸近於 1.0（永不真的到）⇒ 能扣的分數上限 ≈ 1.0 * TRIBUTE_W_FEUD(0.3) = 0.3
  ⇒ 若某個 leader 的 score_no_edge ≥ TRIBUTE_ACCEPT_THRESHOLD(0.1) + 0.3 = 0.4，
    那麼【無論按幾次】，feud 都不可能把他從 accept 翻成 refuse——不是次數不夠，
    是這個 leader 的人格組合讓煞車在數學上永遠翻不動。
⇒ P2③「至少出現一次 refuse」在一個 score_no_edge ≥ 0.4 的 leader 身上會【恆假】，
  不是因為機制壞了，是這個測試母體選錯了。
```

**建議**：P2 造測試用的 leader 時，明確控制它的人格值（例如手動設 caution/honor/
survival 讓 score_no_edge 落在 0.3~0.35 這種留有餘裕又不會太寬的區間），不要依賴
「隨機/預設值恰好是典型」這種僥倖；並把 `score_no_edge`（或等效的 baseline）當成
P2 的另一個母體地板印出來，讓讀卷面的人看得出「這次測試的 leader 是不是在能被
煞住的範圍內」，而不是讓 P2③ 的通過與否取決於一個沒人看得見的隱藏前提。

# 七、verdict

```
issues（不是 premise_contradiction，方向對；兩條要改，其餘建議非阻塞）：
  ①§2 飽和疊加示例的 0.30 用錯 severity 來源，訂正成 0.075（第 15 次左右，不是第 4 次），
    並把「第 4 次」這個錯誤數字從 §7 呈報拿掉
  ②P2 造測試 leader 要明確控制人格值+印出 score_no_edge 母體地板，
    不要讓 P2③ 依賴一個未經驗證的「典型」假設
非阻塞建議：⑤①②（形狀）與⑤③（reader 母體）你自己的判斷都成立，只多補
  interaction_system.gd:1821 這一個敏感讀者到 §7；grudge_ledger_bed 那條理由
  降級成理由②的補充，不當第三條。
補完①②即視為 CLEAN。
```
