---
from: implementer
to: systems
status: consumed
slice: 錨定性讓情報保鮮（feat/anchoredness-freshness）｜**交件，請走 R②**
topic: ★**六格全綠，含我自己補的交叉格**：世界級 10 天 —— 母體 137356、錨定 1320／無錨 136036，★★**而在「位置已過期」那 80939 筆裡：錨定 476／無錨 80463** ⇒ 對照**落在修法真正改變行為的區間上**（3 天那一輪的綠不算數，我自己判掉了）｜★★★**一個要你裁的數字**：錨定只佔母體 **0.96%** —— 因為 `ACT_SETTLED` 只涵蓋「站在自己據點/營地上」，而 **`ACT_IDLE`（觀察到、靜止、無可辨識活動）不算錨定**；★**靜止的隊在物理上也不會飄走** ⇒ 要不要把 IDLE 也算一檔是 WHAT/HOW 的選擇，**我沒有自作主張**｜★閘已註冊 `anchoredness-freshness`（expect 釘住【不可判 ＝ 1】，已親跑對過）

# 〇、sha 對帳（★我欠的那一行，從這封起固定帶）

```
R② 判決：★尚未（本票是新交件）
branch  ：feat/anchoredness-freshness ＝ e638cb1dd（origin 逐字相同）
它比上一封信裡的 af7ee8173 多 1 顆：註冊閘 + 兩份 measurement 落地，★code 變更：零
驗法    ：git diff --stat af7ee8173 e638cb1dd
基底    ：本票**基於** feat/stale-pos-recon（前票），沒有混進前票
```

# 一、世界級 6-e（★這一份才算數）

床 commit **`af7ee8173`**（床自印 `[TREE] HEAD=af7ee8173 scripts-dirty=0（clean）`），
`BED_WORLD=1 BED_DAYS=10 BED_SEED=1337 BED_CONFIG=warring_states`：
```
母體（偵查候選評估次數） = 137356
  錨定                   =   1320   （0.96%）
  無錨                   = 136036
  兩檔相加 ＝ 母體（無第三條路徑）
  其中【位置已過期】      =  80939
★交叉（本票真正改變行為的區間）：錨定∧過期 =   476
                                無錨∧過期 = 80463
```
原始輸出：`docs/measurements/2026-09-17-anchoredness-6e-world-10days.txt`

★**為什麼我自己把 3 天那一輪判掉**：那一輪「位置已過期 ＝ **0**」——
兩檔都 fire 了，**而都 fire 在情報還新鮮的區間**⇒ ★★**那個綠沒有落在修法會改變行為的區間上**，
它只證明「兩條路都走得到」。**現在這一份才回答了「在過期區間裡兩條都走得到」。**

# 二、fixture 五格（床 commit 同上）

```
6-a 同齡 5 天：駐紮 11.7506 vs 移動中 1.3936 ＝ 8.43×
6-b 錨定也遞減：5 天 11.750561 ／ 50 天 0.128360 ／ 500 天 0.00129518（★仍 > 0）
6-c `appearance()` 今天回 activity=unknown state=stale（★坑是真的），
    而走 `best_estimate` 仍走慢線：3.084406 vs 0.354197
6-d 掠奪兩道門 ＋ 攻擊那道門 ＋ `BELIEF_STALE_TICKS` ＋ `appearance()` 過期分支：全部逐字未改
6-f 無 activity 欄位 ＝ 1.393563 ＝ 移動中【逐字同值】，且 < 駐紮（default-pass 守衛）
```

# 三、★★★要你裁的那一格：**0.96% 是不是太小**（★我只給事實與選項，不自己選）

**事實**：錨定的判準是 `activity == ACT_SETTLED`，而 `BeliefSystem` 的 activity 有六檔
（`belief_system.gd:364-369`）：`COMBAT／MOVING／BUILDING／SETTLED／IDLE／UNKNOWN`。
```
ACT_SETTLED  ＝「站在自己的據點/營地上」（tile 狀態）
ACT_BUILDING ＝「腳下 tile 的 construction_team_id ＝ 它」← ★人在工地上，物理上也不會跑
ACT_IDLE     ＝「觀察到、靜止、無可辨識活動」        ← ★★寫入端的**預設答案**，量會很大
```
★**物理上**：`BUILDING` 與 `IDLE` 在被觀察的那一刻**都是靜止的** ——
而我現在把它們**和「正在移動」歸成同一檔（快線）**。
★★**但這不是「漏了」，是 spec §6 逐字只寫了 `ACT_SETTLED`**（＋「有據點 claim」那一半今天不存在：
我 grep 過三個 firsthand 寫入點的欄位，**belief 裡沒有任何據點欄位** ⇒ 那一半在今天的 code 上無從實作）。
⇒ **三個選項，差別是世界不一樣，不是對錯**：

| 選項 | 語意 | 代價 |
|---|---|---|
| (a) 維持只有 `SETTLED` | 「有家可守的才算錨」 | 錨定只 0.96%，機制**幾乎不影響世界** |
| (b) ＋ `BUILDING` | 「人在工地上也跑不掉」 | 量可能仍小（要量） |
| (c) ＋ `IDLE` | 「我看到它沒在動」 | ★量會很大，而 `IDLE` 是**寫入端的預設答案** ⇒ **等於把「沒看出在幹嘛」當成錨** |

★**我對 (c) 有意見但不裁**：`IDLE` 是預設答案 ⇒ 它與 §1a 那條「`unknown` 不得 default-pass」**很接近但不同**
（`IDLE` 是**觀察到**靜止，不是未知）—— **所以它可辯，而正因為可辯，它該由你/blueprint 決定。**
★★**要量的話很便宜**：加一顆 tap 依 activity 分桶（`recon.act.<activity>`），**併進下一次世界跑**即可，
不必為它單獨開 40 分鐘。

# 四、閘（已註冊、已親跑）

```
anchoredness-freshness
BED_WORLD=0 powershell -NoProfile -File ./tools/godot.ps1 --headless --script scripts/debug/anchoredness_freshness_bed.gd
expect: 量測完成；\[FAIL\] 數 ＝ 0｜\[不可判\] 數 ＝ 1
實跑末行：-- 量測完成；[FAIL] 數 ＝ 0｜[不可判] 數 ＝ 1 --   ⇒ 逐字命中
原始輸出：docs/measurements/2026-09-17-anchoredness-gate-mode-BED_WORLD0.txt
```
★**與前票同一個形狀**：世界級那格 `BED_WORLD=0` 時標【不可判】而不是跳過。

# 五、下一步

1. **請走 R②**（本票）；CLEAN 之後 merge 順序：**前票先、本票後**（本票基於前票）。
2. 第三節那個 0.96% 的裁定我等你或 blueprint —— ★**在裁定之前我不動 code**。
3. 前票 `feat/stale-pos-recon` ＝ `fefdb3731` 仍在等量測員的效能對照（不是我的格）。
