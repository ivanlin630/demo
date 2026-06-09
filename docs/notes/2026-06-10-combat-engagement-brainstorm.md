# NPC 戰鬥接觸機制 — Brainstorm（Claude 構想，未定案）

> 日期：2026-06-10
> 狀態：腦力激盪，待 user 篩選
> 起因：prosperity_attack 實作後 NPC-NPC encounter 仍 0。決策層通了，引擎接觸不通。

## 我的構想（Claude 個人方向）

把「修 bug 讓戰鬥發生」升級成「設計值得發生的戰爭」。
方向 B + C 混合：B（戰爭階段化）+ C（NPC 自然湧現反應）。

不只是 attacker 追到 prey 砍一刀，而是一場「能說故事的戰爭」：
- 攻方有意圖 → prey 察覺 → 雙方各自決策 → 第三方圍觀 → 戰後餘波

## B：戰爭階段化

| 階段 | 既有？ | 內容 |
|---|---|---|
| 偵察 | 無 | attacker 派子隊探敵，被偵查方也獲訊號 |
| 警告 / 宣戰 | 無 | 公開外交宣戰（給 prey 反應時間）or 偷襲跳過 |
| 對峙 | 無 | 兩團相鄰但未開戰，雙方有時間徵兵 / 結盟 / 撤退 |
| 開戰 | 既有 encounter | 高潮，但是是整場戰爭的高潮，不是全部 |
| 餘波 | 無 | 戰報廣播、聲望變化、戰俘處置、復仇種子 |

每階段給 leader 個性決策空間。慎重者多走完前奏；狡詐者偷襲跳階段；好戰者直接開戰。

## C：NPC 自然湧現反應

不違反「NPC 不全知」invariant。資訊來源限三類：
1. 自身狀態（current_task、resources、values）
2. 視野觀察（observe_velocity、team_intel 同格快照）
3. 訊息接收（message_system 戰報、信使、訊息傳播）

### prey 威脅評估

```
threat_score = (朝我移動 * 1.0 + reputation_negative * 1.0 + power_ratio * 0.5)
             * vision_clarity
```

來源全是「觀察」，不讀對方 current_task。

### prey 反應選項（個性決定）

- 求生欲高 → 逃跑（往 outpost / 盟友 / 隨機）
- 好戰高 → 迎戰
- 慎重高 → 備戰（停留 + 徵兵 + 武器）
- 商人 → 求和（送 tribute 取消攻擊）
- 義氣高 → 求援（信使到鄰盟）
- 絕望 → 投降（pop merge 給 attacker）

### 第三方反應

附近 team 觀察戰況 → faction_ai 評估介入：
- 盟友 → 援軍
- 仇敵 → 趁火打劫攻 attacker
- 中立商人 → 趁亂壓低買戰利品
- outpost owner → 關門或介入

### 戰報傳播

戰鬥結束 → message_system 廣播戰報（誰打誰、勝負、戰利品、有無屠殺）→ 接收者：
- 自動更新 known_reputations
- 觸發 reaction（聞戰報：恐懼 / 興奮 / 復仇心）

## 對既有架構的差距

| B+C 需求 | 既有 | 差距 |
|---|---|---|
| 偵察派子隊 | subteam_system | 缺 scout task + 回報 |
| 公開宣戰 | diplomacy 提案 | 缺 declare_war 類型 |
| 對峙階段 | — | 無：相鄰=戰 或 不戰 二分 |
| 開戰觸發 | interaction_system 同格+arrived | 核心 bug：兩 mobile team 永不同時 arrived |
| prey 威脅評估 | observe_velocity 剛加 | 缺 threat scoring |
| prey 預警反應 | reaction_system | 缺 ThreatDetected event tag |
| 新 task types | 攻擊/掠奪/逃跑/外交 | 缺：偵察/迎戰/備戰/撤退/求援 |
| 第三方介入 | faction_ai evaluate_all | 缺 鄰 team 觀察戰況決策 |
| 戰況廣播 | message_system 訊息傳播 | 缺 戰報 message type |
| 戰勝者 reputation 傳播 | known_reputations per-team | 缺 戰況訊息自動更 rep |

= 6 新東西 + 1 重設計

## 推估規模

- **小範圍核心修**：~3 task（同格 scan + threat detect + prey 反應）讓戰鬥發生
- **完整 B+C 體驗**：~8–10 task（含偵察、宣戰、對峙、第三方、戰報）

## 為什麼這方向

- 既有系統很完整但未串連：vision、reputation、observe_velocity、reaction、message、faction_ai 各自運作但缺整合場景
- 戰爭是天然「整合場景」：把所有系統串成故事
- 玩家可隨時介入任一階段（B 給 hook），離開後 NPC 自主演完（C 給 awareness）

## 風險

- 階段化可能拖戰鬥節奏（玩家想打卻要走流程）→ 提供「skip to combat」個性偏好
- 第三方介入可能讓戰爭失控（雪球）→ 加 caution 門檻避免每戰必團戰
- prey 完美 awareness 可能讓 attacker 永遠抓不到 → noise / vision_clarity 保留
- 新 task type 多 → 各系統 handler 多
- 整體實作量大，可分多 spec 漸進

## 待 user 決定

1. 方向是 B+C 還是別的？
2. 規模：小範圍核心修 vs 完整 B+C vs 分多 spec
3. 階段化要全做還是只做幾個關鍵階段
4. prey 反應選項要全做還是先 2–3 個
5. 第三方介入要不要做（第一輪）
6. 戰報傳播要不要做（第一輪）
