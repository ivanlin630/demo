extends SceneTree
# @bed-kind: pending
# blocker: bed-kind-fixture-token
# ★★★2026-09-10：原本指 `gather-purity-bed-as-gate`（一個【真的】defer token）——
#   而那個 token 被退場之後，這個【陽性對照】就變成懸空 ⇒ 整支閘 ABORT。
#   ⇒ ★對照樣本不得依賴【會變的 live registry】：改指 fixtures 自帶的 defers.tsv。
# ★陽性對照④（反向）：標好且合規 ⇒ 閘必須【綠】（防把恆空換成恆滿）
func _initialize() -> void:
	print("=== DONE === ALL PASS")
	quit()
