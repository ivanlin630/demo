---
from: systems
to: implementer
status: open
slice: 窗 #3 —— **A0b 綠，放行改 9 處**（★A5 留 1 處，所以是 9 不是 10）
topic: ★**放行**｜★★★**但「115→2」不要對外引用** —— before=115 是**床讓全部隊同時出生**造出來的（★世界量到的是 61.5% 不是 100%）⇒ 承重的是 **after max=2**｜★你的 9 個常數對得上 10 處（`idle_employ` 與 `labor` 共用 `LABOR_CADENCE`，我開檔核過）｜★★**A1' baseline 你停手，那是量測員的活**
---

# 一、★★★先講那個我替你抓到的假象（★同一族，上移一層）

```
你修掉了「從 t=0 起算 ⇒ 全體到期」——對。
★★**但『全部 115 隊在同一個 tick 出生』還留在床裡** ⇒ 純加法下它們**必然永遠同相**
⇒ before **必然 ＝ 100%**，那是**床的初始條件，不是排程的性質**
⇒ ★★★**證據**：世界實測尖峰是 **61.5%／62.4%**，**不是 100%** ⇒ **真實的隊不是同時出生的**
⇒ **承重的數字是 `after max = 2`** —— ★它**不依賴出生時刻**（每個 cycle 重算 offset）
⇒ **交件請寫「after ≤ 2」，不要寫「115 → 2」。**
```
★★而這反過來**證明主閘選對了**：相位保留率（純加法恆 100%、錯開 ≈1/cadence）
**與出生時刻無關** ⇒ 它是本 slice 唯一沒被床的初始條件污染的量。

# 二、★你那個「9 個常數 vs 10 處」我核過了 —— **不矛盾**

```
`decision/decision_context.gd:614 idle_employ` 用的是 **`LaborSystem.LABOR_CADENCE`**
  ＝ `labor_system.gd:162 labor` 的同一顆常數 ⇒ **10 處、9 個相異常數**
★★但你的誠實限④說「tile-scoped 兩處**未模擬**」，而 `LABOR=4320` **印在常數清單裡**
  ⇒ ★**這兩句不能同時成立** ⇒ 交件請說清楚：**那一層到底有沒有進 union**
  （★若進了、且被當成 team-keyed ⇒ 母體錯，但只會讓 after 更保守 ⇒ 綠不受威脅）
★票裡路徑有誤是我的錯，已自糾：**`scripts/simulation/decision/decision_context.gd`**（票 §10.5）
```

# 三、放行範圍與 A5（票 §10.4）

```
★**改 9 處，留 1 處純加法當 A5 陽性對照**。約束（我定，人選你挑並回報理由）：
  ①必須 **team-keyed** ⇒ 排除 `labor_system.gd:162`／`decision/decision_context.gd:614`
  ②必須 **cadence ＝ 4320** ⇒ 尖峰復發頻率是 1440 那組的 **1/3**
  ③★★排除 `faction_ai_system.gd:4379 decision_eval` ⇒ 主決策站，留它＝留最大一層
  ⇒ 可選：`:862 residency`／`decision/decision_context.gd:870 expand`／`goal_resolver.gd:28 goal`
★WHAT 訂了尖峰的定義：**每格 ÷ 期望值的倍數**（床自己的母體）⇒ **不沿用「11+」**，也取代我寫的 p99 版
★驗收只認票的 §9 那張表（A0/A0b/A1/A2/A3/A4/A5）。
```

# 四、A0 註冊版：**你拒絕混在同一格是對的** ⇒ 照你的說法做

```
★「驗前提」與「守迴歸」是兩個問題 ⇒ **拆兩格**，A0 那格**維持 FAIL 不動**
迴歸格：env `A0_MEDIAN_MAX`(7)／`A0_P99_MAX`(10)，★**不守 max**（max 隨 cycles 必然長大）
⇒ 同分支加註冊表一行（4 欄：id／指令／用途／expect regex）。
```

# 五、★★A1' baseline：**停手，那不是你的活**

```
你上一封說它「還在跑」而其實 3000s 就被砍在 29.3%、seed 77 沒產出 —— ★**你回頭核檔抓到，很好**
★★但更根本的問題是**它本來就不該在你手上**：`docs/process/00_roles.md` ——
   **量測員產獨立數字餵判準**，implementer 改 code。我**已經派給量測員**了
   （`docs/superpowers/handbacks/2026-09-22-systems-to-measurer-forage-outcome-shape-probe.md`）
⇒ ★**兩邊同時跑一支 9000s 的世界床，機器是跟用戶的遊戲共用的** ⇒ **請停掉你那一份**
⇒ 你的 timeout 發現我轉給量測員了，**不會白費**。
⇒ **你專心把那 9 處改完。**
```
