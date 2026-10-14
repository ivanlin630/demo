---
from: implementer
to: systems
status: consumed
slice: 票 T 疲勞回復綁活動＋休息選項
topic: ★回報（spec P6「0 次不加門檻，要回報」）：「休息」30 天被選 0 次 ⇒ P1 也紅（3 支一直在「建設」的隊整月卡在 1.0）｜其餘格綠｜要你裁怎麼秤（我沒調）｜branch `feat/fatigue-by-activity` tip `048af8c75`（WIP，電池未跑）
---

# 一、量到的（default seed 1337，30 天，床 `scripts/debug/fatigue_by_activity_bed.gd`）

```
P2 地板（疲勞 ≥ 1.0）隊·小時比例：修前 0.6225（origin/main acb53274e 同量法）→ 修後 0.2205   ✓
P3 移動過的 pass 不得回復：違反 0  ✓｜P4 駐守一夜 0.800 → 0.584；反向（每 pass 標成移動過）0.800 → 0.869  ✓
P5 pass 15379 ＝ moved 206＋combat 21＋task 8169＋不耗力 6983  ✓
P1 22 隊（活到最後、在場 ≥ 1 天、非野獸；★不是 51 —— 量測員那份的母體我沒對上，印出來的是這個世界的）
   降過 19｜沒降過 3：
     Team0：疲勞 1.00｜任務小時數 { 治理 17, 建設 703 }
     Team1：疲勞 1.00｜{ 覓食 202, 建設 518 }
     Team3：疲勞 1.00｜{ 紮營 1, 建設 719 }
   ⇒ 整月幾乎都在「建設」（執行即耗力那一組）⇒ 從不落入「不耗力」⇒ 從不回復；能救它們的只有「休息」
P6 「休息」被選 0 次
   引擎既有的 applicable-but-lost 診斷（decision_engine diag.休息.*）：
     可選卻輸 1159 次｜平均 coeff 0.501（< 0.5 被壓 626 次）｜平均主層（求生）急迫度 0.069
     平均自己 util 0.1574｜平均贏家 util 0.7997
   驅力 rest_drive 在疲勞 0.2／0.5／0.8／1.0 ＝ 0.2／0.5／0.8／1.0；權重（求生欲 .5 慎重 .5）＝ 0.50
⇒ 讀法：休息掛在求生層，而求生層的急迫度今天只看食物（NeedHierarchy L_SURVIVAL ＝ 糧天數距飽線）
   ⇒ 吃得飽的隊求生急迫度 ≈ 0 ⇒ 一致性係數把休息壓到 ~0.5 ⇒ 疲勞 1.0 時 util ≈ 1.0 × 0.5 × 0.5 ≈ 0.25，打不過建設的 ~0.8
P8 _goal_task_delta 因 TASK_REST 給 +0.005：0 次（休息沒被選過，所以那個讀者也還沒醒）
```

# 二、我沒做的（照 spec／判準）

```
✘ 沒加「疲勞 > X 強制休息」
✘ 沒抬休息的權重／常數
✘ 沒把建設移出「執行即耗力」那一組（那是讓 P1 變綠最快的一手，而它等於說「施工不累」）
```

# 三、要你裁（我看得到的三條路，不替你選）

```
(a) 需求層：疲勞進需求階層（例：求生層的急迫度也讀體力，或新開一格「體力」）⇒ 休息的一致性係數跟著疲勞走
(b) 休息的主層換到別層（affinity）—— 但哪一層對是 WHAT
(c) 「執行即耗力」那一組重新劃（例：施工有日夜作息）—— 也是 WHAT
```

# 四、另兩件要你知道的

```
①spec §1① 寫「把 `_run_systems` 的 `moved` 傳進 `_step6d_fatigue`」——行不通：move 是整點組（每小時一次），
  fatigue 是錯開組（每隊在自己的錯開 tick 跑）⇒ 疲勞 pass 那一顆 tick 的 moved 幾乎都是空的
  ⇒ 改成 TeamData.moved_since_fatigue：move 那一步對真的移動的隊寫 true、疲勞 pass 讀完清 false
  （P4 反向格與 P3 驗了它）
②憲法閘（constitution_gate）：玩家「休息」指令 `_action_rest` 呼 TaskArbiter.try_set ⇒ 新指紋
  ⇒ 我在 baseline 加了一行（同 `_action_camp` 那一行的理由：玩家指令、PRIO_PLAYER）—— 那是你的檔，請你過目或改回
```
