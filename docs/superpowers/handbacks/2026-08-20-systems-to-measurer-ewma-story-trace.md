---
from: systems
to: measurer
status: consumed
topic: "[queue #2(§4b gate 之後)·EWMA 解耦 MERGED 後的【行為面】補驗:出 specimen trace 餵 QA 故事稽核(工作流硬規則=長跑下 behavior 結論必經 QA 故事,現有閘全是 determinism/中立性/0-new 這類非行為因果型)·背景:gather 原本每呼一次就推進非冪等 EWMA、推進次數取決於哪個選項贏=既存缺陷,現改 advance 預設 false 只真決策入口推進→【推進頻率真的降了】=intended-change,世界動力學變了·★要的東西:合併後 main(a954df86 之後)長跑(建議 seed1337 warring 或 peaceful_economy 各一,月級窗)+SpecimenDumpHelper 逐隊 motive→action→outcome trace(非只 aggregate),重點看【求生/成長切換有沒有變遲鈍】(need_urgency 餵 consistency_coeff 直接乘進 option util、推進慢=urgency 反應慢的假說)+饑荒/威脅出現後多久才切到求生·★禁只丟 aggregate JSON 給 QA(QA 履不了職、當日 3 次翻案前科)·★如你手上 §4b gate 結果先出來就先寄那封、這封排 #2·完→trace 落地 path 明寫 + handback to:qa(副本 to:systems)·地基KEEP"
---

# queue #2：EWMA 解耦 MERGED 後的行為面補驗（specimen trace → QA 故事稽核）

**背景**：`gather` 原本**每呼一次就推進非冪等 EWMA**、推進次數取決於哪個選項贏＝既存缺陷；現改 `advance` 預設 false、只真決策入口推進 → **推進頻率真的降了**＝intended-change，**世界動力學變了**。已 merge（大考 blocker#1），但現有閘全是 determinism／中立性／0-new 這類**非行為因果型**。

**要的東西**：合併後 main（`a954df86` 之後）長跑（建議 seed1337 warring + peaceful_economy 各一、月級窗）+ **SpecimenDumpHelper 逐隊 motive→action→outcome trace**（**非只 aggregate**）。重點：
- **求生/成長切換有沒有變遲鈍**（`need_urgency` 餵 `consistency_coeff`、直接乘進 option util → 推進慢＝urgency 反應慢的假說）。
- 饑荒/威脅出現後**多久才切到求生**。

★**禁只丟 aggregate JSON 給 QA**（QA 履不了職、當日 3 次翻案前科）。★若 §4b gate 結果先出來就先寄那封，這封排 #2。完 → trace **落地 path 明寫** + handback to:qa（副本 to:systems）。地基 KEEP。
