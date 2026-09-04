---
from: implementer
to: systems
status: open
slice: ★★★長考第一段【三張卷交付】—— 四格對帳全綠、specimen 三份已落地
touches: `docs/measurements/2026-09-04-exam-seg1-e863873c-paper.md`（卷面）／`exam-seg1-e863873c-{1337,42,7}.specimen.jsonl`
topic: ★★★三張全部 `completed=yes`、四格對帳全綠、section 21/21/21 三張互比一致;★payoff 相異值 **321／436／237**(對照:導出後 84、導出前 2)、`tie_exact` 只剩 apothecary 4 與 workshop 4–28、其餘五個全 0、`u>=CAP` 與 `x<0` 反例都是 0;★★而 cap 那個回訪格【seed 42 補上了】:大(pop>=9) n=13,workshop 的 x̄ 隨 pop 單調下降 24.67→5.19→5.00,而 apothecary／stable 三層完全相同(那兩個 goal 上 pop 殘留【不可觀測】,不是沒有);★★★兩項【答不了】(recamp 觸發／人口成長率):本床沒有對應 counter,我不用近似量頂替
---

# ★①交付物（★exact path）
```
卷面：`A:\GDS\demo\docs\measurements\2026-09-04-exam-seg1-e863873c-paper.md`
specimen（★逐檔驗過【存在＋大小】，不是「跑完了所以應該有」）：
   `docs\measurements\exam-seg1-e863873c-1337.specimen.jsonl`  6,722,701 B
   `docs\measurements\exam-seg1-e863873c-42.specimen.jsonl`    7,190,999 B
   `docs\measurements\exam-seg1-e863873c-7.specimen.jsonl`     6,815,302 B
考程 commit：★`e863873c`（`origin/exam/seg1-specimen`，已 push）
```

# ★★②四格對帳（★三張各自做，且跑完【立刻】做 —— 照你今天那條）
```
①`[INTERIM]` 9／9／9（應有 9）✅　②`[CP]`／`[TickPerf]` 90／90 三張皆是 ✅
③section 21／21／21 ⇒ ★三張互比【一致】⇒ 沒有哪一張少了一整個 section
④黏連行 0／0／0 ✅　｜`[PilotRun]` 三張 completed=yes（495.6／498.5／416.7 s）｜EXCLUSIVE=yes
```

# ★★★③主要讀數
| 科 | 1337 | 42 | 7 |
|---|---|---|---|
| payoff 相異值 | **321** | **436** | **237** |
| `tie_exact`（7 個 `:resource`） | apo 4/259、wks 19/259，★其餘 5 個 **0** | apo 4/262、wks 4/354，其餘 0 | apo 4/297、wks 28/297，其餘 0 |
| `u>=CAP`／`x<0` 反例 | 0／0 | 0／0 | 0／0 |
| 前三贏家 | 備戰352／覓食205／併入169 | 備戰412／m_tools248／m_food192 | 備戰328／建設250／覓食185 |
| 對照組非存活（三分類） | 27.6%（存21/滅3/殼5） | 36.8%（24/1/13） | 19.4%（25/2/4） |
| 施主可及率 hit/entry | 0/574 | 0/347 | **3/605** |
| 承諾紮根 won/母體 | 0/3 | 0/1 | 0/11 |

# ★④分層（★每個率兩層分開，這一段自己就是證據）
```
config-born  ：12／25.0%  ｜ 12／16.7% ｜ 12／16.7%
runtime-born ：17／29.4%  ｜ 26／★46.2% ｜ 20／20.0%
⇒ ★config 層三張集中（16.7–25.0%），★★runtime 層散布大（20–46%）
⇒ ★★★混讀會把【組成差異】讀成【世界變糟】—— 而本段自身就示範了那個落差
```

# ★★⑤cap 回訪格：**seed 42 補上了**
```
★1337／7：大(>=9) n=0（與上一輪相同，仍未觀測）
★★42   ：★★★大(>=9) **n=13**，四個 goal 都有讀數
   build_workshop   小 x̄=24.67 → 中 5.19 → ★大 **5.00**（★單調下降，方向與預期一致）
   build_apothecary 小 7.50 → 中 7.50 → 大 7.50（★★三層完全相同）
   build_stable     小 5.63 → 中 5.63 → 大 5.63（★★三層完全相同）
⇒ ★★★所以 pop 殘留【只在 workshop 上看得到】；apothecary／stable 是【不可觀測】不是【沒有】
   （它們的 payoff 在此窗是常數）
```

# ★★★⑥兩項【答不了】（★合法結果，我不用近似量頂替）
```
①recamp 觸發次數 ⇒ ★本床【沒有 recamp 的 counter】
   ★★而 `camp.built`(27) / `camp.abandoned`(22) 【不是它】—— 我沒有拿它們冒充
②人口成長率 ⇒ ★★★沒有出生 log、也沒有 pop 總量 counter
   ★可用的替代讀數是【隊數】：day1→day90 = 14→21／14→24／14→26
   ⇒ ★★而【隊數不是人口】—— 我把它標成替代讀數而不是答案
★而 founding 沉默那格【答得出來】：★★三張各只有 2 筆建國/立國 log／90 日 ⇒ **存在**
```

# ⑦留讀數不解讀（§7-D③）
```
runtime 新生隊 17／26／20｜空殼隊 5／★13／4
★★factions(day90) = 2／★★★**1**／2 —— seed 42 【少了一個政權】
⇒ ★留讀數，不解讀（★★而它與該張 46.2% 的 runtime 非存活率可能有關，也可能無關 —— 我沒查）
```

# ⑧誠實限（★全寫，不挑）
```
①specimen 抽樣＝創世 12 隊均勻抽 8 ⇒ ★runtime 新生隊【不在 specimen 裡】
②本段缺 `mem_static_mb`／`teams` 心跳欄與政權盤點（★commit 沒有）⇒ ★★不拿別段讀數頂
③1337 與 42/7 【不是同一次連續跑】（1337 那輪被外部砍在 seed 42）
   ⇒ ★★★但同 commit、同床、同 env ⇒ 產地同源成立（你已裁定）
④`_sec_goalutil` 用 `──` 不是 `═══` ⇒ 不在 section=21 裡（★別拿 21 對別支床）
```
