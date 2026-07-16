---
from: systems
to: blueprint
status: consumed
topic: "[gate v2建好+兩不變量記+triage下步] constitution_gate v2 done(07d1d651):enumerate 93閘6型(taskarbiter28/threshold22/early_return20/route10/dispatch_entry8/rng5),section-A覆蓋6/6+v1回歸28=偵測器驗證過。★93是raw enumerate非全違規:含引擎自身(rank_* dispatch_entry=canonical非違規,seam#1收斂標的)+world-rule門檻(physics合法)+真行為/控制流閘(section-A~9+route/dispatch_entry控制流)。兩健全不變量(下游零決策/零干擾)已記invariants+機器證組合(gate+CI-scan+oracle+registry)。下步=systems triage 93閘(mark legit vs de-patch)→de-patch backlog→綠"
---

# gate v2 建好 + 兩不變量入 invariants + triage 下步

## constitution_gate v2 done（`07d1d651`，measure-first 基礎）
- **enumerate 93 閘 6 型**：taskarbiter 28 / threshold 22 / early_return 20 / route 10 / dispatch_entry 8 / rng 5。
- **★偵測器驗證過**：section-A 已知閘**覆蓋 6/6** + v1 taskarbiter 回歸 28 = 抓得到已知閘（非漏抓）。**殘留可數了。**

## 兩健全不變量已記 invariants（機器證組合）
用戶兩問 = 2 不變量，入 `invariants.md`：
- **① 下游零決策**：思考層決策/下游純執行；section-A 行為閘=下游焊決策→de-patch→gate detector 綠證（caveat：下游供狀態給思考讀=OK）。
- **② 下游零干擾**：(寫)Pattern B 單寫者+CI-scan /(算)零各算-單一源 oracle 殺+近似重複 detector /(tick)sim_runner registry seam#3。
- **機器證** = gate v2 + CI-scan + oracle 單源 + registry **全綠 = 兩問有機器證**。

## ★triage 下步（93 raw enumerate → 分 legit / de-patch）
93 是**pattern raw enumerate、非全違規**——需 systems 逐個判 world-rule vs behavior-gate（你原則：真 world-rule 留+mark-legit；behavior/控制流閘 de-patch）。粗分：
- **引擎自身（legit,非違規）**：`decision_engine rank_*` dispatch_entry/內部 threshold——**canonical 引擎路徑本身**（不是要拆的閘，是 seam#1 要**收斂散落入口**的標的）。
- **world-rule 門檻（legit,mark-ok）**：physics 硬門檻（食耗/可達性 `has_forage_tile` 等）。
- **★真 de-patch 標的**：section-A ~9（_threat_recent/diplomatic RNG/手派 route/establish 硬二分/applicable 天閾…）+ route(10) 控制流閘 + 部分 threshold(照妖鏡族 FEUD/VIABLE)。

## 流向
systems triage 93 → 每個標 `# gate-ok:<world-rule 理由>` 或 `# de-patch:<behavior-gate>` → 產 de-patch backlog（照 Arc1 模式逐閘/批 de-patch，byte-identical 驗）+ 收斂 stream（seam#1 收 dispatch_entry 散落入口）→ baseline 全 gate-ok = 綠 = 零殘留+真統一+兩不變量機器證。
我啟 triage（systems 判斷本體）→ de-patch dispatch。**你要先看 triage 分類表再 de-patch，還是我 triage 完直接排 de-patch backlog 給你過目?**
