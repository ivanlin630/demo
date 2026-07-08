---
from: blueprint
to: systems
status: open
topic: A2c 方向——faction 剩餘平行權威折入統一引擎(保湧現,深化留 A2d);切法你自決
---

# A2c 方向（藍圖 → 系統）

接 A2b（leader tactical intent 已走秤）。A2c 折 faction **剩餘 off-engine 權威**，收「5 平行權威」碎裂的下一批。

## 願景約束（藍圖 owner；系統鎖 spec 前遵守）

**A2c 意圖 = 純折入保湧現，不重塑。**
- 目標：把剩餘 off-engine 決策路徑收進統一引擎/降為引擎輸入，**消除平行 scorer + god-view 作弊 + hard-set pre-empt**。
- **玩家體感不變**：utility term 校準到**現行門檻行為**。玩家看到的外交（背叛/結盟/徵貢）、擴張選址、勢力合併的湧現戲，A2c 後應大致等價。
- **深化（讓外交/戰略真正參與統一 weigh，如背叛跟生存競秤）= 明確不在 A2c，留 A2d/後續 arc。** 別在 A2c 順手改門檻語意。

**用戶定案（2026-07-09）**：外交折入採「先保後深，分兩 slice」。A2c=保，A2d=深。

## 待收權威（reverse-findings FA 表；供你切 seam）
| FA | 病 | code | 類 |
|---|---|---|---|
| FA8 | diplomatic_ai 背叛/結盟/徵貢=門檻驅動結構變更,全 off-engine | diplomatic:137/299/231 | parallel-path |
| FA6 | strategic_ai→move_target 繞 arbiter | strategic_ai:152 / movement:65 | bypass |
| FA7 | strategic_ai god-view `_nearest_independent` 讀真 faction_id+真 pos | strategic_ai:96-104 | god-view |
| FA5 | MERGE consolidate 在 weigh 前 hard-set pre-empt | faction_ai:1403/1421 | hard-set |
| FA10 | 征服 commit god-view target | faction_ai:1374-1378/1978 | god-view（arc3 霧可收） |

## 邊界（誰決定啥）
- **seam / 哪些併秤 / 哪些降輸入 / 一次折幾條 / 序 = 系統的。** 用戶已定「系統決定切法」——你自決 A2c 收幾條（建議按覆蓋/風險排；FA8 最大玩家可見面，FA7 god-view 跨 arc3 感知霧）。
- **藍圖只給上面願景約束。** 任一權威折入若**實測改玩家體感/平衡意圖** → 鎖 spec 前**回 blueprint 信箱要 sign-off**（純內部路由等價你自決）。

## 流程
- 你 → spec → reviewer 審 → 回 blueprint 信箱（方向 sign-off / 體感疑慮）。
- 下游 impl→measure→qa：用戶偏好試 LG `--from-impl`（見 memory [[feedback_mailbox_trigger]]）。
- **前置**：A2b 尚未 merge origin/main（見 `blueprint-to-systems-A2b-merge-gate-催辦.md`）——A2c 動工前先收 A2b 進 main，免 stale base。

## 參考
- reverse-findings arc：memory [[project_reverse_engineering_arc]]；spec `specs/2026-07-07-reverse-findings.md` line 120-129（FA 全表 + 平行決策權數）。
