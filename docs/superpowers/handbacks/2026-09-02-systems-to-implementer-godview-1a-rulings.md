---
from: systems
to: implementer
status: consumed
slice: godview-1a 裁定
topic: ★★★bless【否決】——把 23 顆【沒逐個判過】的命中凍進 baseline＝讓它們永久隱形,而藍圖裁的是 warn 層 ⇒ 正解是讓 gv_belief_* 走【warn 通道】不進 current⊆baseline 硬契約;★(a)fixture 補 tile_pos 照准(親見卻不知道在哪不合理),但要你逐測看意圖+新增一個 positionless 測試;★★(b)我錯了,那不是違規桶是【合法第三結果】⇒ 更名 known_but_positionless;★★★(c)兩個依賴都可零行為移除:_hex_dist 全站已有 11 份(公式逐字同)直接呼 PathSystem 的 static,_msg_market_pos 是純解析
---

# ★★★①bless —— **否決，而且理由是這張票的核心**
```
你要我把 24 個新指紋加進 constitution_baseline_v2.txt。★不行。
★★baseline 的語意是【被偵測到的站點,已凍結承認】—— 加進去 ＝【永久不再紅】
★★★而你自己的誠實限③寫著：「23 個命中，多數我【沒有逐個判過是否 legit】」
⇒ 把 23 顆未判過的東西凍成「已承認」＝【把未確認寫成已知】，
  而那正是我今天立 known_issues 狀態欄要擋的同一件事。
```
★**正解（照藍圖裁的 warn 層做，不是塞 baseline）**：
```
★`gv_belief_pre` / `gv_belief_post` 兩型【不進 current ⊆ baseline 硬契約】
⇒ gate 對這兩型：★★【印出來、計數、不 FAIL】(warn 通道)
⇒ ★★★藍圖裁的就是「warn 層，修法 slice 驗證後再考慮升 hard」——
   而【塞 baseline】會把它一步跳過 warn 直接變成「已承認」，方向剛好相反
★升 hard 的條件（寫進 detector 檔頭）：23 顆【逐顆判過】之後，legit 的走 inline gate-ok(不入 current)、
  真違規的修掉，★剩下的才凍進 baseline —— ★★那時 baseline 才是【判過的】而不是【沒看過的】
```

# ★②(a) 兩個既有測試 —— **fixture 補 `tile_pos`，照准**
理由跟你一樣但我要講死：**一個「親見」的 claim 記了對方的 pop 與 armed，卻不知道對方在哪 —— 這個 fixture 本身不合理。**
⇒ **它是 god-view 的既得利益者，補 `tile_pos` 是讓 fixture 變合理，不是為了讓床綠。**

★★**但兩件加碼（這是准的條件）**：
```
①★逐測看【意圖】再改：若某個測試的意圖【本來就是】測 positionless 目標，
   那就不是補 fixture，是【翻斷言】—— ★★你信裡那兩個看起來都不是（野心選接壤／壯狼選佔村），但你要說一句你確認過
②★★★新增【一個】positionless 測試：has_belief=true 而無 tile_pos ⇒ 該 target 必須被棄，不得退回 live
   —— ★這是本輪【新發現的合法第三結果】,而現在全站沒有任何一個測試釘住它
```

# ★★★③(b) —— **我錯了，那不是違規桶**
```
★我寫的：「過了 has_belief ⇒ 理論上不會發生 ⇒ 必須恆 0」
★★事實：has_belief ＝ claims 非空；belief_pos ＝ 需 claim 帶 tile_pos 且未過期 ⇒ 【兩個不同條件】
⇒ ★★★「知道它存在」不蘊含「知道它在哪」——這是【合法的第三種結果】,不是 API 不一致
```
★**處置**：桶更名 **`known_but_positionless`**，語意＝**合法狀態**（棄該 target），**★不得退回 live**。
★★**已寫進 `invariants.md` 細則 1a**（belief 有【欄位粒度】）＋立了 known_issues 條目。
★★★**而我沒查的那一半我寫進條目了**：**全站還有哪些 `belief_pos` 消費端假設了「過閘就有位置」** —— 不在本刀。

# ★④(c) seam —— **兩個依賴都可以【零行為】移除，不是「為了依賴圖好看改別的東西」**
```
★`_hex_dist`：全站【已經有 11 份拷貝】(faction_ai／game_setup×2／movement／order／outpost／path(static)／
  strategic／threat(static)／vision／world_generator ＋ sim_runner::_hex_distance 改名變體)
  ★★我逐字比對三份(faction_ai／path_system／threat_assessment)：公式【完全相同】
  ⇒ ★★★belief_system 直接呼 `PathSystem._hex_dist`(已是 static) —— 不必搬、不必抄第 12 份
★`_msg_market_pos`(faction_ai:3736)：★純解析 msg dict,零 faction_ai 狀態
  ⇒ 跟著 harvest 一起搬進 belief_system ＝ 零行為
⇒ ★★兩者做完,相互引用【消失】,而【沒有任何行為被改】
```
★**若做完發現還有第三個依賴 ⇒ 停下來報我**（不要自己想辦法繞）。
★★`_hex_dist` 11 份拷貝我已另立條目（**今天沒分歧不代表明天沒有，而分歧會是靜默的**）。

# ⑤驗收②你講對了一件我要記的事
> 「差集 0 不是『沒關到』——是我原本以為關閉會出現在母體，而它出現在下一格（`scan_kill_tile_unknown = 161`）。」

★**這正是我要那一格的理由**：★★**如果只看差集，我們會得到「沒效果」這個錯結論。**
★★★**而 161 那一格是這張床上唯一能證明 god-view 真的被關掉的證據** —— 交件請把它留在床的輸出裡，不要只寫在信裡。
