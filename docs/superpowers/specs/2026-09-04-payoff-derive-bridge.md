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
2. ★★★**（訂正 2026-09-04，R② 判「跨家族量綱是阻塞依賴」後改設計）不做「家族內正規化」——改成【兩家族同單位】**
```
★查證:_facility_deficit 註解自書「缺口(自身庫存 threshold,★0–1)」(faction_ai_system.gd:5659)
       而 need_keep 是【絕對量】(pop × TARGET_PER_POP…,cap 100)
   ⇒ ★★量綱【系統性分離】—— 家族內正規化會留下一個人選的比例常數,而 R² 說得對:
      驗收①(相異值>2)【抓不到】「兩塊各自有變化但整體仍分成兩塊」這個失敗模式
★★★改法:maintain_* 改用【既有的 0–1 shortage】而不是 need_keep 絕對量
   `trade_valuation.gd:158-159`  target = pop × TARGET_PER_POP[res]
                                  shortage = (target - stock) / max(target, 1.0)   # ≤ 1.0
   ⇒ ★它已經存在,只是被寫在 local_value 內部、沒有獨立出口
   ⇒ ★★抽成 shortage_ratio(state, team, res)（★純重構,local_value 行為必須逐位元不變）
   ⇒ ★★★用【escalation 之前】那個值(SURVIVAL_GOODS 的 ×6 升壓會讓 food 衝到 4.0=又一個分離源)
⇒ ★於是【兩家族同單位 0–1 by construction】,而【正規化常數整個消失】—— 更合 blueprint「禁手填常數」
```
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
| ★8 | **兩家族值域【重疊】**：並排印 maintain_*／build_* 的 min／p25／中位／p75／max ＋ 重疊率 | ★★★R② 指出的失敗模式：**兩塊各自有變化、整體仍分成兩塊** ⇒ 驗收①抓不到 |
| ★9 | `local_value` 抽 `shortage_ratio` 後**逐位元不變**（純重構） | 抽出動作本身不得改行為 |

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

## §4c ★★★【已知、刻意的殘留】：`SURVIVAL_GOODS` 的 ×6 escalation **不進 payoff**（R② 二輪要求明寫）
```
★事實:trade_valuation.gd:160-161  if res in SURVIVAL_GOODS and shortage > 0.5:
                                      shortage = 1.0 + (shortage - 0.5) * 6.0
   ⇒ 本 slice 用【escalation 之前】那個值 ⇒ food 的緊急放大【不進 payoff 管道】
★★R² 查證:「飢餓該有放大待遇」在本 codebase 是 established 且用戶認可的原則
   —— 兩處實作:SURVIVAL_CRUSH(facility_score) / famine_escalation(_self_use)
⇒ ★★★所以排除它會製造一個【同一種飢餓,不同管道給不同緊急度】的不一致
★而本輪仍然排除,理由【只有一個】:含 escalation 會讓 food 衝到 4.0 ⇒ 立刻重開跨家族量綱問題
⇒ ★★這是【刻意的殘留】不是【遺漏】,已記 known_issues 供下一刀決定要不要接進來
```

## §5 誠實限（★寫在 spec 裡，不等結論時才補）
```
★本 slice 讓秤【說話】,不保證它說得【對】—— 量綱基準仍是人選的
★★而那是 need oracle S2+ 的正題;本 slice 的成功判準是【恆等消失】不是【數值正確】
★★★若驗收 1 過而 2 不動(相異值變多但 tie 沒降),那表示平手來自【別的共用項】
   ⇒ 照原樣報,不歸類,不加補丁
```


## §6 ★★★【前置量測回來了】設計【擋下】—— 量綱過關，但**導出值是常數不是分布**（2026-09-04）
```
★量綱那格 PASS:包含率 = 1.00(build 的整個值域【完全被 maintain 包住】)⇒ 不是分離
   ★★而 implementer 自己定義的 overlap_frac = 0.05 【會誤導】:maintain 的 shortage 可以是負的
      (有餘,最低 −9.98),build 的 deficit 被 clamp 在 0 以上 ⇒ 聯集被長尾拉開
   ⇒ ★他把【兩個數字都留在輸出裡】—— 只留包含率會讓下一個人看不到那條長尾
★★★而真正擋下設計的是這個:
   maintain_weapons  573 筆【全部 1.0000】
   build_workshop    128 筆【全部 1.0】｜build_stable 179 筆【全部 1.0】
   build_apothecary  151 筆【全部 0.5】(★恰好等於它的 output_scale)
⇒ ★換上去之後 build_workshop 與 build_stable 【仍然同時是 1.0】⇒ 仍然逐位元相等
⇒ ★★★所以這一刀【解的不是 tie】—— 同單位仍是對的方向,但它不滿足本 slice 的成功判準(恆等消失)
```

### ★★★§6.1 systems 診斷：**這是【結構性飽和】，不是量測 bug**
```
shortage = (target − stock) / target  ⇒ ★stock = 0 時【恆為 1.0】,而「不能比 100% 更缺」
⇒ ★★所以在一個【什麼都缺】的世界裡,任何【比例型】缺口量都會釘在 1.0
   maintain_weapons 恆 1.0 = 這些隊【從來沒有武器】(世界事實,不是儀器問題)
   build_* 恆 = output_scale × 滿 gap  = 同一個飽和,只是乘了不同的 scale
⇒ ★★★推論:payoff 需要一個【不會飽和】的維度 —— 比例量做不到
```
★**而這回頭解釋了為什麼 `need_keep`（絕對量）本來是對的直覺**：**它不飽和。**
★★**被換掉的理由是量綱，而不是鑑別力** —— **兩者要分開記，否則下一個人會以為絕對量已經被否決。**

### §6.2 ★候選（★未驗，交 R² 判其中一個是不是又一顆手抄常數）
```
★payoff ∝ 【缺口的價值】= (target − stock) × BASE_PRICE[res]
   ⇒ ★不飽和(缺 10 單位與缺 100 單位不同)、跨資源同單位(價值)、兩個因子都是既有的
   ⇒ ★★build_* 那半:A 類 evaluator 本來就讀 outputs 的 need ⇒ 同式子可套
★★★而我自己標的疑點:BASE_PRICE 當【單位換算器】是合法的嗎,還是又一顆手抄物理?
   ⇒ 交 R² 判 —— 我不自己放行
★不用 local_value:它內部【已經含 shortage】⇒ 乘上去會把缺口算兩次
```


## §7 ★★★【定案形狀】(2026-09-04，預測成立 ⇒ 設計復活)
```
★payoff = w = (target − stock) × BASE_PRICE[res]      ←【缺口的價值】,兩家族同式
   maintain_*:res = prereq 的 res
   build_*   :A 類 evaluator 已讀 outputs 的 need ⇒ 同式套 outputs
★★實測(30 日/regime/seed 1337)已證它【會變】:
   maintain_weapons  v 573 筆全 1.0000(釘死) ／ ★w 相異值 12、range 34–408
   build_workshop w∈[16,140]｜build_stable w∈[9,54]｜build_apothecary w∈[12,72]
   ⇒ ★★★三個值域【各不相同】⇒ 換上 w 會【拆掉那組 exact-tie】
★而這是一個【預先登記的預測】成立:我在數據回來之前寫下「它會隨 pop 變」
```

### §7.1 負值語意（★必須明寫，否則會被順手 clamp 掉）
```
★w < 0 ＝【有餘】(stock > target) ⇒ 該 goal 不該贏
⇒ ★★做法:payoff 取 maxf(w, 0.0) —— ★★★而【底部平手無害】:一堆 0 互相平手,它們都不會贏
   (與頂部飽和不同:頂部平手會決定誰贏,底部平手不會)
⇒ ★但【值分布 dump 要印未 clamp 的 w】,否則「有餘多少」整段不可見
```

### §7.2 tie-break（★blueprint 裁：與「單獨不採」不矛盾）
```
★單獨採 tie-break = 掩蓋啞秤(秤沒說話,卻用排序決定)⇒ 不採
★★配上推導後 = 秤【說了平手】之後的合法裁決 ⇒ 採
⇒ ★★★規則:真值相等時,選【成本低者】(決定性,不用隨機)
   —— 同「修秤(i)」先例:先讓秤說話,再讓規則裁平手
```

### §7.3 ★★★儀器紀律（implementer 自揭的缺陷，寫進 spec 免得重犯）
```
★第一版用 `-1` 當「答不了」的哨兵,而 w 【本來就能是負的】(有餘)
⇒ ★★床端過濾把【有餘的那些筆】一起丟掉:maintain_material 的 w 母體只剩 20/114
⇒ ★★★低端整段消失,而輸出【看起來完全正常】
★通則:哨兵值必須落在【該量不可能取到的值域】裡 —— 量可為負時,-1 不是哨兵
   ⇒ 用【獨立的旗標欄】而不是魔術值
```


## §7.4 ★★★新證據直接影響 §7.1 的 `maxf(w,0)`（2026-09-04 訂正後數據）
```
★maintain_material 修正後 med = −84.01 ⇒ 【多數時候是有餘,不是缺】
⇒ ★★套 maxf(w,0) 之後,它在多數 tick 上的 payoff = 0 ⇒ 幾乎不會贏
⇒ ★★★而這與先前的實測【互相印證】:maintain_material 本來就是唯一【不平手】的那個
   (0.8696、落 0.1to0.5 桶、tie_exact = 0)—— 因為它是唯一【不缺】的那個
★所以「它幾乎不會贏」不是 bug,是【genuine:它真的不缺】
★★但這使 maxf 那一刀的影響【比我原本估的大】(一個 goal 多數時候歸零),已補送 R²
```
