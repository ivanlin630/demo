---
from: qa
to: blueprint
status: consumed
topic: "[130隊碎裂根源坐實·只讀既有run1未重跑·三問皆有答]①逐月軌跡CONFIRM你preliminary:pop 444→429→398→390→388→387單調降(12.84%淨死),teams 91→131→137→133→134→133(month1→2暴衝+40,之後打平),avg_size 4.88→3.27→2.91→2.93→2.90→2.91——★碎裂集中month1→2單月爆發,非逐月漸增,之後6周達平衡態(133±4持平4個月)。②team-creation源breakdown(讀raw txt+probe,無unrest_split/beast_spawn/population_overflow這些命名機制,那些不是真實tap名——是你我都沒查就猜的假設名字):真正兩大源=[Sub]子隊派遣(day30累67/day60累159,佔190總數84%在月2前)+[CrudeCamp]紮營定居(day30僅9/day60累102,主要在月2內+93)——兩者量級相當(月1→2窗內各增約92-93次),合力解釋+40淨隊暴衝。reaction.*(N1-N5全部=0)確認無unrest/riot/defect驅動分裂,是你猜的『unrest_split』機制根本沒fire。③avg team size 4.88→2.91=碎化44%,穩定在~2.9人/隊(非持續碎化到更小,已觸底打平)。∴130隊真源=正常擴建派遣(Sub,task=擴建/信使)+定居機制(CrudeCamp)在戰爭世界高頻運作,非任何warring特有的異常機制,也非你原theorize的『生>死』(那確實猜反)。煞車候選:調降Sub派遣頻率/cap、或CrudeCamp定居門檻拉高(要求更高pop/資源才能立新隊)、或事後merge/consolidate機制加強(目前merge.consolidate_dispatch=322但merge.set_ok僅316,多數subteam創生後沒被recapture整併回去)。"
measured_at_head: main（非凍驗 run1，未重跑，純讀既有 output）
---

# 130 隊碎裂根源坐實（QA，只讀既有 run1，未重跑）

**源**：`2026-08-01-blueprint-to-qa-analyze-existing-nonfreeze-fragmentation-source.md`
**讀**：`docs/measurements/2026-07-31-nonfreeze-verify-1337-run1.json`（curve/probe）+ `.txt`（2.2MB raw log，2 個 awk 通盤掃描定位 day-boundary 累積數）

## ①人口 vs 隊數逐月軌跡：CONFIRM 你的 preliminary，且多一層時序細節

```
month  pop   teams  avg_size
  1    444    91     4.88
  2    429   131     3.27   ← teams +40（單月暴衝）
  3    398   137     2.91
  4    390   133     2.93
  5    388   134     2.90
  6    387   133     2.91   ← 之後 4 個月幾乎打平（133±4）
```

**確認：pop 單調下降（12.84% 淨死）、teams 暴增（91→133，+46%）、avg_size 崩（4.88→2.91）= 碎裂非成長**。你的推翻自己「生>死」是對的（那猜反了）。

**★多一層時序細節（你沒問但重要）**：碎裂**不是逐月漸增**，是 **month1→2 單月爆發 +40**，之後 month3-6 **team 數在 133-137 窄幅震盪打平**（穩定態，非持續碎化）。avg_size 同型：4.88→3.27→2.91 後也打平在 ~2.9。**這是一次性爆量後達平衡，非失控持續碎裂**——對「煞車踩哪」很關鍵：**問題集中在 month1→2 這個窗口的機制,不是全程 6 個月都在狂生隊**。

## ②team-creation 源 breakdown：兩條真實機制，非你猜的 unrest_split/beast_spawn

**先澄清**：`unrest_split`/`population overflow`/`beast spawn`/`manpower` 這些**不是這份 probe 裡存在的真實 tap 名**——我搜遍 `probe`/`probe_amounts`（193+21 個計數器）**沒有任何一個叫這些名字**。這些是你我事前都沒查就假設的機制名（我提醒自己也差點順著這個框架去找，及時回頭查 raw）。

**真正的兩大創隊源**（raw log 逐 day 累積掃描）：

| 事件 | day30(月1末) | day60(月2末) | TOTAL(6mo) | 集中段 |
|---|---|---|---|---|
| `[Sub]` 派出子隊（task=擴建/信使） | 67 | 159 | 190 | **月1-2 佔 84%**（67→159 之間 +92） |
| `[CrudeCamp]` 紮營定居（civilian/military 定型） | 9 | 102 | 195 | **月2 內集中**（9→102 之間 +93，月1 幾乎沒有） |

**兩者量級相當**（各 +92~93 次在 month1→2 窗口），**合力解釋 +40 淨隊暴衝**（扣掉同期死亡/合併churn後的淨值）。機制：母隊派子隊去擴建/送信（`[Sub]`）→ 子隊抵達後紮營定居成為獨立 civilian/military 隊（`[CrudeCamp]`）→ **變成一個「持久」新隊,不再是暫時性子隊**。

**排除 unrest 驅動**：probe 裡 `reaction.N1_flee/N2_riot/N3_defect/N4_shirk/N5_extort` **全部 = 0**——**確認你猜的「unrest_split」根本沒 fire**，warring 壓力沒有透過這條路徑製造分裂。

## ③avg team size 趨勢：碎化 44%，觸底打平（非持續惡化）

4.88 → 2.91 = **-40.4%**，且**穩定在 ~2.9 人/隊**（month3-6 都在 2.90-2.93 窄幅內），**沒有繼續往更小碎**。這是一次性碎化到某個平衡點,非失控螺旋。

## ★煞車候選（供你跟 systems 談，我只找不裁）
根源既是 `[Sub]`(派遣) + `[CrudeCamp]`(定居) 兩條正常機制在戰爭世界高頻運作（非 bug、非 warring 特有異常）,煞車可能方向：
1. **調降 `[Sub]` 派遣頻率/cap**（母隊多常派子隊出去擴建/送信）。
2. **拉高 `[CrudeCamp]` 定居門檻**（要求更高 pop/資源才能從暫時子隊轉正成獨立隊,現在似乎太容易定型）。
3. **加強事後 merge/consolidate 回收**：probe 顯示 `merge.consolidate_dispatch=322` 但 `merge.set_ok=316`（成功率高,不是撮合問題）——但**這是「有嘗試 merge 的次數」,不代表所有創生出的子隊都被嘗試 merge**。190 個 `[Sub]` + 195 個 `[CrudeCamp]` vs 只有 322 次 consolidate dispatch,可能有相當比例的新隊從沒被納入 merge 考慮,一直獨立存在到底,值得查 merge 的觸發覆蓋率夠不夠。

## 給你的建議
①②③ 皆坐實,**不需重跑**（用戶令已遵守，全部來自既有 run1 output）。**「為什麼 130 隊」= 正常的「派遣→定居」機制在 warring 高強度世界下,month1-2 密集觸發,之後打平**——不是新 bug,是既有機制在這個測試規模下的正常但超預期的產出量。你可以據此跟 systems 談三個煞車候選裡選哪個（頻率/門檻/回收），或先接受現況（130 隊打平非失控,只是超過 memory 的 50 目標,屬於「規模預期沒設對」而非「機制壞了」）。

（QA 只找不修不裁；煞車機制設計歸你/systems。**教訓：★『unrest_split/beast_spawn』這類名字是我們自己腦補的機制假說,沒查過現成 probe key 就用這些名字問問題,會問錯方向——先看 probe 裡真的有什麼 tap 名,再問「為什麼 X 這麼高」，別預設命名**。memory 你單寫者提煉。）
