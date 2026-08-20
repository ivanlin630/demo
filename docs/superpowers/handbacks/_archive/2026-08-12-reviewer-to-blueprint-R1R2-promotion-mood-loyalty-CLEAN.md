---
from: reviewer
to: blueprint
status: consumed
topic: "[R①硬讀源訊號驗+R②判決=CLEAN+1標準必查項] 晉升→初始心情/忠誠spec——R①四靶皆坐實:①現況stress=0/fear=0親讀person_generator.gd:55-56逐字對得上(p.stress=0.0/p.fear=0.0)、loyalty初始來源親讀:54確認LoyaltyBank.set_baseline(p,1.0 if role=='leader' else rng.randf_range(0.5,1.0),'init')=member角色現況random[0.5,1.0]白紙、跟spec講的『無情境』一致;②★源訊號可用性親查team_data.gd確認匿名團/cohort無直接『集體忠誠/士氣』欄(親grep零命中),但team層級確有兩個真訊號可用:unrest_turns(:116,已是event_faction_defect.gd:23的distress_pressure input、既有真實)+known_reputations(:227,team對其他team/領主的信任度,已是_faction_stay_benefit在用的heard_rep same pattern)——spec沒有假設不存在的欄位、正確走『團層級推』這條路,7×over-claim教訓這輪真的守住;③恩義史/對領主態度訊號存在即known_reputations,坐實可接;④晉升情境可區分親讀_try_promote_advisor確認desperate布林值(demand>=PROMOTE_DESPERATE_DEMAND+spare<=PROMOTE_DESPERATE_SPARE時true)+fired_normal/fired_desperate兩路已經在code裡分岔,新officer誕生那一刻這個情境旗標就在手邊,不需要新增偵測機制;R②①③④三調/感激忠誠/情境分化皆WHAT層級待HOW公式,方向合理②接既有loyalty/known_reputations/unrest機制非新機制坐實③怨團拔的複雜個體日後可能叛直接餵入既有defect_util(讀promoted officer自己的loyalty值)零新增plumbing;★標準必查項(第四次同款套用,非新發現而是這arc一路要求的一致標準):三調公式要求HOW階段machine-demonstrate bounded(幸福村高忠誠/怨團低忠誠但非0、絕境摻壓力但非崩潰、和平冷靜非麻木),避免退化成『情境決定死值』的crank;判決=CLEAN+1標準必查項→鎖→systems寫HOW"
---

# R①+R②判決：晉升→初始心情/忠誠 spec — CLEAN + 1標準必查項

## R①（硬讀可用源訊號，7×over-claim 教訓——四靶全查）

**①現況白紙坐實**：親讀 `person_generator.gd:55-56` 逐字對得上——`p.stress = 0.0`、`p.fear = 0.0`。loyalty 初始來源親讀 `:54`：`LoyaltyBank.set_baseline(p, 1.0 if role=="leader" else rng.randf_range(0.5, 1.0), "init")`——member 角色現況是 `[0.5,1.0]` 純隨機、跟情境無關，spec「無情境白紙」的宣稱屬實。

**②★源訊號可用性——親查確認 spec 沒有假設不存在的欄位**：親查 `team_data.gd` 全文，匿名 cohort/team **沒有**直接的「集體忠誠/士氣」欄（grep 零命中）。但 team 層級確實有兩個真訊號可用：
- `unrest_turns`（`:116`）——已經是 `event_faction_defect.gd:23` `distress_pressure` 的輸入，既有、真實、非為這輪新造。
- `known_reputations`（`:227`）——team 對其他 team/領主的信任度，已經是 `_faction_stay_benefit` 在用的 `heard_rep` 同一套資料。

spec 沒有假設不存在的「集體忠誠」欄，正確走「用團層級 unrest/reputation 推」這條路——**這輪 7× over-claim 教訓真的守住了**，跟前幾輪一些 grounding 表偶爾出現的誤分類（如統一派遣 spec 那輪 herald 誤歸類）不同，這輪 blueprint 自己先做了「不假設」的正確防禦姿態。

**③恩義史/對領主態度訊號**：即 `known_reputations`，坐實可接。

**④晉升情境可區分**：親讀 `_try_promote_advisor` 確認 `desperate` 布林值（`demand >= PROMOTE_DESPERATE_DEMAND and team.named_members.size() <= PROMOTE_DESPERATE_SPARE` 時為 true）跟 `fired_normal`/`fired_desperate` 兩條路已經在 code 裡分岔——新 officer 誕生的那一刻，這個情境旗標就在手邊，不需要新增偵測機制，HOW 只要在 `generate_for_team` 呼叫點把這個既有旗標傳進去即可。

## R②

**①③④三調（提拔正底/情境調/來源調）+ 感激→忠誠/情境分化**：WHAT 層級待 HOW 定具體公式，方向合理，接的都是已驗證真實存在的訊號（`unrest_turns`/`known_reputations`/`desperate`），沒有無中生有的資料依賴。

**②接既有機制非新機制——坐實**：忠誠/`stress`/`fear`/`known_reputations` 全是既有欄位，這輪只是在「新個體誕生那一刻的初始值計算」這個單一切入點上，把既有訊號接進去，不是發明新的忠誠/心情系統。

**③怨團拔的複雜個體日後可能叛——零新增 plumbing 直接成立**：`event_faction_defect.gd:23` 的 `defect_util` 讀的是被評估 team 領主自己的 `loyalty`/`values`（`義氣`/`信義`），這輪 promoted officer 如果初始 loyalty 因為源團舊怨被壓低，後續若這個 officer 自己成為某隊領主，走的就是同一套已經審過很多輪的 `defect_util`/`_faction_stay_benefit` 機制——「賭注真實」這個框架不需要新機制驗證，是既有機制自然接住。

**★標準必查項（第四次同款套用，這 arc 一路建立的一致標準、非新發現）**：三調公式要求 HOW 階段 machine-demonstrate bounded——幸福村拔=高忠誠、怨團拔=忠誠低但**非歸零**（感激項要真的能部分抵銷舊怨、不是舊怨一有就整個蓋掉感激）；絕境急徵=摻壓力但**非崩潰**（`stress`/`fear` 要有合理上界）；和平冷靜=滿足但**非麻木**（要跟絕境那邊真的有分化）。避免退化成「情境決定死值」的 lookup-table 式 crank，需要是連續函式對真 state 的反應。

## 判決
**CLEAN + 1標準必查項 → 鎖 → systems 寫 HOW。** 這輪 R① 的四個靶證據紮實，尤其②的源訊號盤點正確避開了「假設不存在的欄位」這個 7× over-claim 教訓的核心陷阱——沒有欄位就老實講沒有、改用真實存在的團層級訊號推，這是這輪 spec 做得最好的地方。設計方向乾淨，接的都是既有機制，唯一必查項是延續這個 arc 一路要求的「genuine bounded 公式需 HOW 階段自證」標準。
