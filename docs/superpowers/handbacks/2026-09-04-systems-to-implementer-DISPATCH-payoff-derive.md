---
from: systems
to: implementer
status: consumed
slice: payoff-derive-bridge ★派實作（R² CLEAN）
tier: slice
topic: ★R² 終判 issues 小、兩條都照做 ⇒ 派;★★而 reviewer 給了一個比我 spec 更好的做法:tie-break 的「成本」直接重用 `_mk_candidate:825` 已經算好的 `_estimate_delay_days`,不要另外定義——又一次「停止把已經算好的數字扔掉」;★★★驗收的成功判準是【恆等消失】不是【那七個開始贏】,它們可能仍然 0 勝而我會判成功
---

# 派工（spec = `docs/superpowers/specs/2026-09-04-payoff-derive-bridge.md` §7＋§8）

```
payoff     = maxf( (target − stock) × BASE_PRICE[res], 0.0 )
   maintain_*:res = prereq 的 res
   build_*   :A 類 evaluator 已讀 outputs 的 need ⇒ 同式套 outputs（★C 類 special 照舊，不動）
tie-break  = 真值相等時選 `_estimate_delay_days` 較小者
   ★重用 `_mk_candidate:825` 那個既有量,★★不要另外定義一個「成本」
值分布 dump = 印【未 clamp 的 w】—— 否則「有餘多少」整段不可見
```

# ★驗收（★成功判準是【恆等消失】，不是【輸家變贏家】）
| # | 判準 |
|---|---|
| 1 | `gu2.payoff_val` 相異值 **> 2**，附完整值分布 |
| 2 | `tie_exact` 逐 option **下降**（★不要求歸零：真平手可以存在） |
| 3 | ★同隊同 tick 的 `maintain_*` **不再逐位元相同**（逐筆貼一例，★**別拿 maintain_material 當代表**：它組成項不同） |
| 4 | determinism：同 seed **三跑一致**（★`fp` 會變＝行為真的改了，**不要求逐位元不變**） |
| 5 | perf：印 `need_keep`／`_facility_deficit` 每決策呼叫次數 ＋ 該段 wall-clock（★`:139` 是**重算**不是取用） |
| 6 | 陰性對照：**導出後仍印值分布** |
| 7 | 憲法閘 PASS（導出式不得寫成新門檻） |
| 8 | 兩家族值域**重疊**：min/p25/med/p75/max 並排 ＋ 包含率（★**兩個數字都留**，別只留一個） |
| 9 | `local_value` 抽 `shortage_ratio` 若做了 ⇒ **逐位元不變**（純重構）★**若你判斷不需要抽就別抽**，spec 不強制 |
| ★10 | **有沒有單一資源因為【價高】而系統性贏**（reviewer 加：BASE_PRICE 跨資源 ~40 倍價差） |

# ★★不在範圍（★明寫，防止順手做掉）
```
★①need oracle S2 本體 ②跨家族「正確性」(本 slice 只保證同單位、不保證秤得對)
★★③SURVIVAL_GOODS ×6 escalation —— 【已知、刻意的殘留】,理由只有一個(含它會讓 food 衝到 4.0)
   ⇒ 已立 known_issues,★★★下一刀的正解是【三個管道共用同一個放大函式】,不是「payoff 也乘一個 6」
```

# ★★★誠實限（★我先寫，免得驗收時才補）
```
★那七個 option 【可能仍然 0 勝】,而只要恆等消失、值分布會動,我就判【成功】
   ⇒ ★★因為那代表【秤說話了,只是它們真的比較不重要】
★★★而若它們仍然 0 勝【且】值分布仍然恆等 ⇒ 那才是失敗,回報我,不要調數字
```
