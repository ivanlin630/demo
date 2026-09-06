---
from: reviewer
to: systems
status: consumed
slice: material-gate-persona
topic: 判決:四常數/驗收六條CLEAN(已merge不追溯);clamp重合讀成(b)巧合,建議補pin assertion但非阻擋級
---

# ①四常數/實測——**核對過，CLEAN**（已 merge，追溯性確認）
`build_afford.gd:16-30` 逐行核對，`MARGIN_MIN=1.0`(剛好付得起，不開舉債路)語意站得住；代數複驗你的兩個邊界（`caution=1,daring=0→2.0`／`caution=0,daring=1→1.0`）算對。

# ②clamp 重合——**讀成 (b) 巧合，但你的風險判斷對，建議補 pin，非阻擋級**
`K_c+K_d=0.6+0.4=1.0` 讓 clamp 自然邊界跟公式值域精確重合，我認為這**更像巧合而非刻意設計**——`K_c`/`K_d` 像是分別憑「慎重多厚、大膽多薄」的手感各自定的，`MIN`/`MAX` 則是分別憑「剛好付得起／最保守」的語意各自定的，沒有看到任何一行推導把兩組數字綁在一起；巧合對到剛好整數邊界（1.0/2.0 這種乾淨數字）比較像是四個數字各自被挑得「好看」時湊巧疊合，不是反推出來的。

**但無論 (a)/(b)，你講的風險是真的**：這關係現在【沒有】被任何東西守住，日後有人只調 `K_c`（不動 `MIN/MAX`）,clamp 會從「防禦性 no-op」變成「靜默削平極端人格」，不紅、不報、只有一群本該不同 margin 的人格拿到同一個值——跟今天在 `material-gate-persona`／`local-value-state-required` 兩票裡反覆出現的「引數個數對、值悄悄變」「default 讓漏傳編得過」是同一個病的第三個化身：**都是「表面訊號正常，實際語意已經脫鉤」**。

**建議：加，但列小 follow-up 非阻擋這票**（票已 merge，這是事後加固）：
```gdscript
# fixture-only：釘住 K_c+K_d 跟 MIN/MAX 的隱含關係，斜率單獨調而不動上下界時炸出來
assert(is_equal_approx(MARGIN_NEUTRAL + (MARGIN_CAUTION_K + MARGIN_DARING_K) * 0.5, MARGIN_MAX))
assert(is_equal_approx(MARGIN_NEUTRAL - (MARGIN_CAUTION_K + MARGIN_DARING_K) * 0.5, MARGIN_MIN))
```
不是過度防禦——這條斷言純粹只在「有人改斜率沒改上下界」時才會紅，平常零成本；且它跟既有「陽性對照」（`avail=0`/`avail`充足那兩條）是同一種紀律：把「可能靜默壞掉」的關係變成「壞了會紅」。你要不要現在補一行、還是排進小票都行，我沒有偏好，只確認這值得做。

# ③兩個陽性對照——**認同，這是對的紀律**
`avail=0`連大膽也擋、`avail`充足連慎重也放行——直接對應今天在 `test-ran-floor` 上踩過的恆真/恆假式覆轍，implementer 自己先擋，好。

**這票沒有新阻擋，追溯確認 CLEAN；pin assertion 是建議，你排時程。**
