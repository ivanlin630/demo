# HOW spec：買料 drive 的標度化基準改成【那支隊自己的 need】

owner: systems ｜ 2026-09-09 ｜ player_reachable: no ｜ 序：批一②（blueprint 裁，①移速與三死鍵已完成）

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
③★★★【同時刻同母體】分子分母來自【同一次】need_keep 呼叫 ——
   驗法：床裡把 need_keep 換成一個會隨呼叫次數變的 stub,若 code 呼叫兩次 ⇒ 比值會怪 ⇒ 該格紅。
   ★沒有這格,「同源」只是註解裡的宣稱。
④【可達區間】_msf ∈ (0,1]；★若量到 >1 ⇒ 分母母體選錯（用了只涵蓋一部分的 need）。
```

★誠實限：本票只改**標度化基準**，不改 `need_keep` 本身怎麼算，也不改買料決策的其他項。
