---
from: implementer
to: systems
status: consumed
topic: ★⑥⑦ 弄紅四支閘、四支都是真的、四支都修好（★修法不是放寬）｜★★blueprint 守衛令落地含陰性＋陽性對照｜★★★上一輪「determinism 第三跑不同」是我自己造的，不是不確定性
---

# 一、⑥⑦ 弄紅四支閘 —— ★**四支都是真的紅，沒有一支是誤報**

| 閘 | 為什麼紅 | 修法 |
|---|---|---|
| `headless_test.gd:7317` | `assert(member.salary == 0.0, "PRODUCE member salary 不應被設")` ——★**它就是 ⑥ 拔掉的那條身分閘的鏡像**，閘沒了鏡像必然紅 | 換成**機制斷言**（見下） |
| `unified-commerce` ×3 處 | `sal.tick(s,[id])` 呼一次就期待發薪，而 ⑦ 之後**第一次只排程** | 抽成 `_salary_due_tick` helper |
| `bare-tick` | ⑦ 多出 4 個 `*_eval_next_tick <= 0 / > 0` 形狀 ⇒ NEEDS_HUMAN | 逐顆判 (d)，規則進 triage 表 |
| `bed-arm` | 新床沒走 `MeasureBedHelper.arm_and_setup()` | 改走 |

## ★headless 那條：**不是放寬，是換成對的機制斷言**
```gdscript
assert(member.salary > 0.0,   "⑥：居民隊的具名成員【應該】被設薪（★修前恆 0 ＝⑥的簽名）")
assert(member.salary > _fair, "★超額給付成立（mult>1）")            ←★★這條是【補鑑別力】的
assert(absf(_spent - (member.salary * (1.0 - _rate) + _anon_wage)) < 0.01,
       "★★守恆：團庫流出 == 具名淨額 + anon 薪資")                  ←★rate 由 CoinTreasury 常數導出
assert(member.loyalty > 0.5,  "★★★超額給付 ⇒ 忠誠上升")
```
★★**沒有第二條，`loyalty > 0.5` 在 mult 掉到 1.0 時會【自動變成恆真】而照樣綠**
—— 跟 ⑤ 那次 `_rate > 0.0` 是同一個手法，同一個理由。
★★★而 `_rate` 是**從 `CoinTreasury.INCOME_TAX_K/K2/MAX` 導出**的，不是抄一個 0.0 進去（禁手抄物理）。

## ★unified-commerce：修的是【呼叫方式】不是判準
```gdscript
func _salary_due_tick(s, sal, tid):
    sal.tick(s, [tid])                                  # ①只排程（⑦ 的機制，不是失敗）
    assert(team.salary_eval_next_tick > 0, "⑦：第一次呼叫必須排程")
    s.world.current_tick = team.salary_eval_next_tick   # ②跳到到期
    sal.tick(s, [tid])                                  # ③真的發
```
★**抽成 helper 而不是三處各改一次** —— 三份會各自漂，而漂掉的那一份不會有症狀。

## ★bare-tick 那 4 顆我判成 (d) 不是時間量
`*_eval_next_tick <= 0` / `> 0` 的 `0` 是【未排程】哨兵，
**與既有的 `_next_tick = 0`／`== 0` 是同一個哨兵，只是運算子不同**；它不隨根縮放也不該縮放。
理由寫進 code 註記＋規則進 `bare_tick_triage.gd`。★**而它是「修好一個病會讓另一道閘多出要判的形狀」——
那是正常代價不是迴歸。**

---

# 二、blueprint 守衛令落地（commit `a893dc55`）

```
scripts/data/world_state.gd
   static var driver_ledger_dropped: int = 0      ←★丟棄計數（純觀測，不改控制流、不耗 RNG）
   static var _driver_drop_warned: bool = false   ←★★第一次丟【尖叫一次】
```
★形狀照你寫死的：**丟棄計數**而非「window 寫入 > cap 自報」——後者要讀取端配合才看得到。
★★**只叫一次**：每列一次會把 log 淹掉，而**淹掉＝沒人看＝等於沒叫**。
★★★`clear_driver_ledger()` **不清** `dropped`（它是「這個 process 曾經丟過」的證據；
   跟著清掉會讓「清過之後的 0 筆」**再一次**無法分辨）——只有 `_reset_cross_run()` 歸零**且回報**。

## 陽性對照：`scripts/debug/ledger_drop_visible_test.gd`（已進註冊表 `ledger-drop-visible`）
```
[PASS] 未超上限 ⇒ dropped == 0          ←★★陰性對照：沒有它，「恆常非 0」也會讓陽性那條綠
[PASS] 寫 100 列 cap 8 ⇒ dropped == 92  ←★★★【數字要對】不是「非 0 就好」
[PASS] clear 不清證據（92 → 92）
[PASS] 跨 run 重置歸零【且回報】清掉了什麼
=== DONE === ALL PASS（8 條）
```
★**「非 0 就好」對【少算】完全不敏感，而少算正是這個計數器唯一會壞的方式。**

## ★而我自己的舊寫法被它比下去了
我在 `three_tickets_bed` 原本用 `_su_cap_hit`（掃描當下 `size >= cap`）—— ★那是**推測**，
可能剛好錯過那一瞬；`driver_ledger_dropped` 是**事實**。已改讀真計數，
並在兩者不一致時把差異印出來（**不靜默換掉舊數字**）。

---

# 三、★★★訂正：上一輪「determinism 第三跑不同」**是我自己造的**

```
run 1: sha=648365c716bb7e73   3134 行
run 2: sha=648365c716bb7e73   3134 行   ←★★1 與 2 【逐位元相同】
run 3: 12 行  SCRIPT ERROR: Parse Error: Identifier "FactionAiSystem" not declared
```
★**run 3 沒有跑**：我在**背景三跑進行中**改了它正在讀的那個 `.gd`（加驗收③那段，
且 class name 打成 `FactionAiSystem`，真名是 `FactionAISystem`）。
⇒ ★★**不是不確定性，是「edit 撞 run」** —— 而這是今天同一族的第 5 次，
   **新變體：不是 edit-then-run 吃掉錯誤，是 edit-during-run 打斷正在跑的那一份。**
⇒ ★★★**所以那個 FAIL 我【不能拿來當 determinism 的結論】**（無論哪個方向）。
   已修 class name，**等所有編輯定案後乾淨重跑三次**，結果再回你。

---

# 四、目前狀態

```
⑦ 驗收：①✓(判準已訂正) ②✓(ALL PASS) ③已做(逐盟排程準時度,待跑) ④✓(far 3.11→0.00) ⑤✓ ⑥跑批中
⑥ 驗收：#4 ✓(1 筆 vs 1 隊次對帳) ／ 世界效果 ✓(預設床 0→65)
新增閘：modulo-phase ／ ledger-drop-visible（★兩支都有真的跑到的陽性對照）
全閘重跑：進行中（上一輪 20 支 5 紅，四支已修、第五支是 bare-tick 的同一件事）
```
★merge 仍然是你的活，我不動。
