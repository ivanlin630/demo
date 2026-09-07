---
from: implementer
to: systems
status: consumed
slice: godview 真違規 5 顆
tier: infra
topic: ★4 顆修掉、★★第 5 顆(#2 invite)【只解一半】——belief 閘提前(pre→post 實測降級)但四個篩選欄位仍是 live,因為 belief schema 裡【根本沒有那些欄位】,補它們＝新增 belief 欄位＝WHAT,我不自己發明;★③用型別防線(拿掉 fallback 參數 ⇒ 那支函式從此收不到外部值);★★★27 顆 inline gate-ok 我【還沒做】,要先跟你確認標行做法(reviewer 給的是函式級理由,而 gate-ok 是逐行判斷)
---

★commit `85af802e`（branch 已 push）｜閘 `PASS (sites=94, removed=1)`｜gv_belief_* WARN 23 → 21

# ★①逐顆
```
①★`decision_context::gather`（兩處）✅
   照【同函式 :670 absorb_yield 的既有正確 idiom】（has_belief 閘 ＋ population_est）——★不發明新的
   （reviewer 說「不是能力問題是漏改一格」⇒ 那就把那一格補成跟旁邊一樣）
   ＋ `belief.join_host_positionless` / `belief.occupy_target_positionless`（合法第三結果，非違規桶）
②★★`_try_invite_nearby_exile` ⚠【只解一半】—— 見②
③★`_evaluate_alliance_need` ✅【型別防線】：`_get_pop_est` 的 fallback 參數【拿掉】
   ⇒ ★★那支函式從此【收不到任何外部值】⇒ 想拿敵方 live pop 當退路也傳不進來
   ⇒ 無 belief ⇒ -1 ⇒ 呼叫端 skip（★沿用 `find_prosperity_prey` 既有先例，不是新政策）
   ＋ `alliance.threat_skip_nobelief`（非 0 ＝ 這窗裡有幾隊「看得到但估不出」）
④★`_find_trade_partner` ✅ 照 A#27 Fix B 同一形狀（★換列舉起點不是換欄位）
   母體 `team_discovered` → `known_targets`；outpost 位置改掃 `team_tile_known` 不掃全圖
   ⇒ gv_mapscan 9 → 8；★baseline 第 76 行（自述 CANDIDATE-LEAK 那行）已一併移除
```

# ★★★②第 5 顆只解一半 —— **另一半我不自己決定**
```
★已解：belief 閘【提到最前面】⇒【看不到的隊，一個欄位都不讀】
   ⇒ 實測分類 `gv_belief_pre` → `gv_belief_post`（★閘前→閘後，你說過前者比後者嚴重）
★★未解：四個篩選欄位（tags／parent_team_id／combat_target／current_task）仍是 live
   ⇒ ★★★成因【不是漏改】：**belief schema 裡根本沒有這些欄位**
     （`vision_system.gd:111-127` 只記 population_est／tile_pos／last_tick／tier／resource_scale）
   ⇒ 要它們走 belief ＝【新增 belief 欄位】＝「觀察者看不看得出對方在幹嘛／是什麼團」＝ WHAT
⇒ ★要裁的三選一：①新增這些 belief 欄位（感知模型擴張）
   ②接受讀 live 並標 gate-ok ＋ 寫理由 ③改判準（只用 belief 有的欄位篩選）
★我已把現況寫死在 code 註解裡，★★不讓它變成下一個「看過先放著」
```

# ★★③27 顆 inline `gate-ok` —— **還沒做，先問一件會影響正確性的事**
```
★你的條件我收下：逐顆貼 reviewer 那一句理由、不批次 sed
★★而 `# gate-ok` 是【逐行】判斷（`constitution_gate.gd`：`line.find("# gate-ok") == -1`）
   ⇒ ★★★要標的是【那個讀 live 的行】，不是函式標題行
   ⇒ 而 reviewer 給的是【函式級】理由（file::func）⇒ ★我得自己定位每個函式裡是哪一行觸發
   ⇒ 那一步【是我在做判斷】，判錯 ⇒ 標錯行 ⇒ 桶沒消
⇒ ★★我打算這樣做（★你點頭我就動）：逐顆定位 → 標上 reviewer 的理由 →
   ★★★【立刻重跑閘】確認那一顆真的從 21 掉下來 —— ★沒掉就是我標錯行，不是它不 legit
★而 21 顆裡有 2 顆【不在那 27 的名單】，我不標：
   `_update_escort`（你說不要猜）／`_try_invite_nearby_exile`（本票只解一半）
```

# ④驗
```
★constitution_gate：PASS (sites=94, removed=1)｜WARN 23 → 21
★★headless_test：HARD-FAILS 3 ＝ baseline、assertion 數 11 ＝ baseline
★★★三個 fixture 補了 belief（★逐測確認意圖後才補）：
   「trade partner 只選有 outpost」／「限居民團 tile」—— 意圖都不是測 positionless
   ★而後者還要補 `team_tile_known`：★★(5,5)→(3,3) 的【hex 距離是 4】> VISION_RADIUS 3
     ⇒ 新 code【正確地】不知道那個據點 ⇒ ★★★補「這格我看過」讓原意圖成立
     （★我差點把它誤判成「修壞了」—— 是算了 hex 距離才知道新行為是對的）
```

# ⑤誠實限
```
①★fixture 補值是我判「意圖不是測 positionless」後才做，判斷可複驗（意圖寫在測試標題裡）
②★★我沒跑長窗量這四顆的行為差：fp 會變（belief 化必然改行為），
   ★★★而 headless assertion 沒動只代表【那些測試的情境沒走到差異】，不代表世界不分岔
③★`_update_escort` 依指示沒碰、沒猜；★★做這四顆時【沒有】順路拿到 call-graph 證據
④★★★床揭的 relay 副本那件已寫進 `dead_team_orders_bed` 檔頭（你要的那句）
```
