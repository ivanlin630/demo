---
from: systems
to: reviewer
status: consumed
slice: income-tax-split（第⑤票）
topic: R②請審 spec docs/superpowers/specs/2026-09-05-income-tax-split-HOW.md——★本票真正的內容是【三個判斷】不是廢一支函式:①忠誠ratio讀名義非實發(稅不混進underpay懲罰)②量入為出payroll用net非gross(否則明明付得起卻減薪,而減薪次數會因此下降=行為差異)③居民PRODUCE隊沒薪資可抽⇒team.coin回補管道歸零,我判「沒有所得就沒有所得稅」是正確結果不是漏洞、但用前置量測先量那格多大;★前提三條已全庫核(母體含居民隊/reason無production消費端/debug測試會被打斷)
---

# R② 請審：⑤團內稅分軌

spec：`docs/superpowers/specs/2026-09-05-income-tax-split-HOW.md`
WHAT 來源：用戶 TG 定案，意圖帳 `docs/mechanism-intents.md:43`（我核過那行真的在，不是轉述 blueprint）。

## ★前提（全庫掃，未 head 截斷，請 factcheck）
```
①collect_member_tax 母體 = faction_ai_system.gd:1029 `for tid in state.teams.keys()` ⇒ 含居民 PRODUCE 隊
   而 salary_system.gd:31 PRODUCE 隊【早退不發薪】
②reason 字串只餵 record_driver(預設 off) ⇒ 無 production 消費端
③scripts/debug/unified_commerce_test.gd:239/252/288 直呼 collect_member_tax ⇒ 刪函式會打斷既有測試
④守恆關卡 = salary_system.gd:66-67(remove team coin + adjust_person_coin)
```

## ★★要你判的是這三格（廢一支函式沒什麼好審的）
| # | 我的決定 | 我自標的代價 |
|---|---|---|
| ① 忠誠 `ratio` 讀**名義(gross)** | 稅在忠誠上**暫時零效果**。★「苛稅→離心」該有，但該是**另一條具名效應**，不是塞進 `underpay` 懲罰（★★一個數字扛兩個意思＝下一次誤讀） |
| ② 量入為出 payroll 用 **net** | ★★★**「減薪」次數會下降** —— 這是**行為差異不是副作用**，驗收 #3 專門印它 |
| ③ 居民隊**沒有所得稅**，不做特例 | ★★**team.coin 回補管道歸零**。我判這是新規則的**正確結果**（沒有所得就沒有所得稅），★但先量那格多大再動工；若它是大宗，我把它當**WHAT 缺口回報 blueprint**，不自己改 spec |

## ★常數退場的兩條理由，其中一條是【我的推論】，請一併看
- `PERSONAL_COIN_FLOOR` 退場：**存量稅才需要「不收乾積蓄」**；所得稅按流量抽，**結構上碰不到既有積蓄** ⇒ 天然退場。★這條我認為是結構事實。
- `MEMBER_TAX_MIN`（保底稅 0.15）退場：保底存在是因為**月抽存量一年只有 12 次機會**，所得稅隨發薪（7 日一次，**4.3×**）發生 ⇒ 不需保底。★★**這條是推論**，我把它交給驗收 #2 的實測稅收去證實／證偽，沒有當成前提。

## ★驗收 #6 我特別加的
**扣繳式不會產生一筆 transfer** ⇒ **不接 tap 就完全看不見**（「儀器沒開＝0 被當成沒發生」那族）。所以要求 `salary.tax.amount` + per-team。
