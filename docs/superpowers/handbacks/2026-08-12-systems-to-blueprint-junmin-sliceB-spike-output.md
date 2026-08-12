---
from: systems
to: blueprint
status: consumed
topic: "[Slice B 承重牆 spike 輸出(只探不改、硬讀 file:line 非 inference)·★核心結構洞見:TAG_PRODUCE binary 混淆兩正交概念①charter/團型(村/軍/商、穩定、建點定)②當下勞力↔戰力配置(動態隨威脅)→军民混编 decouple 法=拆這兩者(非 a 主業過半 flip、非 b 全解綁含路由=Track②A、而是 charter-vs-mobilization split)·★uses_unified:2394=has(MERCHANT)or has(PRODUCE)、:2901 主路由(if uses_unified:_decide_unified;return、非 unified 走 legacy 分裂路)=承重牆·★gate 分 7 語意桶(~23 site 硬讀):A 路由(uses_unified :2394 def+:412/:2901/:4535 caller=決策引擎 vs legacy、Track②A 糾纏)/B 勞力生產(labor:27/37 pool_of+faction_ai:3683/3728=貢獻勞力、Slice B 核心 pool 分數化必改)/C 居民鎖(faction_ai:502 is_resident_static=PRODUCE+own outpost+sim_runner:343/movement:68 駐守鎖=settled resident)/D 劫掠目標/脆弱度(interaction:395 prey_resident+:301/303 PACIFY+:521 tribute payer+diplomatic:263=civilian 可劫/可撫/可稅)/E 域行為(population:30 outpost pop-cap+salary:30 居民不領薪=經濟域規則)/F 軍事行為(faction_ai:3002 equip 重武+:3037 armor=戰鬥單位)/G 建點指派(outpost:170/367/404/407+interaction:1337/1358/1364=團型誕生)·★★decouple 法(推薦=charter/mobilization split):charter(穩定團型、≈現 TAG_PRODUCE for 村)驅動 A 路由+E 薪資pop+C 居民鎖=★這些讀 charter 不改行為(charter=現 tag、村charter 隊動員民兵時 charter 不變→路由不 churn→零 Track②A 糾纏);mobilization-fraction(動態)驅動 B 勞力池+F 裝備+D 脆弱度=★Slice B 核心工作·∴避開 Track②A(路由讀 charter 穩定非動員態)·★effort/blast:charter-split=MEDIUM(加 mobilized_fraction 欄+B 勞力 ~4 site pool 分數化+F 裝備~2+D 脆弱~4 讀 fraction;A 路由/E 薪資pop/C 居民鎖 UNCHANGED 讀 charter 零行為變;G 建點指派 charter+初始 fraction 小)·vs (a)主業過半 flip=LOW code 但路由 churn(動員隊翻路徑=語意 hazard)vs (b)全解綁含路由=HIGH(Track②A unified 遷移)·★∴Slice B via charter-split=gameplay arc 續(MEDIUM、不需用戶-scale Track②A)·序:你判 Slice B scope(charter-split 法我推=續 build 不需帶用戶 vs 你有別 framing)→鎖 spec→R②→build·地基 KEEP·待你裁 decouple 法+scope"
---

# Slice B 承重牆 spike 輸出（只探不改、硬讀 file:line）

## ★★核心結構洞見
`TAG_PRODUCE` binary **混淆兩正交概念**：
1. **charter/團型**（村/軍/商、**穩定**、建點定、驅動路由/薪資/pop-cap/居民鎖）。
2. **當下勞力↔戰力配置**（**動態**、隨威脅變、驅動 pool/裝備/脆弱度）。

军民混编 的 decouple = **拆這兩者**（非 (a) 主業過半 flip、非 (b) 全解綁含路由=Track②A、而是 **charter-vs-mobilization split**）。

## 承重牆：uses_unified 路由
`uses_unified:2394 = has(MERCHANT) or has(PRODUCE)`；`:2901` 主路由（`if uses_unified: _decide_unified; return`、非 unified 走 legacy 分裂路）+ :412/:4535。= 決策引擎 vs legacy、與 Track②A（unified 遷移）糾纏。

## gate 7 語意桶（~23 site 硬讀）
| 桶 | site | 語意 | Slice B 處置 |
|---|---|---|---|
| **A 路由** | uses_unified:2394 + :412/:2901/:4535 | 決策引擎 vs legacy | 讀 **charter**（穩定）= UNCHANGED |
| **B 勞力生產** | labor:27/37 pool_of + faction_ai:3683/3728 | 貢獻勞力 | 讀 **mobilization-fraction** = ★核心 pool 分數化 |
| **C 居民鎖** | faction_ai:502 is_resident_static + sim_runner:343 + movement:68 | settled resident 駐守鎖 | 讀 **charter** = UNCHANGED |
| **D 劫掠/脆弱** | interaction:395 prey_resident + :301/303 + :521 + diplomatic:263 | civilian 可劫/撫/稅 | 讀 **fraction/armed**（脆弱度）|
| **E 域行為** | population:30 pop-cap + salary:30 居民不領薪 | 經濟域規則 | 讀 **charter** = UNCHANGED |
| **F 軍事行為** | faction_ai:3002 equip + :3037 armor | 戰鬥單位 | 讀 **fraction**（mobilized）|
| **G 建點指派** | outpost:170/367/404/407 + interaction:1337/1358/1364 | 團型誕生 | 指派 charter + 初始 fraction |

## ★★decouple 法（推薦 = charter/mobilization split）
- **charter**（穩定團型、≈現 TAG_PRODUCE for 村）驅動 **A 路由 + E 薪資pop + C 居民鎖** → ★**讀 charter 不改行為**（charter=現 tag；村-charter 隊動員民兵時 charter 不變 → 路由不 churn → **零 Track②A 糾纏**）。
- **mobilization-fraction**（動態）驅動 **B 勞力池 + F 裝備 + D 脆弱度** → ★**Slice B 核心工作**。
- ∴**避開 Track②A**（路由讀 charter 穩定、非動員態）。

## ★effort / blast-radius
- **charter-split = MEDIUM**：加 `mobilized_fraction` 欄 + B 勞力 ~4 site pool 分數化 + F 裝備 ~2 + D 脆弱 ~4 讀 fraction；**A 路由 / E 薪資pop / C 居民鎖 UNCHANGED**（讀 charter 零行為變）；G 建點指派 charter+初始 fraction 小。
- vs **(a) 主業過半 flip** = LOW code 但**路由 churn**（動員隊翻路徑=語意 hazard）。
- vs **(b) 全解綁含路由** = HIGH（Track②A unified 遷移）。

## ∴ 結論
Slice B via **charter-split = gameplay arc 續**（MEDIUM effort、**不需用戶-scale Track②A**）。

序：你判 Slice B scope（charter-split 法我推=續 build 不需帶用戶 vs 你有別 framing）→ 鎖 spec → R② → build。地基 KEEP。待你裁 decouple 法 + scope。
