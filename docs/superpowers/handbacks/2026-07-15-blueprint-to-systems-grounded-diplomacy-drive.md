---
from: blueprint
to: systems
status: consumed
topic: [驅動·小 arc 續尾] 求和/外交 grounded 收乾淨(look-before-leap+求和order_task seam bug);大 arc 排序(god-view/照妖鏡/observe)攢用戶醒裁;掠奪根續
---

# 驅動：求和/外交 grounded（mirage 家族最後兩尾）

用戶睡前「繼續」＝續驅動 arc。稽核揭 grounded-ness **只剩求和/外交兩小尾**（我原擔心的一大批沒成真，好消息）。**這是同族續尾（買糧/併入/掠奪同款），小、清晰、無願景 fork → 我驅動,不等用戶。**

## 意圖（WHAT，續 look-before-leap 家族）
1. **求和/外交 look-before-leap**：社交/外交類（需對方同意）＝ungrounded 幻覺同款。求和/外交 applicable 加「對方可能接受」gate（走 belief 估對方意向/關係，非 god-view），做不成不入候選 → fall through。**收乾淨 mirage 家族。**
2. **★求和 order_task seam bug（clear bug）**：`to_task` 的 `order_task=TRIBUTE_OFFER` 被 `_try_diplomacy` 硬寫 `propose_alliance` 丟棄 → **求和變求盟（語意錯）**。修：求和走求和 path，別被覆寫成求盟。+ 既存 `diplomacy_reject_cooldown` 回接 gate（被拒不再纏，鏡射 A-2 learn-from-rejection）。

## 驗收
- 求和/外交做不成時不入候選（belief-gated）。
- 求和真的是求和（非被覆寫成求盟）。
- 被拒 cooldown 生效（不纏 loop）。
- 中性世界（confound 已修）判 + 故事 QA。

## patch-gate-first
先查 order_task 為何被覆寫（seam）+ 求和/外交 applicable 現在驗什麼 → 挖到底 → spec → R² → impl → 中性驗 → QA → 我批。

---

## ★大 arc 排序＝攢用戶醒裁（不擅自開大 arc）
稽核揭三個候選下個主 arc，**排序是願景決策，用戶醒才裁**（我不擅自開）：
- **①感知腳位置 god-view**（我傾向最高）：最大單一結構債、整族違感知鐵律、belief 修路現成（~12 點共根）。**解鎖逃脫/迷霧/伏擊故事**——現在「發現過→永久零迷霧知你在哪」→躲森林繞路都被精準攔截＝世界感覺全知非真實。修＝命運不看玩家臉色 + 不完美資訊世界的位置版。
- **②照妖鏡死常數族**（262/決策31）：建共用人格函式讓整族走（engagement margin/food 安全線/panic/commitment 族）＝AI 深度「同感知不同腦」。部分可 observe-then-tune。
- **③full-HD live 觀察 slice**：開反應/生育看 live 世界。

**我的傾向排序**：god-view 位置(①) → full-HD 觀察(③，在乾淨結構上觀察) → 照妖鏡(②，部分觀察後 tune)。理由：god-view 位置是最大結構債且會扭曲觀察（追擊全精準→逃脫故事觀察不到）,先清。**但用戶按願景定,我攢著。**

- **decide_treatment 域判斷器邊界**（俘虜處置）＝需用戶域 WHAT，一併攢。

## 現在驅動的
求和/外交 grounded（本信）+ 掠奪根（在飛）+ desperation merge（你執行）。大 arc 待用戶醒。
