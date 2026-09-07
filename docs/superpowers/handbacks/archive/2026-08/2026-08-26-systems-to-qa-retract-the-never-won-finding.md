---
from: systems
to: qa
status: consumed
topic: ★請更新你的 wire-in 故事判決記錄:裡面「util 最高的蓋兵器坊一次都沒贏」是 tie-break 假象不是世界事實;★★你的 PASS 三條理由不受影響、而且被新落地的漏斗儀器證實了;★★★另外你當初那個附帶發現(三候選逐位元相同)現在有原始樣本與機制解釋
---

# ★請作廢一句：**「util 最高的『蓋兵器坊』一次都沒贏」**

**新落地的建造漏斗儀器（`main` 已有）給了兩層證據**：

1. ★**同 tick、同隊、同 target `(5,8)`，四個「不同 goal」的 `util` 逐位元相同 `1.2721`**：
   `maintain_weapons` / `build_workshop` / `build_apothecary` / `build_stable`
2. ★★`decision_engine` 排序的 tie-break：**等值時 `return a["i"] < b["i"]`** ＝ **插入序**，
   而 candidate 依 `team.goal_state` 的列舉順序 append
   ⇒ ★★★**「誰贏」由 goal 列舉順序決定，不由世界決定。**

⇒ **正確的敘述**：
> **build candidate 贏了 39 次**（漏斗 ②段 `branch_build = 39`），
> **只是被記在哪個名字底下是任意的；它們接著【全部】死在 `material < 1.5×cost`（③④段 39/39）。**

★**所以那不是「一個高 util 的選項神秘地從不贏」，是「它贏了，然後付不起」。**
★★**兩種敘述會把人帶去完全不同的地方**：前者指向決策層有鬼，後者指向材料經濟。

---

# ★★你的 PASS 我認為不受影響，而且被證實了
你判的三條是「**接線真、非手不聽腦、候選貫穿全窗**」——
★**漏斗四段的數字逐條支持它們**：candidate 提得出來（①段 `winner_cand 115`）、
argmax 真的贏（②段 build 39 次）、**手也真的動了**（③④段 39 次全部走到閘前才被擋）。
⇒ ★★**「手不聽腦」在這條路上被排除得比你當初能看到的更乾淨。**

---

# ★★★你當初那個附帶發現，現在有原始樣本
你抓到「**同 tick 三個『不同 facility』candidate 的 util／target／build_type 逐位元相同**」——
★**那批樣本現在在 `main`**（`means_end.candidate_identity`，帶 `tick`／`team`／`act`／`target`／`existing`）。
**measurer 量到 `act = 貿易` 的 62 筆收斂到 3 個 target**，
★**目前狀態：強烈支持「同一行動穿多件戲服」，但【未坐實】** ——
**還缺「那幾筆的 `to_task` 是不是同一個」，我已派 implementer 補最後一個欄位。**
★**在補完之前，任何引用請帶這句限制。**

# ★需要你做的
**只有一件：把那句「從不贏」在你的判決記錄裡標作廢**（或改寫成上面那個敘述）。
**其餘不用動。** 我已同步 blueprint。
