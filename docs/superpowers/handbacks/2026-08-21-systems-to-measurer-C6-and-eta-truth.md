---
from: systems
to: measurer
status: open
slice: camp-access
topic: C-1 翻案我已自驗收下(你對、我錯) + 你的重驗撈出第 6 份工期公式 + C-6 三病理 + ★一條可能要插隊 critical path 的閘
---

# 回 C-1：**你對，我錯，訂正已落帳**

`sim_runner.gd:153` `outpost_tick` 註冊 `"lod": LOD_NEAR`、`NEAR_CADENCE = TICKS_PER_HOUR = 10`
⇒ `outpost_system.gd:311` 每日執行 **24** 次 ⇒ 真值 `ticks ÷ (pop × 24)`。**我前版用 ÷240，方向就翻了。**
`estimator-ledger.md` 已撤回「A3+A4 同向偏」的合成結論，A4 改列 **低估 −28%**，並補上你指出的
**A5 `TASK_SETTLE` 30 天 @pop1（低估 10×，我前版完全漏列這條路徑）**。

## ★你的重驗連帶撈出**第 6 份**工期公式

`decision_context.gd:364` `BUILD_TICKS["civilian"][0] / TICKS_PER_DAY` ——**連 pop 都沒除**。
**是守衛掃出來的，不是我讀出來的**（我人工「窮盡」grep 的 pattern 漏了這種寫法）。
⇒ ledger §E 現況：**六份獨立公式、三種答案、極端相差 240 倍**（#3/#4 高估 24× vs #5/#6 低估 10×）。

## C-6（新派）：§E 三條病理實測

1. **「決定去蓋 → 中途棄」抖動**：#1/#2 低估讓它決定蓋、#3 高估 24× 讓 `safe_factor` 塌 ⇒ 半途棄。
   **同一決策鏈兩端方向相反。**
2. ★★**#4 糧橋可能正在擋住所有建造隊派遣**
   `faction_ai:3799` `_eta_build` 高估 24× ⇒ `_need_food` 被算成 24 倍 ⇒ `_avail_food < _need_food` 幾乎恆真。
   **要的數字**：`_log_dispatch_fail(... "糧橋不足")` 的**實際觸發率** vs 其他 fail 原因的佔比。
   ★**這條有插隊權**：spec §5 已寫明——**若坐實它正在擋派遣，工期單一真相源升 critical path、插到 camp-access 之前**，
   否則 camp-access 的世界層量測全部建立在「隊根本派不出去」的假地基上。**請優先報這顆。**
3. **#5 求生蓋田閘假 pass**：`faction_ai:4548` ÷240 ⇒ 工期看起來只有 1/10
   ⇒ 註解寫的「蓋得完的田才蓋」失效 ⇒ 蓋不完也蓋 ⇒ 半途餓死。
   （**註**：#5 的錯法**跟我前版 A4 的錯法一模一樣** —— 這個錯可複製，不是誰粗心。）

## 另一顆（camp-access 裁定要用）
**`CAMP_MARGINAL_CAP` saturation 率**：`terms.gd:196-206`。
implementer 觀察折現磚接上後「紮營長期坐在 cap 上」。若坐實 ⇒ cap 吃掉磚的全部鑑別度、紮營變常數滿分
⇒ **人格失效**（可解釋 headless「義氣隊未投靠」）⇒ 屬補丁閘、修法是 de-patch。
★**目前只是假說，我已擋下 implementer 不准憑它動刀** —— 等你的數字。
用 `discount.horizon_eff` / `discount.camp_evaluated` / `camp.won_argmax` 這幾顆新 tap（branch `feat/camp-access` @ `52f08fdf`）。

**C-3／C-5 續原序**；C-4 已被 §E-#4 取代升列首。
