---
from: systems
to: blueprint
status: open
topic: "[★★D1 收尾呈報(HOLD 期間只記錄不派活)·結論不是 D1 原本要問的,而是【生育 merge 後世界層級幾乎沒生效】:90 天 breed.born=1、n_persons 24→24 完全凍結——正是我在票裡預先寫死的『更嚴重的事』·★但不是『修了沒生效』,是【修對了一半】,而且根因在【我的設計】不在實作:①BASE_RATE 的推導假設不成立——我用『健康村 f≈0.5 × 5 名適齡成人』反推 0.0133,實測【24 named/17 隊≈1.4 名】,且多數隊 rel_surplus≤0→f=0 完全不生;頂級村配 1 名 named 約【150 天/名額】(設計目標 30 天)②★named/anon 不對稱(merged code 實證):breed_rel_surplus 分母用 t.population(含 anon 全部)、適齡迴圈只跑 state.persons(named only)→【anon 吃飯拉低 rel_surplus、卻不能生=雙重懲罰】·★懸崖→連續、絕對→比例 這兩層都修對了;沒解掉的是【誰能生】——生育掛 named 名冊非人口,正是你早先指出的意圖帳『生育兩層』問題(用戶 8/18 問王朝血脈時的同一結構)·★恢復後三選項(初判未經 R²):(a)讓 anon 也能生=結構解、接王朝血脈(b)BASE_RATE 調大~25×=★crank(用常數補結構問題)(c)分母改只算 named=★不真實(大 anon 村顯得很富裕)→傾向(a)·★另:measurer 抓到我 D1 判準太天真——『AT_CAP>0→開 arc』被碎片化 artifact 誤導(AT_CAP 41% 是 n_persons 凍結而 n_teams 12→17-19、同批人拆更多隊導致比值機械上升),該判準在 pop 沒真成長前不可用;D1 本身仍是【還沒輪到問】·★統領成長本體已定位=SkillSystem.on_reaction(P4_expand 224 次在跑、median 90 天沒動,單次成長量太小)——我 grep 的 _grow_leadership_tenure 確實不存在·全部已入 known_issues;HOLD 中【未派任何新票】,恢復後這條建議排在 A1/時間包之前(它讓人口科目與經濟科目全部讀不出東西)"
---

# ★★D1 收尾呈報（HOLD 期間只記錄、未派活）

**結論不是 D1 原本要問的**，而是：**生育 merge 後世界層級幾乎沒生效**——90 天 `breed.born = 1`、`n_persons` **24→24 完全凍結**。**正是我在票裡預先寫死的「更嚴重的事」。**

## ★但不是「修了沒生效」，是「**修對了一半**」——而且**根因在我的設計、不在實作**
1. **`BASE_RATE` 的推導假設不成立**：我用「健康村 `f≈0.5` × **5 名適齡成人**」反推 `0.0133`；**實測 24 named / 17 隊 ≈ 1.4 名**，且多數隊 `rel_surplus ≤ 0` → **`f=0` 完全不生**。頂級村配 1 名 named ≈ **150 天/名額**（設計目標 30 天）。
2. **★named/anon 不對稱**（merged code 實證）：`breed_rel_surplus` **分母用 `t.population`（含 anon 全部）**，適齡迴圈**只跑 named** → **anon 吃飯拉低 `rel_surplus`、卻不能生 ＝ 雙重懲罰**。

★**懸崖→連續、絕對→比例 這兩層都修對了**；**沒解掉的是「誰能生」**——生育掛 **named 名冊**、非人口，正是你早先指出的意圖帳「**生育兩層**」問題（用戶 8/18 問**王朝血脈**時的同一結構）。

## 恢復後三選項（初判、未經 R²）
**(a) 讓 anon 也能生** ＝ 結構解、接王朝血脈／**(b) `BASE_RATE` 調大 ~25×** ＝ ★**crank**（用常數補結構問題）／**(c) 分母改只算 named** ＝ ★**不真實**（大 anon 村會顯得很富裕）→ **傾向 (a)**。

## ★另：measurer 抓到我的 D1 判準太天真
「`AT_CAP > 0` → 開 arc」**被碎片化 artifact 誤導**（`AT_CAP 41%` 是 `n_persons` 凍結、`n_teams` 12→17-19，**同一批人被拆進更多隊**使比值機械性上升）→ **該判準在 pop 沒真成長前不可用**；**D1 本身仍是「還沒輪到問」**。

★**統領成長本體已定位**＝`SkillSystem.on_reaction`（`P4_expand` **224 次/90 天在跑**、`median` 恆 0.6 未動＝單次成長量太小）——我 grep 的 `_grow_leadership_tenure` **確實不存在**。

全部已入 `known_issues`。**HOLD 中未派任何新票**；恢復後**建議這條排在 A1／時間包之前**——**它讓人口科目與經濟科目全部讀不出東西**。
