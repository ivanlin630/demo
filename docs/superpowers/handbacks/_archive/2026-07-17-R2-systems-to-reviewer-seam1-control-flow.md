---
from: systems
to: reviewer
status: consumed
topic: "[R②·異質框外審已跑→spec REVISED] seam#1：異質 Sonnet skeptic 判 v1 threat 收斂 FLAWED（5 findings，systems 逐 code 全 file:line 驗證屬實）。已 REVISE spec:剝離 threat 收斂→threat-oracle arc(序3)、只留 S1 registry(byte-identical)+survival/ambient 逐路驗收斂。請 R② 確認 REVISED scope(S1 byte-identical claim + threat 剝離裁定 sound 否 + survival/ambient 逐路驗 plan)。CLEAN→dispatch S1 implementer。"
---

# R②：seam#1 控制流收斂 設計審（異質框外審已跑，spec 已 REVISED）

## ★更新（讀最新 spec，非 v1）
異質 Sonnet skeptic（不同 model=真框外）已跑，判 **v1 threat 收斂 FLAWED**，5 findings 全 file:line。**systems 逐 code 全驗證屬實**（terms.gd:170-171/176/180/239/243、task_arbiter.gd:9/12/20、faction_ai_system.gd:396/405、decision_engine.gd:143）。已據此 **REVISE spec**（見 spec §R② + §目標 REVISED + §交付切片 REVISED）。**你審 REVISED 版，非下方 v1 原文**。

### 5 findings 摘（spec §R② 詳）
1. threat util 量級**故意壓小**（靠 applicable-gate 選），全 pool 被貿易(1.3)/野心(1.5)結構性壓過。
2. 無 threat break-top boost（survival 有）。
3. PRIO 塌 70→50 失黏性。
4. preempt 唯一 call site=rank_threat → S3 殺之。
5. 量測盲點：threat.dispatch probe 在 preempt loop 內，收斂後正常路無 tap（撞觀測不變量）。

### REVISED 裁定（請確認 sound 否）
- **剝離 threat 收斂** → 歸 threat-oracle arc（4 前置:severity-scaling util/break-top boost/preempt 明確/probe 先接）。本就路線圖序3-4 在 seam#1 後。threat dual-path **保留 legit-until-threat-oracle**。
- **留 S1 registry**（byte-identical，安全，交付擴充半）→ CLEAN 即 dispatch。
- **survival/ambient 收斂降 S2 條件**：逐路獨立驗行為保才退役（非假設均質）。

## 審什麼（REVISED）
- (1) **S1 registry byte-identical claim** 站得住嗎？（`applicable()`/`to_task()`→REGISTRY，同 pool 同序、觀測 byte-identical）
- (2) **threat 剝離裁定** sound 嗎？filtered threat 路真編碼不可無腦收斂的語意（量級-壓小×gate-選×PRIO70×preempt×自有 FLEE 公式）——同意保留 legit-until-threat-oracle，還是有更省路子？
- (3) **survival/ambient 逐路驗 plan** 夠嗎？還是它們也藏 threat 類隱性語意（例:rank_survival 的 commitment/previous_task latch `decision_engine.gd:114-118`、rank_ambient 排除 FLEE `:156`）？

## 判準
- CLEAN → dispatch S1 implementer（byte-identical TDD，git per-slice，measurer byte-identical 驗）。
- 若 threat 剝離裁定有洞 / S1 非真 byte-identical → halt 回 systems（file:line）。

## 溯源
Arc2 R① `arc2-r1-clean`；R② 異質 Sonnet skeptic FLAWED verdict（2026-07-17）；用戶真統一標準；[[project_unification_matrix]] 序3-4 threat-oracle；[[feedback_frame_challenge]]。

---
## （下為 v1 原文，已 superseded，留存溯源）

# R②：seam#1 控制流收斂 設計審（升異質框外審）

## 審什麼
Spec：`docs/superpowers/specs/2026-07-17-seam1-control-flow-convergence.md`（讀全文）。
`decision_engine.gd` 的 `rank_scored`（`:15`）已是主統一路（全 applicable pool + util 秤 + argmax，survival `:37` boost 整合）。本 spec 退役 3 條 filtered-subset 非統一路（`rank_survival:105`/`rank_threat:134`/`rank_ambient:159`）+ 其手派 return-gate 路由（route×10 + dispatch_entry），全隊收斂走 rank_scored 一條路；並把 `applicable()`/`to_task()` per-option match 折成 REGISTRY（擴充性）。

## ★為何升異質框外審（非標準同-Opus R②）
- **redirect 核心決策路徑 + 難逆**（改核心 rank 分流）。
- **三方對齊**：真統一北極星（用戶標準）× blueprint 行為意圖 × systems 結構。
- **同-Opus reviewer 與我共框**（groupthink 在判斷層，自驗抓不了自己的框，[[feedback_frame_challenge]]）→ 這 call 值得召不同 model 的 skeptic 攻框。
- 我（systems）已同步 spawn 一個異質 skeptic 專攻下列風險點，verdict 會補進本 thread；你的 R② 判決可納入。

## ★核心風險（請重點攻，spec §關鍵設計 flagged）
**survival「軟」vs threat「硬」語意合併**：
- `rank_scored` 的 survival 是**軟整合**（`:37` food→0 線性加法破頂奪 argmax）。
- `rank_threat`（`:134`）目前是**硬 filtered 子集**（只在 THREAT_OPTION_SET[survival/備戰/迎戰/求和] 內 argmax）。
- 收斂 = threat 選項進**全 pool 用 threat 權重競秤**（非 filtered 硬切）。
- **風險**：非統一隊 threat 行為 filtered-hard → full-pool-weighted 可能變（備戰/迎戰/求和/FLEE 率、preempt 保序）。spec 的安全網是「S2 measure 乾淨全量驗」。
- **審問**：(a) 語意合併在原理上健全嗎？full-pool threat 權重能否複現 filtered-hard 的保序（強威脅下 threat 選項仍奪 argmax，不被發展選項稀釋）？(b)「measure 事後驗」是可接受安全網，還是有 measure 抓不到的設計漏（e.g. 罕發 context 下 threat 被蓋）？(c) preempt scaffolding（序3.5 忙碌打斷，現活 `_evaluate_threat`）收斂後語意保得住嗎？

## 判準
- CLEAN → 我 dispatch implementer（S1 registry byte-identical → S2 收斂 → S3 gate removed，TDD，git per-slice，整 seam 完成才 measurer 乾淨全量）。
- premise_contradiction / 設計漏 → halt 回 systems（附 file:line）。
- 語意合併若判「原理不健全」→ 可能需先做威脅權重設計（非直接收斂）。

## 溯源
Arc2 R① `arc2-r1-clean`（premise 坐實）；用戶真統一標準；[[project_unification_matrix]] 統一路線圖 stream①軌1+stream② seam#1。
