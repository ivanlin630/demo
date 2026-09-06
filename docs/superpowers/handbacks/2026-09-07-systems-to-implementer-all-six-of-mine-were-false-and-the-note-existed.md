---
from: systems
to: implementer
status: open
slice: ★★★我列的六支【全是誤判】，而其中一支是【六天前就寫下這個 bug 的那句註解】
topic: ★你量的對:`TeamData × 未執行` = 【1 站】(data_test.gd:26);★★而我列的六支我逐檔看過,【六支全錯】:game_sim_test:488 與 threat_oracle_s15:50 與 gather_purity_probe_bed:81 是【字串字面值】、seam1_registry(3 站)與 survival_stall_ladder(2 站)是【DecisionContext】、★★★而 s6_build_days_truth:51 是【一句註解】—— 而那句註解的內容是:「不能寫 team.population = pop:那顆是【唯讀衍生】(team_data.gd:55-59,setter 是 pass)」,寫於 2026-09-01(dc95079a)⇒ ★比今天早【六天】,有人早就發現並寫下來了;★而我的 grep 把【那句警告本身】算成了一筆病例;★★所以「刪不是改」最後只適用於【一行】,而我們為了得到這個數字走過 107→58→56→53→52→32→1
---

# ★一、我列的六支，**逐檔看過，六支全錯**
```
game_sim_test:488          "Team%d.population=%d<1" % [...]        ← ★字串字面值
threat_oracle_s15_test:50  "★確非 god-view（other.population=100…" ← ★字串字面值(assert 訊息)
gather_purity_probe_bed:81 "  team.population=%d" % team.population ← ★字串字面值(輸出格式)
seam1_registry_test:47/88/102   c.population / c1.population        ← ★★DecisionContext
survival_stall_ladder_test:66/79 c.population / c2.population       ← ★★DecisionContext
★★★s6_build_days_truth:51   —— 一句【註解】(見下)
```
⇒ ★**所以你量的是對的**：`TeamData × 未執行` = **1 站**（`data_test.gd:26`）。

# ★★★二、而 `s6_build_days_truth:51` 那一筆值得單獨講
```gdscript
# ★★★不能寫 team.population = pop：那顆是【唯讀衍生】(team_data.gd:55-59，setter 是 pass)
```
```
★寫於 2026-09-01(dc95079a)⇒ ★★比今天早【六天】
⇒ ★★★有人早就發現這個 bug、也把成因寫對了(連行號都對)——而它【只是一句本地註解】
⇒ 沒有任何機制把【一個本地發現】變成【全庫的守衛】
⇒ ★而我的 grep 在數病例時,把【那句警告本身】算成了一筆病例
```
★**而這正好說明今天做的那兩支閘是對的**：
★★**`computed-prop-write-guard`（你的）＋ `swallow-setter-gate`（我的）就是那個缺席的機制** ——
★★★**它們會把一句本地註解變成【下一個人寫錯時就會紅】。**

# ★★三、數字的一生（★而每一步錯的都是同一件事）
```
107 → 58 → 56 → 53 → 52 → 32 → ★1
成因依序:①把 `==` 當賦值 ②樹裡有觀測者自己的檔 ③沒過濾接收者型別
        ④字串字面值 ⑤註解
⇒ ★★而它們是【同一件事】:grep 在數【文字】,而問題問的是【語言層的賦值】
⇒ ★★★我在中途就寫過這句(「grep 原理上答不了」),★然後又用 grep 生了兩個數字
```
★**所以我的處置改成**：★★**這一格我不再出靜態數** —— **要數字就用你那個掛在 setter 上的計數器。**

# ★四、實務結論（★縮到很小了）
```
①10 支 DIRTY 床:改走合法路徑,★驗收要有【pop 真的非 0】的證據
②★TeamData × 未執行 = 【1 行】(data_test.gd:26)⇒ 刪,並留一句「這裡原本…從來沒有執行過」
③DecisionContext 那些:★★【一行都不要動】
④★★★而 stage B 從「27 支床的機械修」縮成【10 支修 + 1 行刪】
```
