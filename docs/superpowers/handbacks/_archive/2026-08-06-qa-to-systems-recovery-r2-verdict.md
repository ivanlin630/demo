---
from: qa
to: systems
status: consumed
topic: "★recovery-r2投資sufficiency判=足以merge(不需先做clean organic demo)——獨立驗證:r2_test讀code確認真advance_tick pipeline(非hand-step)+anti-crank真在(faction_ai:4016-4018 build_eta≥food_days→viable=false)+DESPERATION_DAYS=3.0 gate真在(1795-1798)+vid=7 organic案獨立驗證(anchor0.json roi=7.5/dispatched=1逐位元match)+mountain anchor4 dispatched=0確認。★但抓到一處被輕輕帶過的精確度落差:mountain(anchor4)的per_village_roi_sample是空{}——跟anti-crank forest案(anchor2)同款『belief-null vs genuine負ROI declined』無法區分的模糊态,ticket把mountain案寫成『三態mountain-side organic』穩了、但anti-crank案有誠實聲明模糊、mountain沒有,是同款證據卻標準不一。不過這不影響整體判斷,因為mountain-負ROI-correctly-declines真正的證成來源是_test_invest_mountain_no_dispatch這個乾淨unit test(_mk_lord_invest真seed了BeliefSystem.record_claim+dispatch_ledger holding entry,非空belief情境),此路徑跟emergent fixture的belief-null問題無關、獨立成立。★裁定:mechanism證成足夠merge——unit-test三態(含mountain負ROI genuine decline)+anti-crank+organic單點真fire(排除code bug)+code雙bound確認,四條獨立證據線收斂,不是單一窄床。emergent fixture的manual-village belief-null是已診斷、已解釋、範圍明確的measurement-tooling缺口(跟merge-ready的code無關),不需要為了『村真站起來』的user-facing demo故事延後merge——clean organic forest demo可留作未來需要polish敘事時的獨立follow-up(用vid=7那種own-faction holding-ledger resident當target、非manual置村),非merge前置"
---

# ★recovery-r2 投資 sufficiency 判 — 足以 merge

裁：**機制證成足夠 merge，不需先做 clean organic demo**。

## 獨立驗證（不只信 ticket 文字，逐項讀 code + 量測檔）

- **r2_test 真 pipeline**：讀 `recovery_r2_test.gd` 確認 `_test_invest_full_pipeline` 真呼叫 `runner.advance_tick(state, anchor)`（非 hand-step），R1 教訓真的納了。
- **anti-crank 真在**：`faction_ai_system.gd:4016-4018`，`build_eta_days >= food_days → viable=false`——蓋不完的建案真的會落空/落覓食，非 always-win crank。
- **DESPERATION_DAYS gate 真在**：`faction_ai_system.gd:1795-1798`，`lord_food_days < DESPERATION_DAYS(3.0) → return`，跟 claim 一致。
- **vid=7 organic 案獨立驗證**：讀 `2026-08-06-infonet-recovery-r2-invest-anchor0.json` 逐位元 match（`roi=7.5`/`terrain=forest`/`invest.dispatched=1`）——真在資料裡，非轉述。
- **mountain(anchor4) dispatched=0**：讀 `2026-08-06-infonet-recovery-r2-invest-anchor4.json` 確認 `invest.dispatched=0`。

## ★抓到一處證據標準不一致（不影響結論，但要指出）

`anchor4.json` 的 `per_village_roi_sample` 是**空 `{}`**——跟 anti-crank forest 案（anchor2）同一種「belief-null vs 真負ROI declined」無法區分的模糊態（measurer 自己對 anchor2 誠實聲明了這個模糊，**但對 mountain(anchor4) 沒有**，ticket 直接寫成「③mountain案...三態mountain-side organic」寫得比 anchor2 篤定）。空 roi_sample 代表 `_village_est` 這輪對 mountain 村也很可能回傳 null（跟 Village1/Village2 同款 belief-formation 問題）——**這輪 emergent fixture 本身無法真正證明「mountain 是被評估後因負 ROI 才不投」，跟「mountain 也一樣沒被評估到」外部表現相同**，跟 anchor2 的處境一致，不該比 anchor2 更篤定。

**但這不影響整體判斷**——mountain 負 ROI 真正 declines 的證成來源不是這輪 emergent fixture，是 **`_test_invest_mountain_no_dispatch`**（乾淨 unit test）：讀 `_mk_lord_invest` helper 確認它真呼叫 `BeliefSystem.record_claim(...)` 播種 belief + 塞 `dispatch_ledger` holding entry——**這條路徑不受 emergent fixture 的 belief-null 問題影響、獨立成立**。mountain-負ROI-真的-declines 這個結論站得住，只是站在 unit test 上、不是站在這輪 organic 量測上，ticket 的措辭需要精確化。

## 裁定

**四條獨立證據線收斂**（unit-test 三態含乾淨 mountain 負ROI decline + anti-crank 真 gate + vid=7 organic 單點真 fire(排除 code bug) + code 雙 bound 確認）——不是單一窄床冒充 general，證成足夠 merge。

emergent fixture 的 manual-village belief-null 是**已診斷、已解釋、範圍明確**的 measurement-tooling 缺口（跟 `_village_est` 讀 `dispatch_ledger` holding 條目這個既有設計有關，非 code bug），**不需要為了「村真站起來」的 user-facing demo 故事延後 merge**。Clean organic forest demo 可留作未來需要 polish 敘事時的獨立 follow-up（比照 vid=7 用 own-faction holding-ledger resident 當 target、非 manual 置村），非 merge 前置。

**建議**：merge 時修正 ticket 對 mountain(anchor4) 的措辭，改標「mountain 負ROI真decline 由 unit test 證成、emergent fixture 這輪跟 anchor2 同款 belief-null 未淨驗」，避免文字上把 anchor2/anchor4 寫得標準不一致。

---
*QA 驗收官 · 2026-08-06*
