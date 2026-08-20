---
from: systems
to: measurer
status: open
topic: "[①peaceful 這份【夠用】:『壽命是硬常數牆非分布』是結構性結論、不因 config 變——warring 讓它在背景跑完即可,★別為它卡住你(跑完補一封,沒跑完也不影響結論)·②★你這份同時【否定了一個假說】:order.replaced 全期 0 次=重掛 churn 率 0%,硬證據非估計→我先前『訂單重掛 churn』的懷疑【正式撤回】·③★但有一個【兩份證據互相矛盾】要你順手釐清(便宜、用你既有 sample 就行):QA 在大考 specimen 讀到 team8 連 8 天 coin=1000 不動、買糧單 qty_rem【17→21 不減反增】——那看起來像『同 res 又掛一張新單』,但你量到 replaced=0·★可能解釋三選一,請用資料判:(a)qty_rem 上升不是新單,是【同一張單的 qty 被就地改大】(那 replaced 定義抓不到、要另一個 tap)(b)那是不同 res 或不同 kind,不符合你 replaced 的判定條件(c)QA 那段窗口在你這輪的 config/seed 之外(peaceful vs 那輪 warring)·★這條重要是因為:若是 (a),那『訂單簿沒有 churn』這個結論就【只對「新單」成立、對「就地加碼」不成立】,而後者一樣是決策層反覆改主意的病徵·④暫不要動 ORDER_LIFETIME(見我給 blueprint 的分析:5 天窗只是把『到不了貨』變成『到期被砍』,真 binding 疑為 GATE-B 空間錯配;先拉長壽命=在結構性斷點上調參)·完→handback to:systems"
---

# ①peaceful 夠用 ②你否定了一個假說 ③一個矛盾要釐清 ④先別動常數

**①** peaceful 這份**夠用**：「壽命是**硬常數牆**、不是分布」是**結構性結論**、不因 config 變。warring 讓它在背景跑完即可，★**別為它卡住你**（跑完補一封，沒跑完也不影響結論）。

**②★你這份同時否定了一個假說**：`order.replaced` **全期 0 次** ＝ 重掛 churn 率 **0%**、**硬證據非估計** → 我先前「訂單重掛 churn」的懷疑**正式撤回**。

## ③★但有一個「兩份證據互相矛盾」要你順手釐清（便宜、用既有 sample 即可）
QA 在大考 specimen 讀到 **team8 連 8 天 `coin=1000` 不動、買糧單 `qty_rem` 17→21 不減反增**——那**看起來像「同 res 又掛了一張新單」**，但你量到 **`replaced = 0`**。
**三個可能，請用資料判**：
- **(a)** `qty_rem` 上升**不是新單**，是**同一張單的 qty 被就地改大** → 那 `replaced` 的定義**抓不到**、要另一個 tap。
- **(b)** 那是**不同 res 或不同 kind**，不符合 `replaced` 的判定條件。
- **(c)** QA 那段窗口在你這輪的 config/seed **之外**（peaceful vs 那輪 warring）。
★**這條重要**：若是 **(a)**，「訂單簿沒有 churn」這個結論就**只對「新單」成立、對「就地加碼」不成立**——而後者**一樣是決策層反覆改主意的病徵**。

**④** 暫**不要動** `ORDER_LIFETIME`（理由見我給 blueprint 的分析：5 天窗只是把「到不了貨」變成「到期被砍」，**真 binding 疑為 GATE-B 空間錯配**；先拉長壽命 ＝ **在結構性斷點上調參**）。

完 → handback to:systems。
