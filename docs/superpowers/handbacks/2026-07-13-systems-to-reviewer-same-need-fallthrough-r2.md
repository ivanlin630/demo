---
from: systems
to: reviewer
status: consumed
topic: [R②·同需求fallthrough] rank[0]不可dispatch→同need層優先——審不影響conquest/threat既有dispatch+NO-OP保證;dispatch前
---

# R② 設計審：dispatch 同需求 fallthrough（裁 A）

## 前置
- 藍圖裁 A(`forage-dispatch-fix-A`)：rank[0] 不可 dispatch→fallthrough 優先同需求食物替代。
- spec `docs/superpowers/specs/2026-07-13-dispatch-same-need-fallthrough.md`。premise（覓食 undispatchable→fallthrough 生產）已 code 坐實(`forage-dispatch-root`)→免 R①,僅 R②。

## 內容
`DecisionEngine.reorder_same_need_first(ranked)`：same main-need-layer(=rank[0]層,`NeedHierarchy.main_layer_of`)在前、其餘在後,各組保 util 序。接入 `_decide_unified`+`_evaluate_solo` 兩 dispatch loop(rank_scored 後、loop 前)。loop body 不變。

## 請 R② 重點查
1. **★NO-OP 保證（回歸關鍵）**：rank[0] dispatchable 時,重排後 rank[0] 仍首試(同層自身)→dispatch 結果 byte-identical?查穩定重排是否真保證非-bug-case 零行為變（determinism/既有測不動）。
2. **conquest/threat 分支不破**：`_decide_unified`/`_evaluate_solo` loop body 有攻擊征服 scout-verify(`_commit_conquest_attack` return)+threat aux wiring(`_wire_threat_task`)。重排只改**迭代序**,body 不變——查這兩分支**不依賴絕對 util 序**(如「攻擊必 rank[0] 才 scout」之類隱含假設)→重排後仍正確 fire。
3. **main_layer 分組正確**：核心食物(覓食/買糧/乞食/返家/紮營)affinity argmax 皆 L_SURVIVAL?→餓隊覓食失敗優先試這些。掠奪(esteem)/併入(belonging)排除是否合理(spec 論證非主食來源,measurer 驗殘留)。
4. **兩 loop 對稱**：兩處同接入,查 `_evaluate_solo` 的 conquest-return(1466-1476 附近)與重排順序無衝突。
5. determinism（reorder 純算術穩定,零 randf）。

## 註
- 只改 dispatch 迭代序,不改 rank_scored/util/coeff。範圍小。
- CLEAN 則 dispatch。NO-OP 保證破/conquest-threat 回歸/主假設誤→回 verdict。
