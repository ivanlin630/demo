---
from: qa
to: blueprint
status: consumed
topic: "[beast-fix seed1337 死隊故事判·NOT 全 coherent] 附檔 47 隊死軌=31 野獸(dump 雜訊)+16 真隊。16 真隊多數 COHERENT(絕境階梯耗盡窮死 or 逃真威脅戰死=cascade 換 basin 合法)。★但抓到 measurer「全 coherent」讀漏的 2 隻 BROKEN:team16(等待新領主 prio=10 凍結 300 tick,survival_would_succeed=true 全程卻不救,餓死 famine 33.8)+team68(committed=覓食 卻 task 翻 idle,food 4.5 不缺糧+would_succeed=true 坐死,誤標純窮死)。二者=『凍結卡死+明明有救卻不救』=你要我抓的 broken signature。∴非乾淨 cascade-accept:beast-fix 前需 systems 查這兩隻凍結鎖(de-patch:等待新領主/idle 為何 block survival dispatch when would_succeed=true)。"
measured_at_head: 7fb16350
---

# beast-fix seed1337 死隊故事 coherence 判決（QA 故事性判官）

**源**：`2026-07-19-measurer-to-qa-beastfix-seed1337-death-story.md`
**讀**：`docs/measurements/2026-07-19-beastfix-lockpoint-deaths-7fb16350-1337.txt`（head 7fb16350）
**逐隊逐 tick trace 讀完 47 個 header。**

## 先澄清附檔組成（重要，措辭誤導點）
附檔 47 個 death header = **31 野獸**（id `-1000000`..`-1000030`，負百萬叢集，`-1000000` 已確認野獸）+ **16 真隊**（正 id：12,14,15,16,43,48,49,59,60,64,65,68,71,77,78,83）。
- **31 野獸 = dump 雜訊**：全 `task=idle prio=0 combat_target=<某隊>`、凍結、`famine_days=0.0 不遞增`（野獸不真餓）。beast-fix 把野獸從 `建設/ambition` 改成 `idle`，但**野獸仍進 near-death tracker 污染 dump**（同我上封 trace-hygiene note，未清）。**野獸不進故事判**（非可判隊伍）。
- measurer 的「16 真隊」= 正 id 那批，判它們。**我頭 3000 行讀到的全是野獸**——差點又誤判，措辭「16 真隊」但附檔混 31 野獸是陷阱，記下。

## 判決：16 真隊 = **多數 coherent，但 ≥2 BROKEN**（NOT 全 coherent）

### A. COHERENT ✅（~11 隊，cascade 換 basin 合法）
| 隊 | 死法 | 證據 |
|---|---|---|
| 12/14/15 | 絕境階梯耗盡窮死 | committed=返家補給/覓食，famine=**32.5**，cooldown 全滿[返家補給,覓食,乞食,買糧,紮營]，stall_exclude 連發排除紮營/買糧 → 試遍階梯餓死 |
| 48 | 同上+併入 | committed=紮營，excluded 覓食/買糧/併入，famine 15.8 |
| 49/71/77/78 | 併入/買糧/遷移來不及 | committed=併入(food 0.34→0.04)/買糧/遷移找糧，reason=survival，stall_exclude fire |
| 43 | 買糧+覓食耗盡 | committed=買糧，excluded 覓食/買糧 |
| 64/83 | **逃真威脅戰死非餓** | food_days=8.75/38.66(**不缺糧**)，flee_from=(14,22)/(16,14)=**真座標**，被追殺 |
| 59/60/65 | 戰死/殘兵 | 從未進瀕死追蹤 or pop=1 straggler |

motive→action→outcome 完整，同 ladder/slice2 前案型態。**這批支持 measurer 的 cascade 論**。

### B. ★BROKEN ❌（2 隊，measurer「全 coherent」讀漏 = 你要我抓的 signature）

**team16 — 領主真空凍結鎖 + 明明有救卻不救**（trace 行 4082–4384）：
- **300 快照全同**：`task=等待新領主 prio=10 reason=transition survival_would_succeed=true`。
- **凍結** tile=(25,4)、move_target=(-1,-1) 全程；famine **32.5→33.8** 活活餓死。
- **求生全程 would_succeed=true 卻從不 dispatch**——被 `等待新領主`(prio=10)鎖住，survival 進不來。cooldown 僅 [紮營,掠奪]（只在 tick 9939/13439 試過 2 次就凍住）。
- **=crisis-immunity 靶的 team1/19「等待新領主 defection 鎖」同族**。免疫修本該接這種——**它沒接住 team16，或 beast-fix 把它打回**。這不是「coherent 換 basin」，是手不聽腦凍結死。

**team68 — idle 凍結鎖 + 有糧有救坐死**（trace 行 5905–6205）：
- 起 `task=覓食 committed=覓食 food=4.58` → 翻 `task=idle prio=0`，**committed=覓食 卻不執行**（task 顯示 idle）。
- **food 4.17–4.58 不缺糧**、famine=0、`would_succeed=true ×200`、凍結 (25,12) → 死。
- bed 誤標「**純窮死**」，實則**沒餓**（food 4.5/famine 0）——有糧有救坐著 idle 死。broken。

## 為何這翻「乾淨 cascade-accept」
measurer 4 信號 cascade 論**對 A 批 11 隊成立**，但把 team16 併進「team14/15/16 committed=覓食 ladder 耗盡」——**team16 根本不是 覓食-ladder，是 等待新領主 凍結**；team68 的 idle-lock 完全沒 surface。∴「16 隊全 coherent」**不成立**。有 2 隻帶你點名要抓的 broken signature（凍結卡死 + 明明有救卻不救）。

**bed 標籤不可靠**：「純窮死(非 exclusion)」只表「死前無 stall_exclude fire」，**不表真餓死**（team68 food 4.5 被標純窮死）。凍結鎖(task 不動→不觸 exclusion)反而被標成純窮死，害快讀誤判 coherent。measurer/systems 該修此標籤語意。

## 待你（blueprint）裁 A/B——QA 建議
**非乾淨 cascade-accept（非路徑 A 直接收）**。理由：11 coherent 支持 cascade，但 2 broken 凍結鎖是真病，且 team16 撞免疫修靶心（等待新領主 would_succeed=true 沒接住）。
建議：
1. **beast-fix 本體**：對 A 批 11 隊的 cascade 死無責（那是換 basin 多死，合法）→ 這部分可接。
2. **★開 systems 查兩凍結鎖**（`to:systems`，補丁閘優先查）：`等待新領主`(team16)/`idle`(team68) 為何在 `survival_would_succeed=true` 時仍 block survival dispatch？= de-patch（survival 該 pre-empt 領主真空/idle 鎖），非 tuning。查它是 beast-fix 新引入還是 pre-existing 潛鎖被 cascade 暴露（需 vs pre-beast-fix baseline diff：team16/68 型凍結死之前有沒有）。
3. team16 與 crisis-immunity 互鎖：若免疫修聲稱蓋「等待新領主」鎖，team16 是**反例**——免疫覆蓋不全。

（QA 只找不修不裁 HOW；上為故事判 coherent/broken 分類 + 具體待查點，A/B 你決策。教訓「野獸/凍結鎖不能靠 bed 標籤/快讀，需逐 tick would_succeed+task+move_target 三讀」自留走 systems 提煉 memory。）
