---
from: systems
to: implementer
status: open
topic: "[小工單:修 g1a fixture(具名科目①=fixture artifact 定案、非 production floor)·measurer code-read 坐實:headless_test:15297 _mk_produce_team_on 從沒設 leader.skills['統領'](只設 values 貪婪/野心)→effective_pop_cap 讀 skills.get('統領',0.0)=0.0→pop_cap_from_leadership(0.0)=1(team_data:49)→×放大器(L1=2.0)→effective≈2→_seed_pop(team,10) 立刻超額 8→check_overflow_for_team 觸發拆走生產人力(無 named advisor 走 _create_overflow_team)→殘隊跑不動 collect+mint→[g1a] 礦村未鑄幣·★為何 main 沒露:main PRODUCE 居民走 leader-independent _outpost_pop_cap(L1=20)、農業b 換成領導基數×放大器才把 fixture 缺欄暴露=fixture 一直假設 leader-independent cap·★修:給 _mk_produce_team_on 的 leader 補 skills['統領'] 正常值(如 0.5、對齊其他 fixture helper 慣例)·★★注意(共用 helper、必查連帶):先 grep 全 headless_test 用 _mk_produce_team_on 的測(數量+各自斷言)、確認補 統領 後【沒有別的測因 pop_cap 變大/行為變而翻紅或變 trivially-true】;若有測依賴『這隊 cap 很小』的隱含前提→停下呈報我(那要逐測訂正非一改了事)·驗:headless branch vs main 全量比對→[g1a] 轉綠且 0-new(除已知 6 pre-existing)+agriculture_b_test 9/9 仍綠+determinism(fixture 只動 test、production 零改→branch fp 應仍 24cffe3b、若變請標並停下)·★不碰 production code、不加任何 pop-cap floor(floor 要不要=organic 數據決定、measurer 長跑中)·完→handback to:systems·地基KEEP"
---

# 小工單：修 g1a fixture（具名科目①=fixture artifact 定案）

measurer code-read 坐實：`headless_test:15297` `_mk_produce_team_on` **從沒設 `leader.skills["統領"]`**（只設 `values` 貪婪/野心）→ `effective_pop_cap` 讀 `skills.get("統領", 0.0)`=**0.0** → `pop_cap_from_leadership(0.0)=1`（`team_data:49`）→ ×放大器(L1=2.0) → **effective≈2** → `_seed_pop(team,10)` 立刻超額 8 → `check_overflow_for_team` 拆走生產人力（無 named advisor 走 `_create_overflow_team`）→ 殘隊跑不動 collect+mint → **[g1a] 礦村未鑄幣**。

**★為何 main 沒露**：main 的 PRODUCE 居民走 **leader-independent** `_outpost_pop_cap`(L1=20)；農業b 換成**領導基數×放大器**才把 fixture 缺欄暴露=**fixture 一直假設 leader-independent cap**。

## ★修
給 `_mk_produce_team_on` 的 leader 補 `skills["統領"]` 正常值（如 **0.5**、對齊其他 fixture helper 慣例）。

## ★★注意（共用 helper、必查連帶）
先 **grep 全 headless_test 用 `_mk_produce_team_on` 的測**（數量 + 各自斷言）、確認補 統領 後**沒有別的測因 pop_cap 變大/行為變而翻紅或變 trivially-true**；**若有測依賴「這隊 cap 很小」的隱含前提 → 停下呈報我**（那要逐測訂正、非一改了事）。

## 驗
headless branch vs main 全量比對 → **[g1a] 轉綠且 0-new**（除已知 6 pre-existing）+ `agriculture_b_test` 9/9 仍綠 + determinism（fixture 只動 test、production 零改 → **branch fp 應仍 `24cffe3b`**、若變請標並**停下**）。
**★不碰 production code、不加任何 pop-cap floor**（floor 要不要=**organic 數據決定**、measurer 長跑中）。

完 → handback to:systems。地基 KEEP。
