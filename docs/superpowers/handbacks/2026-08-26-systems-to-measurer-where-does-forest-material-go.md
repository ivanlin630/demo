---
from: systems
to: measurer
status: consumed
slice: material-funnel-unlock
tier: probe
topic: ★★★一個三選一的問題:森林 material 每格初始 80-220、再生 12/日,而隊手上 0-20 —— 它是【採不到】、【採到了被消耗掉】、還是【採到了但沒進公庫】?;★這題會決定下一個 arc 的 A 件該不該做,所以判準寫死在票裡
---

# ★問題（**一句話，三選一**）

```
world_generator.gd:10    forest 初始 material = [80, 220] / 每格
resource_system.gd:44    forest material 再生 = 12.0 / 日
── 而隊手上 ──
avail = 0（21 筆）／20（9 筆），需要 50
avail 的定義（faction_ai_system:3821-3827）
   ＝ 站在自家 outpost 上的 tile.public_storage ＋ leader_team.resources
```
⇒ ★**世界不缺 material，缺的是它到不了隊手上。**

> ★★★**要你回答**：**它是【採不到】、【採到了被消耗掉】、還是【採到了但沒進 `public_storage`】？**

---

# ★要量的四個點（**每一段都要有分母，同建造漏斗那套**）
| # | 問題 | 建議看什麼 |
|---|---|---|
| 1 | **有沒有人去採？** | `maintain_material` 這類 goal 有沒有被選為 winner／`TASK_GATHER` 之類的實際 task 次數 |
| 2 | ★**採了多少？** | `collect_resources` 對 material 的實際產出（`collect.*` 既有 tap；★**若沒有 material 專屬的，回報缺口，不要自己加**） |
| 3 | ★★**採到的進了哪裡？** | **private（`team.resources`）vs 公庫（`tile.public_storage`）** —— ★**這兩個是不同的池，而閘只認「站在自家 outpost 上的公庫 ＋ leader 私產」** |
| 4 | ★★★**進來的又出去了多少？** | material 的**流出**（消耗／交易賣掉／稅）—— ★**存量恆低有兩種：沒進來，或進來又走了。這兩種的處置完全相反。** |

---

# ★判準（寫死，不要另行詮釋）
- ★**這題【不是】是非題，是【三選一 ＋ 比例】** —— **報每一段的數字，不要只報結論。**
- ★★**若某一段沒有現成 tap** ⇒ ★**回報「這段量不到、缺什麼 tap」，不要用鄰近數字推。**
  **同你上次做的：「我只到 file:line 坐實機制存在，沒有逐筆資料就不宣稱因果。」**
- ★★★**若答案是「採到了但沒進公庫」** ⇒ **那會推翻下一個 arc 的 A 件（拉高初始庫存）** ——
  **照原樣回報就好，推翻誰不是你的事。**
- **母體**：★**報母體，並標明樣本／cap**（`bump_sample` 若 `樣本數 == cap` 就是 first-N，明講）。

# ★床
**同建造漏斗那張（`peaceful_economy` / `seed 1337` / 30 天）** —— ★**同床同 seed，才能跟漏斗那四段對得起來。**
**跑 `main`（現在含完整漏斗儀器）。可溯源照舊。**
