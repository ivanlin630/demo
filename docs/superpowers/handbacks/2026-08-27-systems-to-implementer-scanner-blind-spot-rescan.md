---
from: systems
to: implementer
status: open
slice: S1c-scanner-name-heuristic
tier: refactor
topic: ★★★★★假說二成立且有 file:line:message_system.gd:3-5 的 MSG_TTL_* 是硬編 tick(1680/3360/7200,用舊 240 算的)⇒S2 後實際時長 1/6(30天→5天);★★★而我查清楚了它是【候選集就漏】不是【判錯】——兩份清單都沒有它;★★★★盲點一句話:掃描器靠【同行有 tick 符號】找,而這一類【自己就是那個值】,不需要引用任何 tick 符號 ⇒「找引用者」抓不到「定義者」
---

# ★★★★★①假說二成立，證據是 code 不是統計
```gdscript
message_system.gd:3   const MSG_TTL_SHORT:  int = 1680   # 7天  × 240 ticks/day
message_system.gd:4   const MSG_TTL_MEDIUM: int = 3360   # 14天
message_system.gd:5   const MSG_TTL_LONG:   int = 7200   # 30天 = TICKS_PER_MONTH
```
★**硬編 tick，用【舊根 240】算的** ⇒ ★★**S2 後 `TICKS_PER_HOUR 10→60` ⇒ 實際時長變 1/6（30 天 → 5 天）。**
★★★**`MsgPrune` 全域刪除 +90.6% 佐證方向** ⇒ **訊息送達 −76% 有機制了；而逾時觸發重評 ⇒ 決策 +22% 也對得上。**

# ★★★②而我查清楚它是【候選集就漏】，不是【判錯】
```
docs/measurements/2026-08-27-bare-tick-candidates.txt  → ★grep MSG_TTL ＝ 空
docs/measurements/2026-08-27-bare-tick-triage.txt      → ★★同樣是空
```
⇒ ★**它從來沒進過候選集** —— **不是你判錯，是掃描器看不到它。**

## ★★★★盲點一句話
> ★**掃描器的候選判準是【同一行有 tick 符號】（`current_tick`／`TICKS_PER_*`／`*_next_tick`／…）**
> ★★**而這一類【自己就是那個值】—— 它不需要引用任何 tick 符號。**
> ⇒ ★★★**「找引用者」抓不到「定義者」。**
★**（第 5 行的註解裡確實有 `TICKS_PER_MONTH`，而掃描器剝註解 ⇒ 連那個偶然的鉤子也沒有。剝註解是對的，不要改。）**

---

# ★★★③要做的（S1c）
```
①★掃描器加【名字啟發式】：常數名含 TTL／TIMEOUT／DURATION／INTERVAL／CADENCE／EXPIRE／TICKS
   ⇒ ★★其右值的 int 字面量【也是候選】，即使該行沒有任何 tick 符號
②★★重掃 ⇒ 產【新增候選】清單（★與舊 143 筆分開列，讓人一眼看出這次補到什麼）
③★★★逐顆結案（沿用四類 a/b/c/d ＋ 理由留 code 註記）
④measurer 額外抓到的 3 個同型漏網常數 ★一併納入這一輪判，不要另開
```
★**名字啟發式會有偽陽性**（例如 `RETRY_INTERVAL` 其實是次數）—— ★★**那沒關係：偽陽性進 `NEEDS_HUMAN`，而漏判才是致命的。**
★★★**照你自己立的那條：讓漏判往【吵】的方向倒，不要往【安靜】的方向倒。**

# ★④驗收
1. ★**重掃後 `MSG_TTL_SHORT/MEDIUM/LONG` 三顆【必須】出現在新候選裡** —— ★★**這是本票的陽性對照，不是附帶。**
2. ★**陰性對照**：**一個名字像但實際不是時間量的常數（例如次數型 `*_RETRY_COUNT`）⇒ 判進 `NEEDS_HUMAN` 或 (d)，而不是被自動改**
3. ★★`fp` 兩床：★★★**掃描器改動 ＝ 純工具 ⇒ `fp` 必須不變**；**而修 `MSG_TTL_*` ＝ 行為改動 ⇒ `fp` 會變**
   ⇒ ★**兩者【分兩個 commit】，否則你分不出哪個造成 `fp` 變**
4. 三閘 PASS（憲法／裸 tick／headless baseline 7）

# ★⑤而修 `MSG_TTL_*` 本身要注意的
★**改成宣告式時，要保住【它原本代表的天數】**（7／14／30 天），**不是保住 tick 數。**
★★**而註解 `# 7天 × 240 ticks/day` 現在是【錯的】** —— **順手改掉，否則它會誤導下一個人。**
