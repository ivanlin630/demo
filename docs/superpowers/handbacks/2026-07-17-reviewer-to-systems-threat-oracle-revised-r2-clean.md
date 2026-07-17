---
from: reviewer
to: systems
status: consumed
topic: "[R② verdict·異質(Sonnet)] threat-oracle REVISED：CLEAN，6 findings 逐項核實真解（含 blueprint 補裁文字對照+terms.gd:75-80 file:line 驗+options.gd REGISTRY 多term結構驗+lerp公式手算驗）。2 個非阻斷、S2 完工前須具體化的 measure 要求（boost cap 驗收場景、fall-through 第5象限檢查）。CLEAN→可 dispatch S1.5→S2。"
---

# R② 判決：threat-oracle REVISED — CLEAN（異質視角，Sonnet 獨立驗證）

## 6 findings 逐項核實「真解否」

1. **god-view leak（S1.5 fix）**：spec §S1.5(a) 修法「無belief→保守 self_team.population（視等強），比照 invariants.md:173 已補5處法，禁讀 other.population」——**修法方向正確**，直接對症下藥（fallback 從讀真值改讀自身值，非猜測敵值），且明文要求「連 invariants.md:173 補入已修名單」，程序完整（不會變成又一個未登記的例外）。✓ 真解。

2. **power_ratio 未曝為 ctx（skeptic 命中）**：spec §S1.5(b) 「ctx 曝 perceived_power_ratio（clean，供 winnable 用；禁 implementer 拿 threat_react 當 winnable proxy）」——修法點出了正確的風險點（threat_react 是 approach+hostility+power 三者混合的 blend 值，若誤當 winnable 用會把「敵人正在逼近」跟「敵人比我強」兩件事搞混），且明確禁止這個誤用路徑。✓ 真解。

3. **★單term vs多term結構不匹配（skeptic「最深洞」）**：逐 code 驗證結構性論證成立。`options.gd` REGISTRY 確認：「掠奪」=`[[loot_drive,loot],[intent_fit,intent_fit]]`（2 term 相加）、「攻擊」=`[[faction_duty,faction_duty],[attack_drive,attack],[intent_fit,intent_fit],[feud_pull,feud]]`（4 term 相加）；反觀「備戰」`[[prepare_drive,prepare]]`/「迎戰」`[[defend_drive,defend]]`/「求和」`[[pacify_drive,pacify]]`**各僅單一 term**。`terms.gd:240` `weight("attack")=0.2+好戰+殘忍*0.3`（單項理論上限1.5）、`:249-250` `weight("loot")=殘忍*0.5+好戰*0.3+貪婪*0.2`——多個正權重項相加，結構上「N term 加總」天生比「1 term × 任意係數」有更高的量級天花板（除非 boost 補償）。**這個結構性論證不依賴精確數值（「~2.0」「>3.0」是說明性非精確引用），本身站得住**——spec 提的「break-top boost（capped，鏡射 survival:37）」補救方向正確。✓ 真解（設計層面）。

4. **高好戰-不可勝 fall-through（blueprint①裁定）**：對照 `2026-07-17-blueprint-to-systems-threat-oracle-fallthrough-ruling.md:12-17` 原文——spec 的 `modulate_win=lerp(winnable,1.0,1−慎重)` 逐字對應 blueprint「謹慎的鷹→不打不可勝之戰」「魯莽驕傲的鷹→照打=死戰last-stand」「零leader fall-through」三句話，非 systems 自己編的近似。✓ 真解，且忠實度高（非改寫走樣）。

5. **FLEE=threat_pressure 漏（skeptic「TOP RISK」）**：逐 code 驗 `terms.gd:75-80`：
   ```
   "threat_pressure":
       if ctx.threat <= 0.0: return 0.0
       return clampf(ctx.threat + ctx.team_panic * 0.4, 0.0, 1.0)
   ```
   確認此 term 存在、確實驅動 FLEE（經 `terms.gd` 前段 survival_pressure/threat_pressure 掛 `"survival"` option，即 rank_scored 的 FLEE 選項），且**不在** spec v1 §前提原 GAP 清單（`:176/180/184`）內——skeptic 抓到的真缺口成立。REVISED §S2 交付切片明文「terms.gd 備戰/迎戰/求和/FLEE(**含:75-80 threat_pressure，finding5**)」已納入範圍。✓ 真解。

6. **severity 上界未定（reviewer 自己 v1 命中）**：blueprint② 補裁（`fallthrough-ruling.md:19-23`）明講「uncapped amplifier=偽裝的硬閘…cap=零殘留閘目標的必須」，spec 據此定 `severity=clampf(ctx.threat_react,0.0,SEVERITY_MAX)`，SEVERITY_MAX 留 measure 校——**方向鎖死（cap 是必須，非可選），數值留 tuning 屬本專案慣例**（同 `SURVIVAL_BOOST_MAX`/`COMMITMENT_BONUS` 等既有 TEST VALUE 模式），不是敷衍留白。✓ 真解。

## ★重點攻（本輪新設計，逐項回覆）

**① break-top boost 會不會是偽裝硬閘？** 部分過關，**1 個 measure 要求須具體化**。設計本身（capped、severity-gated on floor、鏡射 survival:37 的加法破頂模式）方向正確，且 spec 明文與 blueprint②「極佳機會仍可 edge 過」對齊。**但** cap 的實際數值決定它「像不像」硬閘——這是純數值問題，spec 正確地留給 measure（同 SEVERITY_MAX 待遇），**唯 S2 measure 清單目前只寫「severity capped（threat 不無限碾 trade）」太籠統**，無法真的驗證「極佳機會仍可 edge 過」這句話。**要求**：S2 measure 具體加一個場景——「中等 severity + 一個決定性有利的非-threat 機會（如高值貿易/建國臨門一腳）」下，非-threat 選項是否**偶爾**仍能勝出（非「threat 恆勝」）。這是可操作驗收條件，非純方向宣示。

與 survival break-top 的差異（審問也問了）：survival=「存亡必須」（絕境不活=團滅，機制上「幾乎必勝」是設計本意，`SURVIVAL_BOOST_MAX=2.5` 本就寫著「突破天花板奪回argmax」）；threat=blueprint 明講「不必然」（威脅不是每次都該贏）。兩者的 boost 上界哲學本就該不同（threat boost 該遠小於 survival boost 的相對強度），spec 沒有明講這個「threat boost < survival boost」的相對約束——建議 S2 spec 補一句定性要求（不必給數字），把這差異釘進設計文件，非只靠 measure 事後抓。

**② 零 fall-through 四象限真都涵蓋否？** 部分過關，**1 個 measure 要求須補**。逐象限核對 spec §目標式與 blueprint 裁定文字，四個列出的象限（proud-doomed/cautious-hawk/coward/weak-pragmatic）確實各自有主導 response，映射正確。**但**：四個公式（prepare/confront/pacify/FLEE）共涉 5 個人格軸（慎重/好戰/貪婪/信義/求生欲）。若某 leader 同時在**所有**相關軸都趨近極端低值（慎重≈0 且好戰≈0 且貪婪≈0 且信義≈0 且求生欲≈0——理論上第5種、spec 未列的退化象限），四式全趨零，會落穿回 v1 的老問題（只是觸發條件更極端）。這在真實 generator 分佈下有多大機率出現未驗證（spec 沒引 generator 的人格值 floor 佐證此組合不可達，不同於本 session 稍早在別的審查看過「archetype 無低慎重列」這類已驗證的架構性不可達證明）。**要求**：S2 measure 補一項「極端全低人格向量」壓力測試（或引 person_generator.gd 的人格 floor 佐證此象限架構性不可達），非只驗 spec 列的 4 個代表性角。

**③ winnable modulate `lerp(winnable,1.0,1−慎重)` 對否？** 手算驗證通過。GDScript `lerp(from,to,w)=from+(to-from)*w`：
- 慎重=1 → w=1-1=0 → 結果=winnable（原值，respect）✓ 對應 blueprint「謹慎→respect winnable」。
- 慎重=0 → w=1-0=1 → 結果=1.0（全 override）✓ 對應 blueprint「魯莽→override 照打」。
- 慎重=0.5（中間） → w=0.5 → 結果=0.5+0.5·winnable（介於原值與全override之間的線性漸變）——合理平滑，無 kink/不連續。
數學對映 blueprint 意圖無誤，中間值行為合理。✓ 通過。

**④ S1.5 self_pop fallback 洩否？** 通過。推導：`self_armed_ratio=self_armed/self_pop`；fallback `perceived_power=self_pop*0.3`（沿用既有無 intel 時的 flat combat-skill baseline，非本次新增）；`self_power=self_pop*combat_skill_self`。若 winnable 走比值型組合，`self_pop` 在 self_power/perceived_power 的比例中會相消——**fallback 下 winnable 實質只剩「自身戰力係數 vs 0.3 基準」的比較，population 完全不進入計算**，不构成洩漏，也不會系統性高估/低估自身勝算（純粹「假設對手是平均水準」的中性起始假設）。✓ 通過，systems 自己的疑慮可放心。

## 判準結果
**CLEAN → 可 dispatch S1.5 → S2**。6 findings 皆真解（非文字包裝），4 個重點攻擊點：③④ 完全通過、①② 方向正確但各有 1 個「measure 驗收條件須從籠統宣示具體化為可操作場景」的要求（非設計缺陷，是驗收顆粒度問題）：
1. S2 measure 補「中等severity+決定性非-threat機會→非-threat選項偶爾仍勝」具體場景（驗①「非偽裝硬閘」）。
2. S2 measure 補「極端全低人格向量」壓力測試或 generator floor 佐證（驗②「真零fall-through非只4代表角」）。

兩項不擋 S1.5/S2 開工（皆是「S2 完工驗收前」要求，非「開工前」要求），implementer 落地時一併排進 measure 清單即可，不必重送 R②。

## 溯源
Spec `docs/superpowers/specs/2026-07-17-threat-oracle-severity-convergence.md`（REVISED 全文）；systems handback `2026-07-17-R2-systems-to-reviewer-threat-oracle-revised.md`；blueprint `2026-07-17-blueprint-to-systems-threat-oracle-fallthrough-ruling.md`；`terms.gd:75-80/133-135/240/245-251`；`options.gd` REGISTRY（掠奪/攻擊/備戰/迎戰/求和 entries）；decision_engine.gd:35-39（survival boost 對照）；先前本 reviewer threat-oracle v1 HALT 判決。
