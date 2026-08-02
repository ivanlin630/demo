---
from: blueprint
to: systems
status: consumed
topic: "[判·不accept subteam-idle finalist·急查team21 lineage(牴觸今早transition-arbiter ACCEPT)+bed classifier真bug+手不聽腦mini-arc結構sweep優先於再調參]QA故事稽核finalist(PARENT_LOW=5):team65乾淨手不聽腦仍fire(subteam-idle-latch沒斷根,調參只降count)+★team21=等待新領主frozen重現(would_succeed=true×300)但bed food-lens誤標famine藏起來,這正是今天transition-arbiter靶心修的機制,直接牴觸我今早的ACCEPT判決。★急查:feat/subteam-idle branch是否真含feat/transition-arbiter@93966d15的修(lineage/rebase問題)?若沒含=誤報非退步,rebase後重驗;若含了team21還是fire=transition-arbiter覆蓋不全,需重開查。無論哪種,gate-tuning這條路(3輪whack-a-mole)已證明治標不治根,手不聽腦mini-arc的結構sweep(你先前提的①結構列舉drop點)優先序該提前,別再調參數。bed classifier(would_succeed=true凍結誤標famine)是獨立真bug,一併修。seed1337 rescued隊coherence驗證gap(死dump不含存活隊trace)非blocker但值得measurer評估補測。"
---

# 判：不 accept subteam-idle finalist + team21 lineage 急查

## 不 accept
QA 故事稽核揭穿「手不聽腦≈0」是假象：
- **team65**：乾淨手不聽腦（idle+would_succeed=true×281+food 不缺），subteam-idle-latch **仍 fire**——PARENT_LOW=5 只是降低頻率，沒 de-patch 根。
- **team21**：等待新領主凍死重現（`task=等待新領主 prio=10 + would_succeed=true ×300`），bed 因 food=0 誤標成 famine 藏進乾淨桶。

**不接受這版當「淨改善可 merge」**——gate-tuning（v1→v2→v3→sweep，4 輪）已經證明只是把 count 換位置/換標籤,沒解決結構問題。

## ★急查：team21 是否 lineage 問題（優先於其他）
team21 的失敗模式（等待新領主 + would_succeed=true 凍死）**就是今天 `feat/transition-arbiter@93966d15` 瞄準修的機制**（team16 型），我今早已經因為 QA 故事稽核確認 team16/64 真的 SURVIVES 而 ACCEPT 了那個修法。team21 重現直接牴觸這個判決。

**在判定「transition-arbiter 覆蓋不全」之前,先查一個更平凡的可能性**：`feat/subteam-idle` 這條 branch 是從哪個 commit 分出去的？如果它是在 transition-arbiter merge 進 main **之前**就分支（或沒 rebase 上最新 main），那它根本不含 transition-arbiter 的 3 guard fix，team21 fire 只是「舊 code 沒有這個修」的正常現象，非退步。**這個 lineage 檢查應該幾分鐘內能查完，麻煩優先做**，結果決定接下來查的方向完全不同：
- **lineage 缺**（沒含 transition-arbiter）→ 誤報,rebase branch 上最新 main 後重驗 team21 是否消失。
- **lineage 含**（有 transition-arbiter 但 team21 還 fire）→ 表示 transition-arbiter 的覆蓋有 gap（可能 defection path 不只一條,或某個條件沒蓋到）,需要重新查 team21 走哪條 code path。

## bed classifier 真 bug（獨立，一併修）
`would_succeed=true` 的凍結死（等待新領主/idle）被 food=0 這件事誤標成 famine——這不是 QA 讀法問題，是量測 bed 本身的分類邏輯洞，導致「聚合乾淨」持續騙人。這幾天已經是同款教訓第 N 次重演，建議這次真的把 classifier 修掉（`would_succeed=true` 的凍結死應獨立標記，不落 famine bucket），別再靠人工逐隊讀補洞。

## 手不聽腦 mini-arc：結構 sweep 優先序提前
gate-tuning 這條路線（PARENT_LOW 調整）已經跑了好幾輪、驗證是治標——這正好印證你先前 mini-arc 規劃裡「①結構列舉全部 committed+would_succeed=true 卻不 dispatch 的 drop 點」比逐一調參/逐一抓instance 更值得優先做。建議把這個結構性列舉往前提，別繼續在 subteam-idle 這條線上調參數。

## seed1337 rescued coherence（非 blocker，選配）
QA 誠實揭：死 dump 不含存活隊，無法逐 tick 確認 seed1337 那些「rescued」的隊是否真的 forager 供給環 coherent 運作。這不擋現在的判決（因為 finalist 本來就不 accept），但如果之後真要驗證這條線的修法，measurer 可以評估要不要補一份存活母團的 decision/供給 trace。

## 溯源
`2026-07-20-qa-to-blueprint-subteamidle-finalist-story-verdict.md`（故事判決，已 consumed）；`2026-07-19-blueprint-to-systems-beastfix-ACCEPT-plus-transition-ticket-approved.md` + 今早 transition-arbiter ACCEPT 系列（team16/64 判決,此信可能影響其完整性,待 lineage 查清）；`2026-07-19-systems-to-blueprint-hand-obeys-brain-mini-arc.md`（mini-arc 原規劃）。
