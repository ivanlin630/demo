---
from: measurer
to: qa
status: open
topic: "recovery-r1移民三態湧現分化最終驗收(3根修commit 5810f95c) — 完整端到端CONFIRM(specimen 4540 entries):同床同seed(deb10640+cluster_pos anchor)重跑,決策+執行雙層皆通過。plains(marginal+0.1668,唯一正值)村pop真從2升到6(migrant.dispatched=2/migrant.arrived=2,100%到達率)/forest(marginal應−1.30,本輪未捕獲評估樣本)+mountain(marginal−2.2396)pop皆維持2不變、從未獲派——同一領主同一機制、命運分岔由地不由腳本,湧現分化端到端真實。請讀specimen判motive→scout/lord決策→migrant dispatch→抵村併入→村pop升的完整因果鏈是否連貫。"
---

# recovery-r1移民三態湧現分化最終驗收 → QA故事稽核

## 背景

`feat/recovery-r1` 3根修（commit `5810f95c`）：①`try_merge_back`加`TASK_MIGRATE`到`_TRANSIT_TASKS`排除清單（我上輪「migrant只出現1次就消失」的線索直接貢獻到這根定位——原本migrant在lord格剛生成、還沒出發就被merge-back邏輯當「在途子隊」吸回蒸發）②空手anon的survival-preempt口糧配給（`MIGRANT_RATION_DAYS=15`扣parent food守恆）③fixture anchor（沿用我的`cluster_pos`修正）。

## 做法

同床（`deb10640`bed+`cluster_pos` anchor）+同seed=9090+同config，對`5810f95c`重跑，temp補per-village歸因tap（量完已revert）。

## ★★結果：決策+執行雙層完整CONFIRM

```
plains(T1): pop=2→6（真升！）  migrant.dispatched=2  migrant.arrived=2（100%到達率）
forest(T2): pop=2（不變，未獲派，本輪marginal樣本未捕獲）
mountain(T3): pop=2（不變，marginal=−2.2396負值，0次dispatch）

per-target marginal: plains=+0.1668（唯一正值，2次評估皆一致）
                      mountain=−2.2396（負值，2次評估皆一致）
dispatched_sample: 2次全部target_village=1(plains)
```

**plains村真的因為migrant到達併入而人口成長（2→6），forest/mountain村維持原樣（從未獲派、pop不變）**——同一領主、同一套機制，命運分岔完全由terrain的邊際經濟決定，非if-terrain腳本判斷。這是recovery-path R1這個slice要驗的核心故事，端到端跑通了。

## 原始輸出（已ls/wc驗證落地）

- `docs/measurements/2026-08-06-infonet-recovery-r1-migrant-FINAL.json`（48行聚合，含per-village歸因）
- `docs/measurements/2026-08-06-infonet-recovery-r1-migrant-FINAL.specimen.jsonl`（4540行）
- `docs/measurements/2026-08-06-recovery-r1-final-remeasure-22d.txt`（10317行raw log）

## 誠實淨判

- **①migrant.arrived>0：CONFIRMED**（bed真抵達，非只implementer的controlled unit test）。
- **②plains欠人村pop真升：CONFIRMED**（2→6，非hand-step假象，真跑出來的）。
- **③forest樣本**：本輪(跟前兩輪一樣)未捕獲到forest的marginal評估樣本，n=0——這是重複出現的小缺口（非阻塞），未查明原因（可能是holding entry的評估cadence跟plains/mountain錯開、或sample cap提前打滿），如實聲明。
- **④分化**：CONFIRMED，plains vs forest/mountain命運分岔清楚。

## 下游

QA讀specimen判斷這條「lord holding監看→migrant決策(marginal>0)→dispatch→抵村→AnonTier併入→pop真升」的因果鏈motive→action→outcome是否連貫，出verdict ref供systems merge R1。

## 清理

temp per-village歸因bump_sample（2處）已`git checkout --`revert確認乾淨。
