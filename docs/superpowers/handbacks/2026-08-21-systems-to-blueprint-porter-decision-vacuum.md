---
from: systems
to: blueprint
status: consumed
topic: "[★一個願景層問題(非 systems 可裁)+一則帳目誠實·①CONVOY porter 在運輸整趟【完全沒有決策】:faction_ai:761-762 子隊一律走 _evaluate_subteam、:2753-2756 對 TASK_CONVOY 直接早退 ⇒ 不進任何決策路徑;specimen 坐實(追逐窗 20 筆 = reaction 10+heartbeat 10、decision 0)·reaction 層仍在跑所以不是完全無反應,但『運輸中的隊伍該不該有決策能力』(遇襲改道?瀕餓就地覓食?)是願景層問題,交你·②連帶帳目誠實:convoy RETURN 那刀的 gate 4(survival 仍可搶)與 gate 8(persist.hold 對 CONVOY 真 fire)【都只有合成床證據、live 結構上不可達】——沒人呼 try_set 就沒有 hold 可談、沒人嘗試就沒得搶;改善 27.9→9.2/1.3 日【100% 來自 merge_queue 根因修】,我那條 T1 功勞是 0,已寫進 spec §6 不讓錯誤結論留在檔面上·★這不影響 merge 決定(根因修是真的),但你若據此排後續要知道 T1 那條線目前是死的"
---

# 一個願景層問題 + 一則帳目誠實

## ① CONVOY porter 在運輸整趟**完全沒有決策**（交你裁）
`faction_ai:761-762` 子隊一律走 `_evaluate_subteam`；`:2753-2756` 對 `TASK_CONVOY` **直接早退**
⇒ porter **不進任何決策路徑**。specimen 坐實（追逐窗 tick 3600–4600）：
porter_12 共 20 筆 ＝ **reaction 10 ＋ heartbeat 10、decision 0**。

**reaction 層仍在跑**，所以 porter 不是完全無反應。
但「**運輸中的隊伍該不該有決策能力**」——遇襲改道？瀕餓就地覓食？繞開危險地形？——
**是願景層問題，不是我能裁的。** 已記 `known_issues`，交你。

## ② 連帶的帳目誠實
convoy RETURN 那刀的 **gate 4（survival 仍可搶）** 與 **gate 8（`persist.hold` 對 CONVOY 真 fire）**
**都只有合成床（TDD）證據、live 結構上不可達**——**沒人呼 `try_set` 就沒有 hold 可談，沒人嘗試就沒得搶**。

⇒ **`27.9 → 9.2/1.3` 日的改善 100% 來自 `merge_queue` 的 rehome 根因修**，
**我那條 T1（`PROGRESSIVE_HOLD_TASKS += TASK_CONVOY`）功勞是 0**。已寫進 spec §6，**不讓錯誤結論留在檔面上**。

★ **這不影響 merge 決定**（根因修是真的、獨立驗證過），
但**你若據此排後續，要知道 T1 那條線目前是死的**——它要等到子隊走一般決策才會活。
