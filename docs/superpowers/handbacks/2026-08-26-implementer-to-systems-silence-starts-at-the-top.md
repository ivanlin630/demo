---
from: implementer
to: systems
status: open
slice: funnel-tick-buckets
tier: probe
topic: ★★★沉默的起點定位到了,而且在【最上游】:build 類 candidate day0 生 39 個,day1 起【永遠 0】——而候選總量/決策/candidate 得勝【全部持續到 day30】;⇒ 不是「提了不贏」也不是「贏了不派」,是【再也沒有人提要蓋】;交付 @9015a5eb,fp 不變
---

# 漏斗時間軸 — 落地

| | |
|---|---|
| **worktree / branch** | `A:\GDS\demo\.worktrees\funnel-tick`／`feat/funnel-tick-buckets` |
| **commit** | `9015a5eb` |
| **量測落地** | `docs/measurements/2026-08-26-funnel-timeline-30d.txt` |
| **`fp`** | ✅ **`07285478f6182fbcaf4f6603f0f3f938`**，與 main 相同（純 tap） |
| **對帳** | ✅ **逐日 decide 合計 323 == `funnel.decide.total` 323** |

# ★★★答案：**沉默的起點在【最上游】**
```
day |  cand  build |  decide  win_cand |  deleg  br_build
  0 |    72    39 |     27       13 |    39       39
  1 |    49     0 |     16        9 |     0        0
  2 |     0     0 |     11        0 |     0        0
  …
 27 |    85     0 |     18        5 |     0        0
 29 |    75     0 |     18        6 |     0        0
```
★**`build` 類 candidate：day 0 有 39 個，day 1 起【永遠 0】。**
★★**而其他三欄全部持續到 day 30**：候選總量 49→75（甚至越後面越多）、決策每天都在跑、candidate 每天都在贏。

⇒ ★★★**照你的判準一句話**：**沉默不是「候選生了但不贏」，也不是「贏了但不進 build 分支」——
是【day 1 起再也沒有人提出要蓋】。**
⇒ ★**斷點在 `frontier_candidates` 那一段，不在 argmax、也不在 dispatch。**

## ★這句話同時處置掉兩個先前的讀法
| 先前 | 現在 |
|---|---|
| 「39 次 attempt 全在 tick 10」 | **是 day 0，而且【上游就只生了那一批】** —— attempt 只是忠實反映候選 |
| 「有料的隊從不嘗試」 | ★**那 3-4 隊在 day 1 之後【根本沒有 build 候選可選】** —— 不是它們不想，是沒東西可想 |

★★**我不下「為什麼不生」的結論** —— **那要看 `_resolve_build_facility`／goal 的 satisfied 判定，
是下一次量測（或一次讀 code）的事，不是這顆 tap 的射程。**
★**但可以說一句方向**：**day 0 生、day 1 起不生 ⇒ 像是【某個 goal 在 day 0 之後被判成 satisfied／不再 active】**，
★★★**標為待驗，不進帳。**

# ★形狀（照你要的）
- **日分桶**：`funnel.{cand,cand.build,decide,decide.winner_cand,delegate.entry,delegate.branch_build}.day.NNN`
  ⇒ ★**key 有界（一天一個，不是一 tick 一個）。**
- **分母也上時間軸**（`decide.day`）——★**否則「今天贏 6 次」算不出比例。**
- **床印四欄並排**：★**哪一欄先變 0，沉默就從那一段開始** —— **這是判準本身，不是我事後解讀。**
- ★**整天零決策的日子不印**（省版面），★**但逐日合計與總數對帳，確保沒有靜默漏桶。**

# ★下一步
★**照慣例停。** ★★**若要追「為什麼 day 1 起不生」，我建議的下一顆是**：
**在 `frontier_candidates` 對【被跳過的 goal】記一筆原因**（`status != active`／`def.is_empty()`／
`_resolve_*` 回空），★**逐日分桶** —— **那會直接指出是「goal 沒了」還是「goal 在但解不出候選」。**
★★★**我沒有自己開** —— **等你派。**
