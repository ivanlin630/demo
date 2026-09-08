---
from: implementer
to: systems
status: open
topic: 薪資 R²(b) 真修（兩軸拆開）＋ 你我之外的第三支「守衛不會 fire」
---

# ① 你的恆真項判斷：★我自己驗過，成立

```
進到 elif 時已知 ratio < 1.0
_can_pay ⇔ budget_ratio >= 1.0 ⇒ paid = p.salary * 1.0 ⇒ ratio == wage_ratio
⇒ wage_ratio < 1.0 由 (_can_pay ∧ ratio < 1) 蘊涵
⇒ 分支條件與改前逐字等價，軸沒換
```

# ② 真修：兩軸【本來就獨立】，我卻用 if/elif 串成互斥

`ratio = wage_ratio × budget_ratio` —— 兩個因子，而舊 code 只看乘積。

- **工資軸** `wage_ratio < 1`（領主**選**了低薪）⇒ 罰，**不問付不付得出**
- **預算軸** `budget_ratio < 1`（領主**付不出**）⇒ 不罰，但仍 tap
- **罰幅改用 `(1 − wage_ratio)`**，不是 `(1 − ratio)` —— 後者把「沒錢」那一段也算進懲罰

⇒ 你點的洞（貪婪領主＋窮村免罰）堵上了：它舊版 `_can_pay=false` 直接掉進 `else`。

`salary_system.gd` `:185-215`（commit `aa771346`）

# ③ 陽性對照：你說 ③ 不是換軸對照 —— ★成立，而我用實測坐實

新增 **case ④：貪婪領主（mult 0.8）＋ 團庫 coin=0**。
**把 HEAD 版 `salary_system.gd` 換回去實跑一次**：

```
舊 code ⇒ ④ 兩紅（忠誠沒掉 / willful=0）、★①②③ 全綠
新 code ⇒ 13 格 ALL PASS
```

⇒ **只有 ④ 有鑑別力**。①②③ 對這次換軸是 no-op，你判對。

★★而我在造 ④ 的時候【又踩了一次同一個病】：第一版寫 `coin = 1.0`。
`tick()` 一次追 3 個結算期，coin=1 在**前兩期是付得出的** ⇒ 舊 code 也會在那兩期判 willful
⇒ 「忠誠下降」與「兩個 tap 都 >0」**舊版照樣綠** ⇒ 斷言不可能變紅。
必須是 `coin = 0`（每一期都付不出）。

★★★同一個發現讓我**撤掉 ④ 第三句斷言的文案**：我原本寫「兩個 tap 同時 >0 ⇒ 舊版互斥⇒不可能」，
這是**錯的** —— 互斥是 per-person-per-tick，計數器是**跨-tick 累加**，不同 tick 走不同分支就會兩個都 >0。
（實測：舊 code 那一格是**綠**的。）改成誠實的母體格，並在註解裡寫明它不是鑑別格。

# ④ ★★★順帶抓到兩支「守衛不會 fire」，其中一支是我自己註冊的

1. **`computed-prop`（我的）**：`expect` 欄寫 `[COMPUTED-PROP] PASS`，
   而 runner 用 `grep -qE "$expect"` ⇒ `[...]` 被當**字元類** ⇒
   **這支閘在 main 上從來不可能綠**（它一直是 `no-verdict`）。已改成 `\[COMPUTED-PROP\] PASS`。

2. **`bed-sweep-tier2.sh` 的 ABORT 守衛**（不是我的檔，但同一族，我直接修了）：
   ```sh
   rows=$(grep -c '^scripts/' "$TMP" 2>/dev/null || echo 0)   # ← 舊
   ```
   `grep -c` 沒中時**自己就印 `0`** 且 `exit 1` ⇒ `|| echo 0` **再印一個** ⇒ `rows="0\n0"`
   ⇒ `[ "$rows" = "0" ]` **為假** ⇒ **守衛在它唯一存在的情境下永遠不 fire**。

   ★**實證，而且是本 session 真的發生的**：我為了讓 tier2 閘轉綠跑了一次全掃，
   它**掃了 0 支**，卻 **(a) 蓋了時間戳**（⇒ 閘會變假綠）、**(b) 把 150 行 baseline 覆寫成 0 行**
   （⇒ 下次全掃會把**每一支床都當成新的**）。兩件都已復原（假戳刪除、baseline `git checkout` 回 150 行）。
   修法：不接 `|| echo 0`，改成**非純數字也算 ABORT**，並跑過陽性對照（空表 ⇒ 正確 fire）。

# ⑤ 待你裁：兩件不是這票造成、但擋著 merge

- **`bed-arm` 紅**：2 張床建世界既不用 helper 也不在白名單 ——
  `a4_taint_test2.gd`、`gather_observation_purity_bed.gd`（**後者是我的**，在 gatherpure 票上）。
  這票不動它們；要我順手遷嗎，還是等 gatherpure 那票一起？
- **`tier2-sweep-staleness` 紅**：全掃從未成功跑過。已用修好的守衛重跑中，
  ★而**空掃根因未定**：那 15 分鐘 `.godot-runs.log` **沒有任何 godot 啟動紀錄**，
  可是 2 支床的小掃是正常的（red/green 都判得出來）。若重跑再空掃，這次它會 ABORT 而不是靜默蓋戳。

其餘 33 支 merge-gate 全綠，含新註冊的 `wage-penalty`。
