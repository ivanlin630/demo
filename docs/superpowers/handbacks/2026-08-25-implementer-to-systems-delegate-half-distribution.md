---
from: implementer
to: systems
status: consumed
slice: goal-delegate-build-diag
branch: feat/goal-delegate-build-diag @ WIP (worktree 新開,不污染待 merge 的磚)
topic: ★第二半分佈出來:四個 28 完全相等(cand_build_emitted=branch.build=build_fail=dispatch_fail.資源不足)⇒【每一個產生的 build 委派候選都贏了 argmax、都走到委派、都卡在建材閘】;★★「不再產生」不成立,真相是【產生的總量就只有 28,而且 100% 死在同一個閘】;★我【不宣稱】只在 tick 10——樣本是 first-N,天生只顯示最早那批,逐日計數跑中
---

# 第二半：分佈（★只報分佈，不開藥）

**床**：`goal_delegate_diag_bed`（`peaceful_economy` / seed 1337 / 90 天，窗尾 `day 90/90` 已確認）
**branch**：`feat/goal-delegate-build-diag`（★**新開 worktree** —— 磚正在等 merge 判定，診斷 tap 不進那條）

## §1 三層分開報

```
①上游  goal.cand_build_emitted    = 28
②入口  delegate.entry             = 43   ├ branch.build    = 28
                                          ├ branch.convoy   = 15
                                          ├ branch.facility = 0
                                          └ branch.generic  = 0
③結果  delegate.build_ok          = 0
        delegate.build_fail        = 28
        dispatch_fail.資源不足        = 28
```

## §2 ★★判讀：**「不再產生」不成立**

★**四個 28 完全相等**：`cand_build_emitted` ＝ `branch.build` ＝ `build_fail` ＝ `dispatch_fail.資源不足`。
⇒ ★**每一個被產生的 build 委派候選，都贏了 argmax、都走到委派、都卡在建材閘。**
⇒ ★**沒有任何一個是「產生了但輸掉」** —— **argmax 完全不是瓶頸。**

★**所以你問的「為什麼不再產生」，前提要修正**：
**不是「產生了一批之後停下來」，而是【產生的總量就只有 28】，而且【100% 死在同一個閘】。**

★**這也讓兩半接起來了**：**磚那邊量到的 28 筆前提型 `blocked.material`，就是這同一批。**
（★**兩張床、兩個 branch、同一組 28** —— 我不主張它們是同一個世界的同一批事件，
**但形狀與數量完全吻合，且都是 `dispatch_fail.資源不足`。**）

## §3 ★我【不宣稱】「只在 tick 10」

樣本裡 12 筆全是 `tick 10`：
```
{"delegate":true,"label":"build_workshop:location:delegate","team":0,"tick":10,"util":1.2721}
```
★**但 `bump_sample` 是 first-N，不是均勻取樣** ——
★**它【天生只會顯示最早那批】。拿它證明「只在 tick 10」＝ 拿取樣偏差當結論。**

⇒ ★**已加【逐日計數】`goal.cand_build_day.<day>`**（真分佈，不是樣本），跑中，回來補報。
★**同時加了母體兩欄**：`goal.frontier_calls`（resolver 有沒有被呼叫）／`goal.frontier_empty`
—— **沒有它們，「build 候選 = 0」分不出「resolver 沒跑」與「跑了但不產 build」。**

## §4 ★一個不能比的對照（免得被誤用）
本床 `outpost.l0_to_l1 = 1`、`construct.start 21 / complete 18`；
磚那張床是 `l0_to_l1 = 0`、`19 / 19`。
★**兩者【不可比較】** —— 不同 branch、不同 code ⇒ 不同世界。
**我把它們並列只是各自的現況，不是 A/B。**

## §5 待補
逐日分佈 ＋ resolver 母體兩欄。★**若逐日顯示 build 候選【真的只出現在早期幾天】，那才是「不再產生」的證據**；
**若它每天都有、只是總量小，那就是另一個故事。我等數字。**
