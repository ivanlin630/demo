---
from: implementer
to: systems
status: consumed
slice: storage-fits-own-next-step
tier: behavior
topic: ★關係式已 pin(真閘+A/B/C 同一支函式)、cap [200,500]→[250,650]、vault_full 9→3;★★★而改 cap 讓一個既有崩潰現形,對照坐實是【我自己那顆 tap】的 null-deref(rank_scored_ctx 的 state 是預設 null 參數);★★fp 逐位元【不變】——與你 spec 預期相反,理由是 warring_states 上這個 cap 不 binding;★三條寫死舊 cap 的測試改成讀單一真值不是放寬;@eec4f894
---

# ★①做完了

| # | 判準 | 結果 |
|---|---|---|
| 1 | ★**A/B/C 三組對照都跑、都要紅**（同一支純函式） | ✅ `storage_fits OK（真閘 civilian L1/L2 + 對照 A/B/C 皆紅）` |
| 2 | 真閘綠 | ✅ civilian 兩級皆過 |
| 3 | ★`matunload.vault_full` 下降 | ✅ **Team3/4/7：9 → 3** |
| 4 | `upgd.dispatched` | ❌ **仍 0** —— ★**照原樣回報，不預測**（分桶仍 `lt_cost 182／cost_to_margin 75／ge_margin 1`） |
| 5 | 對帳／headless／憲法閘 | ✅ **7 vs 7 PASS**（＋新閘綠）／**PASS (sites=74)** |
| 6 | `fp` | ★**逐位元不變** —— **見下，與你 spec 預期相反** |

★**`military` 一行沒動**（`cap 300 == 全費 300`，`≥` 成立；墊高要另過 WHAT，我沒順手改）。
★**動 cap 不動 cost**，理由照你寫的。

---

# ★★★②而改 cap 讓一個【既有崩潰】現形 —— 對照坐實：**是我自己那顆 tap**

```
SCRIPT ERROR: Invalid get index 'world' (on base: 'Nil')
   at: rank_scored_ctx (decision_engine.gd)
```
★**對照組**：**HEAD 沒有這一條**；**只加 cap 改就有** ⇒ ★★**不是猜，是我造成的。**

## ★根因
`rank_scored_ctx(ctx, current_option, state: WorldState = null, team = null)` —— ★**`state` 是【預設 null 的參數】**，
**harness／單元測試就有不傳的呼叫端。**
★★**而我先前那顆 `funnel.decide.day` tap 無條件寫 `state.world.current_tick`** ——
⇒ **那些呼叫端一旦 `Probe.enabled` 就崩。** ★★★**觀測把被觀測的世界弄掛了。**

## ★★修法【不是靜靜跳過】
**跳過會讓日桶少計、而總量照計** ⇒ ★**我自己建的「日桶加總 == 總量」對帳式會【無聲變不平】。**
⇒ 改成 `.day.no_state` 這個**看得見的桶**：**對帳仍然平，而異常自己會冒出來。**

★**這件事的形狀我記下來**：**「觀測不得改變被觀測物」不只是不耗 RNG —— 也包含【不得讓它崩】。**
★★**而它現形的方式很偶然**：**cap 改動改了某個測試的執行路徑** ——
**若沒有這張票，它會一直躺在那裡，等下一個開 `Probe.enabled` 的人踩到。**

---

# ★★③`fp` 逐位元【不變】—— 與你 spec §6 預期相反，理由查清楚了

```
spec §6：「倉容改＝世界不同 ⇒ fp 兩床都會變」
實測    ：fc9abb6ed8156f4dc45abdd3ca8fd12f   ←★與上一顆卸貨後的基線【逐位元相同】
```
★**理由**：`a4_determinism_check` 跑的是 **`warring_states`**，而**那張床上這個 cap 不是 binding**
——**沒有任何公庫撞到 200**，所以把它抬到 250 對世界零影響。
⇒ ★★**回歸防線因此不花力氣就成立**，★**而新基線就是 `fc9abb…`（照你立的紀律：當場重測、寫進 handback）。**

★**我沒有因為「它該變卻沒變」就去找一個能讓它變的跑法** —— **那會是把儀器調到符合預期。**

---

# ★④三條寫死舊 cap 的測試：**改成讀單一真值，不是放寬斷言**
```
headless_test:8441   os._get_storage_cap(tile,"material") == 200.0
headless_test:8718   cap == 500.0
_test_normal_tax_vault_cap  預存 199.5 ＋ assert pub == 200.0
```
★**它們驗的是【cap 有生效／溢出會卡住】這個行為，不是那三個數字。**
⇒ 改成讀 `TileBank.OUTPOST_STORAGE_CAP[...]`（預存量改 `cap - 0.5`）——
★★**意圖一字未改，它們照樣抓得到「cap 沒生效」的真回歸；只是不再手抄一個設計常數。**
★★★**而這正是本票新閘存在的理由**：**關係式測試取代手抄值測試。**

# ★誠實限
★**Team5 `vault_full` 仍 72/72** —— **私產 120，cap 抬到 250 仍裝不下**（它多卸了 50：250 → 300）。
★★**本票只修「倉庫裝不下」的尺寸**，**它那 400 是床 config 塞的，你已列為刻意不改。**

# ★下一件
★**你新派的 `infra-ladder-dissolve` 我看到了，照你說的排在本票之後 —— 現在開始做。**
