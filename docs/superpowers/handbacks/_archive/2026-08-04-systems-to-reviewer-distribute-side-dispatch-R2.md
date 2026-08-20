---
from: systems
to: reviewer
status: consumed
topic: "[R²審distribute side-dispatch spec(2026-08-04-infonet-distribute-side-dispatch-HOW.md,blueprint RATIFY,症1雙端對稱完成)·root(RE-measure#5坐實):de-scan解候選生成candidate_eval 0→680但dispatch仍0 T0領主恆覓食=distribute留主argmax跟覓食競爭輸(同herald/scout移出前signature)·fix=distribute脫主argmax→平行side-dispatch(同家族de-patch):1移frontier_candidates:117的_distribute_candidates append(主argmax winner不變determinism-neutral移loser)2新_try_distribute_side(side-dispatch pass旁_try_herald/scout_side)每領主reuse _distribute_candidates算最佳賑濟候選(已de-scan belief+人格零god-view零死常數),mini-util=該候選util>0且not throttled→_dispatch_convoy kind=distribute3 throttle一領主一in-flight distribute convoy·★side-action邊界正式化寫進spec(blueprint定防creep):side-dispatch=detach子單位母隊主task不變directive類(herald/scout/distribute三型),各人格mini-util,主argmax零改,每新增型需blueprint sign-off·★審點:①主argmax零改動(移_distribute_candidates出frontier winner不變determinism)②mini-util genuine(既有de-scanned distribute util relief+人格一字不改,只換觸發路徑主argmax→side非crank)③side-action邊界scope硬限(只herald/scout/distribute三型明列非泛化框架,distribute第三型blueprint已sign-off)④de-patch非增殖(distribute從假裝主argmax option還原directive side-action同家族)⑤determinism零新randf+economy food_surplus守reserve·CLEAN→build→re-measure症1端到端(distribute.dispatch>0+糧真到resident runway回升,症1首次閉環)→QA"
---

# R² 審 distribute side-dispatch（blueprint RATIFY、症1 雙端 side-action 對稱完成）

**spec**：`docs/superpowers/specs/2026-08-04-infonet-distribute-side-dispatch-HOW.md`
**root（RE-measure #5 坐實）**：de-scan 解候選生成（`candidate_eval 0→680`）但 dispatch 仍 0、T0 領主恆覓食＝distribute 留主 argmax 跟覓食競爭輸（同 herald/scout 移出前 signature、measure 坐實）。
**WHAT 裁**：blueprint RATIFY——distribute=side-action 家族（領主下令派賑濟 convoy=directive、body 照覓食、同求援對稱）。

## 一句話修法
distribute 從「假裝主 argmax option」→ 平行 side-dispatch（同 herald/scout de-patch）：移出 frontier + 新 `_try_distribute_side`（reuse de-scanned `_distribute_candidates` 當 mini-util、>0 → `_dispatch_convoy`）。

## ★審點（R² refute checklist）
1. **★主 argmax 零改動**：`frontier_candidates:117` 移 `_distribute_candidates` append → 主決策 winner 不變（移 loser 中性）。確認 determinism byte-identical（除 relief convoy 世界效果）、非動主秤。
2. **mini-util genuine 非 crank**（[[feedback_genuine_value_not_crank]]）：mini-util=**既有 de-scanned distribute util**（relief 仁慈/責任 belief + coin greed）、**一字不改、只換觸發路徑**（主 argmax → side-dispatch）。確認非藉機 crank。
3. **★side-action 邊界 scope 硬限**（blueprint 正式化防 creep）：只 **herald/scout/distribute 三型明列**、非泛化 side-task 框架；distribute=第三型 **blueprint 已 sign-off**。確認無「可插拔泛化」後門、每新增型需 sign-off 寫進 spec。
4. **de-patch 非增殖**（框內補丁 lens）：distribute 從假裝主 argmax option → 還原真實 directive side-action（同 herald/scout 家族正解）、非新平行求解器。
5. **determinism 零新 randf** + **economy 不爆**（food_surplus 守 reserve 不變、throttle 一領主一 convoy）。

## 邊界
- throttle：一領主一 in-flight distribute convoy（鏡射既有 convoy throttle）。
- note（別動）：trade deliver-convoy 仍主 argmax（blueprint：日後同 signature 再議）。

**CLEAN → 回 systems → build（續 `feat/info-network-whole`）→ ★re-measure 症1 端到端 on FACTION bed（`distribute.dispatch/food_delivered>0` + 糧真到 resident runway 回升＝症1 首次閉環）→ QA 故事稽核（回溯三因果+whole、verdict ref）→ blueprint 推用戶驗收。** 卡/BLOCKER → 報 `to:systems`。
