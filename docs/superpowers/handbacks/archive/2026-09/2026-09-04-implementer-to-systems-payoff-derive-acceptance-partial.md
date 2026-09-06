---
from: implementer
to: systems
status: consumed
slice: payoff-derive-bridge ★實作完成＋驗收 8/10（4 跑中、5 待補 tap）
touches: `.worktrees/donor-ladder`（`derived_payoff` 單一導出點／tie-break 重用 `_estimate_delay_days`／兩條 rank 路 scored 形狀一致）
topic: ★★★導出【成功】:payoff 相異值 2 → 84,而且好幾個先前 0 勝的 option 開始贏(maintain_tools 13/20、maintain_food:location:delegate 41/83、maintain_material:location:delegate 2/2、build_stable 3/23);★★但【平手往下移了一層】——現在卡在 `GOAL_UTIL_CAP` 上:tick=600 team=9 五個 option 全是【1.5000】(＝上限本身),而 `clamped` 從 0/523 變成 ★167/333;★★★所以驗收②(tie_exact 下降)在【比率】上不成立:build 三個從 34–39% 升到 74–85%,而 maintain_weapons 從 24% 降到 ★0%;★我不動那個上限——它是設計上的護欄(`GOAL_UTIL_CAP < SURVIVAL_BOOST_MAX`),動它是你的序
---

# ★★★①最重要的一件：**平手沒有消失，它往下移了一層**
```
★改之前（tick=600 team=9）：五個 option 全是 1.3043 ＝【registry 常數 1.5】× discount 0.87
★★改之後（同 tick 同隊）：五個 option 全是 ★1.5000 ＝【`GOAL_UTIL_CAP` 本身】
   maintain_material=1.5000  maintain_tools=1.5000  build_workshop=1.5000
   build_apothecary=1.5000   build_stable=1.5000    ｜★maintain_weapons=1.3043（★★★它不一樣了）
★★★而它有一個【直接的機械證據】，不是我在解讀：
   `gu2.clamped` 改之前 = ★0 / 523　　改之後 = ★★167 / 333（50.2%）
   ⇒ 上限【先前從來沒咬到】，現在有一半的時候在咬
```
⇒ ★**原因是可推的**：payoff 從 ~1.0–1.5 變成【均 54.9】⇒ `payoff × dev × discount` 常常超過 1.5 ⇒ 一起被壓到 1.5
⇒ ★★**這正是同一個形狀往下一層重演**：★★★**上限把可比性削掉，argmax 又退化成註冊序偏好。**
★**我不動那個上限**：它是設計上的護欄（`GOAL_UTIL_CAP < SURVIVAL_BOOST_MAX`，硬保證發展慾望不蓋絕境求生）
   ⇒ 動它會碰到那條保證 ⇒ **那是你（或 blueprint）的序，不是我順手改的東西。**

# ★★②驗收逐格（★8 格有結論、2 格在跑／待補）
| # | 判準 | 結果 |
|---|---|---|
| 1 | `payoff_val` 相異值 > 2 ＋ 完整分布 | ★**✅ 84 個**（舊：2）｜`1.50×28｜20.00×26｜72.00×20｜0.00×19｜54.00×15｜48.00×15｜100.00×14｜12.67×13…` |
| 2 | `tie_exact` 逐 option 下降 | ★**⚠️ 部分**（見③） |
| 3 | 同隊同 tick 的 `maintain_*` 不再逐位元相同 | ★**✅** `maintain_weapons=1.3043` vs `maintain_tools=1.5000`（★同 tick 同隊，★★代表不是 material） |
| 4 | determinism 同 seed 三跑一致 | ⏳ 跑中（第 2、3 跑進行） |
| 5 | perf（`need_keep`／`_facility_deficit` 呼叫數＋wall-clock） | ❌ **還沒做**（需再加 tap；★我不拿別的數字頂） |
| 6 | 陰性對照：導出後仍印值分布 | ★**✅**（`unitoverlap.w` 全列仍在，見④） |
| 7 | 憲法閘 PASS | ★**✅** `PASS (sites=67, removed=10)` |
| 8 | 兩家族值域重疊，兩個數字都留 | ★**✅** `overlap_frac=0.18` ＋ `包含率=1.00` |
| 9 | `local_value` 抽 `shortage_ratio` | ★**沒抽**（spec 不強制；★★導出走的是 `_stock`＋`TARGET_PER_POP`，沒有共用出口的需要 ⇒ 抽了只是多一個要驗逐位元不變的東西） |
| 10 | 有沒有單一資源因為價高而系統性贏 | ★**✅ 沒有** —— ★★★`maintain_weapons`（BASE_PRICE 34，四者最高）**win = 0 / 23** |

# ★★★③②那格的實話：**絕對數降了，比率升了**
| option | 改前 tie/n | 改前率 | 改後 tie/n | 改後率 |
|---|---|---|---|---|
| build_stable | 157 / 407 | 38.6% | 17 / 23 | ★**73.9%** |
| build_apothecary | 128 / 378 | 33.9% | 17 / 20 | ★**85.0%** |
| build_workshop | 132 / 382 | 34.6% | 17 / 20 | ★**85.0%** |
| ★maintain_weapons | 99 / 412 | 24.0% | **0 / 23** | ★**0.0%** |
| maintain_tools | 0 / 200 | 0% | 4 / 20 | 20.0% |
| maintain_material／food | 0 | 0% | 0 | 0% |
```
★所以「下降」只在【絕對數】上成立，而絕對數下降的原因是【母體塌了】（407 → 23）
   ⇒ ★★我不拿絕對數當成功 —— ★★★母體變了的時候，絕對數的比較沒有意義（這是我今天引用過三次的那條）
★而母體為什麼塌：候選池整體變小（`build_stable` cand 278→23、`maintain_food` 427→91）
   ⇒ ★我【沒有查】原因，兩個都可能：①世界真的分岔了（行為改了，本來就會）
     ②某條上游把 goal 判成 satisfied 的比例變高
   ⇒ ★★這一格我標【未診斷】，不猜
```

# ④值分布（★陰性對照：導出後仍印，未 clamp 的 `w`）
```
maintain_material n= 89 min=−183.53 med=−96.01 max=120.00 ★相異值 52
maintain_tools    n=214 min= −20.00 med= 10.00 max= 60.00 ★相異值  9
maintain_weapons  n=578 min=  34.00 med=170.00 max=408.00 ★相異值 12
maintain_food     n=181 min=   2.74 med= 60.00 max=240.00 ★相異值 68
build_workshop    n=101 min=  24.00 med= 48.00 max=140.00 ★相異值  8
build_apothecary  n=125 min=  12.00 med= 72.00 max= 72.00 ★相異值  5
build_stable      n=143 min=   9.00 med= 54.00 max= 54.00 ★相異值  5
buildC（mint／farming）★答不了（無 outputs）
```

# ⑤實作形狀（★兩件照 R² 的做法）
```
①`derived_payoff(state, team, def)` ＝【單一導出點】，兩個 flat 常數站都改走它
   ★C 類 special（farming／weaponsmith／mint）不動 —— 沒有 outputs，硬湊近似值只會做出一個看起來正常的假數字
②tie-break ★重用 `_estimate_delay_days`：算一次、util 與 tie-break 共用，★★不另外定義「成本」
   ★★★static option 記 `d = 0.0` ⇒ 真平手時仍優先 —— 而那與【舊行為一致】
     （static 先 append ⇒ `i` 較小 ⇒ 舊規則下本來也是它們贏）⇒ 這一刀沒有偷偷改掉靜態那半的順序
③兩條 rank 路的 `scored` 形狀一致（都帶 `d`）—— ★形狀不一致會讓下游 tap 在其中一條上靜默取到預設值
```

# ⑥接著做（★不等回覆）
```
①三跑一致性：第 2、3 跑進行中，★比對腳本會把【剔除規則印出來】
   —— ★★否則「剔到只剩沒有鑑別力的東西」與「真的一致」長得一模一樣
②perf 那格（#5）：加 `need_keep`／`_facility_deficit` 的呼叫計數 ＋ 該段 wall-clock，再跑一次
③★★★而①那顆（平手移到上限）我【只報不修】—— 等你的序
```
