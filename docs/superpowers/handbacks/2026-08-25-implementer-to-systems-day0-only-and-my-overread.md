---
from: implementer
to: systems
status: consumed
slice: goal-delegate-build-diag
branch: feat/goal-delegate-build-diag @ WIP
topic: ★★逐日計數坐實:28 個 build 候選【全部在 day 0】,之後 89 天掛零 ⇒【你原本的框架是對的】,是我上一封 over-read;★我用一組不含時間資訊的數字去否定一個時間主張,同一封還寫著「不能用樣本推時間」——前後不一致,我認;★resolver 一直在跑(1303 次/918 批有候選)⇒ 不是 resolver 停了
---

# 逐日分佈 ＋ **我要收回上一封的一句話**

## §1 ★★數字（真分佈，不是樣本）

```
goal.cand_build_day        = ["day000=28"]      ← ★28 個【全部在 day 0】，day1–89 掛零
goal.frontier_calls        = 1303               ← resolver 一直在被呼叫
goal.frontier_empty        = 385
goal.cand_total_batches    = 918                ← 而且【918 批確實有產出候選】
```

⇒ ★**resolver 沒有停、也不是回空** —— **它一直在產候選，只是【再也不產 build 型】。**

## §2 ★★我上一封 over-read，明確收回

我寫：
> ★★判讀：**「不再產生」不成立**

★**錯。逐日計數顯示 day 0 之後真的不再產生 —— 你原本的框架在這一點上是對的。**

★**而且錯得比「結論錯」更難看**：
**我當時手上的證據是「四個 28 全等」，那組數字【完全不含時間資訊】。**
★**我在同一封信裡才剛寫「不能用 first-N 樣本推時間分佈」，
接著就用一組根本沒有時間維度的數字，去否定一個【關於時間】的主張。**
⇒ ★**我要求別人「證據要能支撐該主張」，自己這一封沒做到。**

★**仍然有效的部分我也講清楚**（不因為錯一半就全撤）：
- ✅ `argmax 不是瓶頸`（28 個候選【全部贏了】，零「產生了但輸掉」）
- ✅ `100% 死在建材閘`
- ⛔ `「不再產生」不成立` ← **這句撤回**

⇒ ★**真相是【兩件事同時成立】**：**總量只有 28 ＋ 全部集中在 day 0 ＋ 全部死在同一個閘。**

## §3 下一層母體（不開藥，繼續往上）
候選來自 `GoalResolver.frontier_candidates` → 走 `team.goal_state` 裡 **status == "active"** 的 goal，
label 形狀是 `build_workshop:location` / `build_apothecary:location` / `build_stable:location` / `maintain_material:location`
⇒ ★**全是 `location` prereq。**

★**三種形狀（都待驗，我不挑）**：
1. 那些 goal 在 day 0 之後**不再是 `active`**（完成／放棄／被換掉）
2. goal 還在，但 `_resolve_location_prereq` **之後都回 `{}`**
3. goal 還在，但走進了 `def.has("facility")` 的 `_resolve_build_facility` 分支（★**那條 `continue` 會跳過 prereq 迴圈**）

⇒ ★**下一批 tap 我加【每次呼叫時的 active goal 分佈】＋【location prereq 回空的原因】** ——
**母體是「有幾個 active goal 帶 location prereq」，不是「產出幾個候選」。**
★**我先報母體再說原因。**

## §4 ★對 `factioned` 床那個判讀格的影響
你寫：**infra 路活了之後 `cand_build_emitted` 會不會 > 28**。
★**現在多一個更銳利的問法**：**新床裡 build 候選會不會【出現在 day 0 以外的日子】？**
- **會** ⇒ 供給確實被 faction 層卡住
- ★**不會（仍然只有 day 0）** ⇒ ★**這是【goal 生命週期】的問題，跟 faction 無關** —— 新床也解不了。
★**這個判讀格比「總量」更能分辨兩者，建議一起放進新床的票。**
