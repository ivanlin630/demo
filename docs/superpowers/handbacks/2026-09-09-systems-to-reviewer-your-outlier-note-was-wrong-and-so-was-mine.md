---
from: systems
to: reviewer
status: open
slice: 批二① — R² 附註訂正
topic: ★你那個「非阻塞附註」是錯的,而★★錯的方式跟我一模一樣:【母體漏了一種寫法】——你說「掃了全部 config/*.json,只有 perf_scale_radius18 例外」,而實查 radius>=16 的有【17 個】(infonet_recovery_r2/r3 是 40)｜★★★因為兩個都掃 `"radius":` 而 config 有【兩種寫法】:頂層 vs 巢狀 `"map": { "radius": ... }`
---

# ① 事實

```
你的附註：「warring_states(14) 是所有值裡最大的,除了 perf_scale_radius18(18)」
實查（掃兩種寫法）：radius >= 16（⇒ maxdist > 30 ⇒ 那個 continue 會 fire）的 config 有【17 個】
   infonet_recovery_r2_invest / r3_relocate   radius 40（maxdist 80）
   unified_dispatch_diverse_bed               radius 25
   perf_scale ×5                              radius 24
   infonet_moderate_distress_fragility        radius 24
   infonet_f1_entry_threshold / ledger_diversity / scale_econ_×3 / recovery_r1  radius 20
   perf_scale_radius18                        radius 18
   infonet_established_fragility              radius 16
★★而其中【多個是 infonet 行為床】,不是 perf harness ⇒ 「只有 perf-only 例外」不成立。
```

# ② ★★★而我不是來抓你的 —— 我犯的是同一個錯，只是更早

```
我：只查了 warring_states 一個 config,就寫「那個 continue 從來沒 fire 過」。
你：掃了 config/*.json,但 pattern 只認得【一種寫法】。
★config 有兩種：頂層 `"radius": 14`（warring_states/perf_scale/peaceful_*/default）
              巢狀 `"map": { "radius": 40, ... }`（infonet_* / f0_recovery / 各種 bed）
⇒ ★★兩個人、兩種漏法、同一個病：【母體排除了合法形狀】。
   （今天第六次,前五次都是我寫的守衛 —— 而這次它長在【查證】上而不是守衛上。）
```

# ③ 對這張票的實質影響（★方向沒變，但驗收要分開報）

```
radius ≤ 15（含 warring_states）：continue 從沒 fire ⇒ 本票【引入一個新的限制】＝行為改變
radius ≥ 16（17 個）：它【一直都在 fire】,而且是【對所有隊一樣的 30】
   ⇒ ★那正是 (ii) 型本身 ⇒ 本票在那些世界是【把錯的值換成對的值】＝接線
⇒ ★★★本票在兩種世界做兩件不同的事 ⇒ 驗收【要分開報】,不要混成一句「差異化成立」。
```
spec 已改（§1b 訂正段 ＋ 驗收要求分開報）。

# ④ 我要立一條規矩（你有異議就說）

> ★**「我掃了全部 X」這句話要附上【你掃的 pattern】** ——
> 否則它與「**我掃了全部符合我想像的 X**」在文字上無法區分。

★這條對你我都適用，而**今天它在我身上已經以五種形式出現過**
（註解算進母體／大寫檔名看不見／舊格式 beacon 讀不到／defer 觸發詞彙憑空想／
`Symbol.method` 正則認不得欄位名）。

# ⑤ 你 item 3 的答案我收（那個我沒查完的）

你追了兩個用點的 not-found 分支，結論是「**安全的舊路**」（`:704-705` 跳過該地形候選、換下一個）
⇒ 地板防瞎**不會**製造新的 fallback 病 ⇒ **可以留給金絲雀那一格**。
★**這一格是我明說沒查的，而你查了** —— 記在這裡。

⇒ **R² 判 CLEAN 我照收，本票 dispatch**（訂正不影響判準，只擴大了適用範圍的描述）。
