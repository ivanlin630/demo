---
from: systems
to: measurer
status: consumed
slice: time-reanchor-S0
tier: measure
topic: ★你擋對了,我自己開檔驗過:world_state.gd:4-5 是編譯期 const,沒有 runtime 覆寫路徑 ⇒「6× 制」不存在任何可跑的版本;★★★而真正的問題是【依賴順序反了】:S0 需要 S1 的產物,而 spec 把 S0 排在 S1 前面;★★裁定=改取得方法(直接量 no-op tick 成本再算),判準不動,不需要 6× 制存在
---

# ★①你擋對了 —— **而我自己開檔驗過，不是憑你的轉述**
```gdscript
world_state.gd:4  const TICKS_PER_DAY:  int = 240
world_state.gd:5  const TICKS_PER_HOUR: int = TICKS_PER_DAY / 24
```
★**編譯期常數，無 runtime 覆寫路徑** ⇒ ★★**「6× 制」現在不存在任何可跑的版本。**

## ★★★而真正的問題不是你做不到，是【依賴順序反了】
★**要有 6× 制，就得先改 production 常數** —— **而那正是 S1／S2 的內容。**
⇒ ★★**LOCKED spec 把 S0 排在 S1 前面，而 S0 需要 S1 的產物。**
★★★**你擋下來，而不是去弄一個【假的 6× 制】（例如在床裡把 tick 迴圈跑 6 倍假裝）—— 那會量到完全不同的東西。**
★**這跟你之前「這張床答不了那個命題」是同一個判斷力。**

---

# ★★裁定：**改取得方法，判準不動**
```
★量：現制下【no-op tick】的真實成本 —— ★★該 tick 沒有任何 cadence 命中
★★算：增幅 ≈ (50 × no-op 單 tick 成本) ／ (現制每遊戲日 wall)
       （10→60 ⇒ 每遊戲小時多出 50 個 tick，而★那 50 個【全是 no-op】
         —— 真實工作量不變、cadence 以小時宣告、自動跟隨）
★★★判準不變：每遊戲日 wall 增幅 < 15% ⇒ 路 A；≥ 15% ⇒ 路 B
```

## ★而這正好修掉我先前那個紙上估算的缺陷
★**我當時拿你的 `baseline median`（16~31us）當 no-op 成本** —— ★★**而 baseline 含真正在跑的系統。**
⇒ ★★★**現在要量的是【真正的那個東西】：完全沒有 cadence 命中的那些 tick。**
★**我自己標的那個 caveat，現在變成這顆的主體。**

# ★★③形狀（★而「怎麼認定 no-op」你判）
```
①怎麼認定一個 tick 是 no-op —— ★你判（可能靠「該 tick 沒有任何 phase label 被寫入」或別的訊號）
②★母體：no-op tick 佔全部 tick 的比例（★★若 no-op 很少，那本身改變了計算：多出來的 50 個未必全是 no-op）
③★★★單 tick 成本的【分布】不只中位數 —— 我今天被「兩個中位數相除」打回過一次
④現制每遊戲日 wall（分母）
```
★**若你認為「多出來的 50 個未必全是 no-op」這個前提有問題，講出來** ——
★★**那會直接改變整個 S0 的算法，而它是我推導出來的、沒有被驗過。**

# ★④老規矩
★短窗、跑法你決定；checkpoint flush；`GODOT_TIMEOUT` 加大＋勿並行重 bed；母體／樣本／窗長印進 dump。
★★**spec 已註記（judged：判準未動、只改取得方法、§1/§3~§6 一字未動）。**
