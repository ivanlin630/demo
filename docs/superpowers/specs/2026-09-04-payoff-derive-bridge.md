# HOW spec — payoff 導出（橋接版）

**owner**: systems ｜ **裁定來源**: blueprint「payoff 必須推導，禁手填 13 個新常數」
**尺寸判定**: ★**≤ 一 slice ⇒ 考前做**（理由見 §1，★而它取決於一個【已經在算的值被丟掉】的事實）

## §1 尺寸為什麼是一 slice —— **兩個信號都已存在，其中一個已在同一支檔案裡被算出來**
```
★build_* 那半:`goal_resolver.gd:76` / `:104` 已經呼叫
     fai._facility_deficit(state, team, f, otile)
   而它只被拿去跟 NeedOracle.CONSTRUCTION_DESIRE_MIN 比 ⇒ ★★連續量被壓成布林然後【丟掉】
   ⇒ ★★★所以這不是「接新管線」,是【停止把已經算好的數字扔掉】
★maintain_* 那半:NeedOracle.need_keep(state, team, res) 已存在且是 per-resource
   而 maintain_* 每個 goal 的 prereq 就帶著 res（food/material/tools/weapon_melee_low/coin）
   ⇒ ★呼叫點在 goal_resolver.gd:139（payoff 讀取處）,state/team/ctx 都在手上
```
★**而這正是本 repo 已經修過一次的形狀**（`reaction_system.gd:229` #4 截斷懸崖）：
**把比較搬到【連續量】上，而不是把常數調一調。**

## §2 範圍（★做什麼）
1. `goal_resolver.gd:139` 的 `float(def.get("payoff", 1.0))` 改為導出：
   - `maintain_*` ⇒ 由 `NeedOracle.need_keep(state, team, <prereq.res>)` 導出
   - `build_*`    ⇒ 由既有 `_facility_deficit(state, team, facility, otile)` 導出（**同一次呼叫的值，不重算**）
2. **家族內正規化**（各自除以該家族的量綱基準），★**常數只剩「量綱基準」一個，且必須標明它是量綱不是偏好**
3. **值分布 dump 保留**（`gu2.payoff_val` 相異值計數）——★**這是驗收的主證據**

## §3 ★★★不在範圍（明寫，防止順手做掉）
```
★①tie-break 仍是 registry 插入序 —— blueprint 已裁【單獨不採】(它讓 0 變隨機,沒讓秤說話)
   ⇒ 本 slice 不碰它;若導出後仍有真平手,那是【真平手】,留著給下一格
★②跨家族可比性(maintain vs build 的量綱是否可直接比)【本 slice 不解】
   ⇒ 理由:need_keep 是資源量級(CONSTRUCTION_MATERIAL_NEED_CAP=100),_facility_deficit 是慾望量級(門檻 0.3)
   ⇒ ★★兩者【部分同根】(A 類 evaluator 走 NeedOracle-gap),但 C 類專屬 evaluator 與 B 類 gating 不同源
   ⇒ ★★★所以「跨家族數字可比」是【未證的】—— 本 slice 明標未解,歸 need oracle S2+
★③禁 crank:目標【不是】讓那七個 option 開始贏
   ⇒ 若導出後它們仍然不贏而【值分布不再恆等】,那是【秤說話了】= 成功
```

## §4 驗收（★機械可判，★★不含「輸家要變贏家」）
| # | 判準 | 為什麼 |
|---|---|---|
| 1 | `gu2.payoff_val` 相異值 **> 2**，並附完整值分布 | ★現況 87.8% 只有兩個值；**這是主證據** |
| 2 | `tie_exact` 逐 option **下降**（★不要求歸零） | 真平手可以存在 |
| 3 | ★**同隊同 tick 的 `maintain_*` 五個不再逐位元相同**（逐筆貼一例） | 聚合看不出逐位元相同 |
| 4 | determinism：**同 seed 三跑一致** | ★`fp` 會變（行為真的改了）⇒ **不要求逐位元不變**，改要求可重現 |
| 5 | ★**perf**：印 `need_keep` 每決策呼叫次數 ＋ 該段 wall-clock | 遞迴守衛在，**但頻率變了** |
| 6 | 陰性對照：**導出後仍印值分布** | 防「改完就不看了」 |
| 7 | ★★**憲法閘 PASS** | 導出式不得寫成新門檻 |

## §5 誠實限（★寫在 spec 裡，不等結論時才補）
```
★本 slice 讓秤【說話】,不保證它說得【對】—— 量綱基準仍是人選的
★★而那是 need oracle S2+ 的正題;本 slice 的成功判準是【恆等消失】不是【數值正確】
★★★若驗收 1 過而 2 不動(相異值變多但 tie 沒降),那表示平手來自【別的共用項】
   ⇒ 照原樣報,不歸類,不加補丁
```
