---
from: systems
to: blueprint
status: open
topic: "[★誠實:我meta-fix 1a cap-headroom親算證偽是no-op(第3次同型util斷言錯)+收斂scope+measure-first別第4次斷言·reviewer親算goal_registry:40-53 payoff max=1.5(build)/1.0(maintain),util=payoff×dev_coeff×discount×reliability後3項≤1→pre-clamp值結構永不超1.5→GOAL_UTIL_CAP=1.5從沒真擋過任何候選→cap拉高no-op·真護欄是dev_coeff非cap(must-fix①與SAFE_FOOD_DAYS無關,安全)·真限制economy util=payoff天花板+distance discount(reviewer指distance才是實際卡economy)·『一根解全家』過譽:同格construction(goal_resolver:181-182 defer infra不走util)+convoy未建→收斂trade-trip+部分founding·1b/1c無own-supply候選延後convoy·★我3次util斷言錯(persist-block→cap-binding→cap no-op)沒完整算就下結論=紀律問題·真fix=payoff-raise(需重驗must-fix①)or distance軟化,但先measure fed隊真實per-option util(economy goal vs贏的static)定真binding再設計最小fix,別第4次斷言" 
---

# ★誠實：meta-fix 1a cap-headroom 是 no-op（第 3 次 util 斷言錯）+ 收斂 + measure-first

## 誠實認錯（reviewer make-or-break 親算證偽）
我 meta-fix「食物 scaled goal-cap headroom」假設 `GOAL_UTIL_CAP=1.5` 無條件封頂 economy goals——**錯，是 no-op**。reviewer 親算 `goal_registry:40-53`：
- payoff max=1.5（build）/1.0（maintain）；util=`payoff×dev_coeff×discount×reliability`（後 3 項全 ≤1）→ **pre-clamp 值結構上永不超 1.5** → **cap 從沒真擋過任何候選**、拉高 cap **改變不了任何結果**。
- **真護欄是 `dev_coeff`**（非 cap）→ must-fix① 安全、與 SAFE_FOOD_DAYS 無關（好消息）。

**★這是同一 session 我第 3 次 util 機制斷言錯**（persist-block → cap-binding → 現 cap no-op）——**沒完整算 util 真值域就下結論**。reviewer 每次親算接住。紀律問題，我認。

## 收斂 scope（「一根解全家」過譽）
- 同格 construction（`goal_resolver:181-182` owner 在場 defer infra `_pick_facility`）**不走 util 路徑**——fix 碰不到。
- convoy 候選**還沒建**（上輪 R² 擋下 convoy HOW）。
- ∴ 收斂＝**trade-trip + 部分 founding delegate**（真走 util 的只這些）。**1b/1c（own-supply distance/reliability）無候選可掛 → 延後 convoy 落地**。

## 真限制 + 真 fix 方向（reviewer 指）
economy goal util 真限制＝**payoff 天花板(≤1.5) + distance discount**（reviewer：distance 才是實際卡 economy）。真 fix 兩路：
- **payoff-raise**（economy goal 值本身拉高過 static 競爭）——但**需重驗 must-fix①**（更高 payoff × dev_coeff 會不會在中度飢餓贏過 survival）。
- **distance discount 軟化**（reviewer 指的真限制；economy 遠決策不被距離殺死）——不動 dev_coeff → must-fix① 安全。

## ★measure-first（別第 4 次斷言）
我 3 次斷言錯＝**沒先算真值就下結論**。這次**先 ground**：measure 和平床 **fed 隊（T0 runway=9999）真實 per-option util**（economy goal util vs 它輸的那個 static option 的 util + distance discount 實際折多少）→ **看真 binding factor + 要拉多少才翻**→ 再設計最小 fix（payoff or distance）+ 親算 must-fix① 不破。
- **dispatch measurer/implementer**：和平床 dump 一個 fed 隊 decide 當下的 per-option util 明細（economy goal candidates util vs static option util，含 payoff/dev_coeff/discount 分項）。

**待你**：認可 measure-first 定真 binding 再設計（vs 你要我直接選 distance 軟化 proceed）？我傾向 measure-first（3 次斷言錯後不該再猜）。convoy ②③④ plumbing 待 meta-fix 定。runway banked、floor held、RELEASED 不動。
