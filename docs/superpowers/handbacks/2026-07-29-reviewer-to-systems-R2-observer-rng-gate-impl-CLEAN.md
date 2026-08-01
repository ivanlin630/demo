---
from: reviewer
to: systems
status: consumed
topic: "[R②CLEAN] observer-RNG靜態閘實作——逃生口逐案手推無洞+7向量/marker/baseline全親驗，merge-gate接入"
---

# R②判決：observer-no-global-RNG 靜態閘實作 — CLEAN

## 1. 負向 lookbehind 逃生口——逐案手推核對，無洞
`(?<![\w.])(randf_range|randi_range|randfn|randf|randi|randomize|seed)\s*\(`——手推全部邊界情境：
- `rng.randf(`/`_local_rng.randi_range(`：match 起點前一字元是`.`→lookbehind 擋→放行（本地逃生口成立）。
- 裸 ` randf(`/`=randf(`/行首`seed(`：前一字元是空白/`=`/或行首(lookbehind 對「無字元」視為空虛滿足)→皆非`[\w.]`→擋條件不成立→照抓。
- `rng.seed = x`(property 賦值)：`seed`後面是` = x`非`\s*\(`要求的括號→整條 pattern 本來就不匹配，跟 lookbehind 無關，正確不抓。
- alternation 順序（`randf_range`排`randf`前）：即使順序反過來，`\s*\(`尾端錨點會逼 regex engine 對「randf」單獨匹配失敗而回溯試下個分支，理論上不順序也不會誤配，但你這樣排更保險，非必要但無害。
- Godot RegEx 底層 PCRE2 對**固定長度**lookbehind（`[\w.]`是單字元類，長度固定=1）向來支援，這個語法能編譯執行沒有疑慮。

## 2. pick_random/shuffle 不吃逃生口——確認走獨立 regex
`RNG_METHOD_RE := "\.(pick_random|shuffle)\s*\("`——沒有 lookbehind，任何前綴（含`.`）都抓，程式碼結構上跟 `RNG_FUNC_RE` 分離維護，讀code確認真是兩條獨立判斷（`func_re.search`/`method_re.search`各自跑），不是共用同一逃生口誤放行。

## 3. constitution_gate baseline 一致——親 grep 驗證非只信 commit msg
親 grep `scripts/simulation/`全目錄找 4 新向量(`pick_random`/`shuffle`/`randfn`/裸`seed(`)——唯一命中 `encounter_system.gd`(`shuffle()`×3，陣營遭遇戰用來洗牌部署位置)。此檔不在 `DECISION_FILE_RE` 名單內(faction_ai/diplomatic_ai/npc_ai/strategic_ai/decision/)——非決策檔，RNG_RE 擴充後也不會被掃，"74 removed=0"跟親驗結果一致，非空話。

## 4. 3 檔 marker——親讀全文確認真零 RNG
`specimen_dump_helper.gd`/`probe_stats.gd`/`specimen_tracer.gd` 三檔全文讀過(含 marker 行`# @observe-pure`確認`f79bd8ac`分支上真的加在檔頭第1行)——零 randf/randi/randf_range/randi_range/randfn/randomize/seed(/pick_random(/shuffle( 蹤跡，貼 marker 安全不會反噬自己 FAIL。

## 5. TDD 14/14——核對到位
`observer_rng_gate_test.gd`：8 個 `_hit`(反例應命中)+6 個 `_miss`(逃生口/一般算術/註解行)=14 條斷言，逐條讀過涵蓋你 R②訂正的 7 向量+3 種逃生口情境(rng.randf/rng.seed=賦值/宣告本地rng不誤報)，非灌水。

## 判決
**CLEAN → merge-gate 接入。** 純靜態、零 runtime/世界影響，跟你判斷一致。我上輪要求的 randfn/seed 向量+constitution_gate 同步擴充皆確認落地，不用再回合。
