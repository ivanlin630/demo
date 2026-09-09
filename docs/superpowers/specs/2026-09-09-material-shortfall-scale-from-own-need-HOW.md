# HOW spec：買料 drive 的標度化基準改成【那支隊自己的 need】

owner: systems ｜ 2026-09-09 ｜ player_reachable: no ｜ 序：批一②｜狀態：R² CLEAN（2026-09-09，兩項補完）⇒ 可 dispatch

## §1 病

```
terms.gd:25   const MATERIAL_SHORTFALL_FULL: float = 80.0
              # TEST VALUE — 買料 material 缺口標度化基準（≈一 weaponsmith cost；缺此量→drive 滿）
terms.gd:306  var _msf: float = clampf(ctx.material_shortfall / MATERIAL_SHORTFALL_FULL, 0.0, 1.0)
```

分子是**那支隊自己的缺口**，分母是**一個對所有隊都一樣的常數**。
⇒ ★「缺 80 材料」對一支想蓋大設施的隊是小事，對一支只想補個柵欄的隊是天大的事，
   而現在它們得到**同一個 drive**。★★(ii) 型：看見了一個錯的值。

## §2 ★★★分子分母必須同源（單位＋母體都是）

```
分子  decision_context.gd:599
      c.material_shortfall = maxf(NeedOracle.need_keep(state, team, "material", lv)
                                  - ResourceSystem.effective_holding(state, team, "material"), 0.0)
⇒ 單位＝material 數量；★而它【已經是】相對於 need_keep 的差
★★正確分母＝【同一次呼叫的 need_keep】：
      _msf = shortfall / max(need_keep, ε)
   ⇒ 語意＝「自己的需求有幾成沒被滿足」，★天然落在 (0,1]，clamp 變成多餘的保險而非判準
   ⇒ ★★★而且 shortfall > 0 ⇒ need_keep > holding ≥ 0 ⇒ need_keep > 0 ⇒ 【不會除以零】
```

★**不要用 `_construction_facility_need`（`coin_treasury.gd:52-53` 那條）當分母**：
它只涵蓋**建設**那一塊，而分子的 `need_keep` **涵蓋更多**（註解 :597 自己寫著「need_keep 含 construction need」）
⇒ ★★分子分母母體不同 ⇒ 比值會 > 1 且沒有意義。**這正是我 memory 裡「分子分母要同一母體」那條。**
★★★（我在批一那封信裡把 ② 寫成「coin_treasury 已對齊真 build-need」——
   那是**它那一端**的正確做法，**不是這一端的分母**。這裡更正。）

## §3 修法

```
①`decision_context` 把該次的 `need_keep(material)` 一起存下來
   （★不要在 terms 裡【再呼叫一次】—— 兩次呼叫之間世界可能已變 ⇒ 分子分母就不同時刻了）
   建議欄名 `material_need_total`，與 `material_shortfall` 在同一段落賦值。
②`terms.gd:306` 改成 `clampf(ctx.material_shortfall / maxf(ctx.material_need_total, 0.01), 0.0, 1.0)`
③`MATERIAL_SHORTFALL_FULL` ★連常數一起刪，只留一行註解說明舊版。
```

## §4 驗收

```
①【腦看得見】同世界 before/after：★需求大的隊與需求小的隊,在【相同絕對缺口】下 drive 不同
   ⇒ dump 至少兩支 need_total 差很多的隊,印出它們的 _msf，看兩者是否分開。
②【分布】接線前 _msf 由絕對缺口決定 ⇒ 接線後跨隊【相異值增加】（母體＋相異數，不是單點）。
③★★★【同時刻同母體】分子分母來自【同一次】need_keep 呼叫。
   ★我原本寫的 stub 驗法【不可行】（R² 2026-09-09 指出，我自己標了不確定而沒查）：
     `need_oracle.gd:13` 是 `class_name` + `static func` ⇒ GDScript 沒有 instance／DI 縫可換身，
     要能 stub 就得動 NeedOracle 本體，而本票誠實限寫著不動它。
   ★★改成【結構檢查】——理由是這件事本來就不是 runtime 性質：
     照 §3① 的修法（一個 local var 同時餵兩欄、同段落賦值），「只呼叫一次」是【程式碼形狀】保證的。
   ⇒ 驗法（★放進床裡用 `FileAccess` 讀原始碼,不是靠人 code review ——
      「code review 檢查項」不可執行,下一輪就沒人做）：
     `decision_context.gd` 裡 `NeedOracle.need_keep(state, team, "material"` 的出現次數 == 1，
     且 `material_shortfall` 與 `material_need_total` 兩行的賦值來自同一個 local var。
   ★★★成對對照（缺了它這格是恆真）：床內先對一段【自己造的、含兩次呼叫的字串】跑同一個計數器，
     必須數到 2 ⇒ 證明計數器真的會動；再對真檔跑，必須是 1。
④【可達區間】_msf ∈ (0,1]；★若量到 >1 ⇒ 分母母體選錯（用了只涵蓋一部分的 need）。
```

## §5 ★連帶要修的一支床（R² 查出來的，不是我）

```
material_buy_test.gd:77/79   lo/hi 兩支只設 material_shortfall = 80.0，不設 material_need_total
⇒ 改完後新欄未賦值 = 0.0 ⇒ _msf = 80/0.01 = 8000 → clamp 1.0
⇒ ★斷言 d_hi > d_lo 【很可能照樣過】,因為新舊都 saturate 到 1.0 —— 那是巧合不是測到東西
```
★★而它餵的是**世界不會產生的狀態**：`shortfall` 定義上 ≤ `need_keep`，
`need_total = 0` 時 `shortfall` 只能是 0。⇒ 這已經不是「候選」，是
**「床餵了世界不會產生的輸入」的實例**。
⇒ 修法：`lo`／`hi` 兩支都加 `material_need_total = 100.0`（★兩者相同，保留原測試意圖
「差異只來自 `material_build_urgency`」）⇒ `_msf = 0.8` 不再 saturate，
`d_hi > d_lo` 才是真的測到 urgency 的效果。

★其餘讀 `material_shortfall` 的點不用動（R² 全掃過）：`framework_f1_test.gd:50`、
`material_buy_test.gd:85/94/98/103` 都只餵 `options.gd:419` 的 `applicable` 布林閘，不進 `terms.gd:306`。

★誠實限：本票只改**標度化基準**，不改 `need_keep` 本身怎麼算，也不改買料決策的其他項。
