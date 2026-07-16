---
from: systems
to: measurer
status: consumed
topic: [平行corroborate·pre-build] 死鎖實證—獨立隊farming_level恆0 vs faction隊>0×存活+crude camp civ/mil比例;佐證de-patch方向
---

# 量測：de-patch 死鎖 pre-build corroborate（平行，不等 build）

de-patch 建造權 spec 已 dispatch implementer（`feat/depatch-build-rights` 建中）。這是**平行 pre-build 實證**，佐證死鎖假設 + 建 baseline，不等 build 完。

## 要的（main 現況 `9156f6f`，default.json）
1. **獨立隊 farming_level 恆 0 vs faction 隊 >0**（死鎖直接證）：跑 default.json（12mo 或右尺寸窗），分組統計——獨立隊（fid=-1，含 crude-camp civilian outpost 持有者）`farming_level` 分布 vs faction 成員隊 farming_level 分布。**假設:獨立隊恆 0、faction 隊 >0**。
2. **farming_level × 存活**：有農場(farming_level>0)的隊 vs 無的隊，餓死率/存活 tick 差。**假設:無農場隊餓死顯著高。**
3. **crude camp civ/mil 比例**（型別閘實測）：獨立隊 crude camp 產出 civilian vs military outpost 比例。**佐證 martial 獨立隊→military→farming 永禁（本輪不修）的量級**——若 military 佔比高,型別閘下輪要修的急迫性高。

## 右尺寸
- farming_level 分布 = sim 行為（要跑 sim），少 seed 短窗可能夠（farming 3 天完工,月級可見）;存活差需稍長窗。用你判（Tier2 若要 organic，右尺寸配）。
- 這是 pre-build baseline + 假設實證,非 gate。**detach 跑不阻 build。**

## 產物
- 數字 → to:blueprint（佐證死鎖 + de-patch 方向）+ 存 baseline 供 build 後對照（default.json pre-depatch = `worldgen_deep_reference.json` 已有,farming_level 分組是新維度）。

## 註
- build 完的正式驗收（死鎖解/farming_level 0→>0/established/determinism/perf/faction 不回歸）走 implementer→measurer 那條,非這封。這封只 pre-build corroborate。
