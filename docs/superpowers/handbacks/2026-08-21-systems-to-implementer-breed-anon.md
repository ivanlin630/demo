---
from: systems
to: implementer
slice: breed-anon-eligible
tier: full
status: open
topic: "[派工·生育(a) 讓 anon 也算生育者(用戶拍板『(a)匿名也能生』,R² CLEAN)·★排序:convoy branch 同步 → monotonic-person-id → 本刀(不急,但它是目前唯一在治『人口與經濟科目全部讀不出東西』那個根)·spec=docs/superpowers/specs/2026-08-21-breed-anon-eligible-HOW.md·★查證後範圍很窄:_breed_balance 早就把 anon 算進兩性池了(anon 一直是配偶只是不算生育者),本刀只補這一半;不需要實例化任何 anon 個體(它是 cohort 計數)·★真工作量在【團層代理】三欄:food 不另設(f(rel_surplus) 已是團層糧食項,再加一層=同一件事扣兩次)/safety 用『該隊 named 通過安全門檻的比例』(無 named 取 leader、★再無取 0.5 不是 1.0——R² 建議採納:缺人管理的隊不該預設最安全)/醫療 anon 無加成(照實給 0 不假裝有)·★★§3 常數重錨【先量再定】:現行 0.0133 的推導錨『5 名適齡成人』實測不存在(1.4 名/隊);P_ref 要【跨多個 peaceful snapshot 取中位數】不用單一快照(R² 建議,同 K 值那輪教訓:單一快照的中位數本身也是抽樣值)·⛔明令禁止『因為還是不生就把 BASE 往上調』——低產出先問是不是 genuine·gate 7:breed.eligible_anon 恆 0 就明寫本刀 inert"
---

# 派工：生育 (a) —— 讓 anon 也算「生育者」

**WHAT**：用戶 2026-08-21 拍板「**(a) 匿名也能生（推薦）**」｜**R² CLEAN**
**spec**：`docs/superpowers/specs/2026-08-21-breed-anon-eligible-HOW.md`

## ★排序
`convoy` branch 同步 → `monotonic-person-id` → **本刀**。
不急，**但它是目前唯一在治「人口與經濟科目全部讀不出東西」那個根**（`n_persons` 至今凍結在 24）。

## ★查證後範圍很窄
`_breed_balance` **早就把 anon 算進兩性池**（`m = anon×(1-ratio)`、`f = anon×ratio`）
⇒ **anon 一直是「配偶」，只是不算「生育者」**——**本刀只補這一半**。
**不需要實例化任何 anon 個體**（它是 **cohort 計數**）。

## ★真工作量在「團層代理」三欄
| named 用的 | anon 的代理 |
|---|---|
| `needs.food > 0.7` | **不另設** —— `f(rel_surplus)` **已經是團層糧食項**，再加一層 ＝ 同一件事扣兩次 |
| `needs.safety > 0.7` | **該隊 named 通過安全門檻的比例**（無 named 取 leader、★**再無取 `0.5`，不是 `1.0`**） |
| `skills.醫療` 加成 | **無**（乘 1.0）——**照實給 0，不假裝有** |

★ `0.5` 那個 fallback 是 **R² 建議、我採納**：**缺人管理的隊不該預設「最安全」**（我原案寫 1.0，那是我自己最可疑的一點）。

## ★★§3 常數重錨：**先量再定**
現行 `BREED_BASE_RATE = 0.0133` 的推導錨是「健康村 × **5 名適齡成人**」——**實測 1.4 名/隊，那個錨不存在**。
新錨 `BASE = (1/30) / (0.5 × 適齡數(P_ref))`，**目標 ＝ 用戶已拍的 pacing (B) ≈ 一個月一個名額**。

★ **`P_ref` 要跨多個 peaceful snapshot 取中位數，不用單一快照**（R² 建議）——
**同 K 值那輪的教訓：單一快照的中位數本身也是一個抽樣值**，拿它當常數的錨會**把抽樣雜訊烙進世界**。

⛔ **明令禁止**：「**因為還是不生就把 `BASE` 往上調**」。
**低產出先問是不是 genuine**（世界真的窮 ⇒ `f` 本來就低），**再談常數**。

## gate
照 spec §4 七條。★ **gate 7**：`breed.eligible_anon` **恆 0 就在帳上明寫「本刀 inert」**（同 T1／T3 的處理）。
`fp` **會變**（生育是世界行為）＝ **intended-change**，帳上明寫別讓人讀成迴歸。
