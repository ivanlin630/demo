# 決策模型 v2 深化（③內政 / 慾望泛化 / ④情緒）— 未來 arc 停車筆記

> 藍圖×用戶 brainstorm 2026-07-19（無信箱藍圖 session，純未來願景）。**非現在派工**。存 `notes/`（不碰 canonical、不發 handback）。observe-gated（v2 §建構序：thrash-fix→慾望泛化→③→④⑤ 後疊；②③④ 降級「觀察 live 後才做」）。
> **主軸：今天做的維度（身份/正統/天命/天災）全是決策模型 v2 的輸入。v2＝引擎，那些＝餵進去的料。** v2 大框在 game-design.md（v2 §1-6，2026-07-14），此筆記＝今天的深化增量。接 [[2026-07-19-identity-dynasty-legitimacy-brainstorm]]、[[2026-07-19-natural-disaster-brainstorm]]、[[2026-07-19-active-rumor-fabrication-brainstorm]]。

## ③ 內政：從「內亂機制」升成「內部正統爭奪」
game-design v2 §5 已有骨架（老大拍板 + 納諫異議成本 + 對稱牙 exile/split/coup/snap + de-patch scripted events）。今天升級：

- **★一個 mandate-belief，兩個聽眾（外部承認 + 內部忠誠）統一**：頭人失天命（敗仗/天災/饑荒）→ **外邦不承認 AND 自己人不挺，一起崩**。內部政治＝天命 belief 在自己成員心中跌破臨界（非獨立的「不滿累積」）。
- **member 層引擎決策（scripted events 死）**：每成員秤「對現頭人 mandate-belief vs 對挑戰者 vs 留下值不值 + 自利 + 人格」→ 效忠/叛逃/挺政變/分裂。
- **挑戰者主張＝四種正統論證之一**（血脈聖裔/軍功天命轉移/神職加冕/眾意天意）→ 成員各自信誰。
- **觸發基質＝天命侵蝕**（取代舊 `unrest_turns>=20` 死門檻）：天命是讓 ③ fire 的底層 belief，非硬計時。
- **snap 接 mandate 壓力**：失天命→stress→snap→砸鍋（屠殺/魯莽戰）→天命更崩→死亡螺旋（團滅 or coup）。
- **de-patch**（承既有計畫）：`event_unrest_replace/split/exile` 退役，換 member 層 mandate 政治。
- 一句：**coup＝成員信挑戰者的天命論證勝過現頭人。外憂內患同源一 belief。**

## 慾望泛化：慾望域 registry + 新域
game-design v2 §1 已有公式（`慾望 = 人格尺 ×（感知 possible − 現狀）落差`，復合錨＝內在抱負/鄰比/過去自己），雛形＝層5 食安。今天增量：

- **★結構＝慾望域 registry（承綜合發展維度 registry）**：每域 entry＝(a) 怎麼感知這域 possible（走 belief）×(b) 哪些人格 trait 加權 ×(c) 跟現狀 gap。加域＝加 entry，非新架構。
- **既有域**：食安/財富/權力/地盤/安全 + 發展維度（經濟/軍事/建設）。
- **今天新增域**：
  - **正統/天命**（雙面：內在＝被視為正主的榮耀；工具＝穩固統治）。
  - **信仰虔誠**（傳教/淨化→聖戰）。
  - **血脈/傳承**（立朝、保嗣，接聯姻/繼承）。
  - **榮耀/名聲**。
- **★鄰比（相對剝奪）對新域特別有戲**：感知鄰居有高天命/大王朝/受尊榮 → 相對剝奪 → 慾求之 → **野心/嫉妒/爭鋒湧現**（軍閥見鄰邦被尊正統之君→慾求承認→挑戰）。「不甘」自己長，非寫死。
- **紀律**：registry 吸收全部但別一次全建（先內在+鄰比、過四關才加過去自己；域也觀察 live 後哪個真有戲才加）。

## ④ 情緒：瞬時加速器，把跨線換道活起來
game-design v2 §6 已有（fear/stress/panic，序7 後疊）。今天增量：

- **★角色＝慾望×現實 到 行動 之間的瞬時加速器/調節器**（憲法：**調感知/慾望輸入，非行為 override**——恐懼放大威脅感知，引擎再秤；非「panic→自動逃」；同人格＝輸入權重非腳本）。高恐懼→放大威脅感知+壓縮慾望；冷靜衰減回基線（瞬時，不像人格）。
- **今天接點（情緒接活新維度）**：
  - **天災恐慌**：災→fear/panic。
  - **mandate 崩＝義憤/叛亂狂熱**：成員不只冷降 belief，是生熱義憤（「偽王天罰！」）→ **④是 ③內政的加速器**（冷 mandate-belief + 熱狂熱 → 推成員過行動線）。
  - **snap＝情緒溢流**：頭人 snap（③）就是情緒事件（stress 累積→溢流→暴怒/魯莽）。**④ 和 ③ snap 同一套機器。**
  - **喪慟/復仇**：失親/失嗣/失土（連 relations/血脈）→悲慟→復仇→驅 feud（接慾望泛化 w3 過去自己錨）。
- **★核心洞見：情緒是讓「跨線換道」（v2 §3）活起來、有時看似不理性的東西。** 冷 util 說「別反太險」，熱狂熱照樣推過線 → 激情驅動、看似不理性但很人性的行為湧現（冒死起義、血仇、驚慌逃）。模擬器長出「人」而非算式的地方。
- **紀律**：晚/最小/observe-gated（只 fear/stress/panic，非全套情緒模型）。

## ⑤ 淺預判（今天無新料）
攻擊前加一層淺預判對方反應折進 winutil，不做深博弈樹。今天沒新增。

## 貫穿：v2 是引擎，今天的維度是輸入
- ③④ 都騎 belief-store（mandate-belief、感知威脅）。
- ③ 的 coup、慾望泛化的爭鋒、④ 的義憤，全是同一套引擎（慾望×現實×人格×情緒）在不同域/聽眾的輸出。
- de-patch 精神一貫（scripted unrest events 死，換引擎決策）。

## 溯源
本 session brainstorm（③內政=內部正統爭奪/一 belief 兩聽眾 → 慾望域 registry + 正統/信仰/血脈/榮耀新域 + 鄰比爭鋒 → ④情緒=跨線加速器/接天災mandate/snap/喪慟）；game-design v2 §1-6（2026-07-14）；接今天三筆記（身份/天災/造謠）；[[project_unified_decision_framework]]；[[project_reverse_engineering_arc]] ③內政 de-patch。
