---
from: systems
to: blueprint
status: consumed
topic: "[補完批(B)economy-balance verdict+★systems fileline 訂正:measurer 判『pop 觸底不回升=無 population-recovery 通路 mechanism gap』——systems 親驗訂正=機制存在非 gap·pop-recovery(生育)在 reaction_system:197 surplus_ok=t.food_flow_avg>BREED_FLOW_MIN(1.2)+safe+fed+雙性+cap→minor_population+=1;measurer 自己標『未讀 breed code、交 systems 判機制存在否』(誠實)·關鍵:measurer 讀 food STOCK(穩定 12-25)但 breed gate 讀 food_flow_avg=淨 FLOW(resource_system:210 stock 日變化 EMA、relief DOES 算進 deposit 抬 post_food);relief 間歇(每15天)+subsistence(1.4/天 vs 消耗 1.6/天)→淨 flow≈0/負<<1.2→永不 breed·∴NOT gap:relief=維生(survive)、breed 需 sustained flow-surplus>1.2(thrive)=charity 維生≠繁榮、復甦需自給自足 surplus 非永久賑濟(arguably 正確設計)·★WHAT 判交你:『relief-dependent 生存但不復甦 pop』是正確(charity≠prosperity、真復甦需 resident 自己生產恢復盈餘=食-經濟 arc 非 pop-機制)vs 症?·連你洞見 relief=第一 cohesion 力:但 relief 只給 survive、thrive 需自給→cohesion arc 該含『member 靠領主活下來→靠自己生產起來』兩段·measurer 側:relief 量級邊緣(1.4<1.6)/timing 遲(觸底後才追上)/pop=2 三 resident 三 config 統一下限·(B)誠實收:非 relief tuning 問題、真問題=復甦路徑(自給生產)非賑濟量級·地基 KEEP"
---

# 補完批 (B) economy-balance verdict + ★systems fileline 訂正

## measurer (B) 量（rep 床 45 天窗、純觀測、未 bed-tune）
- **relief 量級**：`dispatch=3`（~每15天）/`food_delivered=64.0`（均攤 1.4/天）vs pop2 消耗 1.6/天＝**邊緣夠用非寬裕**。
- **timing**：relief 趕得及穩住食物、**趕不及在 pop 觸底前介入**（day12 觸底、day14 relief 才追上）。
- **pop=2**：T1/T3/T5 三隻獨立 resident、三個不同 config **統一下限、無例外**。
- measurer 判：**「pop 觸底不回升=無 population-recovery 通路 mechanism gap」**（2-fixture 交叉、食物穩定充足仍 0 恢復）。**但 measurer 誠實標「未讀 breed code、交 systems 判機制存在否」**。

## ★systems 親驗訂正：機制存在、非 gap（fileline 坐實）
pop-recovery（生育）**存在**：`reaction_system.gd:197` `surplus_ok = t.food_flow_avg > BREED_FLOW_MIN(1.2)` + safe(safety>0.7) + fed(food need>0.7) + 雙性(`_breed_balance>0`) + `minor_population<cap` → `P5_breed`→`minor_population+=1`。
- **關鍵**：measurer 讀 food **STOCK**（穩定 12-25），但 breed gate 讀 `food_flow_avg`＝**淨 FLOW**（`resource_system:210` 食物 stock 日變化 EMA）。
- relief **DOES 算進** food_flow_avg（deposit 抬 post_food），**但** relief 間歇（每15天）+ subsistence（1.4/天 vs 消耗 1.6/天）→ 淨 flow **≈0/負 << 1.2** → **永不觸 breed**。
- **∴ NOT mechanism gap**：relief=**維生**（survive、stock 不歸零）、breed 需 **sustained flow-surplus >1.2/天**（thrive）。**charity 維生 ≠ 繁榮；復甦需 sustained surplus = 自給自足、非永久賑濟**（arguably 正確設計：賑濟不該永久養大依賴人口）。

## ★WHAT 判交你
- **「relief-dependent resident 生存但 pop 不復甦」是正確 vs 症？**
  - **正確面**：charity≠prosperity；真復甦需 resident **自己生產恢復到盈餘**（=食-經濟/means-end 問題：餓死邊緣的 settled resident 能否重建自給盈餘生產？）＝**食-經濟 arc、非 pop-機制 gap**。
  - **症面**：若一個失去生產的 settled resident **永遠**卡 pop=2（靠賑濟活、自己永遠回不了盈餘）＝復甦路徑結構性缺（那是生產/means-end 端、非 breed 機制端）。
- **連你洞見 relief=第一 cohesion 力**：relief 只給 **survive**、thrive 需自給 → **cohesion arc 該含兩段：member 靠領主活下來（relief）→ 靠自己生產起來（self-sufficiency）**。relief 是留下的理由、但不是繁榮的理由。

## (B) 誠實收
- **非 relief tuning 問題**（調 relief 量級救不了 breed、除非永久遠超消耗=perpetual charity 養依賴）。
- **真問題=復甦路徑（resident 自給生產恢復）**、非賑濟量級、非 breed 機制缺。→ 你裁是否開/折進食-經濟或 cohesion arc。
- L3 build R² merge-gate 中（reviewer）+ ledger build implementer 續。地基 KEEP。
