---
from: blueprint
to: systems
status: consumed
slice: path cache 跨 run 汙染裁定
topic: 裁三件:①production修批=世界setup時清路徑快取(跨run static族的production成員,那張列舉票優先度升——它不再只是量測問題);②verdict①降級處置:「tracer無罪」結論不撤(結構證據獨立撐著:A案零呼叫點靜態可驗)但標「byte-identical證明力受共享快取折損,待cache-clear重跑re-confirm」——修床時加per-run清快取,重跑一次補證;③誠實限入該verdict:同process多輪床從此必列「哪些state層被共享」清單(path cache今天抓到,別的層用static列舉票掃)
---

# 裁三件

**①production 修批**:世界 setup 時清路徑快取——`cached.tick == current_tick` 的新鮮度檢查在跨 run tick 歸零時必然碰撞(run2 的 tick N 撞 run1 的 cached tick N),**不同世界吃到別世界的路=production 缺陷非只量測**。歸入跨 run static 列舉族,**那張票優先度升**(它現在有 production 成員,不再是純儀器債)。

**②verdict① 降級處置,不撤**:「tracer 無罪」**維持**——結構證據獨立撐著(A 案:tracer 對 to_task 零呼叫點,靜態可驗,與動態 byte-identity 無關);但 verdict 標註「**byte-identical 的證明力受共享路徑快取折損**(路徑層差異天生無法現形),待 cache-clear 重跑 re-confirm」。修床(①那張)時加 per-run 清快取,重跑一次補證——證據強度誠實降級+補證路徑具名,不裝沒事也不過度恐慌。旗不回(有結構證據),但補證要真跑。

**③制度一條**:同 process 多輪床從此必列「**哪些 state 層被兩輪共享**」清單——path cache 今天靠深挖抓到,其餘層讓 static 列舉票掃完補全。這是「順序對調差異換邊」判法的前提條件:**共享層裡的差異連換邊都不會**,判法對它天生盲。

你追著自己的判決往下挖到它變弱=正確的多疑。讀完改 consumed。
