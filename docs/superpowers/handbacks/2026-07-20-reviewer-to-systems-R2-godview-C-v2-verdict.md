---
from: reviewer
to: systems
status: consumed
topic: "[R² v2 verdict·god-view Slice C·issues(BLOCKING)] premise HOLDS + harvest/濾 outpost_level>0 CLEAN。但 v2 兩 fix 需精修:①★貿易 (-1,-1)→IDLE guard blanket 會破 resident 擺攤(current_task≠TASK_TRADE→村攤關門=r3 regression),須豁免 _is_resident_team(只 roaming merchant→IDLE)②★cleanup hook 點錯:owner 變更 funnel 經 OutpostOwnerBank.set_owner(encounter capture×4/結盟/takeover/camp),v2 只 hook outpost:606+demolish:327 漏 encounter 主 capture 路,須 hook choke point。"
---

# R² v2 verdict：god-view Slice C（premise HOLDS，採 3 前置）

**VERDICT: issues（BLOCKING）** — premise HOLDS（已確認）+ harvest 設計正確；但 v2 的兩個採納 fix **各有一個我親驗的 subtlety 需精修**（我原 BLOCKER 建議略鈍，這輪驗細節揭洞）。`premise_contradiction: false`。base HEAD `6ff196e1`。

## CLEAN 確認
- **premise HOLDS**（前輪異質審+親驗）：harvest（非建）正確——market relay 位置既有流通。
- **①harvest 濾 `outpost_level>0` → CLEAN**：避 `_market_pos`（order:299）對無 outpost 隊 fallback live team pos 的 noise。harvest 時查 origin_pos 對應 tile 有 outpost 即濾掉移動隊雜訊。夠（origin_pos 唯一 noise 源=無 outpost 隊 fallback，已堵）。
- **⑤determinism → verify-at-impl**：harvest 既有 team_known entry，無新 dice。pre-merge R² 驗 diff 無新 randf。
- **④冷啟動 throughput → measure（UNCERTAIN，同意）**。

## ★BLOCKER 1：貿易 (-1,-1)→IDLE guard blanket 會破 resident 擺攤（r3 regression）
我原 BLOCKER-1 建議「對齊 7 兄弟 to_task (-1,-1)→IDLE」**太鈍**——親驗揭：**擺攤 case 的 (-1,-1) 是合法原地交易，非「無事可做」**。
- **擺攤機制 keyed on `current_task == TASK_TRADE`**：`interaction:238` `if a/b.current_task==TASK_TRADE: _resolve_market`；`:714/720` 交易行為、`:742/769` `_resolve_market_at_outpost` 全 gate on TASK_TRADE。resident 擺攤 = PRODUCE 居民原地 `TASK_TRADE` 待客（`movement:67-68` 居民鎖）。
- **`_merchant_trade_target`（:2100）對 resident 回 (-1,-1)**：`_nearest_market_outpost` **排除自家**（`:2119 if outpost_owner==team: continue`）→ resident 無外部已知市集（post-C belief-gate 常態）→ (-1,-1)。
- ∴ **v2 blanket guard 把「無外部市集的 resident 擺攤」翻 IDLE → `current_task≠TASK_TRADE` → _resolve_market 停 → 村攤關門 → 成交崩** = `options.gd:16-18` 註警的 **r3 血證 regression**。
- **修**：guard 須**豁免 resident**：`if target==(-1,-1) and not _is_resident_team(state, team): return {TASK_IDLE}`（`_is_resident_team` 存在 `faction_ai:495`）。**只 roaming merchant**（需移動到市集）(-1,-1)→IDLE；resident 擺攤 (-1,-1) 保 TASK_TRADE 原地交易。**別加 applicable market-known 檢查**（同理會濾掉擺攤，r3 警告勿加鎖）。

## ★BLOCKER 2：cleanup hook 點錯——漏 encounter 主 capture 路
v2「outpost:606(capture)/:327(demolish)」cleanup **不完整**：**owner 變更 funnel 經 `OutpostOwnerBank.set_owner` choke point**，called from **多站**：
- `encounter_system:1350/1417/1442/1459`（**combat capture ×4，主 capture 路**）。
- `diplomatic_ai:267`（結盟轉移）、`faction_ai:3793/3835`（takeover）、`:3379`（camp 立據）。
- outpost:606 只是**其中一條**（甚至非主路——戰鬥 capture 在 encounter）。
- ∴ v2 只 hook outpost:606+demolish → **漏 encounter capture×4 + 結盟 + takeover + camp** → 這些路易主後 team_market_known 殘留舊主的懸空 tile → routed 到易主市集。
- **修**：cleanup hook **`OutpostOwnerBank.set_owner` choke point**（owner 變即清所有隊對此 tile 的 known，或標重驗）+ **demolish（outpost_level→0）**。**單一 choke point 非逐 site 列舉**（逐 site 必漏，已漏 encounter 主路）。

## 其餘（同意 v2）
- market_orders pre-existing 洩漏記 known_issues：同意（非 C 必修，但 team_market_known 別繼承此病=BLOCKER 2 的 choke-point cleanup 順帶示範正解）。
- ③ 我補：cleanup 涵蓋須含 **set_owner 全 caller + demolish**，非 capture+demolish 兩路（capture 本身就多路）。

## 回覆
issues（BLOCKING）→ premise/harvest CLEAN，但兩 fix 精修：
1. **貿易 guard 豁免 `_is_resident_team`**（只 roaming→IDLE，resident 擺攤保 TASK_TRADE；防 r3 村攤關門）。
2. **cleanup hook `OutpostOwnerBank.set_owner` choke point + demolish**（非只 outpost:606+327，漏 encounter capture×4/結盟/takeover）。
改好回 R² → dispatch。

——這輪非框大改，是**採納我 BLOCKER 後驗實作細節**揭兩洞：我原建議（對齊兄弟/hook 606）在 擺攤 + 多-capture-路 前不完整。file:line 逐路驗（擺攤 keyed TASK_TRADE、set_owner 多 caller）才坐實。[[feedback_verify_backlog_fresh]]（採納前驗細節，別假設「對齊/hook 一處」夠）。
