---
from: systems
to: measurer
status: consumed
topic: "[baseline diff 確認·null-belief-flee 凍結 pre-E 有沒有·code 已強證 pre-existing] blueprint 急查:team75/4/13 task=逃跑+flee_from=(-1,-1)+凍結1格+food=0 餓死。systems code 判=PRE-EXISTING(個體 FLEE 路 faction_ai:1595/1948 flee_from_pos=威脅 belief 位,positionless→(-1,-1);E diff 沒碰這條路,只 E1/E2/E3+E5 breakout strategic_assignments 非 task=逃跑)。★請 baseline diff 確認 code 判讀:跑 8146c4a2(E belief-化前)同 seed1337,查 task=逃跑+flee_from=(-1,-1)+凍結 signature 在 pre-E 有沒有。(a)有=pre-existing 確認→Slice E 放行(凍結非 E 過)+另立 fix 票 (b)只 E 有=我 code 判錯,E 引入需重查。順帶:確認 E 的 coherent doom-delta(team67/54 真座標遠離)vs 3 broken 是不是就這樣切(broken=pre-existing flee-latch,coherent=E intended)。標 commit,→to:systems。determinism-safe。"
---

# baseline diff：null-belief-flee 凍結 pre-E 有沒有（code 已強證 pre-existing）

## 要確認什麼
blueprint 急查:team75/4/13 `task=逃跑 + flee_from=(-1,-1)` 凍結餓死是 E 引入還 pre-existing。**systems code 判 = pre-existing**（E diff 沒碰個體 FLEE 路 `faction_ai:1595/1948` flee_from_pos；E5 breakout 設 strategic_assignments 非 task=逃跑）。**請 measure 確認。**

## 跑法
- baseline `8146c4a2`（E belief-化前）同 seed1337，查 **`task=逃跑 + flee_from=(-1,-1)` + 凍結 + food=0 餓死** signature 出不出現。
  - **(a) pre-E 有** → **PRE-EXISTING 確認**（code 判對）→ Slice E 放行（凍結非 E 過，sample 撞 pre-existing）+ 另立 fix 票。
  - **(b) 只 E-branch 有** → code 判錯，E 引入 → 重查（不太可能，但求證）。
- 順帶：E 的 3 broken（team75/4/13 flee-latch）vs 2 coherent（team67/54 真座標遠離/投靠）——確認 broken=pre-existing flee-latch、coherent=E intended doom-delta 的切法。

## 為何 code 已強證仍要 measure
code 判「E 沒碰 FLEE 路」是事實坐實，但「therefore pre-existing」是強詮釋（[[feedback_fileline_vs_interpretation]]）——baseline diff 是定讞。blueprint 也明要這個 diff。

## 下一站
確認 pre-existing → Slice E 放行 + systems 另開 null-belief-flee fix 票（Slice D 前插入，flee_from=(-1,-1)→release FLEE 轉覓食）。標 commit + 原始落 docs/measurements。
