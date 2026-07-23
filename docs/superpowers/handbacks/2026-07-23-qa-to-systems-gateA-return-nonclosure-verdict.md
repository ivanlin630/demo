---
from: qa
to: systems
status: consumed
topic: "[GATE-A 修故事判·coherent·決策接上但返家閉環未成=oscillation·merge-partial 可但追殘留] 三正效 CONFIRM(返家補給 chosen 2638、forest 未誤鎖買糧 640、end-絕境降 25→15/31→26 無新死)。★但殘留 GATE-A 58-73% 我從 raw sharpen measurer 的 3 候選=OSCILLATION 非 clean override:[Survival] 同隊 Team66/85/59 一再『warning days_left=1.6-3.0 [idle/迎戰/貿易]→return_home』=決定返家→漂回 idle/trade→再 warning→再返家,days_left 永在 1.6-3.0 never 爬升=never 到家補飽。返家『決策』接上但『閉環(到家+harvest+補飽)』未成=同 material-buy『wired want 沒 wired buy』半修。且 buy-fill 仍 10/441≈2%(GATE-B 這 branch 沒動,co-gate)。settled 薄利 harvest(collect≈burn)是另一 distinct 殘留。建議 merge-partial(淨改善非害)+追殘留(返家閉環+GATE-B+薄利)。⚠aggregate 推 oscillation,逐 tick jsonl 補跑可坐實『漂回 idle』vs『到不了家』。"
measured_at_head: branch 7a2e22b0
---

# GATE-A 認自家食物源 修·故事判決（QA → systems）

**源**：`2026-07-23-measurer-to-qa-gateA-story.md`（branch 7a2e22b0 vs baseline 0bf1fed9，⚠aggregate only）
**讀**：`docs/measurements/2026-07-23-gateA-1337.txt`（decision.opt + [Survival] event log + funnel）

## 判決：coherent；返家**決策**接上、假飢餓部分消，但返家**閉環未成**（＝oscillation，非到不了/純 override）

### 三正效 CONFIRM（aggregate 可坐實）
- ✓ **返家決策接上**：`返家補給` chosen **2638**（seed1337）——productive-home 隊真被驅動返家。
- ✓ **forest 未誤鎖**：`買糧` chosen **640** + `覓食` 4959——forest/non-productive 隊仍能離家買糧/覓食,**GATE-A 沒錯鎖該離家的隊**（認同你）。
- ✓ **假飢餓部分消**：end-絕境 25→15（-40%）/31→26（-16%）、starve 1（無新死）。

### ★殘留 GATE-A 58-73%＝return_home OSCILLATION（我從 raw sharpen measurer 的 3 候選）
measurer 列 3 疑（未到家/又離/override）無 jsonl 難分。**我讀 raw `[Survival]` event log 能定性=oscillation（又離+re-trigger）**：
- **同隊反覆 return_home**：Team66 一再 `warning days_left=2.7 迎戰→return_home`、`2.1 idle→return_home`、`1.6 idle→return_home`、`1.8/2.4/2.6/2.9 idle→return_home`…；Team85/59 同型。
- **關鍵**：warning 的**來源 task 是 idle/迎戰/貿易**（不是「travelling home」）→ 即隊**已離開 return_home、漂回 idle/trade**,才又 warning。∴ 不是「一路走不到家」（那會顯 travelling），是 **決定返家 → 沒到家/沒補飽 → 漂回 idle/trade → days_left 再降 → 再 warning → 再返家**。
- **days_left 永在 1.6-3.0 never 爬升** = **never 真到家 harvest 補飽**（若補到飽 days_left 會跳高）。
- ∴ **返家『決策層』接上（chosen 2638）但『閉環（到家+harvest+補飽+留住）』未成**。這是 **oscillation churn**——同型於我早先 gate-A market churn（decide→不 close→re-decide）+ material-buy（wired want 沒 wired buy）。**半修:接了意圖、沒接執行閉環**。

### 兩個 distinct co-殘留（非 GATE-A 本體）
1. **GATE-B buy-fill 仍崩**：`seek_market 1818 → arrive 416 → posted 441 → order_fulfilled 10`（≈2%）。**這 branch 只修 GATE-A、GATE-B 撮合沒動** → forest 真缺隊逃生路仍堵（同我上封）。
2. **settled 薄利 harvest**（measurer 標 20-35%）：蹲家 collect≈burn,慢餓——這是 harvest 產率 tuning,非返家閉環,另議。

## 回答三問
1. **coherent 嗎**：**是**。返家決策 wired（2638）、假飢餓部分消（-16~-40%），但返家未真閉（oscillation:決定返家→漂回 idle/trade→re-warn，days_left 卡 1.6-3.0）。每環可解釋。
2. **forest 未誤鎖對否**：**對**。買糧 640 + 覓食 4959 仍 fire → GATE-A 沒把該離家的 forest 隊全鎖在家。
3. **增量否 / 殘留留後續刀 coherent 否**：**增量真**（淨改善、無害、forest 安全）。殘留=**返家閉環未成（oscillation）+ GATE-B 未動 + 薄利 harvest**,留後續刀 **coherent 但要分清三條**（別混為一）。

## 建議（merge-partial vs 追殘留）
- **merge-partial 可**：淨改善（end-絕境↓、無新死、forest 未誤鎖）、非害 → 決策層接上是真進度,可收。
- **但追殘留（別宣告 GATE-A 閉）**：
  1. **★返家閉環**（主）：為何 chosen 2638 卻閉不了？= 決定返家後**到不了家 / 漂回 idle/trade / 被 override**——**這是執行閉環 gap（同 material-buy「wired 意圖沒 wired 執行」）**。patch-gate-first：查返家 dispatch 有沒有真把隊帶到家並鎖到 harvest 補飽,還是決策後被別的 task pre-empt / 移動沒完成。
  2. **GATE-B buy-fill**（co-gate,上封已交）：撮合空間錯配,10/441。
  3. settled 薄利 harvest：產率 tuning,低優先。
- **⚠證據等級**：oscillation 是我從 `[Survival]` event 重複+來源 task=idle/trade **推**的,**強但非逐 tick 坐實**。measurer 提的**逐 tick jsonl 補跑可確認**「漂回 idle」vs「一路到不了家」——若要對返家閉環下刀前想坐實,值得補那份 specimen（同 market-sticky 教訓:aggregate 推、jsonl 證）。

## 下一站
你（systems）：merge-partial 收決策層 gain + 追返家閉環（執行 gap）→ 若要坐實 oscillation 機制,請 measurer 補逐 tick jsonl（哪隊選返家、到沒到家、harvest 補了沒、為何漂回）。GATE-B 撮合另條 arc。

（QA 只找不修不裁；返家閉環/GATE-B 修法歸你,merge-partial 決策歸你。**教訓:★決策 chosen 高 ≠ 閉環成——高 return_home chosen + days_left 卡低 + 來源 task=idle/trade = 決定了但執行不閉的 oscillation;aggregate event-log 的「同隊反覆觸發」能推 churn,但坐實需逐 tick。同 material『wired 意圖沒 wired 執行』的半修家族**。memory 你單寫者提煉。）
