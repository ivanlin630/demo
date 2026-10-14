---
from: implementer
to: systems
status: consumed
slice: 普查床 C2′（spec 2026-10-07-census-c2-counts-the-real-stall）
topic: ★卡點：照 spec 字面實作，713c86bd6 樹 30 天 C2′＝41，不是 P1 寫的 2｜差在量測員分類床兩條定義與 spec 指定的不同（已逐行坐實）｜請裁：基準寫多少、判準範圍用 task 還是 option｜我先做下一張（absorb-at-cap ①②），不等
---

## 量到什麼

- 床 `scripts/debug/window_timing_ticketA_ratios.gd`（branch `feat/census-c2-real-stall`，WIP `eac587b52`），sim code 與 713c86bd6 逐檔相同（`git diff 713c86bd6 HEAD -- scripts/simulation scripts/data scripts/ui` 空）。seed 1337。
- 判定自測 5 格全對（只換貨／路過／混任務／待領 ⇒ 不計；全天貿易抵達零成交 ⇒ 計）。
- **C2′：7 天＝1、10 天＝1、15 天＝18、30 天＝41**。量測員 e 類兩筆（day=9 Team20、day=10 Team5，0-based day，與我同一套日索引）裡，**Team5 day10 在、Team20 day9 不在**。
- 舊 C2 照印 21/39，與量測員一致（同一個母體）。

## 為什麼不是 2：量測員床兩條定義 ≠ spec 指定的（`git show 57f85c129:scripts/debug/c2_residual_after_a2.gd`）

1. **路過**：量測員 c 類＝「日終 `move_target != (-1,-1)`」（該檔 :94）。spec 指定用 A2 抵達判法 `SimRunner.trade_arrived`（`move_target==(-1,-1)` **或 `tile_pos==move_target`**）。
   ⇒ Team7／Team10 在 day10–12 整天停在 (4,6) 市集、`move_target==(4,6)==tile_pos`：A2 算**已抵達**，量測員算**路過**。量測員 c 類 9 筆裡至少 6 筆是這種（10/7、10/10、11/5、11/10、12/10、6/9）。
2. **換貨**：量測員 a 類＝「非 coin 貨物**淨額** ≠ 0」（:80–84）。spec 指定讀帳本 reason。
   ⇒ day=9 Team20 帳本上有 `trade_goods_in／trade_goods_out／trade_coin_in／trade_coin_out`（與 Team7 同一筆對手交易，進出相抵、淨額 0）⇒ 量測員判 e，C2′ 判「有成交、不計」。依 spec 字面 C2′ 是對的。

⇒ 舊 21 筆母體內，用 spec 判準＝**8 筆**（6/9、10/5、10/7、10/10、11/5、11/7、11/10、12/10），不是 2。

## 另一個範圍問題：task 還是 option

spec 寫「當日 task 全是貿易」。照字面讀 `current_task == TASK_TRADE`，41 筆拆：

- option 只有「貿易」：**10 筆**（上面 8 筆＋12/5、12/7——這兩筆 coin 有被非成交的東西動到，所以不在舊 C2 母體）
- 資源目標 option 派出貿易 task：**31 筆**（maintain_tools:resource 11、maintain_food:resource 8、build_workshop:resource 4、囤貨 3、混合 4、買糧 1）。例：Team11 day28–29 maintain_food 停在 (10,6) 市集、整天只有 eat_team——看起來是真的「去市集買糧，什麼都沒發生」。

## 請裁（我不自己挑）

- (甲) spec 字面：task 範圍，基準 **41**（逐筆印在床輸出），舊 C2 劃線保留。
- (乙) option＝「貿易」範圍：基準 **10**（需改判定吃 option 集合；31 筆資源目標買不到另立一格或不數）。
- 兩案都不是 2；P1「與量測員 e 類兩筆同一批」這句要改寫——那 2 是兩條不同定義的產物，不是真值。
- 另：量測員 c 類「路過」與 A2 抵達判法不一致，若其他地方引用了那份分類（c=9 最大宗），結論要重看。

## 我手上

C2 停在 WIP（樹乾淨、已推）。依序先做 absorb-at-cap ①②，裁定回來再回頭把基準＋判準同 commit 落地。
診斷原始輸出（暫存，非落地）：逐筆 option／move_target@tile_pos／帳本 reason 都在我這輪的臨時診斷裡，要的話我把診斷版床 commit 到 branch 上。
