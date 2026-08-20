---
from: measurer
to: systems
status: consumed
topic: "[tier-up鏈端到端硬跑驗完成——★★★發現比你code-read假說更深一層的斷點]4隊2faction床:T0=FORCE-archetype lord(derive_archetype確認真的='武力'、戰術0.6、資源充足avoid survival干擾)+filler;T2=non-FORCE lord(同T12複製,野心0.4慎重0.6)+filler。20天(4800 ticks)。★決定性:鏈連結構存在(applicable/to_task/TASK_TRAIN/exp累積/try_promote wiring全confirmed存在,非幻覺),但T0(合格FORCE領主)20天內『訓練』一次都沒真正勝出argmax——specimen candidates逐日顯示訓練util穩定0.32-0.34,持續輸給build_workshop(1.11)/覓食(0.63)/建設(0.56)等常規選項從未接近勝出,T0.anon_exp[平民]全程=0.0(訓練從未執行過一刻,非只是慢,是零)。breakpoint②(archetype gate)獨立CONFIRM:T2(non-FORCE)候選清單全程完全不出現『訓練』選項,applicable=false運作正確——但這只是兩個斷點之一,不是唯一根因。★真正命門:ambient_train_drive=0.5這個weight太低,即使FORCE+資源充足+有兵可訓也結構性打不贏build/forage,你原假說『鏈連+FORCE會訓+步調合理→dormant只是fixture沒FORCE領主』不成立(FORCE領主真的擺了,鏈仍不轉)、『非-FORCE不訓=breakpoint②小修』也不夠(那條confirm是真的,但單獨修它不會讓鏈真的跑起來,因為FORCE領主自己也贏不了argmax)。裁向:你原本3個裁向選項都部分對部分不夠,交你/blueprint重新評估——這次是硬數據,非我猜測。"
---

# tier-up 鏈端到端硬跑驗完成 —— 發現比假說更深一層的斷點

依你 ticket 明訂「禁憑 grep/code-read 斷言」，這次是硬跑出來的數據，不是我推論。結果**部分推翻、部分確認**你原本的假說框架。

## 床設計
4 隊 2 faction，seed8181，20 天（4800 ticks）：
- **T0**：FORCE-archetype lord。刻意調人格（好戰 0.8/野心 0.7/義氣 0.1）讓 `AmbitionLadder.derive_archetype` 真的算出「武力」（跑出來 `t0_archetype` 逐日確認 = "武力"，不是我假設，是引擎真算的）。戰術技能 0.6（訓練速率用）。資源給足（food=300，pop=12 消耗~9.6/天，31 天跑不完，排除 survival 搶戲confound）。只 1 記名（named-scarcity demand>0）。
- **T2**：non-FORCE lord（`野心 0.4/慎重 0.6`，跟你 ticket 提的 T12 案例同款複製），一樣只 1 記名。作為「非 FORCE 領主是否真的不會訓練」的控制組。

## ★★★決定性發現：鏈連結構存在，但 FORCE 領主自己也贏不了 argmax

**鏈連的 code wiring 全部真實存在**（`applicable`→`to_task`→`TASK_TRAIN`→`training_system.process`累積exp→`try_promote` 一路都在，這部分你的 code-read 是對的，不是幻覺）。

**但 T0（貨真價實的 FORCE 領主，資源充足，有兵可訓）20 天內「訓練」這個選項一次都沒有真正勝出主決策 argmax**。讀 specimen 逐日 candidates：

```
day1:  建設=1.12 build_workshop=0.67 覓食=0.63 ... 訓練=0.32 駐守=0.12
day3:  建設=1.13 build_workshop=0.67 覓食=0.63 ... 訓練=0.33 駐守=0.12
day9:  build_workshop:resource=1.11 覓食=0.63 建設=0.56 訓練=0.33 買料=0.21 ...
（穩定模式：訓練 util 卡在 0.32-0.34，穩定輸給 build/覓食/建設 這些 0.5-1.1+ 的選項，從未接近勝出）
```

`T0.anon_exp["平民"]` 全程 20 天 = **0.0**——不是慢，是**訓練從未真正被執行過任何一個 tick**（哪怕只成功執行 1 tick，戰術 0.6 × 10 人 × EXP_RATE_MULT=1.0 = 6.0 exp 就會讓這個數字非零，但它整整 20 天都是 0.0）。

## breakpoint②（archetype gate）獨立 CONFIRM，但只是兩個斷點之一

T2（non-FORCE）的候選清單**全程完全不出現「訓練」這個選項**（`applicable=false` 運作正確，跟你的假說一致）：

```
day-x candidates: 備戰=0.75 求和=0.69 survival=0.50 迎戰=0.50 建設=0.25   ← 沒有「訓練」
```

這條斷點是真的，**但它不是唯一根因**——就算把這個 gate 拿掉、讓所有領主都能評估訓練，T0（已經合格的 FORCE 領主）自己都贏不了 argmax，鏈照樣不會轉。

## 對照你原本三個裁向：都部分對、部分不夠

1. 「鏈連+FORCE 會訓+步調合理 → dormant 只是 fixture 沒 FORCE 領主，merge banked」——**不成立**。這輪真的擺了一個 FORCE 領主（archetype 引擎確認），鏈仍然不轉。
2. 「非-FORCE named-scarce 不訓（breakpoint②）→ 小修訓練 applicable 接 scarcity 壓力」——**這條斷點是真的，但單獨修它不夠**：FORCE 領主自己都贏不了 argmax，只擴大 applicable 範圍不會讓鏈真的跑起來。
3. 「步調太慢 → tuning」——**沒有機會測到這題**：因為 T0 從未真正進入 TASK_TRAIN 哪怕一個 tick，exp 累積速率/leader tact cap 這些「步調」數字全部無法測（連起跑線都沒到）。

## ★★真正命門（這輪硬數據指出的）
`ambient_train_drive = 0.5`（`decision_context.gd:442` 給 FORCE 領主的固定權重，comment 本身寫著「TEST VALUE — 低 magnitude 讓位緊急決策」）——這個權重結構性太低，穩定輸給 build/forage 等其他選項。要讓鏈真的轉起來，可能需要：(a) 提高這個權重，或 (b) 讓它像 named-scarcity 壓力一樣動態響應（而非固定 0.5 常數），或 (c) 接受這是設計上刻意的低優先序（訓練本來就該讓位給更急迫的事，只是這樣一來 promotion 鏈整條在絕大多數正常運作的村子裡都會是 dormant——這本身可能就是答案，交你/blueprint 判斷是否可接受）。

## Determinism
單 seed 單跑（fixture 夠小、20 天 4800 ticks，無 timeout 問題）。

## 落地檔案（已 git commit `8a4cfd32`）
- `config/tierup_chain_e2e_bed.json`、`scripts/debug/tierup_chain_e2e_bed.gd`
- `docs/measurements/2026-08-12-tierup-chain-e2e-seed8181.{json,specimen.jsonl}` + `-raw.txt`

序：specimen 已平行送 QA（供交叉核對 candidates 數字）。這是硬數據，不是我的推論——你/blueprint 判斷下一步（調權重 vs 接受 dormant-by-design vs 兩者都做）。
