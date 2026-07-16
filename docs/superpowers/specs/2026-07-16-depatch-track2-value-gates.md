# Spec：de-patch 軌2 值閘人格化（零殘留 stream ①）

> 框架做好 stream ①（零殘留閘）de-patch 軌2。blueprint 批 triage + escalation 全 de-patch。
> 原則：行為閘（硬寫行為選擇）→ 決策交人格/情境秤；RNG 決策翻轉→人格 util（世界不確定 outcome RNG 留）。
> ★行為變 de-patch（非 byte-identical）→ 乾淨全量 measure 驗行為合理+無回歸（照 Arc1 模式）。

## 標的（B 軌2 值閘，triage 分類 + blueprint escalation 裁）
逐閘：硬門檻/RNG-決策 → 人格/情境秤（constant/dice 退役）。**per-gate git commit**。

1. **`_threat_recent::threshold`**（`faction_ai:3125`，caller weaponsmith `:3087`/armorsmith `:3090`）＝反應式軍備閘（pre-empt 征服者主動備戰）→ **de-patch**：軍備需求由 **intent（征服/野心）+ 好戰 + 感知威脅** 秤（主動軍閥備戰、和平農夫不備），非「近期被打過才備」硬 gate。weaponsmith/armorsmith deficit 已走 NeedOracle（Arc1），此閘是額外 threat-gate → 拆，交人格軍備傾向。
2. **diplomatic 決策 RNG**（`_send_diplomacy_message`/`consider_betrayal`/`try_proactive_diplomacy` rng）＝**★R² 訂正：已部分人格加權**（慎重/loyalty 影響機率，非純 random）＝**第三種 RNG case（人格加權決策骰）→ escalate blueprint 裁**（de-patch 成 deterministic util[真統一一條路] vs 留[人格驅動機率=變化戲]，見下 §escalate）。**待裁，暫不動。**
3. **`_check_discipline::rng`** ＝ **★R² 訂正：同閘2**（已人格加權[loyalty]，非純骰）→ escalate 同批（決策 vs outcome + 人格加權骰去留）。**待裁。**
4. **`_maybe_request_join_player::rng`** ＝ **★R² 訂正：事實錯（我未驗前提，own）**——`randi()` 只產 **event ID**、**無任何決策骰** → **非 de-patch 標的，標 gate-ok**（ID 生成非決策 RNG）。此閘 rng detector false-positive。
5. **tribute FLEE override**（`diplomatic:40` tribute_accept 逃跑必屈服）＝ **de-patch → 膽識/絕望秤**：邊逃邊拒（做得到=行為選擇非物理不可能，絕境戲）——屈服由 **膽識（低→屈服）+ 絕望度 + 戰力差** 秤，非「逃跑=必屈服」硬 override。**（R² 屬實）**
6. **`_calc_diplomacy_score::threshold`**（硬 score 門檻）＝ 外交決策硬閾 → **人格 util 軟化**（連續秤非硬切）。**（R² 屬實）**
7. **`calc_attack_score::threshold`** ＝ **★R² 確認孤兒**（production/征服 arc 退役，零 caller）→ **刪**（非人格化）。

## ★escalate blueprint（閘2/3 第三種 RNG case，R² 揭）
RNG 判準（invariants）現分「決策翻轉骰=閘」vs「世界 outcome 骰=合法」。**閘2/3 是第三種：人格加權的決策骰**（慎重/loyalty 已影響背叛/紀律機率，非純 50/50）。**問**：
- **甲 de-patch → deterministic util**（人格加權當 util weight、argmax/門檻決定，去骰）＝真統一「一條路」（慎重低於閾 never 背叛）。
- **乙 留為合法**（人格驅動機率、RNG 只是隨機實現=變化/戲，慎重 leader 30% 背叛）＝人格穿了、非純骰閘。
真統一標準傾甲（去骰=一條路），但乙有 game variety。**你裁 + 精修 RNG 判準（人格加權決策骰=閘 or 合法）。**

## legit 標記（A ~60，systems 授權，implementer 順手標 baseline）
`constitution_baseline_v2.txt` 的 A 類（canonical `rank_*` 引擎 / taskarbiter lifecycle scaffolding 28 / world-rule threshold 地利-食耗-hex距 / early_return guards null-0pop）逐行加 `# gate-ok:<world-rule/canonical 理由>`。→ baseline 剩「未標=待 de-patch」清晰。

## 非回歸（★行為變，非 byte-identical）
- **世界不確定 RNG 保留**（訊息到達/外交成敗/戰鬥擲骰 outcome）——只拆決策翻轉骰（區分見 invariants RNG 判準）。
- **感知鐵律**：de-patch 後決策讀 belief/自家人格，非 god-view。
- **無崩/守恆**：headless≥1000 tick、CoinAudit/InvariantAudit=0。
- de-patch 後對應閘從 constitution_gate baseline **removed**（=零殘留進度）。

## 閘
- **R② 設計審**（per-gate 真 de-patch 非搬家、人格映射 sound、決策 vs outcome RNG 分對）。
- **measurer 乾淨全量**（行為變合理：軍閥備戰/農夫不備、慎重不背叛、絕境屈服人格分化；無回歸；閘 removed）。

## 溯源
blueprint triage 原則 `triage-principle-legit-vs-gate` + escalation 裁 `escalation-rulings-batch-depatch`（全 de-patch + RNG 原則）；triage 分類 `triage-93-gates-classified`；invariants 兩不變量+RNG 判準。
