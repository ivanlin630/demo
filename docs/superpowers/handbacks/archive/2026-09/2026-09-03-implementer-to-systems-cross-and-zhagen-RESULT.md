---
from: implementer
to: systems
status: consumed
slice: band × filter 交叉 ＋ 紮根條件級（3 seed × 30 日）
touches: scripts/simulation/faction_ai_system.gd, scripts/simulation/decision/decision_engine.gd, scripts/simulation/decision/decision_context.gd, scripts/simulation/decision/options.gd
topic: ★★★紮根有明確答案:`can_settle_here` 三 seed 都是 86~100% false(19/21),而 resume_site 那支是偶爾救回來的那一支 ⇒ 卡住的是【can_settle_here】;★★而 band×filter 我【拒絕挑一個贏家】:深帶按次數是③主導(53~86%),按相異集合③卻通過 64~80% —— 兩者又相反,而④⑤在深帶的絕對量不小;★深帶「找到施主」的 seed 差異是 0.5%↔52%,單 seed 下任何結論都會錯
---

# ★★★①紮根：卡住的是 `can_settle_here`

`options.gd:239`：`applicable = can_settle_here or settle_resume_site != (-1,-1)`（兩支互斥且窮盡）

```
seed   母體  can_settle_here=false   resume_site 為空   兩者皆false(不 applicable)  applicable
1337     7        6 (85.7%)             4 (57.1%)              4                      3
42       6        6 (100.0%)            5 (83.3%)              5                      1
7        8        7 (87.5%)             5 (62.5%)              5                      3
合計    21     ★19 (90.5%)            14 (66.7%)             14 (66.7%)              7 (33.3%)
```
★**`can_settle_here` 幾乎恆 false（90.5%）**，★★**而 `settle_resume_site` 是【偶爾把它救回來】的那一支**
（applicable 的 7 次裡，多數靠它）。
⇒ ★★★**下一步是拆 `can_settle_here` 本身** —— **而我沒有拆，也沒有猜它為什麼 false。**

## ★而兩個母體不同，我先講清楚免得看起來矛盾
```
`zhagen.mother` = 21（每次 rank_scored 且 IDLE 且 committed==紮根）
#10 的 `not_in_ranked` 紮根 = 9（只在 redispatch funnel 那個決策入口）
⇒ ★兩者【都是對的】，量的是不同的東西：前者是「這個狀態出現幾次」，後者是「再派那一格看到幾次」
⇒ ★★不要把 21 跟 9 相減
```

# ★★②band × filter：**我拒絕挑一個贏家，因為兩個口徑又相反**

## 最深帶（`food_days` < 0.5）
```
seed   呼叫  ①母體空  ②無belief  ③無food_est  ④不夠分  ⑤到不了  找到施主   ②集合 ③集合  ③/②
1337    261    73        0          952        330      273      6 (2.3%)    80    51    64%
42      219    56        0         1955        198      132      1 (0.5%)    77    51    66%
7       716    61        0         4424       2476     1434    372 (52.0%)   98    78    80%
```
★**按【次數】：③ 主導**（53~86%）—— ★★**按【相異集合】：③ 仍通過 64~80%** ⇒ **兩個口徑又相反。**
★★★**而這正是上一輪已經發生過的事**：**少數沒有 `food_est` 的隊被每 tick 重掃 ⇒ 次數灌水。**
⇒ **所以深帶【不是】被資訊門檻擋死的** —— ★而④⑤在深帶的絕對量不小（seed7：④2476／⑤1434）。

## ★★★而最刺眼的是 seed 差異，不是哪一道濾網
```
深帶「找到施主」：2.3% ／ 0.5% ／ ★52.0%
⇒ ★同一份 code、同樣 30 日、只差 seed ⇒ ★★「世界有沒有施主」是【世界長出來的樣子】不是機制常數
⇒ ★★★所以【單 seed 下的任何結論都會錯】—— 而我上一輪報「深帶 0.0~7.2%」時只有兩個 seed 有深帶資料
```
★**照你先寫死的判讀表**：沒有任何一列乾淨命中 ——
★★**④主導？** 只有 seed7 的④接近③的一半。★**⑤主導？** 沒有。★**③主導？** 次數是、集合不是。
⇒ ★★★**我的結論是「這張表答不出單一主因」，而那本身是答案**：
**深帶的施主可及性主要由【世界隨機性】決定，其次才是濾網。**

# ★③其餘帶（供對照，非重點）
```
ge5    ：找到 3117/8534(36.5%)、2945/7767(37.9%)、3336/8456(39.5%)  ⇒ ★三 seed 高度一致
0.5to2 ：115/412(27.9%)、130/634(20.5%)、290/734(39.5%)
⇒ ★★不餓的帶【三 seed 一致】，越餓越發散 —— ★★★而那與「越餓越依賴少數幾個鄰居」相容
   （但我沒有量鄰居數，所以這句是【相容】不是【坐實】）
```

# ④誠實限
```
①★單 config（warring）；★★三 seed 在【深帶】差異極大 ⇒ 深帶結論需要更多 seed
②★`zhagen.mother` 合計只有 21 ⇒ ★★90.5% 這個比例的信賴區間很寬，
   ★★★但「can_settle_here 是那一支」這個【形狀】三 seed 一致
③★我沒有拆 `can_settle_here`，也沒有猜（blueprint 明令）
④★★fp：本輪只加 Probe 桶（含一個 `# gate-ok` 標記，理由寫在該行：整段在 Probe.enabled 內、
   純計數、不改 scored 也不改控制流——與 faction_ai 的 redispatch funnel 同形同理由）
   ⇒ merge-gates 11 綠／headless 紅（仍是 dcef1f63 那 5 條 branch-only）
```

# ⑤落地
```
量測  docs/measurements/2026-09-03-band-cross-zhagen-warring-seed{1337,42,7}-30d.txt
床    scripts/debug/three_tickets_bed.gd
commit fcb90d08
```
