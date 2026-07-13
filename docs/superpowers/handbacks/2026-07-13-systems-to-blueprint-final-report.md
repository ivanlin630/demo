---
from: systems
to: blueprint
status: consumed
topic: [★FINAL一次性交付] ⑦釋放統一完成+今日決策引擎arc全貌——四項驗收全達;★established首次organic>0;過頻1712→381;誠實caveat
---

# FINAL：⑦ 釋放統一完成 + 今日 arc 交付（一次性，供用戶親判）

藍圖要的四項全達。main HEAD `cef31e2`。

## ①determinism ✅
byte-identical（1337×1mo cmp；systems 驗）。全 arc 各 slice 各自 determinism CLEAN。

## ②架構紀律自查 ✅（藍圖硬性）
- **主 rank 重評收斂單一 `_should_reeval` predicate**（IDLE/stuck/crisis/directive_fresh/cadence-due）。_decide_unified + _evaluate_solo 兩入口皆走此,無他路自判主重評（grep 佐證）。
- **唯一 _should_reeval 外的重評-timing**=`:3075` survival relatch——**spec §3 保留的 survival hysteresis 例外內**（survival 機械內部「何時重選 survival option」,強套 _should_reeval 會引入不當 directive_fresh 觸發=餓隊因 faction 令 relatch 覓食,反錯）。**正當範圍例外,非殘留 N-瞎子**。
- 保留刻意例外（藍圖裁）：TaskArbiter 優先權插隊/LOD/survival hysteresis。
→ 「合併≠統一」紀律守住:判斷點真收斂,非四段 if 換殼。

## ③代表隊 trace——過頻大修 ✅
Team7（pop 穩定 [10,10,10,10]）3mo：
- **decision_count 381**（前輪同隊 cadence/survival-path/fallthrough 各 2023/1957/1712 → **381,約 4-5× 降**）。過頻 1712 修好。
- winner 分布：**買糧 71% > 覓食 22% > 生產 7% > 紮營**——**健康多樣（食物策略主導），非病態**（對比前輪 94% survival / 91% 生產 lockstep）。
- 產物 `main_story_trace_v7.txt`（完整逐次決策+候選）。

## ④established——★本 session 首次 organic >0 ✅
3seed×3mo（default.json）：
| seed | attrition | established |
|---|---|---|
| 1337 | 15.4% | 0 |
| 42 | 18.1% | 0 |
| **7** | 12.1% | **1** |

**seed7 established=1**——整條「established=0 世界從沒真活」調查鏈（S1→⑦）**第一次 organic 跑出立國>0**。attrition 全面降 12-18%（session 初 45-91%）。

## 今日改動完整清單（決策引擎世界崩潰調查鏈,全 merged main）
1. **S1** 五層急迫度感測(inert)
2. **S2** coeff 表+rank 接入+plan_phase 原子退役+§6 標籤+就緒度 raw
3. **normalize T1-T5** 優先序→coeff,base term→中性執行品質[0,1](層內 base 校+訓練 eval-gate)
4. **cadence T-cad1/2** 拿掉非-unified IDLE-lock,週期重評+crisis-bypass
5. **survival-path** FLEE 威脅 gate(撤 spurious FLEE 0.6 floor,winner=survival 907→0)+latch 重選
6. **fallthrough** rank[0]不可派→同 PASSIVE_SURVIVAL 組(覓食失敗試買糧非落生產)
7. **⑦釋放統一** 單一 _should_reeval(過頻 1712→381+命令即時)

## 誠實 caveat（非全解）
- established 僅 **1/3 seed**(seed7),非全面解鎖——方向對,未穩定跨 seed。
- 決策頻率 381 仍略高於「低百」理想(方向對,可再 tune DECISION_CADENCE)。
- **③命令即時響應/細部不回歸未細查**(measurer 時間考量,聚焦 trace+established)——determinism/架構紀律我已驗;若要 faction 協同/famine/combat 不回歸數字,measurer 可補跑,告知即派。
- 守門員全圖 ②分流入口收斂(成員洞已證不存在=低價值)+灰區(urgency 重疊/commitment/豁免)本輪未動(藍圖裁擱)。

## 判讀（measurer+systems）
今日 main = 這條 arc **目前最健康狀態**：決策頻率合理、行為多樣不病態、established 首次點亮、attrition 大降。仍不完美但方向明確對。用戶要的「看得到 main 照構想跑」——這份 trace+established 是直接證據。

## 序
交你轉用戶親判。用戶反應決定下一步（穩定 established 跨 seed / tune 頻率 / 補不回歸驗 / 或暫告段落）。⑦=今日自主大活收尾,系統 standby。
