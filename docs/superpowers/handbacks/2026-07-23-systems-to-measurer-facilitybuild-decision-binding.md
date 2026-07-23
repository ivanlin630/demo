---
from: systems
to: measurer
status: consumed
topic: "[facility-build keystone 開場·①build-decision fire率+誰preempt·patch-gate-first survival-override prior·R① 坐實 binding 前置(別假設 build-decision 是 binding)] blueprint 開 facility-build keystone(poverty-trap 逃生),top-down 決策鏈序①決策②means-end③accumulation。★我 binding-hypothesis『binding 在 build-decision 端非 accumulation』本身是 causal claim,照新 R① 要 measure 坐實再 spec。求量①:①**建設/TASK_BUILD fire 率**(隊多常選建設 option/上 TASK_BUILD;全隊+per-類 mil/civ)②**★誰 preempt**(建設 option @PRIO_DISPATCH 50[else 類,DecisionOptions.priority_for],survival-class @80/threat @70——查建設不 fire 時贏的是不是 survival-class[覓食/返家/survival/掠奪]@80 systematically preempt=patch-gate-first survival-override prior,同 workshop-build 終閘 farming survival-crush)③**建設 applicable 但落選 vs 根本沒 applicable**(_pick_facility argmax score>threshold?)④**★關鍵岔路**:建設 fire 了但 facility 仍近零(=binding 在下游 ②means-end/③accumulation)vs 建設根本不 fire(=binding 在①決策端,survival preempt)。⑤%隊 survival-mode(survival-class 常駐 preempt,連 91% coin/food-stressed)。判準:建設 fire 率低+survival preempt 主導→binding=①決策端(survival-override),spec 治決策;建設 fire 但下游失敗→binding=②③,續量。main HEAD 最新 seed42/1337 長跑 §④b。★別下 fix 結論,坐實 binding 位置 to:systems。"
---

# facility-build keystone 開場 measure：① build-decision binding 坐實（R① 前置）

blueprint 開 facility-build keystone（poverty-trap 逃生=發展層），**top-down 決策鏈序**：①build-decision → ②means-end want → ③accumulation（別倒修）。**★我 binding-hypothesis「binding 在 build-decision 端非 accumulation」= causal claim → 新 R① 要 measure 坐實再 spec**（別假設）。

## 求量 ①（build-decision fire 率 + 誰 preempt，patch-gate-first）
1. **建設/TASK_BUILD fire 率**：隊多常選「建設」option / 上 TASK_BUILD（全隊 + mil/civ 分）。
2. **★誰 preempt**（patch-gate-first survival-override prior）：建設 @`PRIO_DISPATCH 50`（else 類，`DecisionOptions.priority_for`）vs **survival-class @80 / threat @70**。建設不 fire 時**贏的是不是 survival-class**（覓食/返家/survival/掠奪 @80）**systematically preempt**？= 同 workshop-build 終閘（farming survival-crush）的 survival-override 家族。
3. **建設 applicable 但落選** vs **根本沒 applicable**（`_pick_facility` argmax score>threshold 0.05?）。
4. **★關鍵岔路（定 binding 層）**：
   - **建設 fire 了但 facility 仍近零** → binding 在**下游**（②means-end target 白買 / ③accumulation reserve 湊不到）。
   - **建設根本不 fire** → binding 在**①決策端**（survival preempt 建設 @50）。
5. **%隊 survival-mode**（survival-class 常駐 preempt，連 91% coin/food-stressed → 多數隊卡 survival → 建設 @50 難贏）。

## 判準（坐實 binding 位置，我 spec）
- **建設 fire 率低 + survival preempt 主導** → binding = **①決策端（survival-override）** → spec 治決策（de-patch survival-override 對建設 or 調 priority，同絕境階梯/照妖鏡家族）。
- **建設 fire 但下游失敗** → binding = **②means-end / ③accumulation** → 續量那層。

## 跑法
main HEAD 最新 seed42/1337 長跑 §④b。**★別下 fix 結論**——坐實 binding 位置 to:systems（R① 前置，別讓我在假設上 spec）。
