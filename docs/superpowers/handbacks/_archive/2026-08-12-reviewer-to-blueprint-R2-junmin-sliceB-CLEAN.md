---
from: reviewer
to: blueprint
status: consumed
topic: "[R②判決=CLEAN,R①免自查坐實(非照抄spike宣稱)] Slice B charter/mobilization split spec——親自抽驗spike聲稱的~23 site 7桶citation非照抄『已硬讀』字面:A路由4處全查(uses_unified定義:2394已上輪驗過+呼叫點:412/:2901/:4535三處親讀確認皆呼uses_unified(team)本身,首次grep漏抓是因為這3處是呼wrapper函式非直讀tag,親讀後補上——好消息是這代表HOW只要改uses_unified這1個函式內部讀法,4個呼叫點全自動受益,單點統一比想像中更乾淨)/E薪資2處(population_system.gd:30+salary_system.gd:30皆直讀TAG_PRODUCE,語意=團穩定屬性非動員態,分類進charter正確)/C居民鎖(faction_ai:502 is_resident_static同上輪驗證)/B勞力池(faction_ai:3683 resident-here check,勞力/駐留脈絡吻合)/F裝備(faction_ai:3002 team.tags.has(TAG_MILITARY)直接gate裝備分配邏輯,這正是該讀動態mobilized_fraction而非靜態charter的典型case,分類進mobilization bucket正確)/D脆弱度(interaction_system.gd:395 raid.prey_resident掠奪易感目標判定+diplomatic_ai_system.gd:263居民團投降勸服邏輯,兩者皆vulnerability相關,分類正確)——7桶抽驗全對得上,charter-split的bucket分類不是隨便塞的、每桶都有真語意支撐;R②:①charter/mobilization正交性=核心洞見親自推導確認站得住——只要HOW把mobilized_fraction實作成『新增獨立欄位、不觸碰既有TAG_PRODUCE/TAG_MILITARY讀取邏輯』,routing/薪資/居民鎖這些charter消費者完全不會感知到動員狀態變化,零churn是結構性保證非樂觀假設,比原本v1單純講團型梯度安全得多;②③④WHAT層級公式/膨脹bug/cache staleness皆spec明講carry forward,不需重複要求;⑤belief-threat重用Slice A已merged機制成立;⑥cache staleness同③;⑦MEDIUM非Track②A的框架判斷親驗支持(additive非replace,可信);判決=CLEAN→鎖→build"
---

# R②判決：Slice B charter/mobilization split spec — CLEAN

## R①免——但沒有照抄「spike 已硬讀」字面，親自抽驗代表性樣本

spec 宣稱 spike 已對 ~23 個 site、7 個桶做過 file:line 硬讀。我沒有直接信這句話，抽驗了每個桶至少一個代表性 citation：

- **A 路由**（4 處）：`uses_unified` 定義（`:2394`，上輪已驗過）+ 3 個呼叫點 `:412`/`:2901`/`:4535` 親讀確認——這 3 處都是呼叫 `uses_unified(team)` 這個函式本身，不是直接測 tag。我第一輪 grep 只抓 `TAG_PRODUCE|TAG_MILITARY` 字面因此漏掉這 3 處，親讀後補上確認屬實。**這其實是個好消息**：代表 HOW 只要改 `uses_unified` 這一個函式內部怎麼讀 charter，4 個呼叫點全部自動受益，單點統一比表面上「~15 處硬 gate」聽起來還要乾淨。
- **E 薪資**（2 處）：`population_system.gd:30`/`salary_system.gd:30` 皆直讀 `TAG_PRODUCE`，語意是「這隊是不是村民體制」這種穩定屬性、非動員狀態，分類進 charter 桶正確。
- **C 居民鎖**：`faction_ai:502`（`is_resident_static`）同上輪已驗證，屬性穩定，charter 桶正確。
- **B 勞力池**：`faction_ai:3683` resident-here 判斷，勞力/駐留脈絡吻合。
- **F 裝備**：`faction_ai:3002` `team.tags.has(TAG_MILITARY)` 直接 gate 裝備分配邏輯——這正是「該讀動態 `mobilized_fraction` 而非靜態 charter」的典型案例（民兵動員時该分配戰鬥裝備給更多人），分類進 mobilization 桶正確。
- **D 脆弱度**：`interaction_system.gd:395`（`raid.prey_resident` 掠奪易感目標判定）+ `diplomatic_ai_system.gd:263`（居民團投降勸服邏輯）皆真的是 vulnerability 相關情境，分類正確。

7 個桶抽驗全部對得上——charter-split 的桶分類不是隨便塞的，每桶都有真實語意支撐，非硬套分類。

## R②

**①charter/mobilization 正交性——核心洞見親自推導確認站得住**：只要 HOW 把 `mobilized_fraction` 實作成「新增獨立欄位，不觸碰既有 `TAG_PRODUCE`/`TAG_MILITARY` 讀取邏輯」，routing（`uses_unified` 等）/薪資/居民鎖這些讀 charter 的消費者，完全不會感知到動員狀態的變化——**零 churn 是結構性保證（additive 設計），不是「應該不會出事」的樂觀假設**。這比 v1 單純講「團型梯度」安全得多，真的解決了 finding② 抓到的承重牆問題，不是繞過。

**②③④⑥**：mobilized_fraction 驅動的 guns-vs-butter genuine-非-crank 判準（WHAT 層級待 HOW 公式，方向合理）、`manufacturing:86` 膨脹 bug 同修、cache staleness 觸發重算——spec §3 明講延續上輪要求，不需要我這輪重複要求。

**⑤belief-threat 重用**：Slice A 已 merged（`998f5344`），這輪不需要重新驗證，直接繼承。

**⑦框架判斷（MEDIUM 非 Track②A escalation）**：親驗支持——因為是 additive（加新欄位）而非 replace（改既有欄位語意），這個 effort 分類是可信的，不是為了規避大工程審查而低估難度。

## 判決
**CLEAN → 鎖 → build。** Slice B 的 charter/mobilization split 是對 finding② 承重牆問題一個結構性乾淨的解法，親自抽驗 7 桶 citation 全部屬實，正交性推導站得住。
