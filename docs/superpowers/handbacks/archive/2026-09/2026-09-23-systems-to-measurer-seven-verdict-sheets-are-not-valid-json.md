---
from: systems
to: measurer
status: consumed
slice: 卷面衛生 — 7 份 .measure.json 不是合法 JSON
topic: ★148 份 `docs/process/verdicts/*.measure.json` 裡有 **7 份 `json.load` 失敗**（逐份附 line:col 與錯誤字串）｜★★**而它們全部也缺 `is_sim`** ⇒ 就算修好格式，`verification_gate` 裁定#2 仍會判 FAIL ⇒ **是兩件事要一起做**｜★★★**查得出它的閘【存在且早就寫好了】**（`verification_gate.gd:69` 逐字「.measure.json JSON parse error」），**但 `pre-push` 只用 `--slice=<本分支>` 叫它** —— 註解自己寫「branch-scoped 免 stale 誤擋」⇒ **全量模式從來沒跑過，而這 7 份正是它會擋的東西**
---

# 一、七份（★逐份附 `python json.load` 的原話）

```
desperation-violence-cell.measure.json          Expecting ':' delimiter: line 58 column 114
S2-before-7items-final.measure.json             Expecting ':' delimiter: line 4  column 70
S2-manufacture-three-bucket-probe.measure.json  Expecting ':' delimiter: line 32 column 139
S2-mergedbase-purity-final.measure.json         Expecting ':' delimiter: line 20 column 3
S2-purity-final.measure.json                    Expecting ':' delimiter: line 6  column 143
S7-lod-production-neutrality.measure.json       Expecting ':' delimiter: line 22 column 104
S7-tracer-fp-divergence.measure.json            Expecting ':' delimiter: line 12 column 3
```

★**七份是同一個錯誤類別**（`Expecting ':' delimiter`）⇒ 幾乎一定是**字串裡有沒跳脫的 `"`**
（這幾份的 key／value 都是長中文句子，裡面很容易夾一對引號）。

★★**我沒有動它們**：卷面是你的產物，**而我改它＝改記錄下來的數字的載體** ——
即使我只碰標點，**下一個讀的人也分不出我動過什麼**。

# ★★二、第二件事：七份**都缺 `is_sim`**

```
verification_gate.gd:72-74 裁定#2：active verdict 缺 is_sim → FAIL（measurer 必設 true/false）
⇒ ★所以「修好 JSON」之後它們仍然會紅 —— ★★兩件事要一起做，否則你會修一次、紅一次
★★★而這七份的日期（2026-08-27 ～ 2026-09-17）跨在裁定#2 前後
   ⇒ 判 is_sim 的依據是【那一輪到底有沒有跑模擬】，那件事只有你知道
```

# ★★★三、為什麼沒有人發現（★這一段比那七份重要）

```
scripts/debug/verification_gate.gd:41-47   會掃【所有】active *.measure.json
:69  fails.append("%s: .measure.json JSON parse error")      ← ★偵測早就寫好了
scripts/hooks/pre-push:44-50
  branch=…; slice=…; measure="docs/process/verdicts/${slice}.measure.json"
  if [ -f "$measure" ]; then  … --slice="$slice"             ← ★★只掃【本分支自己那一份】
  註解逐字：「branch-scoped 免 stale 誤擋」
```

★**所以這不是「沒有閘」，是【閘被刻意縮到只看自己那一格】** ——
★★**而那個縮法本身是對的**：全量模式今天一跑就會擋住**所有人的 push**（七份 stale 的紅）
⇒ ★★★**「先修乾淨再放寬掃描範圍」與「先放寬掃描範圍逼人修」是兩種順序，
而第二種會讓一個跟你這次改動無關的紅燈擋在你面前** —— 我不選第二種。

★**而我【不加新閘】**（用戶 2026-09-10 立規：已有 hook 覆蓋的不准再加第二支）。
⇒ **這七份修完之後，「要不要把 `pre-push` 放成全量」是一個獨立問題，我到那時才談。**

# 四、我要你做什麼

```
①七份逐份修成合法 JSON（★只動格式，不動任何數字；★★改動處請在 commit 訊息裡逐份列出來）
②同一輪補 is_sim（true/false 依那一輪有沒有跑模擬）
③修完回我一行：`python -c "json.load"` 七份全過 ＋ 148 份全過
★不急：這七份都是 stale 卷面，不擋任何在飛的票；★★而機器現在在實作端手上，這件事不需要 Godot
```

★**誠實限**：我是用 `python json.load` 掃的，**不是 Godot 的 `JSON.parse_string`**。
★★兩者對「沒跳脫的引號」應該一致，**但我沒有驗過它們在這七份上給同樣的答案** ——
你修完若想更保險，用 `verification_gate.gd` 不帶 `--slice` 跑一次（那是真正會判它的那支）。
