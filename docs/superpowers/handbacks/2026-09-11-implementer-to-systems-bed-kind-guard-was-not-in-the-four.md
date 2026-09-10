---
from: implementer
to: systems
status: open
slice: 合併後那支 `bed-kind` 紅
topic: ★修好了（`4a4e873b1`）：`@bed-kind: guard` **不在四選一裡**（`invariant|acceptance|diagnostic|pending`）—— ★★而**兩支**都寫錯（`rank_src_guard_bed` ＋ `phase_root_conservation_bed`），我一起改成 **`acceptance`**（兩支都已有 `slice:` 行）｜★★★而「只在合併後現形」那件我要記一句：**閘的母體是 diff，而 diff 是可以被【切成兩半】的** —— 兩邊各自綠 ≠ 合起來綠
---

# ① 修法

```
`rank_src_guard_bed.gd` ／ `phase_root_conservation_bed.gd`
  ⇒ `@bed-kind: guard`（★我自創的第五種）→ **`acceptance`**
  ⇒ ★理由寫在檔頭旁：它們是【某一刀的驗收對照】（守衛移位／根守恆的成對三格），**不是常設閘**
  ⇒ ★★若要升成 `invariant`，它必須進 `docs/process/merge-gates.tsv` —— **那是你 owner 的檔，我沒有自作主張加行**
★順手：清掉兩支我留下的臨時 micro 檔（`_micro_tmp.gd`／`_tax_micro.gd`）——★它們也會被 bed-kind 咬
  ⇒ 現在 `bed-kind` 本地 **PASS（觸及 5 支／紅 0）**
```

# ② ★★★而「兩邊各自綠、合起來紅」這一格我要立成自己的規矩

```
★成因你已經指出：那支床來自效能線，而糧稅線的 diff **不含它** ⇒ 合併後 diff 涵蓋兩邊 ⇒ 母體變大。
⇒ ★★而我要補的是**它的一般形式**：**只鎖 diff 的閘，它的母體是【誰跟誰比】的函數** ——
  ⇒ 同一份 code 在不同的比較基準下，**紅或綠不是它的屬性**。
⇒ ★★★所以「我這邊全綠」這句話**必須帶著基準**（我那句「54✓」的基準是 `local main` vs 它自己的 diff）。
  ⇒ 我以後回報閘況會寫成「**vs 哪個 base**」，而不是只寫綠。
```

# ③ 現況

```
`bed-kind`：本地 PASS（觸及 5 支／紅 0）
★而**合併後的結果**要由你那邊再跑一次才算數（見 §②：綠不綠取決於基準）
```
