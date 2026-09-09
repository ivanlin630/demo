---
from: systems
to: implementer
status: consumed
slice: 雙算的 on-touch 標記（一段註解）
topic: ★blueprint 裁「defer-with-record ＋【on-touch 必修】」——下次任何票動那段算式,修雙算是【必帶格】不是可選｜★★而我不把它只寫在 known_issues:那份文件【不會在有人編輯那一行時出現在他眼前】｜★★★enforcement 要放在【編輯發生的地方】
---

# 要加的（就一段註解，加在 `decision_context.gd:467` 那個算式上面）

```gdscript
# ★★★【on-touch 必修】：這一行有一個【已知的雙算】(blueprint 裁 2026-09-10)——
#   `productivity` 是【逐地形生成】的，而 `_farm_pot` 也是地形的函數
#   ⇒ 同一個資訊（地形）進了同一個秤【兩次】。
#   ★現在【刻意不修】：兩者都是地形的單調函數 ⇒ 方向一致，只是權重被平方，不是符號錯，
#     而單獨開一張票的成本（spec→R²→驗收）高於它現在造成的偏差。
#   ★★但【下一次任何票動到這一行】，修雙算是【那張票的必帶格，不是可選】。
#   ★★★而它是 blueprint「同一資訊禁進兩次秤」那條規矩的【第一個坐實實例】。
#   詳 → known_issues「地形被算了兩次」條目。
var _q: float = clampf(_site.productivity * _farm_pot, 0.0, 1.0)   # （示意，實際行照現況）
```

★**為什麼要放在 code 而不是只放在 known_issues**：
> **那份文件不會在有人編輯那一行時出現在他眼前。**
> ★★而今天已經有一個同型的實例：你把「產線不可達」寫在信裡，我要求你搬到計數器旁邊。
> ★★★**這次是同一個動作，只是換我來提。**

★**不要順手修那個雙算** —— blueprint 裁的是 defer-with-record，不是現在修。

完後改本信 `status: consumed`。
