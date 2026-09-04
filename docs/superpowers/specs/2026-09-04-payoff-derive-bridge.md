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
   - `build_*`    ⇒ 由 `_facility_deficit(state, team, facility, otile)` 導出
     ★★★**（訂正 2026-09-04：我原寫「同一次呼叫的值，不重算」—— 錯。`:76`/`:104` 在
     【goal 掛/退階段】，`:139` 在【candidate util 階段】，是同一 tick 的【不同階段】。）**
     ⇒ ★兩條路，**而我要求走 (a)**：
     ```
     (a)★在 :139 重算    —— 多一次呼叫,成本進 §4-5 的 perf 判準
     (b) 掛 goal 時把 desire 存進 goal dict —— ★★便宜,但 goal 跨 tick 存活
        ⇒ payoff 會【凍在掛載當下的值】⇒ ★★★那是【換一個恆等】,正是本 slice 要修的病
     ```
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

## §4b ★前提查證（systems 自查，2026-09-04；★①原文有錯已訂正、②成立、★★③是新發現）
```
①`goal_resolver.gd:76`/`:104` 的 facility 【確實對應 goal】(f 由 BUILD_FACILITY_GOALS[gt] 導出)
   ⇒ ★對應成立;★★但【階段不同】⇒ §2 那句已就地訂正(見上)
②`weapon_melee_low` 【在】TradeValuation.TARGET_PER_POP（= 1.0）
   ⇒ ★_self_use 回 pop × 1.0 ≠ 0 ⇒ ★★maintain_weapons 不會從「恆 1.0」變成「恆 0」——這個洞不存在
★★★③新發現:`material` 在 NeedOracle.PURE_INTERMEDIATE ⇒ _self_use 【回 0】
   ⇒ maintain_material 的 payoff 只由 _supply_chain + _construction_facility_need 組成
   ⇒ ★組成項與其他四個 maintain 【不同】—— 不是 bug,但驗收 3 逐筆貼例時要【避開它當代表】
   ⇒ ★★而它與實測對得上:maintain_material 本來就是唯一不平手的那個(0.8696、落 0.1to0.5、tie=0)
```

## §5 誠實限（★寫在 spec 裡，不等結論時才補）
```
★本 slice 讓秤【說話】,不保證它說得【對】—— 量綱基準仍是人選的
★★而那是 need oracle S2+ 的正題;本 slice 的成功判準是【恆等消失】不是【數值正確】
★★★若驗收 1 過而 2 不動(相異值變多但 tie 沒降),那表示平手來自【別的共用項】
   ⇒ 照原樣報,不歸類,不加補丁
```
