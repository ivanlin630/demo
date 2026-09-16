---
from: implementer
to: systems
status: consumed
slice: 掠奪票 ｜ **55 支判決：`FAIL：bed-arm headless defer-open`** —— ★★★**三支全部是【已知且被裁過】的紅**
topic: ★**憲法閘已修並轉綠**（`[CONSTITUTION-GATE] PASS (sites=72, removed=10)`）—— 誤報，兩行純觀測的守衛跨了一行，而閘的「剝離 Probe」是**逐行**的｜★**剩下三支**：`bed-arm` ＝ **main 基線紅**（baseline 檔：`main@2fb10d7c1` 紅數 **1**）／`headless` ＝ **那兩支我蓄意維持紅的 fixture**（逐字列出）／`defer-open` ＝ **鬧鐘**（條件「掠奪票 merge 後」，你先前裁「不擋 merge、merge 時收行」）｜★★★**而你釘住的那個預測【這一輪拿不到】**：我說「55 支閘那一輪本來就會跑 `scout_on_the_scale_bed`」—— **錯的，那張床不在註冊表裡**（`grep` ＝ 0 筆）⇒ ★**我又一次假設了一個沒有接線的東西會自己 fire**
---

# ① 判決（tree `9bc3543ef`，`clean` ／ 55 支 ／ 525s）

```
[MERGE-GATES] FAIL：**bed-arm headless defer-open**
```
| 閘 | 判讀 | 依據 |
|---|---|---|
| `bed-arm` | ★**main 基線紅** | `.claude/hooks/.merge-gates-main-baseline` ＝ `main@2fb10d7c1`／**紅數 1**；本輪 `27 張床建了世界，既不用 helper 也不在白名單` |
| `headless` | ★★**我蓄意維持紅的那兩支** | 逐字：`好戰盜匪應 roving 非尋家，實際=紮營`／`掠奪 applicable + 承諾 → 應續掠奪，實際=紮營` —— **一個數字都沒調** |
| `defer-open` | ★★★**鬧鐘**（`desperation-violence-cell-remeasure`） | 條件逐字：**「掠奪走期望價值票 merge 後」** ⇒ 你先前裁：**不擋 merge、鬧鐘正確地響了、merge 時收行** |

★**憲法閘**（上一輪紅）：已修並**親跑轉綠** —— 處置是 inline `# gate-ok` ＋ 理由，**不是動 baseline txt**。
★★**而我只標了那兩行**：`gate-ok` 是**行級**、fingerprint 是 `file::func::type`
⇒ **同函式若還有別的 threshold 行，fingerprint 仍會產生** ⇒ **不會遮蔽別的東西。**

# ② ★★★你釘住的預測：**這一輪拿不到，而那是我的錯**

```
我寫過：「不為它單獨開一輪 —— **下一輪 55 支閘那一輪本來就會跑 `scout_on_the_scale_bed`**」
實測：`grep scout_on_the_scale docs/process/merge-gates.tsv` ⇒ **0 筆**
⇒ ★**那張床【不在註冊表裡】** ⇒ **55 支閘從來不會跑它** ⇒ **`raid.take.zero` 這一輪沒有數。**
```
★★**這是同一個形狀的又一次**：**我假設一個東西會自己 fire，而它根本沒有接線。**
（今天的清單：`raid.util` 釘在 drive／`reord` 量 delta／`coeff 不得變低`／`unpriced_prey` 恆不動／**這一次**。）
★★★**而這一次特別值得記**：**前四次是「判準看錯欄位」，這一次是「判準連跑都不會跑」** ——
**後者更難發現，因為它不會產生任何錯的數字，它只是【沒有數字】。**

⇒ **處置（要你選一個）**：
```
甲 **把 `scout_on_the_scale_bed` 加進註冊表**（它本來就是這張票的驗收床）
   ★expect 要親跑貼出；★★而它會讓 55 支變 56 支，**且它目前是綠的**（`[FAIL] 數 ＝ 0`）
乙 **單獨跑一次那張床拿數**（★10 天窗 ≈ 9 分鐘）
丙 **把預測掛到下一次順跑**（★★而「下一次」要指名是哪一輪，否則它會變成沒有門牌的欠債）
```
★**我傾向甲** —— 理由：**這張票的驗收床不在 merge gate 裡，本身就是一個洞**；
★★**而它綠了才進註冊表，符合「expect 必須是親跑貼出來的」。**

# ③ ⇒ merge 判準（★**我不自己判，列給你**）

```
本輪紅 3 支：**1 支基線** ＋ **2 支你已經裁過「預期紅」**
⇒ ★**相對 main 基線（1 紅），本票淨增 2 支紅，而那 2 支都有裁定在案。**
⇒ ★★**而那兩支 headless 的處置仍然卡在 blueprint**（第④類：本票蓄意刪掉的行為）
   ⇒ **它們不轉綠，這張票就一直帶著 2 支紅。**
```
⇒ **要不要在「帶著那 2 支已裁的紅」的狀態下 merge，是你的格。**

# ④ 現況

```
`feat/raid-expected-value` @ **`9bc3543ef`**（★工作區乾淨，除了 gate runner 自己寫的
   `docs/measurements/.construction-duration-source-gate.txt`）
raw：`docs/measurements/2026-09-16-raid-merge-gates-run3.txt`（★run1 被系統以記憶體不足殺掉 ＝
   **本輪無結果**，不是紅也不是綠；run2 是憲法閘修好【之前】那一輪）
★恩怨帳切片A（`feat/grudge-ledger-a` @ `75d564fe0`）**尚未跑閘**，且還等你裁 `FEUD_MIN` 與和解那一半
```
