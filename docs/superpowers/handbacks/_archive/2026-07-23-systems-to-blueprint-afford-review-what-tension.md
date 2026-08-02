---
from: systems
to: blueprint
status: consumed
topic: "[afford×1.5 系統性重審結論=WHAT tension 呈裁·tools-demand①已進 R²·v2a 已 merged e6519f9f] 你授權我重審 afford×1.5 系統性影響+調整計算方式。結論:★倍率不可安全下修——mint(cost 100)的 0.5×=50 buffer load-bearing(empty-window[1.0,1.4]實證破 G1a);任何幫 weaponsmith(cost 80,buffer 40,需<37 才可達 117)的 buffer 下修必連帶把 mint buffer 拉進 broken zone(absolute-cap/fixed-reserve/降倍率皆證再入 mint danger,推導在內文)。∴weaponsmith 真閘=material 天花板 117 < 需求 120(差 3),非可縮 margin。解閘要嘛①raise material 過 120(=reopen material,牴觸你「117 夠」)要嘛②降 weaponsmith material cost(=你的 balance lever,80→70→需 105<117)要嘛③接受 weaponsmith 暫閘、先推 tools-demand+其他經濟深度。這是跨 WHAT/HOW tension,呈你裁(cost/ceiling intent 屬 game-design)。tools-demand①(生產解閘)不受此 tension,已 spec+R²(reviewer)進行中,獨立可交付。"
---

# afford×1.5 系統性重審 → WHAT tension 呈裁

你授權（tools-demand-reframe-confirmed）：「重審這個倍率的系統性影響範圍（哪些設施受影響、是否該調整計算方式）」。我重審完，結論是**倍率本身不可安全下修**，真正的閘是別的層——這觸及你的 WHAT lever，呈你裁。

## 系統性映射
- ×1.5 三處：`faction_ai:2572`（新 outpost OUTPOST_COST）、`:2658`（upgrader）、`:2801`（facility builder）。
- `avail = tile.public_storage + owner.resources`（2800）；funding 只轉 `cost`，**0.5×cost = owner 出資後保留的 buffer**（防 serial-funding 把 owner 掏空）。

## ★倍率不可安全下修（推導）
- mint cost material **100** → buffer 0.5×=**50**。這 50 是 **load-bearing**：實證 empty-window **[1.0,1.4] 破 G1a mint chain**（owner-depletion），只有 ≥1.5 撐得住。
- weaponsmith cost **80** → buffer 40 → 要可達 117 需 buffer <**37**（即 required<117）。
- **任何 buffer 下修方案都連帶砍 mint**：
  - 降倍率（全域）→ mint 進 [1.0,1.4] broken（已 ABANDON）。
  - absolute-cap `min(0.5×cost,CAP)`：CAP<37 才幫 weaponsmith → mint buffer 被 cap 到 37 = 倍率 1.37 for mint → **broken zone 內**。
  - fixed-reserve `cost+R`：R=20 → weaponsmith 100✓ 但 mint 120 = 保留 20 = 倍率 1.2 → **broken zone 內**。
  - 三者皆因 **mint(100) 與 weaponsmith(80) cost 相近** → 無法只砍一邊。
- facility-specific carve-out = 你已撤回。
- ∴ **buffer 不能縮**。

## ∴ weaponsmith 真閘 = material 天花板 117 < 需求 120（差 3）
不是可縮的 margin，是 material 累積上限離需求差 3。解閘只剩：
1. **raise material 過 120**（讓 mil 隊累積更高）——但=**reopen material**，牴觸你「117 夠了別再花力氣」。
2. **降 weaponsmith material cost**（80→e.g. 70 → 需 105<117）——=**你的 balance lever**（cost 屬 game-design.md）。
3. **接受 weaponsmith 暫閘**，先推 tools-demand + 其他經濟深度，回頭再處理。

## 請裁（cost/ceiling intent 屬你）
①②③哪條？（我傾向：若你要 weaponsmith 近期建成 → ②降 cost 最乾淨無副作用；若 weaponsmith 非近期關鍵 → ③先擱、推別的深度。①reopen material 我不建議，你剛判夠。）

## tools-demand① 不受此 tension、獨立交付中
生產解閘（tools=0→tools 進經濟）與 afford 正交，已 spec + R²（reviewer）。**單獨此刀不會讓 weaponsmith 建成**（afford②仍擋）——成功判準=tools 進經濟。measure→QA 會照這故事判。

## 溯源
v2a merged `e6519f9f`（融合驗綠）。implementer build-gate finding `2026-07-23-implementer-to-systems-material-buy-buildgate-finding.md`（consumed）。
