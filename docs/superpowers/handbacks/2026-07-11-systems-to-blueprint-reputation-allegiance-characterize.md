---
from: systems
to: blueprint
status: open
topic: [characterize+scope] 名聲歸附三閉環——1部分/2沒建/3沒建;語意nuance(現名聲=intel信任非道德);大arc
---

# 回 blueprint：名聲驅動自願歸附 三閉環 characterize + scope

三閉環各查完（file:line，這次讀到底）。**現況：一部分、兩沒建 + 一語意 nuance 你要先定。**

## 三閉環現況
| 閉環 | 現況 | file:line |
|---|---|---|
| **1. known_reputations 更新源** | **部分**：親身 diplomacy（`diplomatic_ai:253 結盟+0.2`/`:321 背叛-0.5`/`:188 拒-0.1`/gift+0.05）+ 二手 belief（`belief_system:209/212`——**但那是 intel 準確度信任**：source 情報準(r 0.7~1.3)→+、亂報/扭曲→−）。**無傳聞傳播**（message_system `:161/207` 只**讀** rep 不散播；per-observer 自建，無 gossip「X 是好保護者」擴散）。用戶要 b=吃傳聞→**沒建**。 | `team_data:198` update_reputation(clamp 0~1) |
| **2. 事件→名聲（relation_edges）** | **沒建**：`relation_edges`(protect/gratitude/betray/killed) grep+reput=空，**不接** update_reputation。護人→漲/背叛→跌 這條斷。 | — |
| **3. 決策讀名聲** | **沒建**：`join_drive:89`/FLEE **不讀** `known_reputations[protector]`。投靠 vs 逃不看保護傘名聲。（rep 別處有讀：belief 信任/diplomatic 提案/encounter 駐守/faction_ai，決策歸附點漏。） | `terms.gd:89-91` |

## ★語意 nuance（你先定，影響 scope）
現 `known_reputations` = **intel-可信度（情報準不準）+ diplomatic-行為（結盟/背叛）混合**，**非「保護/仁德」道德名聲**。你要的「名聲好→值得投奔」是**道德/保護軸**，現欄沒喂道德事件（閉環2 斷）。二選一（你裁）：
- **(α) 擴同一欄**：把 protect/gratitude 等道德事件也喂進 known_reputations（intel+道德混一分）。省欄、但語意混（一個好情報源≠一個好保護者）。
- **(β) 分二軸**：`known_reputations`(情報信任，現狀不動) + 新 `allegiance_rep`/`protector_rep`（道德/保護名聲，歸附決策讀此）。語意乾淨、但多一欄 + 傳播/事件各接。
- **systems 傾向 (β)**：情報可信度 vs 值不值得投奔是**不同語意**（reviewer 冗餘 lens 也會問）；混一欄=語意撞。

## scope 評估（大 arc，非 tweak/中 slice）
| 閉環 | 要建 | 量級 |
|---|---|---|
| 1 傳聞傳播 | message_system 帶名聲 gossip（二手：A 告訴 B「C 名聲如何」→ B 更新對 C 的 rep，衰減/距離）；主觀 per-observer 保 | **中-大**（新傳播機制） |
| 2 事件→名聲 | protect/gratitude/betray/killed（relation_edges 或事件）→ update_reputation/allegiance_rep（護→漲/背→跌） | **中** |
| 3 決策讀名聲 | `join_drive`/FLEE weight × `名聲[protector]`（高名聲 host→投靠翻贏逃；場景 E 逃1.0 vs 投靠0.82 掛名聲翻盤）+ 投靠 finder 找高名聲保護傘 | **小-中** |
| (β 若選) 新欄 | `allegiance_rep` context + 傳播/事件/決策全接此軸 | +小 |

**總量級 = 大 arc**（新傳播閉環 + 道德名聲軸 + 歸附決策改；比補 utility 大）。**咬既有系統**：message_system（傳播）/belief_system（信任 pattern 參照）/relation_edges（道德事件源）/known_reputations（欄）——**複用非重造**（傳播接 message、事件接 relation_edges、決策接 rank_scored term）。

## 守則守
- 複用既有（message/belief/relation_edges/known_reputations），禁重造。
- 名聲決策走 rank_scored 真 term，過框架內冗餘 lens（新名聲 term vs 既有；α/β 語意撞問題見上）。
- 主觀 per-observer（known_reputations 已 per-team ✓），別偷懶讀全域真值。

## → 你給 user 裁
1. **α vs β**（名聲軸混一/分二）——影響語意 + scope。
2. **投資額**：大 arc（三閉環全建 vs 先建閉環3決策讀名聲+閉環2事件源、傳聞傳播 defer？分階段可能）。
3. a/b/c 續按住（這條若成，consolidation 靠名聲歸附活，不動征服平衡=繞死結）。

**分階段建議**（若你要縮風險）：先閉環3（決策讀 rep）+閉環2（道德事件喂 rep）= 中 slice 先看「名聲磁鐵發不發得動」（用現有 diplomacy-rep 波動先測），**傳聞傳播（閉環1 gossip）大工 defer** 到磁鐵證有效再投。→ 你評。
