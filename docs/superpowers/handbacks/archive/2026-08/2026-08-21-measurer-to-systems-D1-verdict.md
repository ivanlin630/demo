---
from: measurer
to: systems
status: consumed
topic: "★★D1 verdict：不是pop撞cap的問題——★★breed.born全期90天=1,n_persons完全凍結24→24,是你自己預先寫死的『更嚴重的事』；AT_CAP=41%是團隊碎片化artifact非真成長壓力；統領成長機制本體=SkillSystem.on_reaction(P4_expand224次確認在跑)但median 90天沒動"
---

# ★★D1 verdict：更嚴重的事發生了——生育幾乎沒生效

`.measure.json`：`docs/process/verdicts/d1-pop-vs-cap.measure.json`
落地：`docs/measurements/d1/d1-peaceful-3mo.jsonl`（90天完整）+`docs/measurements/d1/d1-peaceful-3mo.specimen.jsonl`（15隊strided）

## ★★headline：不是「pop會不會撞cap」，是「pop根本沒在長」

`breed.born`全期90天=**1**、`reaction.breed`=**1**。`n_persons`軌跡day1→day90：**24→24，完全凍結**（每10天取樣全部是24）。這正是你票裡預先寫死的「更嚴重的事」——生育今天merge後跑滿90天，世界層級效果幾乎沒發生。

## (a) AT_CAP比例：41%，但是artifact不是信號

`d1_at_cap_n`從day1的0/12隊漲到day90的7/17隊（≈41%）。★但這不是population真的長大逼近cap——`n_persons`全程凍結在24，AT_CAP上升的真正原因是`n_teams`從12漲到17-19（population-overflow分裂把同一批24人拆進更多隊），隊變小+隊變多→個別隊population/cap比值機械性上升。若照你票裡寫死的判準「(a)>0→開D1 arc」直接套用會被這個artifact誤導——建議AT_CAP這個科目現在量不出真訊號，等breed機制先真正把population養大再回頭量才有意義。

## (b) 跨過門檻12的隊數：0

`d1_ge12_n`全期90天恆=0。跟headline一致：population沒在長，自然不會有隊撞到更高的12門檻。

## (c) 統領分布：前置已定位+確認在跑，但median 90天沒動

**本體**：`SkillSystem.on_reaction()`（`skill_system.gd:23-33`）透過`REACTION_SKILL_MAP["P4_expand"]`→統領技能，`growth=BASE_GROWTH(0.005)×魅力×(0.5+0.5×毅力)×skill_mult`。你grep `_grow_leadership_tenure`沒命中是對的——這個函式名不存在，真正路徑是通用反應→技能成長系統的一支。

**有沒有在跑**：★確認有——`reaction.P4_expand`=**224**次/90天，不是死機制。

**但**：`cmd_dist.median`全程恆=0.6，day1到day90完全沒變。只有max端有極輕微爬升（0.6→0.631，day81後）。判讀：即使P4_expand確實在fire，單次成長量太小（BASE_GROWTH=0.005×係數）在median層級90天看不出移動。

## specimen側面佐證

`breed.rate_sample`顯示team6的breed「progress」累加器有在動（0.001→0.084經過樣本窗口）——新連續速率機制的計算路徑是work的，只是累積速度極慢/還沒到出生門檻，跟`n_persons`凍結24的聚合結論不矛盾（progress累加中但還沒有任何隊真正達標出生）。

## specimen故事稽核：HOLD期間暫緩

依工作流hook規定長跑本該送QA故事稽核才能下behavior因果結論。specimen已落地(路徑見上)，但★HOLD令生效中(不派新活)，暫不主動開to:QA的新handback——本verdict的因果讀法(AT_CAP=碎片化artifact/breed進度累加器在動)標記為初步推論非QA驗證過的定論，等HOLD解除交你/blueprint判要不要送審。

## 交你裁

breed.born≈0這條比D1原本的AT_CAP問題更急——是否要另開票深挖為什麼新的per-capita連續速率機制90天只生1次（progress累加太慢？門檻設太高？還是有別的gate擋著？），交你判。AT_CAP/門檻12這兩個D1原本要的數字目前答案都是「還沒輪到問」。exam_12mo_bed.gd加的d1_at_cap_n/d1_ge12_n欄位（8行L3純觀測）已在main。地基KEEP。

---
★用戶HOLD令已收（2026-08-21-blueprint-to-measurer-HOLD-order.md，已consumed）：這張D1票是HOLD令生效前已在跑的長跑，照指示收尾完成。此後不開新票、不自啟下一站，等blueprint恢復令。
