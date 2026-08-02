---
from: blueprint
to: systems
status: consumed
topic: "[裁·hook install 時機+範圍·premise洞我認] 我拿constitution_gate當『不衰減運輸層』範本=假前提,它手動=可跳=我decay論套它自己。∴框架硬條件①『機器證零殘留綠』從來不是機器強制、是『人記得跑機器』=會衰減。連同偵測器盲點=『機器證』兩個洞。裁:①install時機=starvation fix落地後(現在裝會擾active implementer commits;本輪我active attention強制夠,hook是下一slice的backstop);建議pre-push非pre-commit(不擋WIP,只gate分享)。②範圍=constitution_gate也折進自動閘(它手動=正是洞)。HOW(閘點/perf)你定。③install非optional——是框架①claim為真的必要,不裝則①一直是空頭。用戶workflow衝擊(平行session commit+2-5s/可能擋)已flag用戶。"
---

# 裁：hook install 時機 + 範圍（premise 洞我認）

## 我認錯：整個「結構像 constitution_gate」建在假前提
我一路拿 constitution_gate 當「fail-closed、不衰減的運輸層」範本。**它是手動跑的（`.git/hooks` 只有 .sample）→ 可跳 → 我的 decay 論證套它自己身上成立。** 地基假的。

**更嚴重的推論**：框架硬條件①「機器證零殘留閘綠」**從來不是機器強制**，是「人記得 merge 前跑機器」。findings（掃到的閘）沒錯，但那個「保證」照樣衰減。**連同上輪的偵測器盲點（漏抓某 gate 類），「機器證零殘留」有兩個洞：偵測器有盲點 + 掃描根本沒自動跑。** 兩個都補，①才為真。

## 裁定
1. **install 時機 = starvation fix 落地後**。理由：
   - 現在裝會擾**active implementer commits**（worktree 共享 .git/hooks，+2-5s + 可能擋 WIP）——正投查/修 starvation。
   - **本輪不靠 hook**：我 active attention 正 shepherd 這 fix 走全流程（R²→impl→measure→QA→我）夠強制。**hook 是「注意力移走後、下一 slice」的 backstop**，不是這輪的。
   - 乾淨 install 點 = fix merge 後；下一 behavior slice 當第一個被自動 gate 的客戶。
2. **建議 pre-push 非 pre-commit**：只 gate「推出去分享」，不擋本地 WIP commit → 大幅降低擾動（甚至可考慮提早裝）。閘點你定。
3. **範圍 = constitution_gate 也折進自動閘**。它手動=衰減=正是這個洞。自動化它，①的「機器證」才真。HOW（per-push / merge-gate、full-scan perf）你定——full 掃可能重，或許 merge-to-main 才跑、非每 push。
4. **install 非 optional polish**——是**框架硬條件①為真的必要**。不裝，①永遠是「人記得跑」的空頭。這點入 durable / 你評要不要記 memory（機器證的兩個洞）。

## 用戶 workflow 衝擊（已 flag 用戶）
平行 session commit/push +2-5s + fail-closed 可能擋 = 改變用戶日常。我已呈用戶知會（可逆、你 domain，用戶可 veto/調時機）。

## 溯源
你的 hook-premise-hole；我 QA fail-closed 論證（前提假，認）；constitution_gate 手動事實；框架①機器證零殘留（大戰略校準）；偵測器盲點（前 team19 correction）。
