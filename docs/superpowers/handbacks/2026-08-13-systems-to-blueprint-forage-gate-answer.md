---
from: systems
to: blueprint
status: consumed
topic: "[★補丁閘查答案(gate 先於 tuning、你三候選裁定):在據點旁覓食=residency/所有權 gate 擋(候選③)+部分生產 facility-gate(候選①)、非 util 輸(候選②非主因)·★code 坐實三 option gate:①生產 applicable=has_own_outpost AND has_manufacturing_facility(options:34、雙 gate;有 outpost 無 facility→produce.appl_kill_nofacility=A2 主病 known [[project_size_matter_arc]] mfg de-patch/no_facility 同源)②採集(raw tile 收集累積路、resource_system:65 _collect_from_tile)=自動 for TAG_PRODUCE resident 站自家 tile(labor 池 pool_of 只算 TAG_PRODUCE、以 home tile 為準)=resident-gated、非 option 是 per-tick 自動收集③覓食(options:57)=population≤FORAGE_VIABLE_POP AND has_forage_tile=苟活地板小 pop 可用·∴『在據點旁覓食』真相=該團不是那據點 resident(不 own outpost/非 TAG_PRODUCE)→生產 option 不 applicable(無 own outpost)+不在 labor 池(採集不觸)→候選只剩覓食(+貿易/建設)=候選②util 輸不成立(採集根本不在候選、無得秤)、是候選③residency gate 前置擋掉累積路·★∴plug=成為 resident(①佔據=紮營 found[desperate+未佔農地 gate]or settle-at-outpost[subteam→convert_to_resident])、~60%流浪團卡在沒 resident 化=四段①佔據+②生產fire 同一 gate(production 需 resident+outpost、wanderer 無=只覓食苟活)·★不 over-unify(我剛燒3次):此為 structural gate 事實、measurer 四段量化(佔據率=幾團 resident vs 流浪、生產fire=resident 團採集/生產真跑否)定量級+是否多段並發·★修法方向(供你、非搶 WHAT):若坐實=修①佔據 residency 化門檻(紮營 gate 太嚴[需 desperate+未佔農地]、或 settle 決策鏈不 fire、wanderer 進不了 resident)=接既有 residency 路非重建經濟=較小 scope;facility-gate(生產需 manufacturing facility)是另一層(established-chain 五層雞生蛋 known)·序:measurer 四段+三守恆+訂單/節奏切面出→systems consolidate 世界帳本→你帶用戶生存經濟基座 arc(現指向 residency 化+生產 pipeline 兩層)·地基 KEEP·禁預設待量化"
---

# ★補丁閘查答案：在據點旁覓食 = residency/所有權 gate（候選③）+ 部分 facility-gate（候選①）

gate 先於 tuning。三候選裁定：**候選③（residency gate）主因 + 部分候選①（生產 facility-gate）、候選②（util 輸）不成立**。

## code 坐實三 option gate
- ①**生產** applicable = `has_own_outpost AND has_manufacturing_facility`（options:34、雙 gate；有 outpost 無 facility→`produce.appl_kill_nofacility`=A2 主病 known、[[project_size_matter_arc]] mfg de-patch/no_facility 同源）。
- ②**採集**（raw tile 收集=累積路、`resource_system:65 _collect_from_tile`）= **自動 for TAG_PRODUCE resident 站自家 tile**（labor 池 `pool_of` 只算 TAG_PRODUCE、以 home tile 為準）= **resident-gated、非 option 是 per-tick 自動收集**。
- ③**覓食**（options:57）= `population≤FORAGE_VIABLE_POP AND has_forage_tile` = 苟活地板小 pop 可用。

## ∴ 真相
「在據點旁覓食」= 該團**不是那據點 resident**（不 own outpost / 非 TAG_PRODUCE）→ 生產 option 不 applicable（無 own outpost）+ 不在 labor 池（採集不觸）→ **候選只剩覓食（+貿易/建設）**。∴候選②「util 輸」**不成立**（採集根本不在候選、無得秤）、是**候選③ residency gate 前置擋掉累積路**。

## ★plug = 成為 resident（①佔據）
紮營 found（desperate+未佔農地 gate）or settle-at-outpost（subteam→convert_to_resident）。~60% 流浪團卡在沒 resident 化 = 四段①佔據+②生產fire **同一 gate**（production 需 resident+outpost、wanderer 無=只覓食苟活）。

★**不 over-unify**（我剛燒 3 次）：此為 structural gate 事實、**measurer 四段量化**（佔據率=幾團 resident vs 流浪、生產fire=resident 團採集/生產真跑否）定量級 + 是否多段並發。

## ★修法方向（供你、非搶 WHAT）
若坐實=修①佔據 residency 化門檻（紮營 gate 太嚴[需 desperate+未佔農地]、或 settle 決策鏈不 fire、wanderer 進不了 resident）= 接既有 residency 路非重建經濟 = **較小 scope**；facility-gate（生產需 manufacturing facility）是另一層（established-chain 五層雞生蛋 known）。

序：measurer 四段+三守恆+訂單/節奏切面出 → systems consolidate 世界帳本 → 你帶用戶生存經濟基座 arc（現指向 residency 化 + 生產 pipeline 兩層）。地基 KEEP。禁預設待量化。
