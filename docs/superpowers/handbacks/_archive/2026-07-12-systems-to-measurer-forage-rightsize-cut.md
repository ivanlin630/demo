---
from: systems
to: measurer
status: consumed
topic: [右尺寸砍·省時] forage A/B別跑滿3seed×12mo×2檔(~4hr)—A/B從3mo選檔+12mo只winner檔1-2seed;established是下游慢變量本slice不主判
---

# 右尺寸砍：forage-floor-tune 別跑 4hr（協議 Tier2 右尺寸）

~4hr（3seed×12mo×2檔）對這 slice 是燒錯窗。這 slice **真問題=急性崩解沒解 + A/B 5v7 選檔**,那是**月1-3 的事,3mo 就答得出**。12mo 只為 established 苗頭（慢變量,且本 slice 是上游急性修,established 還受 A門/B2 下游卡=本 slice 不主判 established）。砍法：

## 1. A/B 從 3mo 選檔（非 12mo）
- **5天 vs 7天的差異（急性崩緩解 + 7檔誤開成長）在 3mo 全看得到**（attrition 月1-3 降幅 / farming_level=0 隊 pop 有無爆長 / 7檔 buffer 是否誤達建國盈餘）。
- ∴ **A/B 兩檔都只跑 3mo×3seed**（你 A 檔 3mo 已跑中；B 檔 7天也只 3mo）→ 選檔。**別在 12mo 跑 A/B**（省一半)。

## 2. 12mo 只跑 winner 檔 × 1-2 seed（established 苗頭）
- A/B 選出檔（5 or 7）→ **只那一檔跑 12mo,且 1-2 seed 夠**（established 是趨勢觀察,非 3seed robustness gate;本 slice 不主判 established>0,只看「急性崩解後 established 有無鬆動苗頭」）。
- established 完整解需 A門/B2 下游另修——12mo 這裡只標「苗頭/需下游補」,不當本 slice 成敗。

## 3. 平行 seed（若記憶體 ok，協議槓桿#2）
- 你前輪驗過 2 detach 進程平行未撞上限 → **3mo 的 3seed 可試 2-3 進程平行**（各 seed 一 detach，非單批序列）→ 3× 序列 → ~1.5× wall。撞資源就退單批。
- 守大窗 SOP①：不自拆單一 run,但**跨 seed 各自 run 平行**是允許的（協議明訂）。

## 淨效果
- 原 ~4hr（3×12×2）→ **3mo×3seed×2檔（選檔，可平行~15-30min）+ 12mo×winner×1-2seed（~30-80min）≈ 1hr**。
- 省 ~75%,且答到本 slice 真問題（急性崩+A/B）。established 苗頭當 bonus 觀察非 gate。

## 註
- 你已跑的 A 檔 3mo 不浪費（就是要的）。B 檔改 3mo 別 12mo。
- 深度 12mo 參照（用戶前定 2seed×12mo）仍可留,但那是「新基線參照」非 A/B gate——A/B 用 3mo 定,參照另存。
- 3mo 報 blueprint 判急性崩解沒解 + A/B 選檔（不等 12mo）。
