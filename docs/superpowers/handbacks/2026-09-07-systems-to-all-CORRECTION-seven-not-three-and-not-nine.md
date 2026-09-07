---
from: systems
to: all (measurer/implementer/blueprint/qa/reviewer)
status: consumed
topic: ★★★訂正我自己兩次：`gather` 純讀路徑寫的是 **7 處**，不是我先報的 3，也不是我接著要報的 9；★★而 `ewma_advance_test` **是對的**——那 2 處由 `if advance:` 守著，是我多算
---

# 一、★真數（逐站查過守衛，不是數賦值行）
```
★純讀路徑【會寫】= 7 處（都是【節奏快取】，與 advance 無關）
  :310 :311  _btile.idle_employ_cached / idle_employ_next_tick     守衛＝cadence
  :454 :456  team.expand_eval_next_tick / expand_site_cached        守衛＝cadence
  :732 :734 :735  consolidate_target_cache / absorb_target_cache / consolidate_eval_next_tick
★不算 = 2 處
  :790 :792  team.need_urgency / plan_phase  ← ★由 `if advance:` 守著
             （gather 簽名 `advance: bool = false`）
```

# 二、★★我錯了兩次，方向相反
```
第一次報 3 ⇒ ★少算：我用了帶過濾的 grep，漏掉 :310/:311/:456/:735
第二次要報 9 ⇒ ★★多算：我數了賦值行，★★★但【沒有查每一行的守衛】
⇒ 而 `ewma_advance_test` 是綠的、6 條斷言全 PASS ——
  ★★★它跟我的數字矛盾，而【對的是它】
```
★**我停下來的原因是那個矛盾**：一支綠的守衛床與我的數字打架時，
**我不假設是床錯**——去讀了現場，然後發現是我。

# 三、★★★機制（比我原先講的精確）
```
多呼叫一次 gather()，若剛好落在【節奏到期】的 tick
⇒ 快取被刷新，★而且 *_next_tick 被往後推
⇒ ★★【下一次合法的評估被延後】⇒ 事件時序位移
```
★所以它不是「觀測讀到髒值」，是**觀測把別人的鬧鐘按掉了**。

# 四、★正解就在同一個函式裡
```
:788 `if advance:` —— ★EWMA 已經用這個模式解過同一個問題
⇒ ★★而其他 7 處【沒有套用】⇒ 修法是【把同一個模式補上】，不是發明新東西
⇒ token `gather-not-pure-read` 已按真數改寫，判準兩向驗過（現 rc=1、模擬已修 rc=0）
```

# 五、★給 measurer 的具體下一步
```
★短期（不必等修）：床觀測時呼叫 gather(state, team) 的地方，
  ⇒ 檢查是否可以改讀【已經被 gather 過的 ctx】而不是自己再 gather 一次
★★而若非 gather 不可 ⇒ 卷面標明「本量測會按掉節奏快取的鬧鐘」，
  ⇒ ★★★這條誠實限比「純讀」那句準確得多，而床檔頭現在寫的是後者
```
