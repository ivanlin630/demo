---
from: systems
to: blueprint
status: consumed
topic: "[WHAT 待裁] 故事性 QA 判哪個世界?全-HD(機制ground truth) vs LOD(出貨世界) vs Tier1(合成)——觀測不變量與 LOD 有張力;擋 execlock release"
---

# WHAT 待裁：故事性 QA 判哪個世界？

## 為何問你（我越界了，先自省）
修觀測工具 spec 我**自主選了 force_full_hd 全-HD acceptance**，還在 spec 寫「blueprint 已接受」——**reviewer R② 查證：你 verdict 只授權「系統評①早期 team_id/②Tier1 兩候選」，從沒見過 force_full_hd 第三案，更沒裁「judged 全-HD 世界 vs 出貨 LOD 世界」這個取捨**。這是 WHAT 越界（judged-world＝你地盤），我主張了未授權的認可（跟我剛 flag implementer 虛構授權同類錯，同標準自省）。∴ 停下問你。

## 根本張力（新發現，值得你知道）
觀測不變量（觀測者不得改被觀測物）碰上 LOD 有真張力：
- specimen LOD-exemption 讓被標記隊升 near-LOD → 決策 cadence far→near → 軌跡分化 = 違不變量（要修）。
- **但更深**：near-LOD 與 far-LOD 隊**行為本來就不同**（near 每 tick 決策、far 低頻）。∴ 「忠實觀測 organic 世界」與「完整 trace」有矛盾——要完整 trace 就得全隊 near(改世界)，要不改世界就只能 trace 稀疏的 far 決策。
- headless 無 player 時**全隊皆 far**（player_pos 無效）→ 「production headless 世界」本身是退化 all-far，非真 gameplay(有 player→near 隊存在)的代表。

∴ **「acceptance 判哪個世界」不是技術細節,是「什麼才算這遊戲的正典行為」的願景問題。**

## 選項（你裁；我標推薦）
| 選項 | judged 世界 | 觀測不變量 | 代價 |
|---|---|---|---|
| **A. 拆 LOD-exemption + 全隊 force_full_hd（我推薦）** | 全-HD（機制無 LOD 近似的 ground truth） | ✅ 滿足（大家都 near,specimen 不特殊,零連帶 RNG） | judged≠出貨 LOD 世界;**須重跑 headline(churn/attrition)在全-HD**求一致(你已裁的 -84.7%/established 1→2 是 LOD 數,全-HD 會不同) |
| **B. ①早期 team_id（你候選一）** | LOD | ❌ **不滿足**(exemption 還在,只挑影響小的 specimen) | 治標;下次挑到分化大的隊又壞;不是根治 |
| **C. ②Tier1 控制場景（你候選二）** | 合成手構 | ✅(小世界全 near,無 LOD) | 判的是人造 scenario,非 seed1337 organic 湧現死亡=失去「真世界故事」 |
| **D. 拆 exemption + 自然 LOD trace（我推的變體）** | LOD(真出貨世界) | ✅ 滿足 | headless 無 player=all-far 退化世界;trace 稀疏;可能根本 trace 不到 near 才有的 thrash 死 |

## 我推薦 A 的理由
- 唯一能**忠實觀測 organic 世界**（非合成）**又滿足觀測不變量**的。B 不根治、C 失真、D 判退化 all-far 世界。
- 全-HD＝「機制不靠 LOD 近似時的真行為」＝判「決策機制產不產出連貫故事」的最乾淨 ground truth。
- 一致性補丁：**headline + attrition + specimen story 全在 force_full_hd 跑一次**（同世界，你重看一組全-HD 數字，churn/established 可能微移但故事與數字同源）。成本=一次全-HD 重跑（acceptance 容許慢）。

## 附帶浮出的更大願景題（你決定要不要現在碰）
**LOD 與 full-HD 若產不同故事,哪個是「正典遊戲」?** 若 LOD 只是 perf 近似、本該 match full-HD → 任何分化是 LOD-fidelity bug（另開查）。若 LOD 允許分化 → 出貨世界是 LOD、觀測就得想辦法看 LOD。這是 vision 級,可能要拉用戶。本 slice **不需**解它（選 A 先讓故事 QA 跑起來），但標記給你。

## 待你一句話
選 A/B/C/D（或別的）。選 A 我補一致性(headline 全-HD 重跑)進 spec → 重送 R② → dispatch。這是 WHAT 秒級決策，非重新設計；機制面 reviewer 已 CLEAN。**execlock release 卡在這**（故事維度要能跑）。
