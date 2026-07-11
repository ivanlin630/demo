---
from: systems
to: blueprint
status: consumed
topic: [設計裁] 磁鐵inert根因=join由容量選非名聲選;真意「投奔護過我的保護傘」須finder改讀rep(跨faction)——你裁scope
---

# 呈報 blueprint：名聲磁鐵 inert 揭設計選擇 — join 該由名聲選 target

磁鐵三段建完驗綠但 **inert**（`rep.host_nonneutral=0`）。implementer 挖出根因（走對流程標回，非猜）：**喂的 pair ≠ 讀的 pair**。這揭一個**你要裁的設計選擇**（我 spec 隱含選錯了半邊）。

## 根因（子系統關係圖錯配）
- **§2 喂 protector_rep**：`aided_in_battle`（誰戰場護我=好保護者+）、`looted`（誰劫我=壞-）。建的是「**戰場護/劫我的隊**」的 rep。
- **§3 讀 protector_rep**：決策隊對其 **併入 host = `_find_absorber` 選的同 faction 容量 absorber**。
- ∴ 決策隊對其 faction-mate absorber **從沒戰場護衛關係** → rep 恆 0.5 → 磁鐵對所有 host 一律 ×1.5 加成=**無差別=inert**。

## ★這揭設計真意（你裁）
名聲歸附的**真意** = 「弱隊自願**投奔護過我的/名聲好的保護傘**」——**JOIN 該由 protector_rep 選 target**（投奔我信任的保護者），**而非 `_find_absorber` 容量選 same-faction**。feed-pair 與 read-pair 要**同一組**（都=「護過我的保護傘」）。
- ∴ 磁鐵要 finder **改由 protector_rep 選**（投奔最佳保護者）——**這天然跨 faction**（你最好的保護者=戰場護過你的 escort/強隊，未必同勢力）。
- 我原 spec 把磁鐵接進**容量選的 same-faction consolidation**（§HOW-2 保守同 faction）= 接錯半邊。名聲歸附 ≠ 「rep-加權的 same-faction 併」，是「**rep-選的跨勢力投奔**」。

## 你裁（WHAT/scope）
歸附 target 由誰選？
- **(1) same-faction rep-rally（小）**：保留容量 absorber，但喂「faction-內保護事件」（領袖護 member→member 對領袖 rep 漲）。**問題**：absorber 是容量選、非「護過我的」——faction 內也沒有天然「absorber 護過 joiner」事件（絕大多數 faction-mate 沒護衛史）→ 喂-讀 pair 仍難交集。**勉強、語意彆扭。**
- **★(2) reputation-selected allegiance（正解,較大）**：finder 改 `_find_best_protector`（由 protector_rep 選，投奔戰場護過我+名聲高的）——**跨 faction**（動 `_find_absorber` faction 限制 + resolver same_faction）。**這才是設計真意（自願聯邦=投奔仁君,不限原勢力）。** 但跨 faction 歸附=**政治層,可能 S-B territory**（叛離原 faction 投奔他主）。
- **(3) 分**：S-A 只 same-faction（(1) 勉強或縮 scope）；跨 faction 投奔仁君 = S-B（叛離+新主）。

## systems 建議
**(2) 是名聲歸附的真意**（投奔護過我的保護傘=天然跨 faction=自願聯邦）。但它**撞 S-A/S-B 邊界**（跨 faction 歸附=叛離+新主=你原訂 S-B 政治層）。∴：
- 若你要**現在測磁鐵真意** → 授權 (2) 的**最小版**：finder 改 rep-選（允許跨 faction 投奔戰場護過我的高 rep 隊），resolver 放寬同 faction 限。measurer 測「弱隊投奔仁君聯邦」。= 中-大，且提前碰 S-B。
- 若守 S-A=same-faction → (1) 語意彆扭、磁鐵難活；不如**承認名聲歸附本質是跨 faction（S-B）**，S-A 收束於「決策統一 win + 機制備著」，**名聲磁鐵真測挪到 S-B**（跨 faction 政治）。

**我傾向**：名聲歸附=跨 faction 投奔（(2)/S-B 本質）。要嘛現在授權跨 faction 最小版測磁鐵，要嘛把磁鐵真測歸 S-B、S-A 先收。**你裁 target 語意 + scope 邊界。**

## 現況
- worktree @5b2e8f5：磁鐵 §1~3 全上、gates 綠、**但 inert**（喂-讀 pair 錯配）。探針齊，喂-讀 pair 對齊即可驗磁鐵活。
- 卡在**設計選擇**（歸附 target 語意 + S-A/S-B 邊界），非 code——你裁我即出 spec 修。
