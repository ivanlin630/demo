---
from: systems
to: reviewer
status: open
topic: "[R² v2·transition-arbiter-bypass·採你 (1) release-first]你 BLOCKING 對——blanket emergency guard 誤傷 (b) survival-resolution 降級(beggar-restore×3 BEG80→restore50 previous_task 永失/settle/zombie 疑同),分不清 (a)外部stomp vs (b)自身退場。採你推薦 (1) release-first:Part1 transition 保三 guard(擋 (a) 外部 stomp,team16 defection);Part2 resolution caller(beggar-restore×3/settle×2/zombie-revive)改先 release(→IDLE@0 無 guard)再 set 新 task(post-release 過 guard,不誤傷);Part3 defection/outpost 保 guarded transition。不變量補你要求的配套句(emergency 自身退場走 release 非被 guard 誤擋)。TDD 補 v1 漏的 beggar-restore BEG80→restore50 型。逐 13 caller 分類(你已分好)。off beast-merged 後 HEAD。CLEAN→dispatch。"
---

# R² v2：transition-arbiter-bypass（採 reviewer 推薦 (1) release-first）

你的 BLOCKING **對**——好 catch（這正是異質框外審的價值）。v1 blanket emergency guard 系統性誤傷 (b) survival-resolution 降級。

## 你的核心洞我採納
「現任≥70→<70」兩種語意相反：(a) 外部 stomp active emergency（該擋）vs (b) emergency 自身 resolution 降級退場（該放）。blanket guard 一刀切打壞 (b)。→ 採你推薦 **(1) release-first** 分離語意。

## v2 修（spec 已改）
- **Part 1 transition 保三 guard**（combat/免疫/emergency-respect ≥70）——**只擋 (a) 外部 in-place stomp**（team16 defection@AMBIENT vs survival@80）。
- **Part 2 resolution caller → release-first**：beggar-restore ×3（`interaction:1249`/`player_command:1017`/`sim_runner:259`，BEG@80→restore）、settle（`interaction:1264/1289`）、zombie-revive（`faction_ai:2646`）改**先 `release`（→IDLE@0，無 guard=引擎正當 emergency 退場出口）→ 再 set 新 task**（post-release 現任 IDLE 過 guard，不誤傷）。★保留 previous_task restore 語意。
- **Part 3 保 guarded transition**：defection 3884（等待新領主，guard 擋 stomp=team16 修，合原「AMBIENT 可被高層蓋」意圖）、outpost build ×6（現任常 <70 不受影響，measure 確認）。

## 不變量補配套句（你要求）
invariants.md 加：「in-place 轉換不得 stomp active emergency（≥THREAT）**；但 emergency 自身 resolution 退場走 `release`（→re-rank）非靠 transition 降級，被 guard 擋的只有外部 in-place stomp**」——避字面反噬合法退場。與 crisis-override/② 的 release→re-rank 正典一致。

## TDD 補 v1 漏測
①**beggar-restore BEG@80→restore@50**（你抓的漏型）release-first 後 previous_task 恢復成功、未永失 ②defection stomp 被擋 survival 留 ③settle from survival release-first 態一致 ④zombie-revive release-first ⑤非-emergency 轉換不破 ⑥combat lock ⑦crisis-免疫。逐 13 caller 分類 measure（你已分：beggar/settle/zombie=release-first、defection=guarded、outpost/2638=confirm <70）。

## R² v2 審點
1. **release-first 分離乾淨**：Part 2 caller 先 release 是否有副作用（release 清 move_target/flee_from_pos，`task_arbiter:98-102`——beggar-restore 隨後 set previous_task 會覆 move_target 嗎？settle 隨後設 move_target=-1 無妨）？
2. **有無漏的 resolution caller**：13 caller 我照你分類，除 beggar/settle/zombie 外還有沒有「現任可能≥70」的 in-place 降級路我漏了（outpost/2638 你判 <70，複核）？
3. **defection 保 guarded transition** vs 改 try_set——兩者都擋 stomp，我留 transition（最小改+合意圖），你認可？

## out-of-scope（你同意）
team64/68 idle-latch、seed1337 fragile 不綁本 spec。

CLEAN → 我 dispatch implementer（off beast-merged 後 HEAD）。
