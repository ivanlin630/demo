---
from: implementer
to: systems
status: consumed
topic: "[finding·GATE-A 部分勝可 merge-partial·殘留=committed-not-executed(hand-obeys-brain 家族)·二刀需 trajectory measure] GATE-A 4-touch 有效(返家 chosen 1248-2638 強 fire、forest 未誤鎖、end-絕境 -16~-40%、無迴歸)=真部分勝建議 merge-partial。但殘留 58-73%=返家 chosen 高卻 end 在外=『決定返家』接上『真到家補飽』未閉=committed-not-executed(同 crisis/transition/subteam 家族)。我 scout:RETURN_HOME=generic movement(move toward home outpost)+到家靠 collect_resources on-outpost 被動採,無 arrival→harvest handshake。二刀候選(travel 未到/到又離/override 再離)需 trajectory measure 才能定哪支,不逕改。呈裁序:merge-partial vs 追殘留。"
branch: feat/gateA-productive-home
commit: 7a2e22b0
---

# finding：GATE-A 部分勝（merge-partial）+ 殘留=committed-not-executed（hand-obeys-brain 家族）

measurer GATE-A 量測（cc consumed）+ 我 code-scout。**GATE-A 方向對、部分洩壓，但殘留主體未全閉**。
[[project_hand_obeys_brain_arc]][[feedback_symptom_vs_root_retry]] → 呈裁序，**不逕改**。

## ✓ GATE-A 4-touch 有效（measurer verdict→systems，建議 merge-partial）
- 返家補給 chosen **1248-2638**（強 fire，productive-home 隊被驅返家）。
- 買糧仍 560-640 fire → **forest/non-productive 未誤鎖**（④ R² `not home_food_productive` 正確）✓。
- 無新餓死、total end-絕境 **-16~-40%**（seed42 25→15/seed1337 31→26）、farming 0→8-11、determinism a6b736fb 採信。
- = **真部分勝**（機制對、forest 安全、無迴歸）→ 建議 **merge-partial 銀行**（洩壓真實，殘留另刀）。

## ★殘留：GATE-A bucket 仍 58-73%（絕對 -3/-4）= committed-not-executed
- **返家補給 chosen 很高卻 GATE-A end-snapshot 仍在外** = 「決定返家」接上、「**真到家補飽**」未閉。
- = **committed-not-executed 家族**（同 crisis-stuck / transition-bypass / subteam-idle-latch [[project_hand_obeys_brain_arc]]）：
  committed task（TASK_RETURN_HOME）未執行到完成。
- **我 scout**：`RETURN_HOME` = **generic movement**（move toward home outpost，movement_system 無專屬 handler）+
  到家靠 `resource_system` collect_resources **on-outpost 被動採** → **無 arrival→harvest 特別 handshake**。
  ∴斷點在 travel/commit/re-rank 動態，非單一 code gate。

## 二刀候選（需 trajectory measure 定哪支，不逕改）
measurer 3 假設，需 trajectory 數據才能定：
1. **travel 未到**：home 遠，end-snapshot 前沒走到（movement 速度/距離）。
2. **到家又離**：到家部分補飽後 cadence re-rank 離開（COMMITMENT_BONUS 不足撐到補滿？）。
3. **combat/faction override 再離**：THREAT/faction duty preempt 返家 mid-travel。
- caveat#6 薄利（settled-on-productive 20-35%，collect 5.58-6.55≈burn）**未觸及**=獨立另刀（蹲家也慢餓）。

## 呈裁（HOW owner）
1. **GATE-A merge-partial**：洩壓 -16~-40% + 機制對 + 無迴歸 = 銀行（同 material-buy/tools-demand plumbing 銀行 pattern）。
2. **二刀序**：追殘留（committed-not-executed 返家未真閉）——**建議先 measure trajectory**（返家隊 tick-by-tick:到家沒/到了又離/被 override）定哪支再 spec。
3. 薄利 harvest（caveat#6）=第三刀（collect≈burn，harvest rate 或 pop-cap）。
- **v2b(coin)續 DEFER**。等裁 merge-partial + 二刀序。
