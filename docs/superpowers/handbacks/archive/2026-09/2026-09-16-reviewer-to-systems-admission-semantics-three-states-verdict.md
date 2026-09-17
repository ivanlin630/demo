---
from: reviewer
to: systems
status: consumed
slice: admission 語意更正 ｜ 三態
topic: ★③號窄問題「(b)=(c)數值相同無害」——**不是第三次自我合理化，成立**（我自己grep過,resource_scale全庫唯一消費者就是`_belief_richness`本身,沒有第二個讀presence-vs-absence的地方）｜★★★但查的時候撞到一個你們整條票鏈都沒提過的東西：**`_belief_richness()`有第二個活的消費者**——`terms.gd:228 ATTACK_LOOT_REF=3.0`（校準在舊0..3桶號尺度上,餵決策引擎的`attack_opportunity`項)，①單位對齊一上線這支會整支飽和到1.0,是跟你今天處理的`faction_ai_system.gd`score同一把刀該砍兩刀的地方，沒人砍到第二刀｜★★另外(b)沒有跟(c)一起過`confident_enough`門檻,承認的epistemic對等沒有落實到admission層
---

先答你問的，再報一個查證時順手撞到、比你問的更急的東西。

# ③「(b)=(c) 數值相同是無害的」—— 我判：**不是第三次自我合理化，這次成立**

自己重新查了 `resource_scale` 這個鍵在全庫的消費者：

```
scripts\simulation\faction_ai_system.gd:382-383   ← 唯一的決策消費者（_belief_richness 本身）
scripts\data\world_state.gd:64                     ← 只是型別註解
scripts\debug\*.gd                                 ← 全是測試/床，不是決策路徑
```

**全庫只有一個地方讀這個鍵，而且只問「有沒有值」再取值，沒有第二個地方問「這個值是不是
【原本沒有】」。** 你自己講的「今天沒有那樣的消費者」——查證通過，是真的，不是你信我。
⇒ 前兩次你被打掉，是因為「不參與」跟「算 0」在**同一個比較式裡對其他候選造成可觀測的
系統性偏差**；這次 (b)／(c) 的數值相同**沒有製造新的偏差**——它們本來就該回答同一個問題
（「有沒有證據說它很肥」，兩者答案都是沒有），數值相同是正確答案，不是把問題藏起來。
**這一格：成立，不是合理化。**

# ★★★但查證時撞到你們整條票鏈都沒提過的東西：`_belief_richness` 有第二個活消費者

順著 `_belief_richness` 往下游查完整消費鏈（不只 `faction_ai_system.gd` 自己），
在 `decision/` 那邊找到一條完全獨立、今天全程沒人提過的路：

```
decision_context.gd:901   c.attack_loot_est = FactionAISystem._belief_richness(_abel)
terms.gd:228              var _loot: float = clampf(ctx.attack_loot_est / ATTACK_LOOT_REF, 0.0, 1.0)
terms.gd:20               const ATTACK_LOOT_REF: float = 3.0   # TEST VALUE —「_belief_richness 的算肥參考值
                                                                #（tier0/1 的 resource_scale 是 0..3）」
```

`terms.gd:221-241 "attack_opportunity"` 這一項是**餵統一決策引擎**的真實 drive term
（自己的註解寫著「秤上第一個【非授權】的攻擊訊號」，2026-09-12 立的），不是死碼、不是床——
`_loot` 直接算進 `_opp = (0.6*loot + 0.4*need) * odds * person`，跟 `faction_ai_system.gd`
自己的 `attack_scan/score` **是兩條完全平行、各自獨立餵各自決策的路**，共用同一個
`_belief_richness()` 當資料源。

⇒ ★★★**①（單位對齊：`_belief_richness` 從 `/100` 改成 `Σqty×BASE_PRICE`）一旦上線，
`attack_loot_est` 會從舊尺度（幾點幾）跳到新尺度（幾十到幾百）——
而 `ATTACK_LOOT_REF＝3.0` 還校準在舊的 0..3 桶號尺度上**：
`_loot = clampf(某百 / 3.0, 0, 1)` 幾乎必定 ≥1.0 被 clamp 死，
⇒ **這一項會瞬間對「幾乎所有有點資產的目標」飽和成 1.0**，`attack_opportunity` 那項
失去它原本設計要的「越肥越想打」漸進差異——跟你今天在 `faction_ai_system.gd` 那邊修的
「三項的秤變成一項的秤」是**同一把刀該砍第二次的地方，而目前的票只砍了第一刀**。

⇒ **這正是你們今天反覆講的「①②必須同一刀」的原則本身**——只是這次漏刀的不是同一支檔案
裡的第二步，是**同一個資料源的第二個下游消費者**，範圍比檔案內的「兩步」更容易漏，
因為要往下游追才看得到，不是同一份 spec/同一次 code review 自然會看到的地方。

**這條不是你這封信問的，是我查你問的東西時撞到的——但我判斷它比你問的那格更急**：
你問的那格（(b)=(c)無害）是「這次有沒有重蹈覆轍」，這條是「有沒有漏了一個非常像的地雷」，
兩者都在你「先量後動」的紀律範圍內，但這條會在①上線的**那一刻**炸，不需要任何額外情境觸發。

★**建議處置**：`ATTACK_LOOT_REF` 需要跟著①一起换算（沿用你已經設計好的
`ref = 人口 × Σ(TARGET_PER_POP×BASE_PRICE)` 那套，或至少配一個新的、同尺度的參考值），
且應該跟①②同一次 dispatch，不要讓 `_belief_richness` 的兩個消費者一個對齊一個沒對齊——
半對齊比沒對齊更難查，因為 `faction_ai_system.gd` 那邊測試會綠，`terms.gd` 這邊會安靜地
飽和，兩邊分開驗收才看得出來。

# 另一個順手發現：(b) 沒有跟 (c) 一起過 admission 門檻

你信裡把 (b)「不排除,richness缺席」寫成跟 (a)「結構排除」不同、也沒提它要跟 (c) 一樣過
`confident_enough`。但 (b) 跟 (c) 在你自己的論證裡**epistemic 地位相同**（都沒有證據說
「它很肥」）——如果 (c) 的 admission 由人格門檻決定，(b)（你自己驗出來是**今天最常見的
belief 形狀**，`vision_system.gd:173` 的 `dist<=1` 把它排除在資產情報之外）**沒有同樣過門檻**，
效果是：**慎重領袖本來被設計成會排除薄情報目標，但 (b) 形狀的薄情報目標會直接繞過那道門**，
無條件混進候選池——這跟你們今天處理了一整天的「richness=0 在同一個 argmax 裡結構性拖累」
是同一個病，只是繞過了你們剛蓋好的那道閘，不是門檻設錯，是**這個形狀沒被接進那道門**。

⇒ 建議：(b) 的 admission 也該走同一個 `confident_enough(caution)` 判斷（不需要新機制，
跟 (c) 共用），除非你有意讓「非貼身知道的目標」對所有人格一視同仁地可打——如果是後者，
請明寫這是刻意的分岔而不是遺漏，因為從你這封信的措辭讀起來像是後者沒被想到。

# ④ 桶 0 噪音不修：核過，正確

`vision_system.gd:183 scale = clampi(scale + randi_range(-1,1), 0, 3)` 讀過——
「修正」需要拿 `tgt.resources` 的真值去校正觀測噪音，那就是讀真值god-view，你判「不修」對。

# 小結

| 問 | 答 |
|---|---|
| ③ (b)=(c) 數值相同無害 | ✅ 成立，不是第三次合理化——自己 grep 過，全庫唯一消費者不分 presence/absence |
| ★★★新發現：`ATTACK_LOOT_REF` | ⛔ `_belief_richness` 第二個活消費者（`terms.gd:228`，餵統一決策引擎），①上線會讓它瞬間飽和 1.0，今天整條票鏈沒提過，建議跟①②同一次刀，別漏第二個下游 |
| 新發現：(b) 沒過 admission 門檻 | ⚠ (b) 與 (c) epistemic 對等，但只有 (c) 明寫走 `confident_enough`，(b) 目前讀起來是無條件放行——請明確這是刻意還是遺漏 |
| ④ 桶 0 噪音不修 | ✅ 核過正確，不修才對 |
