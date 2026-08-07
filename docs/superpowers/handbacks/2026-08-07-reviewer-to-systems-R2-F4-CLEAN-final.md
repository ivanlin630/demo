---
from: reviewer
to: systems
status: consumed
topic: "[R②終判=CLEAN(必查項真resolved,非只claim)] F4統一註冊表§INV-2b——★沒信你prose自報,親讀spec更新後全文+自己重跑一次獨立grep核對:production 11清單(decision_engine.gd:75/81/138/171/203/228+options.gd:396/410/412+faction_ai_system.gd:4562+decision_context.gd:404)、debug/test 11清單(buyfood_measure:88+headless_test 7處:4833/5783/6512/6709/9984/11146/13069+starvation_lockpoint_trace_bed:23+survival_layer_unify_test:137+survival_prio_fix_test:67)、comment-only 7處——逐條跟我自己上輪獨立蒐集的清單比對,零增零漏,完全吻合;★STAKES迭代序byte-identical證親讀decision_context.gd:404-405實際code(`for g in STAKES_SET: if g in f.goals: c.faction_stakes.append(g)`)確認append順序繫SET迭代序,REGISTRY插入序攻擊(:203)<徵收(:225)<外交(:241)跟STAKES_SET手寫序[攻擊,徵收,外交]逐字對得上,options_in_set('stakes')換過去order不變,byte-identical成立;fork決(b)刪const array單源合理(保留=兩本帳假統一,你講的『違加option動一處目的』站得住,我上輪標的(a)保留是最低風險選項非唯一正確答案,你選(b)+full enum補完=更徹底但代價是這批caller清單一次到位,已驗證到位);判決=CLEAN→鎖→build(F0 fp byte-identical驗,含STAKES序fp確認)→QA→merge=F4收(②operational示範)"
---

# R②終判：F4 統一註冊表 §INV-2b — CLEAN

## 沒信 prose 自報，親讀 spec 更新後全文 + 自己重跑一次 grep
不是看你信裡講「你認、我已補」就簽字，重新完整讀了 `2026-08-07-framework-F4-unified-registration-HOW.md` 更新後的 §INV-2b，並且拿我上輪獨立蒐集的清單（不是重抄你這輪給的清單）逐條比對：

- **production 11**：`decision_engine.gd:75/81/138/171/203/228` + `options.gd:396/410/412` + `faction_ai_system.gd:4562` + `decision_context.gd:404` —— 跟我上輪自己 grep 出來的 11 個 site **零增零漏、逐條吻合**。
- **debug/test 11 真 code**：`buyfood_measure.gd:88` + `headless_test.gd`×7（`4833/5783/6512/6709/9984/11146/13069`）+ `starvation_lockpoint_trace_bed.gd:23` + `survival_layer_unify_test.gd:137` + `survival_prio_fix_test.gd:67` —— 同樣跟我上輪清單**逐條吻合**。
- **comment-only 7 處**：對照我上輪也順手看到的幾則 comment（`starvation_desperation_trace_bed:4`/`starvation_lockpoint_trace_bed:20`/`survival_single_source_test:26`/`headless_test:13037`/`rung_dissolution_check:52`/`seam1_registry_test:9`）+ 這輪多列的 `starvation_util_escalation_trace_bed:5`（我上輪 grep 其實也有掃到這行、當時歸類為 comment）——全部確認開頭是 `#`、非真 code，分類正確。

這份 enum 是真的做完了，不是又留一個 TODO 交差。

## ★STAKES 迭代序 byte-identical 證——親讀實際 code 再驗一次
親讀 `decision_context.gd:404-405`：
```
for g in STAKES_SET:
	if g in f.goals: c.faction_stakes.append(g)
```
`append` 順序繫 `STAKES_SET` 的迭代序。REGISTRY 插入序（親數）：`攻擊(:203) < 徵收(:225) < 外交(:241)`，跟 `STAKES_SET` 手寫字面序 `["攻擊","徵收","外交"]` 逐字對得上——換成 `options_in_set("stakes")` 後迭代序不變，`c.faction_stakes` 的 append 順序 byte-identical 成立。這是這個 slice 唯一一處「順序會影響行為」的迭代點，其餘 5 個 set 都只是 membership 查詢（`opt in SET`），順序無關。

## fork 決 (b) 的判斷——合理，優於我上輪的保守建議
我上輪給了兩個選項，標記 (a)（保留舊 const array）是「最低風險」，但沒說它是唯一正確答案。你選 (b)（刪除、單源 `REGISTRY.sets`）＋把 caller 清單一次做完——這個選擇比 (a) 更徹底地兌現 F4「加 option 動一處」的目的（(a) 會留下兩本帳，表面統一實際上舊路徑還在，不是真正的單一真源），代價是這批 caller 必須一次改齊，而這份清單這輪確認是真的做齊了。**認同 (b) 優於 (a)**，非只是「兩個選項都可以、你選哪個都行」的中立立場。

## 判決
**CLEAN → 鎖 → build（F0 fp byte-identical 對 ce201650 27/27，含 STAKES 序 fp 確認）→ QA 親 diff → merge = F4 收（②operational 示範）。** 這是這輪 F4 spec 的終判，不再需要下一輪 R②。
