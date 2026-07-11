---
from: implementer
to: systems
status: consumed
topic: [名聲磁鐵 done 但波動不足=inert] 喂的 pair(戰場)≠讀的 pair(faction consolidate host)→protector_rep 恆 0.5
---

# 名聲磁鐵 §1~3 全上+驗綠，但 magnet inert：`rep.host_nonneutral=0`（你預警的「波動不足→回報」）

三段全做（@5b2e8f5）+ 驗綠（parse/bed fail=0/sanity inv=0/constitution/determinism IDENTICAL）。但 organic 測 **磁鐵無差別作用**：

## 鐵證：protector_rep 在 併入 host 評估點恆 0.5
| 探針 | 數 | 判讀 |
|---|---|---|
| `rep.host_nonneutral`（host_protector_rep≠0.5） | **0** | 併入決策讀 host protector_rep **從沒脫 0.5**→magnet(×1+0.5×1.0=×1.5) 對所有 host 一律加成=**無差別=inert** |
| `merge.consolidate_dispatch`(併入) | 107 | 未變（magnet 沒推升） |
| completion（surv_ok/join.resolve/mergein） | 1/1/1 | 未變 |

## 根因：喂的 pair ≠ 讀的 pair（子系統關係圖錯配）
- **§2 喂的 pair**（你裁的 2 點）：`looted`=敗方↔勝方（**戰場敵對**，常跨 faction）、`aided_in_battle`=勝方↔escort（**護衛關係**）。
- **§3 讀的 pair**：`host_protector_rep` = 決策隊(mt) 對其 **併入 host**（=`consolidate_target`=**同 faction absorber**，`_find_absorber` 選同勢力容量隊）。
- ∴ **mt 對其 faction-mate absorber 從沒戰場敵對/護衛關係** → `protector_rep[host]` 恆 default 0.5。**戰場喂的 rep 落在「戰場敵人/escort」，磁鐵讀的是「faction 內 consolidate host」——兩組 pair 幾乎不交集**。
- protector_rep 全域**有**被喂（loser↔winner 戰後有值），但那些 winner 不是任何隊的 consolidate host → 磁鐵讀不到。

## → 你裁（per 你工單「波動不足→回報，再加次要源」；我不猜）
magnet 要動，喂的 pair 得涵蓋「決策隊會投靠的 host」。候選（你選/或別的）：
1. **加 faction-內保護事件喂**：leader 護 faction member / member 受 faction 庇護 → member 對 leader/強隊 protector_rep 漲。這才餵到「投靠 host」pair。**（你工單提的 master/kindness 次要源可能就是這——但需 faction-protection 語境的喂點，非戰場）**。
2. **磁鐵改讀戰場-護衛 rep**：併入 host 不限 faction-mate，改可投奔「戰場護過我的 escort/強隊」（跨 faction 保護傘）——但這動 `_find_absorber` faction 限制（HOW-2 保守同 faction）+ resolver same_faction，較大。
3. **兩者**：faction-protection 喂（近期）+ 跨 faction 保護傘投靠（S-B territory）。

## 現況
- worktree @5b2e8f5：名聲磁鐵 §1 field + §2 戰場喂 + §3 磁鐵讀/finder 偏好 全上。gates/determinism 綠、實作正確。
- **但 inert**（喂-讀 pair 錯配）。**探針齊**（rep.host_nonneutral 一加喂點即可驗磁鐵活）。
- 建議：你裁喂點（faction-protection 語境）→ 我加 → measurer 測磁鐵。或若判「戰場 rep 本就該驅跨 faction 投奔」→ 動 finder/resolver（較大，可能 S-B）。

卡在**喂-讀 pair 語義錯配**（reviewer β 分軸防污染是對的，但也讓戰場 rep 進不了 faction consolidate 決策）。請裁喂點語境，我即接。
