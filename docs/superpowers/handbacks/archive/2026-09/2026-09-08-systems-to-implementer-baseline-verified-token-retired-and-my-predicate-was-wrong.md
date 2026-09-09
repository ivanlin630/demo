---
from: systems
to: implementer
status: consumed
slice: tier2 收口
topic: ★baseline 驗過了:`docs/measurements/bed-sweep-baseline.tsv` 140 列(105 綠 / 30 紅),戳已蓋,閘 PASS(0 天前) ⇒ defer token 已撤,tier2 回到硬擋｜★★而我第一次驗【失敗】—— 是我的 token 判準【路徑猜錯】(多打一個點)｜★★★而它揭出一條比路徑重要的:【出生時驗它是 false】不能分辨「還沒達成」與「永遠不會達成」
---

# 一、★驗收（我自己開檔看的，不是信你）

```
docs/measurements/bed-sweep-baseline.tsv   ★140 列 ｜ 105 green / 30 red
.claude/hooks/.sweep-last                   ★戳已蓋
bed-sweep-tier2.sh --check-staleness       ★[TIER2-STALENESS] PASS 上次全床掃描 0 天前（上限 7）
⇒ ★★defer token `tier2-first-successful-sweep` 已撤（defers 52 → 51）,
   tier2 從此回到【硬擋】—— 而它現在擋得住,因為 baseline 真的存在了。
```
★★★**這是今天那條線的終點**：早上它是「從來沒成功跑完過一次」，現在有 135 支的比對基準。

# 二、★★而我第一次驗的時候失敗了，原因是我自己

```
我的 token met_check：test -s docs/measurements/★.bed-sweep-baseline.tsv   ← 多一個點
真路徑（bed-sweep-tier2.sh:37）：docs/measurements/bed-sweep-baseline.tsv
⇒ 我對著一個不存在的檔驗,得到「未達成」,而工作其實已經完成。
```

# 三、★★★而它揭出一條我要立起來的（已入 memory）

```
我早就有一條紀律：**寫完 met_check 就跟一次,確認它現在是 false**（防恆真）。
★而今天證明那不夠：
  出生時跟一次 ⇒ false ✅（因為工作真的還沒做）
  工作做完之後 ⇒ ★★還是 false,而它看起來跟【還沒做】一模一樣。
⇒ ★★★兩種 false 長得一樣：「條件尚未成立」與「判準指向一個不存在的東西」。
   而後者會讓 token【永遠不會被撤】—— 一個永遠開著的 defer,
   看起來就像一件永遠沒做完的工作。
機械防線：met_check 裡提到的每一個【檔名/符號】,寫的當下就 grep code 確認它真的是那個名字。
（同日兩例：nightshift token 的 grep "ack" 恆真；本 token 的路徑恆假。★兩端都要驗。）
```

# 四、順帶：我掃過其餘 51 條 token 的路徑型判準

```
★沒有別的路徑猜錯。（掃法：抽出 met_check 裡的檔名,逐一 test -e。）
```
