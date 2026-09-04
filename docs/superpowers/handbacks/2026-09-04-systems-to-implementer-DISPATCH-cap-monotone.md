---
from: systems
to: implementer
status: open
slice: goal-util-cap-monotone ★派實作（R² CLEAN）
tier: slice
topic: ★派,而【merge 我壓在考試 GO 之後】——理由:merge 會改 argmax=改世界,而長考的多張跑必須同源;做完驗收就停在 branch,別催我 merge;★★R² 抓到我 spec 一個實質數學錯:x 必須是 payoff=maxf(w,0) 不是原始 w(w 可為負 ⇒ x∈(−1,0) 時 u 變負、x→−1 時發散);★★★而 pop 敏感度那格不是是非題:maintain 側自我抵銷、build 側有殘留【而殘留方向對齊 size_matter_arc】—— 我加了驗收 9 把它變成可觀測,別讓它靜默存在
---

# 派工（spec = `docs/superpowers/specs/2026-09-04-goal-util-cap-monotone-HOW.md`）
```
u = CAP × x / (1 + x)        ★單調遞增、值域 [0, CAP) ⇒ GOAL_UTIL_CAP < SURVIVAL_BOOST_MAX 【不必改】
x = ★payoff / UNIT           ★★必須是 payoff = maxf(w, 0.0)，★★★不得是原始 w
UNIT = pop × ResourceSystem.FOOD_PER_PERSON_PER_DAY × BASE_PRICE["food"]   ←【該隊一天生計的價值】
```
★**`x` 那條是 R² 抓到的實質錯**（我 spec 原本寫 `x = w/UNIT`）：
```
w 可以是負的(有餘)⇒ x ∈ (−1,0) 時 u 【變負值】⇒ 保序與值域兩個賣點都破
★★而 x → −1 時分母趨近 0 ⇒ ★★★u 發散,公式炸開
```

# ★★驗收（★9/10 是我這輪新加的）
| # | 判準 |
|---|---|
| 1 | `gu2.clamped` 大幅下降（現況 167/333；★不要求歸零） |
| 2 | 同隊同 tick 五個 option **不再同為 CAP**（逐筆貼一例） |
| 3 | `tie_exact` 逐 option 再下降（對照 74–85%） |
| 4 | ★**保證未被侵蝕**：`u ≥ GOAL_UTIL_CAP` 的**反例計數 ＝ 0**（機械斷言） |
| 5 | determinism 三跑一致（`fp` 會變） |
| 6 | 值分布印 `w`／`x`／`u` **三欄**（★組成項一起存） |
| 7 | 憲法閘 PASS |
| 8 | perf：段級 `PHASE_TIMING` before/after，`EXCLUSIVE=yes` |
| ★9 | **依隊規模分層印 build 的 `x`／`u`**（小／中／大 pop 三段）⇒ ★★把 pop 殘留【變成可觀測】 |
| ★10 | ★**`x < 0` 的發生次數 ＝ 0**（★★不是「數學上不會」，是**量到它沒有**） |

# ★★★而 merge 我壓在【考試 GO 之後】（★這是排程裁定，不是你的事做不好）
```
★merge 會改 argmax ⇒ 改世界
⇒ ★★而長考的多張跑【必須同源】(同一顆 code),否則張與張之間不可比
⇒ ★★★所以:做完驗收就【停在 branch】,回報我,別催 merge
★而順序取決於用戶按 GO 的時間:
   GO 先到 ⇒ 考試跑在【現在的 main】,cap 在考後 merge（卷單風險④已標「仍有一半落在上限」）
   GO 沒來而你先做完 ⇒ 也等 —— ★因為我們無法預測 GO 何時到,而【考到一半換 code】比【晚一點修好】糟得多
```

# ④pop 殘留那格：**照 R² 改寫成兩半，不是是非題**
```
★maintain_* 側:target ∝ pop 而 UNIT ∝ pop ⇒ ★★【自我抵銷】
★★build_* 側:建設成本【固定】而 UNIT 隨 pop 長大 ⇒ x 系統性變小 ⇒ 大隊「蓋東西比較不急」
⇒ ★★★而那個方向【對齊既有設計意圖】(project_size_matter_arc:規模經濟 absent 是已知缺陷)
   ⇒ 「同一筆固定成本對大隊相對負擔更輕」正是規模經濟的一種展現 ⇒ ★不是新 bug
⇒ ★★驗收 9 就是為它加的:【讓它可觀測】,而不是靜默存在
```
