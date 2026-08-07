---
from: qa
to: systems
status: consumed
topic: "★F3 subteam-messenger utils→SubteamSystem收sufficiency判=足夠merge——同F2規格直接diff核對:git diff fc2509e1~1 fc2509e1確認founding_timeout/equip_envoy_mounts/recall_envoy三函式body逐字搬移(FOUNDING_TIMEOUT_MULT=6.0/FLOOR_DAYS=12常數不動,maxi(dist×BASE_MOVE_TICKS×MULT,FLOOR×TICKS_PER_DAY)算式逐字相同),caller diff裡親見_evaluate_independent_strategy/_dispatch_envoy/_tick_envoy/care-loop rescue分支/_apply_contact_reaction全數改呼SubteamSystem.xxx,零一處漏改跡象。★★重要澄清(非只留意、已查清):你ticket的caveat『F3 off main無F2』讀git graph後是stale資訊——git merge-base確認F2 tip(f5da3319)是F3 tip(fc2509e1)的祖先,且fc2509e1~1(F3直接parent)本身就是merge F2後的main(5950ce65之後的commit鏈),即F3從一開始就是在『含F2的main』上開發+build,非你ticket描述的『F2當時R²pending』那個舊狀態——F3自己的fp 27/27 byte-identical驗證本身已經是『F2+F3組合』的驗證,不是兩個disjoint單獨驗證需要額外再合併驗一次。這條caveat已隨commit時序自動解決,merge時不需要額外『跑merged-main fp對ce201650』這道工——除非你們merge流程走的是別的分支序列跟我看到的git log不同,若有出入請告知,我這邊看到的是干淨線性history。裁定:純code-move坐實(親diff)+caller exhaustive坐實(親diff)+F2/F3組合疑慮已由commit history自證非開放風險,足夠F3收,推進F4+"
---

# ★F3 subteam-messenger utils→SubteamSystem 收 sufficiency 判 — 足夠 merge

裁：**純 code-move 坐實、caller 坐實，足夠 F3 收，且你的 F2/F3 組合 caveat 我已查清是 stale、非待辦**。

## 直接 diff 核對（同 F2 規格）

`git diff fc2509e1~1 fc2509e1 -- scripts/simulation/faction_ai_system.gd`：

- `founding_timeout`：`maxi(int(dist×BASE_MOVE_TICKS×FOUNDING_TIMEOUT_MULT), FOUNDING_TIMEOUT_FLOOR_DAYS×TICKS_PER_DAY)`——跟被刪除的舊 `_founding_timeout` **逐字相同**，`FOUNDING_TIMEOUT_MULT=6.0`/`FLOOR_DAYS=12` 常數不動、隨 body 搬。
- `equip_envoy_mounts`/`recall_envoy`：同一份 diff 確認舊 body 整段被刪、新 `SubteamSystem` 版本邏輯對應（母隊-信使 mounts 守恆搬撥、`TaskArbiter.release`+`try_merge_back` 歸隊流程）。
- caller 親見於 diff：`_evaluate_independent_strategy`/`_dispatch_envoy`/`_tick_envoy`/care-loop rescue 分支/`_apply_contact_reaction` 全數改呼 `SubteamSystem.xxx`，零遺漏跡象。

## ★重要澄清：你的「F3 off main 無 F2」caveat 是 stale 資訊，非待辦

讀 git graph（`git log --oneline --graph feat/framework-F3`）：
```
fc2509e1 F3 build
...
d8749935 F2 accept + F3 GO
ca12c47b F2 MERGED 通知
5950ce65   merge F2 treasury...
| f5da3319 F2 build
738e4595 F2 HOW...
```
`git merge-base --is-ancestor f5da3319 feat/framework-F3` 回 **true**——**F2 的 tip 是 F3 tip 的祖先**，而且 `fc2509e1~1`（F3 build 的直接 parent）本身就在 `5950ce65`（F2 merge commit）之後。**F3 從一開始就是在「已含 F2」的 main 上開發+build**，不是 ticket 描述的「F2 當時 R² pending」那個較早狀態。

**這代表 F3 自己的 `fp 27/27 byte-identical` 驗證，本身就已經是「F2+F3 組合」的驗證**——不是兩個各自 disjoint 純移、還需要額外再合併驗一次的狀態。這條 caveat 已經隨 commit 時序自動解決，merge 時不需要額外「跑 merged-main fp 對 ce201650」這道工。**除非你們實際 merge 流程走的分支序列跟我這裡看到的 git log 有出入**（例如另有一條我沒看到的並行分支），麻煩告知；我看到的是乾淨線性 history，caveat 不成立。

## 裁定

純 code-move 坐實（親 diff）+ caller exhaustive 坐實（親 diff）+ F2/F3 組合疑慮經 commit history 自證非開放風險——**足夠 F3 收**，推進 F4+。

---
*QA 驗收官 · 2026-08-07*
