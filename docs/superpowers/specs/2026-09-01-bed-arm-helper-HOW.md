---
status: DRAFT(待 R²;★排在 S6 phase2 之後,implementer 不離關鍵路徑)
owner: systems
slice: bed-arm-helper
origin: measurer 提案 2026-09-01 —— ★「把規則變成沒得選，而非寫在註解裡靠記得」
---

# ★★★§0 先訂正我自己的規模宣稱
我先前寫「其餘上百張床全沒改」「逐床改不可行」。★**兩句都錯，而且是同一個錯：我沒有數。**
```
呼叫 GameSetup.setup() 的床        ＝ 136
★其中 arm 在 setup【之後】(真盲)  ＝ ★12
   arm 在 setup 之前(正確)          ＝ 93
   完全不 arm Probe(不用 tap)       ＝ 31
```
⇒ ★★**真盲區是 12 張，不是上百張** ⇒ ★★★**逐床改【是可行的】，我當初的「不可行」是憑印象說的。**

# ★§1 兩腿（★順序：先修存量，再防增量）
```
腿A 先修那 12 張：把 arm 移到 GameSetup.setup() 之前（★機械、可逐張驗）
腿B helper + 閘：防未來新床再犯
```

# ★★§2 腿B：helper（採用 measurer 提案）
```
MeasureBedHelper.arm_and_setup(cfg, strip_player) -> WorldState
  內部順序【寫死】：Probe.reset() → Probe.enabled = true → GameSetup.setup(...) → (可選)拆玩家
⇒ ★新床呼叫它就自動繼承正確順序,作者不用記得順序
```
★**而 helper 只約束【呼叫它的】床** —— ★★**所以它一個人不夠。**

# ★★★§3 腿B 的另一半：**閘**（★這是我加的，helper 單獨無效）
```
閘：掃 scripts/debug/** 內【直接呼叫 GameSetup.setup()】而未經 helper 者
★母體 = GameSetup.setup() 的呼叫點（★引擎決定的窄口,不看名字 ⇒ 改名不會漏）
★★既有的入白名單（避免恆紅）,★★★而白名單【條目數就是盲區規模】,每次跑都印出來
   輸出形狀同「本輪無母體」那個註記：不是 FAIL,但不可以長得像通過
```
★**為什麼白名單數要印**：★★**它會單向下降，而且不會被遺忘** ——
★★★**「入白名單」若不印數字，就是把 12 張床的盲區洗成合法。**

# ★§4 順帶查到的一件（★不在本票，具名記錄）
```
scripts/debug/peaceful_economy_bed.gd 大量讀 Probe.counts / Probe.samples，
★而它自己【不 arm Probe】—— 它依賴【別處】arm 且沒被 reset
★★目前是work的（基線量測跑出來的數字非零 ⇒ 那條路徑上確實有人 arm）
★★★但那個依賴【沒有寫在這個檔案裡】—— 而它是兩張基線床之一
⇒ helper 正好治這型：把「誰負責 arm」從【檔案外的默契】變成【一行呼叫】
```
★**我沒有斷言它是 bug**（數字非零就是反證）—— **記錄的是它的脆弱性，不是它的錯誤。**

# ★★§5 驗收
```
①腿A：那 12 張逐張驗 arm 行號 < setup 行號（★機械可查）
②腿B 陽性對照：★新增一張直接呼叫 GameSetup.setup() 的床 ⇒ 閘必須紅
③★★白名單數字必須出現在閘的輸出裡（★★★失敗長相＝閘綠而沒人知道還有 N 張盲的）
④腿A 修完後白名單應為 0 或明確剩幾張並列出原因
```
