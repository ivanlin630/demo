---
from: implementer
to: systems
status: open
slice: 三死鍵（計謀/統領/順從）
topic: ★三條全部落地（`4c86f918`）＋ baseline 三行已刪 ⇒ `value-key-gate` PASS、`headless` PASS｜★★驗收照 blueprint 的判準走【分布】：統領 66 隊相異 64、計謀 134 人相異 130（>0.7 池 5 人）、慎重→忍耐度 66 隊相異 62｜★★★而閘有一個盲點被我踩到：**它把【註解】算成產線讀點** —— 我先繞開了，修法給你（那是你的檔）
---

# ① 三條的落地形態（照 spec，不是照票的舊狀態）

| | 改法 | 為什麼 |
|---|---|---|
| **(a) 計謀** | `advisor.values.get("計謀",0.5)` → `advisor.skills.get("計謀",0.0)` | presentation 的語氣挑選（blueprint 重裁） |
| **(b) 統領** | `ctx.leader_values["_command"]`（`decision_context` 從 `leader.skills` 取，default `0.0`） | `terms.gd` 拿不到 skills ⇒ 走 `_loyalty`／`_is_merchant` 的同一套注入 |
| **(c) 順從** | → `慎重`，**`:521` 的註解公式一起改** | 不開第九軸；★註解本來描述一個不存在的輸入，那正是這票在治的病 |

★**default 三處都跟著 0.5 → 0.0（skills 側）**；(c) 走 values ⇒ 維持 0.5（正典鍵，0.5 是真的中位）。

# ② 驗收：★分布，不是單點（blueprint 判準）

```
統領→_command   母體 66 隊   min 0.003 / median 0.262 / max 1.000   相異 64
計謀技能        母體 134 人  min 0.000 / median 0.200 / max 0.884   相異 130
                >0.7（"sarcastic" 語氣的候選池）＝ 5/134 ＝ 3.7%
領主慎重        母體 66 隊   min 0.354 / median 0.500 / max 0.978   相異 64
苛稅忍耐度      母體 66 隊   min 0.238 / median 0.351 / max 0.448   相異 62
scout_drive     _cmd=0.0 ⇒ util 0.3000 ／ _cmd=0.9 ⇒ 0.7050（staleness 相同 ⇒ 差異只能來自 _cmd）
★反向對照三格   values 裡【沒有】統領／計謀／順從 這三個鍵 ⇒ 舊寫法的 0.5 是死值（不是「剛好都 0.5」）
=== DONE === SECTIONS=5/5 FAILS=0
```
★**床是 `scripts/debug/dead_value_keys_wiring_bed.gd`（acceptance）**，
★★**`SECTIONS=n/5` 照你要求推廣到這支了**（「中途崩＝通過」不再有第二次）。
★**(a) 的「比例合理」我只能給到這裡**：`5/134` 是**候選池**，不是實際語氣分布 ——
真的語氣分布要走顧問對話的呼叫路徑，**本票沒有量**（誠實限，別當成語氣佔比）。

# ③ 兩支閘

```
value-key-gate     PASS（正典 11 鍵）；★.value-key-baseline.tsv 的三行【已刪】
headless-regression PASS（失敗清單與 baseline 逐條相同 3=3）
bed-kind / bed-parse PASS
```

# ④ ★★★而 `value-key-gate` 有一個盲點，我踩到了：它把【註解】算成產線讀點

我在 `decision_context.gd` 寫了一句註解解釋舊寫法錯在哪，裡面自然出現了那個字串 ⇒
★**閘紅在【一句說明】上，而 code 是對的。**

★★**這種紅會教人把說明刪掉，而不是把 code 修對** —— 跟你今天說的「假紅讓人不再看這支閘」同族。

**我先繞開了**（把註解改成不含那個字串），**但那是繞開不是修好**。修法（你的檔，你決定）：

```
抽鍵之前先濾掉註解行：把 grep -rhoE 改成 grep -rhE | grep -v '^[[:space:]]*#' | grep -oE …
（三處：INJECTED / USED_PROD / USED_BED）
```
★**我實跑過陽性對照**：在 `scripts/simulation/` 塞一支只有 `values.get("這個鍵不存在")` 的檔 ⇒
閘確實紅並具名它（`✗ "這個鍵不存在"`），移除後回綠 ⇒ **閘的鑑別力本身是好的**，只有母體含註解這一格要修。
（★我試著自己改了兩次，都被這層 shell/heredoc 吃掉反斜線；與其留一個半殘的閘，我把修法給你。）

# ⑤ 下一站

三死鍵票完成 ⇒ 依 blueprint 的批一序列，下一站是 **②材料去重**。
★票還沒到我信箱 —— 你開票我就接。
