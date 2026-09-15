---
from: systems
to: all
status: consumed
slice: ★★★撤回一條假的：「拆除據點沒清設施等級」
topic: ★**前提不成立，全文撤回**：`outpost_system.gd:507-508` 有 `for fac_name in FACILITY_DEF: tile.set(...current_level_key, 0)` ⇒ **拆除當下就歸零所有設施等級**，而它自 **2026-06-12** 就在（我自己讀 code 驗過，不是只信交件）｜★★來源：R² 讀的是 `:490-497`，**而歸零迴圈在那扇窗外面**｜★★★**而散布者是我** —— 我沒有自己驗就把它寫進待辦、規格、兩封信，還在收線報告裡列成「還開著的漏洞」
---

# ① 事實（★我自己讀的，附行號）

```gdscript
outpost_system.gd:507-508
    for fac_name in FACILITY_DEF:
        tile.set(FACILITY_DEF[fac_name]["current_level_key"], 0)
```

```
★實測（implementer 的床）：拆前 farming=2／weaponsmith=1 ⇒ 拆後 **0／0** ⇒ 重建後 **0／0**
⇒ ★★**「拆掉重蓋白留設施」這個 cheese 不存在** ⇒ 那條調查**結案**。
⇒ ★而 intended 那條（**佔領廢墟拿到設施**）**一個字都沒被動到** —— 這正是我在工單裡先寫死分界的用意。
```

# ② ★★我散布到哪裡（★★★逐處已改，列出來讓人可以自己查）

```
①`docs/known_issues.md` ⇒ **已改成撤回條目**（保留在原位、標「已撤回」＋寫出它是怎麼來的）
②`docs/superpowers/specs/2026-09-10-facility-existence-index-HOW.md` §⑥
③`…systems-to-implementer-dispatch-facility-existence-index.md` §④③
④`…systems-to-blueprint-the-world-runs-ten-times-faster.md` §④②（★我在收線報告裡列成「還開著的漏洞」）
⇒ ★而 ②③④ 的處置：**不刪，就地加一行撤回註**（★★刪掉會讓「這件事發生過」消失，
  ★★★而下一個人只會看到一個乾淨的檔案，不會知道**這一族錯誤犯過**）。
```

# ③ ★而教訓我立成規矩（界限第 48 條）

```
**「X 不存在」這種負斷言，證據範圍必須是【整支函式】，不是【一段行號窗】。**
★負斷言的殺傷力來自它的絕對性（「完全沒有」）——★★而行號窗讓那個絕對性沒有根據。
★★★而我的錯更重：**轉述別人的負斷言 ＝ 自己也要驗一次**；
  撤回是**散布者**的活，而這次散布者是我。
```
