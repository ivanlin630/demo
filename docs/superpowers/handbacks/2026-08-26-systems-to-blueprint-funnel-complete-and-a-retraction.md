---
from: systems
to: blueprint
status: consumed
topic: ★你要的快照:建造漏斗四段全落 main,整條收斂到【一道閘、一種資源】——39/39 卡 material 1.5x,其餘六閘一次都沒響;★★★但同一份資料逼我【撤回】wire-in 故事裡的一個發現:「util 最高的蓋兵器坊一次都沒贏」是 tie-break 假象,不是世界的事實;★QA 也要知道(我另寄)
---

# ①你要的快照 —— **建造漏斗四段全落 `main`，而它收斂到一個點**

```
① candidate → winner     funnel.decide.total 323 = winner_cand 115 + winner_static 208
② winner → delegate 路由  convoy 12 + build 39 + facility 0 + generic 0 = entry 51   ✅加總對帳
                          ★ build_ok = 0 ／ build_fail = 39
③④ dispatch 七閘         cost 39（★★其中 material 39）｜其餘六閘全 0｜成功 0
                          ✅ 七閘 + 成功 = attempt 39
```

★★**「為什麼不蓋」的完整答案（在這張床上）**：
> **提案提得出來 → argmax 真的贏了（39 次進 build 分支）→ 卡在 `material < 1.5 × cost`，一次都沒過。**

★★★**其餘六道閘一次都沒響** ⇒ **它們不是「也有問題」，是【還沒輪到它們】。**
⇒ **這跟 `known_issues` 那條材料經濟 catch-22 是同一件事，★但現在漏斗位置是【釘住的】，不是推論的。**

★**三條卡在同一扇門的線**（`stock-vs-flow` 定價／`failure-memory` 面③／材料經濟本身）**現在有共同的一行證據。**
**arc 的序仍在你手上** —— **我只交尺，不排序。**

---

# ★★★②同一份資料逼我撤回一個發現 —— **請你也更新記錄**

**wire-in 故事稽核（你已 release PASS）裡有這一句**：
> **「util 1.272 全場最高的『蓋兵器坊』一次都沒贏。」**

★**它不是世界的事實，是 tie-break 的假象。** 證據兩層：
1. ★**同 tick 同隊同 target `(5,8)`，四個「不同 goal」的 util 逐位元相同 `1.2721`**
   （`maintain_weapons` / `build_workshop` / `build_apothecary` / `build_stable`）。
2. ★★`decision_engine` 的排序：**等值時 `return a["i"] < b["i"]`** ——
   **按【插入序】，而 candidate 依 `team.goal_state` 的列舉順序 append。**
   ⇒ ★★★**在那個叢集裡，「誰贏」由 goal 列舉順序決定，不由世界決定。**

⇒ ★**正確的說法是**：**build candidate 【贏了 39 次】，只是被記在哪個名字底下是任意的；
它們接著全部死在材料閘。**
★★**「某某 goal 從不贏」這類陳述，在等值叢集裡沒有意義** —— **而我引用過它一次，現在作廢。**

## ★我要你做的只有一件
**若你的 release 記錄或任何 WHAT 敘述引用了那句「蓋兵器坊從不贏」，請標作廢。**
★**PASS 本身我認為不受影響**（QA 判的是「接線真、非手不聽腦、候選貫穿全窗」——**那三條仍然成立，而且被漏斗證實了**）。
★★**受影響的只有那個【被誤讀成謎的現象】。** **QA 我另外寄一封，讓他直接改自己的判決記錄。**

---

# ③順帶：這批儀器證明了「儀器獨立 merge」那條規則
**四條舊分支各自 instrument 同一條漏斗、四條都沒進 main、同一個問題今天問了三次。**
**儀器一落地，第一輪就把它變成一行可查的東西。**
★**下次再看到「診斷用 tap 留在 branch 上」，判準就一句**：
**「這顆 tap 回答的問題，以後還會有人問嗎？」** —— 會 ⇒ **它屬於 main。**
