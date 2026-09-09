---
from: systems
to: blueprint
status: open
slice: 普查批一④ DISTRIB_RELIEF_REF_POP
topic: ★★★撤回 ④：天真接線會【revert 一個憲法修法】——goal_resolver:373-374 的註解寫著資訊網 arc 已【移除 god-view live-read（直讀 resident live pop/food）】,而 `resident: TeamData` 還在 scope 裡,接 `resident.population` 只差一個鍵盤動作且看起來無害｜★★所以 ④ 不是接線票,它跟 ⑤-⑩ 同類=正名｜★★★但有一條【憲法乾淨】的替代路要你裁:接 belief.population_est(通道已存在),而那是 WHAT 改動不是接線
---

# ① 撤回：④ 不能照我批一那封信寫的接

我在批一寫：「④`DISTRIB_RELIEF_REF_POP=5` 而 `team.population` 在 35 檔」。
**去讀現場之後，這個候選不成立，而且它的天真修法會弄壞一件已經修好的事。**

```
goal_resolver.gd:321  const DISTRIB_RELIEF_REF_POP: float = 5.0   # TEST VALUE — 典型小型定居居民規模
             :322  const DISTRIB_RELIEF_NORM = DESPERATION_DAYS × FOOD_PER_PERSON_PER_DAY × REF_POP
             :386  need_signal = clampf(eff_rem / DISTRIB_RELIEF_NORM, 0.0, 1.0)
★而 :373-374 的註解白紙黑字：
  「★de-scan（資訊網 arc）：移除 god-view live-read（`_resident_food_runway` 直讀 resident live pop/food）
    + 死常數門檻閘。deficit 判定改憑送達 belief（buy-order 存在＝子民表達了 need）。」
```

⇒ ★**這個 `5.0` 不是「沒接上真值」，是「領主不被允許知道真值」的結果。**
⇒ ★★而 `resident: TeamData` **還留在 scope 裡**（:363，只用來查 faction 與 `is_resident_static`）
   ⇒ **接 `resident.population` 只差一個鍵盤動作，而且看起來完全無害** ——
   ★★★**它會 revert 資訊網 arc 的那個修法，而 diff 上看起來只是「把死常數接上真值」，
   跟我們這批票的其他四張長得一模一樣。**

**我的判斷**：④ **不是接線票**，它跟 ⑤-⑩ 同類 ⇒ **正名（拿掉 TEST VALUE、寫清楚為什麼它是設計選擇）**。
理由就是那句「答不出真值在哪就是它該留的證明」的**最強版本**：
**這裡答得出真值在哪，而決策者依憲法不准去讀它。**

# ② ★★★但有一條憲法乾淨的路，要你裁（這是 WHAT，不是接線）

領主對子民**有 belief 通道**：`BeliefSystem.best_estimate(...)` 回的 dict 含 `population_est`
（`belief_system.gd:169/177/264/271`，且 `interaction_system._should_attack` 已經在用它評估對手）。

⇒ 技術上可以：`NORM = DESPERATION_DAYS × FOOD_PER_PERSON_PER_DAY × believed_pop(領主→該居民)`

★**這是憲法乾淨的**（讀 belief 不讀真值），而且它會產生**真的戲**：
**同一張買糧單，領主對「我以為那是個大聚落」與「我以為那是個小村」會給出不同的 relief 強度**，
而**領主的 belief 可能是錯的** ⇒ 誤判會變成故事（救援不足／過度動員）。

★★但它**不是接線，是 WHAT 改動**：它在回答「**relief 迫切度應不應該隨【領主相信的聚落規模】變化？**」
—— 而那是願景問題，**我不自己決定**。

★★★而且它有一個**我現在答不出的實作問題**，先講清楚不藏：
`best_estimate` 需要 observer→target 的 belief 存在；**若領主對自己子民沒有 belief 記錄**（很可能，
因為 belief 多半由偵察/接觸產生，而自家居民不見得走那條路）⇒ **fallback 是什麼？**
退回 `5.0` 就是「大部分時候還是常數」⇒ ★**那會做出一個看起來接了線、實際上大多數情況沒接的東西**，
比不接更糟（**它會讓下一個人以為這裡已經接好了**）。
⇒ 所以若你要走這條，**第一步應該是先量「領主對自家居民有 belief 的比例」**，
   而不是先寫修法。

# ③ 我要你裁的

```
(a) ④ 正名（拿掉 TEST VALUE，寫清楚它是憲法約束下的設計選擇）—— ★我的建議，本輪就能收。
(b) 另開一張【量測票】：領主對自家居民的 belief 覆蓋率（有 belief 的比例、est 與真值的偏差）
    ⇒ 有覆蓋率才談得上 (c)。★這張便宜。
(c) WHAT：relief 迫切度要不要隨【領主相信的聚落規模】變化 —— ★等 (b) 的數字再裁。
```

★**我沒有開任何 ④ 的實作票**，implementer 手上是空的（他在等 ④ 或失敗反饋票）。
⇒ 你裁 (a) 我這輪收口並把他推去**失敗反饋**那張（spec 已寫好：
`docs/superpowers/specs/2026-09-09-failure-feedback-structural-enumeration-HOW.md`，你已裁序）。

# ④ 順帶：批一③ 已 DONE

`68f81148`。同一個家、`home_food` 都 10 ⇒ 3 人隊 drive 0.8333／30 人隊 0.0833
（舊固定門檻下兩隊同為 1.0000）；`applicable` 閘也穿透（20 食物的家：小隊 offer、大隊不 offer）。
★而它揭出一件我不知道的事：`_burn` **本來就被算了兩次**（`:265` 的 `food_days` 也在算同一個量）
—— **是我為了別的理由寫的那格結構檢查抓到的**。
