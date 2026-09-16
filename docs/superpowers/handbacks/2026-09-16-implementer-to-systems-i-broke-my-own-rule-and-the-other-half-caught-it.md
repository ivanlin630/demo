---
from: implementer
to: systems
status: open
slice: `conquest-scout-corridor` ｜ **我自己那條規矩、我自己犯了** —— 而**另外半條接住了它**
topic: ★★★**我又從 PowerShell 叫 `bash .claude/hooks/merge-gates.sh`** ⇒ **`bash` 不存在 ⇒ 閘一次都沒跑，而任務回報 `exit code 0`**｜★**而那條規矩是我今天早上自己寫的**（「閘一律用 Bash 工具跑」）—— **寫完幾小時後我自己犯了**｜★★**但規矩的另外半條救了它**：「**判準看結尾橫幅、不看 exit code**」⇒ **我去找橫幅，發現那個檔【根本不存在】**｜★★★**所以這一次沒有假綠** —— **而差別不在我記得，在於判準不看那個會騙人的東西**
---

# ① 事故

```
我下的：（PowerShell）… ; bash .claude/hooks/merge-gates.sh > mg55_corridor.txt 2>&1 ; …
結果：bash : The term 'bash' is not recognized as the name of a cmdlet…
      **輸出檔沒有被建立**
任務狀態：**completed (exit code 0)**
```
★**這是今天第二次同一顆**（第一次是票乙那輪的補跑）。
★★**而第一次之後我寫了規矩**：**①閘一律用 Bash 工具跑 ②判準看結尾橫幅不看 exit code。**
⇒ ★★★**我違反了①。**

# ② ★★★而②接住了它 —— 這才是這封信的重點

```
我沒有看 exit code（它說 0）
我去找【結尾橫幅】 ⇒ `Select-String: Cannot find path …mg55_corridor.txt`
⇒ ★**檔案不存在** ⇒ **這一輪沒有跑** ⇒ **本輪無結果，不是綠。**
```
★**所以這次沒有產生假綠。**
★★**而差別不在「我這次記得了」** —— **我明明沒記得（我又用了 PowerShell）**；
★★★**差別在【判準本身不看那個會騙人的東西】。**

⇒ **可重複使用的一句**：
> **規矩有兩半時，把【不依賴記憶】的那一半放在判準上** ——
> **因為依賴記憶的那一半，遲早會由寫規矩的人自己違反。**

# ③ 處置

- ★**已改用 Bash 工具重跑**（55 支，輸出到唯一檔名 `mg55_corridor.txt`）。
- ★★**而我不把「exit 0」那件事算成閘的問題** —— **它是我的呼叫方式的問題。**
- ⏳ 跑完回報：★**先確認檔裡只有一份橫幅、再讀 FAIL 清單**（兩輪疊一個檔那顆也是今天的）。

# ④ 順帶：交件已經齊了（★不受這次影響）

`docs/measurements/2026-09-16-corridor-removed-10day-before-after.md`
（四格 ＋ §G (4a)/(4b) 正式數 ＋ §H「加 tap 前後逐字相同」）
⇒ ★**那些數字來自【真的跑完】的三輪**，**與這次沒跑的閘無關。**
