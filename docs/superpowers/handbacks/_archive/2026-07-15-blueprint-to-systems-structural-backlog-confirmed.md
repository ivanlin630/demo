---
from: blueprint
to: systems
status: consumed
topic: [用戶定·結構backlog確認要處理] 沒框架(死常數族照妖鏡/思考腳記憶情緒)+多求解器(F-I1雙diplomacy)+矩陣殘(prisoner死路/F-B1雙epistemics)=確認work item,你排progress.md序;非現在急(經濟freeze arc在飛)但不能忘
---

# 結構 backlog 確認要處理（用戶定「也要處理」）

用戶看完結構稽核,定調:**沒框架 + 多求解器 + 矩陣殘 = 都要處理**（非一次性 flag 忽略）。確認為 work item,你 owner 排 `progress.md` 序。**非現在急**（經濟 freeze arc 在飛）,但不能忘。

## 確認要處理的（承結構稽核報告）
1. **死常數照妖鏡「族」**（沒框架最大塊）：**建共用人格函式讓整族走**,非逐條溶：
   - `calc_engagement_margin(leader_values)`（攻擊/佔村門檻族：ATTACK_STRENGTH_RATIO/OCCUPY_WIN_MARGIN/POP_RATIO/READINESS_MIN）
   - 收編 `food_security_target` band（DESPERATION_DAYS/SURVIVAL_SATED_DAYS/SURPLUS_FOOD_DAYS）
   - 「隊伍膽識」聚合（PANIC_WEIGHT+PANIC_STRESS/LOY+readiness，接潰退已用的 courage 源）
   - `commitment_bonus(leader_values)`（散 4 檔 0.15/0.3 收斂）
2. **多求解器 F-I1**：雙 diplomacy resolver（god-view `_try_diplomacy` vs belief `handle_diplomacy_message`，同動詞相反 epistemics）——**統一成一個走 belief**（連①求和 seam bug 同根,可一起）。
3. **矩陣殘**：prisoner_population 死路（`encounter:1295` 寫零消費）清、F-B1 known_member_states 雙 epistemics（god-view 7 caller live + belief）拆。
4. **思考腳（記憶/情緒）泛化**：記憶只讀仇（恩/信/懼寫黑洞）、情緒只 panic→FLEE → 決策讀取端拓寬（承 v2 §6 情緒調節器 + 記憶染價值）。**深接線,較後。**

## 排序建議（我願景排,你 HOW 調）
**當前在飛**：經濟 freeze arc（凍結追蹤中）+ 發展模型統一框架化（同 arc）。
**接著**（用戶定要處理,序）：
- **死常數族照妖鏡**（最大「沒框架」,共用人格函式）——高值,直接續「決策穿人格非平頭」。
- **F-I1 雙 resolver + 求和/外交 grounded**（一起,同根）。
- **矩陣殘**（prisoner/epistemics 清）。
- **思考腳泛化**（記憶/情緒,深接線,最後）。

**全用統一框架式做**（族走共用人格函式、雙 resolver 併一、思考腳走引擎讀取）——同用戶剛定的發展模型統一框架精神。

## 產出
你把這些排進 `progress.md` backlog + 序。經濟 freeze arc 收一段落 → 挑下一個（我傾向死常數族,最大沒框架）→ 我出願景意圖 → 你 spec。**現在只確認不遺忘 + 排序,非馬上開。**
