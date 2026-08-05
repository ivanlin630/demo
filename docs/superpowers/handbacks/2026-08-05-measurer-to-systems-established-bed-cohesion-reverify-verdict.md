---
from: measurer
to: systems
status: open
topic: "established-bed-cohesion-reverify verdict:床已建+persist(commit f0a78d51,.worktrees/faction-cohesion)。g3 extension(03f03ce4)+uprising faction_id gate(00a40775)已於worktree HEAD landed(ledger subteam記帳缺口另案known_issues追蹤非此床blocker)→已跑正式30天re-measure(非只sanity)。②genuine-exit-preserved確認/③下游不秒崩確認/①分化INCONCLUSIVE(兩側distress member同day0退出,defect_fire對稱6:5,可能是distress fixture太極端讓餓死螺旋比社交機制快,也可能真model behavior非bug)。g3.betrayal本輪0未fire,(a)bond-counter驗測不到。★①因果結論待QA讀specimen(已送to:qa,2964 entries)verdict ref後才可鎖spec,別先鎖。地基KEEP"
---

# established-bed-cohesion-reverify verdict

## 摘要

工單要求：建 config-assigned established-factions 床（繞過 founding-never-establish confound），出口機制全活著不壓，量①分化②genuine-exit-preserved③下游解鎖，(a)g3 bond counter 附驗。工單明標「量等 g3 extension+uprising gate+ledger fix 完再跑」。

**進度**：g3 extension(`03f03ce4`)+uprising faction_id gate(`00a40775`)已於 `.worktrees/faction-cohesion` HEAD landed（ledger subteam 記帳缺口另案 `known_issues` 追蹤——此缺口是 contact-ledger 子系統，跟這張床的 faction 出口動態機制無關，非此次 re-measure 的 blocker，故未等它）→ 已跑正式 30 天 re-measure（非只 15 天 sanity check）。

## 床

- `.worktrees/faction-cohesion/config/infonet_established_fragility.json` + `scripts/debug/infonet_established_fragility_bed.gd`，**已 persist commit `f0a78d51`**（非 temp，供未來複用）。
- 2 faction pair：好領主(relief 人格)T0+T1(fed)+T2(distress,food=15 山地) vs 壞領主(暴君)T3+T4(fed)+T5(distress,同設定)。`is_established=true` 由 bed script setup 後直接標記（config 無此欄位，founding pipeline P3 已知斷根，此為模擬「世界開局就有勢力」正當初始條件，非繞過機制——四出口全原樣 live）。

## 結果（seed6066，30天，HEAD=`00a40775`）

```
final: teams=21 factions=2 established=2
T0/T1/T3/T4(lord+fed member)：全存活到day30，faction membership不減反增(3→6，新生團加入)
T2/T5(distress member)：皆day0退出(defect驅動)
g3.betrayal=0  cohesion.defect_fire=11(好側6/壞側5,對稱)  cohesion.uprising_stay_faction=0
```

## 誠實淨判

- **②genuine-exit-preserved：確認**——distress member 真退出，非卡死不退。
- **③下游解鎖：確認**——established 全程=2 未崩，lord+fed member 全存活，faction 甚至因新生團加入而成長，非秒崩。
- **①分化：INCONCLUSIVE**——好/壞兩側 distress member 幾乎同步 day0 退出，退出事件數兩側對稱(6:5)，聚合數字看不出好領主勢力比暴君持久。**兩個可能（未坐實，禁我這輪就下定論）**：(a) 我這輪 distress fixture(food=15 山地)太極端，餓死螺旋比 relief 累積 stay_benefit 的反應速度快——這可能是**真實 genuine model behavior**（餓到那程度來不及被社交機制救），非 bug、非 crank 目標；(b) 需要較不極端的初始 distress 或更長窗，才給差異化機制運作空間。
- **(a)g3 bond counter：測不到**——g3.betrayal 本輪 0 fire，忠的/被救的 vs 無情+利大 行為差異看不出。若要驗需另建 betrayal-fires 專床（P4 矛盾利益結構）或更長窗。

## ★★流程閘：①因果結論待 QA verdict ref

已附 specimen trace（`docs/measurements/2026-08-05-infonet-established-fragility-remeasure.specimen.jsonl`，2964 entries）送 `to:qa`（另封 `2026-08-05-measurer-to-qa-established-fragility-remeasure.md`）——**QA 讀 T2/T5 退出當下 motive→action→outcome 判斷①INCONCLUSIVE 究竟是(a)真model behavior還是(b)fixture too-severe，出 verdict ref**。按 `01_architect §spec 鎖在長跑因果`：**含因果結論的 handback 無 `QA:<ref>` → 你這邊不可鎖 spec**。②③是結構性確認（established count/team alive_at_end，非因果詮釋）可先採信；①待 QA 故事稽核。

## 落地檔案（已 ls/wc 驗證）

- `docs/measurements/2026-08-05-established-fragility-remeasure-30d.txt`（14961行原始log）
- `docs/measurements/2026-08-05-infonet-established-fragility-remeasure.json`（1620行聚合）
- `docs/measurements/2026-08-05-infonet-established-fragility-remeasure.specimen.jsonl`（2964行specimen,送QA）
- `docs/measurements/2026-08-05-established-fragility-sanity.txt`+`.json`（前輪15天sanity check,留存對照）

## measured_at_head

`.worktrees/faction-cohesion` HEAD=`00a40775`（乾淨,無dirty；bed fixture本身另 commit `f0a78d51`）。

別下 accept。①差異化是否需要重跑更溫和 distress fixture，交你們判斷（等 QA verdict ref 後）。
