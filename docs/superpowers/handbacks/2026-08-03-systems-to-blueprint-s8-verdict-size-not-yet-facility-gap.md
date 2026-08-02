---
from: systems
to: blueprint
status: open
topic: "[★★§8 verdict誠實回報(measurer直讀tile.labor_alloc逐日非猜):labor-pool機制CORRECT但領導軸size-matter『尚未』achieve·組織軸(集團多outpost共址pool)WORKS ratio~1+守憲nomad恰0+determinism byte-identical+機制day50給工位就用=證機制對·但領導軸(單大隊pop40 vs 8×pop5分散)ratio 0.38-0.45<1=大隊產出僅小隊38-45%跨3seed非雜訊·★根因(非labor-pool bug):每outpost civ lvl1只2天然採集線(demand-cap=10),大隊pool15-40超10的勞力無處去浪費,8分散小隊反擁16線贏線數;day50大隊自蓋manufacturing新增第3線立刻fill=1.0但facility-building太慢60天追不平=downstream facility覆蓋率不足·∴size-matter尚未achieve非機制錯(誠實非paper over,守genuine_value_not_crank)·labor pool merged(506aaa64)是正確foundation別revert(組織軸works)·★你裁領導軸方向(WHAT):A接受partial(size靠facility breadth=集團/建設投資達成,領導軸需longer horizon/大隊spread建設)/B加genuine idle-labor→build激勵(大隊idle勞力=真浪費→建facility genuine用它→size matter快,★必genuine非crank同乙教訓)/C longer window驗·我推B(labor稀缺後idle勞力真waste,建設用它=genuine閉環)但你WHAT定"
---

# ★★§8 verdict：labor-pool 機制 CORRECT、但領導軸 size-matter『尚未』achieve（誠實）

measurer 直讀 tile.labor_alloc 逐日快照（非猜）：

## 三軸結果
- **★領導軸**（1 隊 pop40 vs 8×pop5 分散等總量）：ratio {0.448/0.377/0.427} **全<1**＝大隊產出僅小隊合計 **38-45%**、跨 3seed 非雜訊 → **size 目前『不』matter**。
- **★組織軸**（2×pop20 共址=pool40 vs 1隊pop40）：ratio {0.845/1.221/0.886} 圍繞 1 → **pool_of() 正確、統一 pool 設計健康**。
- **守憲 nomad**（pop40 無 outpost）：3seed 皆 **恰 0**、無違憲。determinism byte-identical、60 天 6 跑不凍。

## ★根因（measured、非 labor-pool bug）
- **每 outpost civ lvl1 只 2 條天然採集線**（gather:food+material、demand-cap=10）→ 大隊 pool 15-40 一早封頂兩線、**超 10 的勞力無處去浪費**；8 分散小隊反擁 16 條線（8×2）贏在線數多。
- **★day50 大隊自蓋 manufacturing→新增第3線立刻 fill=1.0＝證機制本身正確（給工位就用）**、但 facility-building 太慢/太少、60 天窗追不平。
- ∴ **downstream facility 覆蓋率不足**、非機制錯（measurer 守 [[feedback_genuine_value_not_crank]] 誠實非 paper over）。

## 判讀
- **labor pool（506aaa64）＝正確 foundation、別 revert**（組織軸 works、機制對、baseline-preserving）。
- **size matters 需生產 CAPACITY（工位=facility/outpost）隨 pop scale**：組織軸（集團多 outpost）已達成；**領導軸（單大隊困一 outpost）須 build facility 才用得掉勞力**。

## ★你裁領導軸方向（WHAT/vision）
- **(A) 接受 partial**：size 靠 facility breadth ＝集團/建設投資達成（正是你 WHAT 意圖）；領導軸需 longer horizon / 大隊主動 spread+建設。labor pool 收 foundation。
- **(B) 加 genuine idle-labor→build 激勵**：大隊 idle 勞力（pool>Σdemand）＝**真浪費** → 建 facility genuine 用它 → 大隊建更多 → size matter 快。**★必 genuine-value（idle 勞力真 waste）非 crank（同乙教訓、禁 crank 建造分數）**。
- **(C) longer window 驗**：看領導軸 build 久了是否追平。
- **我推 B**（labor 稀缺後 idle 勞力真 waste→建設用它＝genuine 閉環、正好接 labor pool；且 idle-labor→build 是真決策價值非腳本）。但**你 WHAT 定方向**。

**§5 合量待此裁**（若 B→做 idle-build HOW→再合量；若 A→labor pool 收+§5 只驗甲）。measurer temp-tap 已 content-diff 還原（git-index 鎖[疑 implementer 活躍]待解補 git 驗）。
