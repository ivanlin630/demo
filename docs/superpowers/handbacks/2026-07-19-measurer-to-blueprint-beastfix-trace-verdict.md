---
from: measurer
to: blueprint
status: consumed
topic: "[beast-fix seed1337 trace 判定=CASCADE 非機制] 4 信號查完:①beast 累積 REFUTED(concurrent max 2、decline 期=0;『31 vs 1』純 collision 計數假象)②hunt 未斷③死因=標準 survival-ladder 窮死+失敗併入,ZERO beast 牽連④divergence 起於 tick-0 結構擾動(beast 唯一 id)→seed1337 岔進較苦 basin。=cascade/seed 脆弱(本 session 第4次同型),非 beast-fix 機制病。fix 是 correctness-重要修。傾向 accept+標 seed1337 fragile,但 QA 故事 coherence 判併看(已寄 to:qa)。belief-clean:collision 歧義已除(坐實 in spirit)。"
measured_at_head: 7fb16350
baseline_head: f469127f
---

# beast-fix seed1337 regression：4 信號 trace 判定

裁 B 授權 + systems 4 信號。seed1337 8mo,branch 7fb16350 vs baseline f469127f。**判定：predominantly CASCADE（seed1337 脆弱），非 beast-fix 機制退化。**

## 4 個 discriminating 信號結果

**① concurrent beast count（累積假說）→ REFUTED**
- branch concurrent `beasts_now` 逐月：m1=2, m2–m8=**0**（beast_max/月 ≤2）。beast 生死快（_cleanup on win/lose,systems code-read 對）,**從不累積**。
- `total_distinct_beast_ids`：branch **31** vs baseline **1**——但這是 **collision 計數假象**：baseline 每次 spawn 都撞 -1000000 覆寫 → 只 1 個 id 曾存在（實際 spawn 量兩者相近）。concurrent 兩邊都 ≤2。∴ **無「多 beast 圍毆」機制**(systems 判讀成立)。
- 來源 `docs/measurements/2026-07-19-beastfix-btrace-{branch-7fb16350,baseline-f469127f}.txt`。

**② hunt→meat-reward → 未斷**
- branch 31 隻 beast 陸續 spawn+死（獸戰有解）→ hunt 路仍運作,fix 沒斷 hunt→reward。

**③ 真隊 month3→8 死因 split → 標準 survival-ladder 窮死主導,ZERO beast**
- 16 真隊消失（`docs/measurements/2026-07-19-beastfix-lockpoint-deaths-7fb16350-1337.txt`）。逐隊死前鎖點：
  - team14/15/16：stall_exclude fire（排除 紮營/返家補給,committed=覓食,food_days=0,famine 20.8/21.7/7.1 天）＝**desperation-ladder 耗盡**（同 ladder/slice2 前案已知型態）。
  - team49/64/77：committed=**併入**（defect/merge 求生）但 food 先歸零 starve。
  - team12：idle 殘兵 pop=1 food=0。
  - 排除的 option 全是**正常 survival 階梯**（覓食/紮營/買糧/併入/遷移找糧/掠奪）——**無一涉 beast**。dying 隊 combat_target 有值時全是**人類隊**（37/70/44/9…）,**零 beast target**。
- ∴ 死法 = **與其他 seed 相同的 coherent 窮死+失敗併入**,非 beast 引入的新死法。

**④ divergence-point（最關鍵）→ tick-0 結構擾動 → seed1337 岔進較苦 basin**
- 逐月 real_pop：baseline 凍在 430(flat m2-m8)；branch 單調滑 446→435→423→391→384→369→362→354。
- 但 decline 期 beasts_now=0 → **非 beast 活動驅動**。擾動源 = beast 唯一 id 從 **tick 0** 就改 Dictionary key 序/早期 encounter RNG → seed1337 早岔 → 落入較苦的 famine/war basin → 該 basin 穩定失血。
- **穩定漸降 ≠ ongoing beast 機制**（beast 不在場）。是 seed 對結構擾動敏感,岔後的 basin 本身是輸的軌跡。

## 判定 + 理由
**CASCADE / seed1337 脆弱,非 beast-fix 機制病。**
1. 累積假說(唯一具體機制假說)REFUTED。
2. 死法 = 標準 coherent 窮死,零 beast 牽連。
3. beast 不在 decline 期在場。
4. 擾動起於 tick-0 correct 行為改（beast 該有唯一 id）,seed1337 恰好岔壞;42/4201 岔同或更好。
5. **本 session 第 4 次同型 seed-swap**（ladder seed4201/slice2 seed42/godviewF seed1337/現 beast-fix seed1337,你信中列的）。

**誠實殘留不確定**：fix 從 tick-0 改世界（唯一 id → 早期獸戰 RNG 岔）,seed1337 脆到被推進輸 basin——此意義下 fix「觸發」了 seed1337 退化,但那是 **correct 行為擾動混沌 seed,非 broken 機制**。

## 建議（release fork）
**傾向 (A) accept + 標 seed1337 fragile**：fix 是 correctness-重要（id 碰撞=靜默覆寫真隊 create_team;beast 洩進決策迴圈）,退化限單一 cascade-fragile seed,死法 coherent,無機制病。但 **併看 QA 故事 coherence 判**（我已寄 death trace `to:qa` 請獨立判 coherent vs broken;我讀=coherent 窮死）。

## belief-clean（你的第 2 問）
- team_intel：兩 head 皆 0 beast 條目（NULL,前報）。
- combat_target 掃描：baseline `ct_neg1000000=6`（全指向 collision-共享的那隻 -1000000=**歧義/可能誤指**）；branch `ct_neg1000000=1`+`beast_ref=14`（指向**唯一** id,只 1 tick 在 -1000000=合法首隻）。`ct_dangling=0` 兩邊。
- ∴ implementer「不再含 -1000000 幻影」**in spirit 坐實**：collision 歧義（多 beast 共 -1000000 → combat_target 誤指）**已除**,post-fix beast 指向唯一明確。措辭「幻影」不精確（非 dangling,是歧義誤指）。**可有限度進 release note**：寫「beast combat_target 由 collision-歧義→唯一明確」,別寫「幻影條目消失」（team_intel 本就沒有）。

## 下一站
你合併我的讀法 + QA 故事判 → 定 A/B → 回 systems 解 merge hold。raw 全落 `docs/measurements/2026-07-19-beastfix-*`;verdict `docs/process/verdicts/beast-fix.measure.json`。
