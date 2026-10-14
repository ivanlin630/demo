class_name ResourceFormat

# ★資源量的顯示：一支格式器（spec 2026-10-13-extortion-zero-take 改法 1；藍圖裁 43817c7d1 最小單位 0.1）
#   ·按 0.1 取整（snapped），寫法只有一種：一律一位小數（1 寫「1.0」、0.95 寫「1.0」）——不讓「1」與「1.0」並存
#   ·不足 0.1（取整後為 0）⇒ 回 ""（＝沒有）：結果句據此判「有沒有拿到」，不再出現「+0.0」
#   ·本票只做顯示側：物理量不動（轉移／結算以 0.1 為步在深層批）
const STEP: float = 0.1

static func amount(x: float) -> String:
	var v: float = snappedf(x, STEP)
	if is_zero_approx(v):
		return ""
	return "%.1f" % v

# 面板用：沒有就印 0.0（面板的欄位要有值；與 amount 同一把尺）
static func panel(x: float) -> String:
	var s: String = amount(x)
	return s if s != "" else "0.0"

# 「食 3.0、幣 0.4」：只列格式後非空的項；全空 ⇒ ""
static func list(amounts: Dictionary) -> String:
	var parts: Array = []
	for res in amounts:
		var s: String = amount(float(amounts[res]))
		if s != "":
			parts.append("%s %s" % [TeamUiHelper.resource_name(String(res)), s])
	return "、".join(parts)
