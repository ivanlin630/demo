---
from: blueprint
to: systems
status: consumed
topic: [S-A 設計更新] join+整併 收成一個「併入」決策——好感/凝聚分流+忠誠初始化;疊既有S-A code非重起
---

# systems 工單：consolidation S-A 統一「併入」設計更新

用戶定案（2026-07-11）。design doc 已更新 + committed（`docs/superpowers/specs/2026-07-10-consolidation-unified-decision-design.md` §★★統一「併入」收斂）。**取代 join/整併 兩 option 框**。

## 核心變更
實測揭 join/整併 **冗餘**（都走 `merge_teams` 全併、搶同絕境 niche → join 常勝 → 整併 marginal 2.5%）。**收成一個「併入」決策**（消兩求解器＝真統一，非框架內補丁）：
```
併入(host) = joiner 想併(survival rank) AND host 願收(統領容量+意願)
結果分流(resolve 時算)：
  人少+好感高+低凝聚  → dissolve 散進去(舊 join,滅團)
  人多 or 好感低 or 高凝聚 → 整隊變子隊(附庸,保身份)
```

## 參數（用戶挑，file:line 坐實）
- 好感(joiner→host) = `team.known_reputations[host]`(team_data:187) ± `relation_edges`(person_data:63 feud/killed/gratitude/protect=記憶恩怨)
- 凝聚 = `loyalty`(person_data:14，對原隊；低→易散 dissolve、高→整團傾子隊)
- host 容量/意願 = `統領` skill(pop_cap 已用) + host rank 秤願不願收

## 併入時 set 新人起始忠誠（補語意漏洞）
- 漏洞：`merge_teams` 換 team_id 但**不動 loyalty** → 新人原封保留「對舊領袖」忠誠當成對新 host。
- 修：set 新人對 host 起始忠誠 = f(好感, 情境 voluntary/coerced, 義氣)。**脅迫/低好感→低→心不甘子隊→S-B 叛離燃料**。

## ★留用 vs 新加（疊既有 S-A code，非重起）
| 留用（已建照吃） | 新加/改 |
|---|---|
| consolidate_drive 食壓化、churn cadence、`:214` 到達修、C2 survival-class、order_target/movement 到達修、`merge_teams` 容量→dissolve/子隊(已有!) | ①join+整併 合成一個「併入」option ②結果補「好感/凝聚」分流軸(疊既有容量軸) ③併入時 set 新人起始忠誠 |

**併決策統一之前的 S-A 修(churn/seam/priority/reachability)全部 carry forward**——它們修的是真 bug，統一併入照樣需要。不重起。

## 地板守則（不變）
- 收進 rank_scored 真 term，禁 flat/補償閘。gate#1 非搬餓(併進真 surplus host)。防 mega-blob(隊數不崩)。
- 「外來隊變子隊」非矛盾(用戶點)：併入即成 host 子隊(掛 parent、繼承 host faction)，忠不忠=S-B 戲。**輕量 characterize**：merge→建子隊路對「非自己分出的隊」faction 繼承/parent 設定跑得順否(非 blocker)。

## 流程（R② 必過）
- 你出更新版 S-A 技術 spec（併入 option 合一 + 分流公式 + 忠誠 set 公式，TEST VALUE）。
- **spec-lock/build 前 to:reviewer R②**（每 slice 必過，02_reviewer）——此為顯著設計變更，審設計健全。R①免（前提全 file:line 坐實，無未驗斷言）。
- spec→implementer→measurer(gate#1 非搬餓 + 湧現 + 隊數不崩 + 忠誠初始化生效 + 三 gate)→ 數字 to:blueprint。
- 忠誠 set 公式我給大方向(脅迫低/自願高)，TEST VALUE 你定，measurer 之後量叛離頻率再調。

繼續。
