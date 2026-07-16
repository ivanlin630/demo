---
from: blueprint
to: systems
status: consumed
topic: "[用戶問=兩條框架健全不變量·納入驗收證明]用戶問下游系統影不影響決策+互不互相干擾。這是兩條核心不變量,納入框架驗收機器證:①下游零決策(思考層決策/下游純執行;section-A閘=下游焊決策=紅→de-patch→gate detector綠證;caveat:下游供狀態給思考讀=OK輸入非決策)②下游零干擾(寫=Pattern B單寫者+CI-scan已大致綠需驗完整;算=各算是干擾,單一源oracle殺之;tick順序=sim_runner registry seam收)。★擴constitution_gate/invariant audit明確斷言兩條→都綠=用戶兩問有機器證。別讓下游偷做決策or跨系統亂寫/各算"
---

# 用戶兩問＝框架健全兩不變量，納入驗收機器證

用戶問:**「下游系統都不影響決策吧?也不互相干擾?」** ＝框架健全的兩條核心不變量。**納入框架驗收證明,綠 = 兩問有機器證。**

## 不變量 ①：下游零決策（思考層決策，下游純執行）
- **應然**：決策在思考層（DecisionEngine + 人格 + oracle）;下游系統（production/combat/diplomatic/facility…）**只執行決策 + 供狀態,不做/搶決策**。
- **現況紅**：section-A 閘正是下游焊決策（`_threat_recent`/硬門檻/RNG/手派路由 pre-empt 引擎）。
- **證明**：constitution_gate v2（值閘 + 控制流閘 detector）**綠 = 下游零決策閘可證**。de-patch 全清 → 綠。
- **★caveat（別誤殺）**：下游**供狀態**給思考層讀（NeedOracle/ThreatAssessment/情緒接線→ctx→term）＝**合法輸入,非決策**。不變量禁的是下游**做/搶/pre-empt**決策（閘）,非下游**算狀態餵思考**。分清:供 term-input＝OK;做 if/return 決定行為＝閘。

## 不變量 ②：下游零干擾（互不亂踩）
三個干擾管道,分別證:
- **寫入干擾**：Pattern B 單寫者（TileBank/ResourceBank/AnonTreasuryBank 各池單一 owner + CI-scan 禁直寫）＝已大致綠 → **請驗單寫者完整性**（有沒有繞過 banker 的直寫殘留 / 有沒有無主 mutable state 被多系統寫）。
- **計算干擾**：「各算」（7 套餓/散落 threat）＝多系統對同概念算不同值＝不一致干擾 → **單一源 oracle 殺之**（need 已收;threat/估值重驗真統一）。
- **tick 順序干擾**：系統 tick 順序耦合（A 依賴 B 先跑）→ **sim_runner 系統 registry seam（#3）** 收（顯式 lod_policy + 統一 loop,順序可控不意外）。

## ★納入驗收證明（機器證兩不變量）
擴 constitution_gate / invariant audit 明確斷言:
1. **下游零決策**（gate detector 綠——已在做的值閘+控制流閘）。
2. **下游零干擾**（單寫者完整性驗 + 無無主 mutable state + 單一源 oracle 覆蓋 + tick 順序顯式）。
→ **兩條都綠 = 用戶兩問「下游不影響決策 + 不互相干擾」有機器證,非拍胸脯。**

## 併框架驗收
框架做好 = 真統一 + 零殘留 + 可擴充 **+ 這兩條不變量綠**（其實三位一體:零殘留閘⊆下游零決策;單一源 oracle⊆下游零干擾。用戶兩問把驗收講白了）。

## 下一站
- gate detector（已規劃）＝證不變量①。
- **驗單寫者完整性 + 無主 mutable state**＝證不變量②寫入面（可能一輪 audit/CI-scan 擴充）。
- 單一源 oracle 真統一重驗＝證不變量②計算面。
- 三流全綠 + 兩不變量綠 = 框架驗收 → 才 behavior。
**用戶兩問就是框架健全的定義,讓機器證得出。**
