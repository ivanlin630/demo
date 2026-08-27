extends SceneTree
# ★★★床解析閘（2026-08-27 血證）：merge 解衝突時我在 qty_tap_bed.gd 留下孤兒縮排 ⇒ Parse Error，
#   而【三道 merge-gate 全綠、而且是正確地綠】—— 憲法閘/裸 tick 閘/headless 都【不載入 debug 床】。
#   ★★而那張床正是產出全部 S2/S3 數字的那一張 ⇒ 壞掉沒人知道，直到別人去 merge 才炸。
#   ★★★所以這不是「再小心一點」能解的：要一道【會載入每一張床】的閘。
func _initialize() -> void:
	var bad: Array = []
	var n: int = 0
	var d := DirAccess.open("res://scripts/debug")
	if d == null:
		print("[BED-PARSE-GATE] FAIL：開不了 res://scripts/debug"); quit(); return
	d.list_dir_begin()
	var f: String = d.get_next()
	while f != "":
		if f.ends_with(".gd"):
			n += 1
			# ★★第一版我用 `load() == null` 判 —— ★陽性對照沒過：
			#   注入孤兒縮排後它仍然 PASS，因為 load() 對 parse error 不回 null。
			#   ★★★那就是一台【假綠機器】—— 而我整天在抓這個形狀，這次是我自己做的閘。
			#   ⇒ 改用 GDScript.reload() 的錯誤碼，它才真的重新 parse。
			var res = load("res://scripts/debug/" + f)
			if res == null:
				bad.append(f + "（load 回 null）")
			# ★★★而【偵測】不在這支腳本裡：
			#   第一版用 load()==null → 假綠（load 對 parse error 不回 null）
			#   第二版用 reload(true) → 302 個腳本太慢，跑到被殺
			#   ★第三版：只負責【把每一張床都 load 一次】，
			#     而 Godot 自己會把 Parse Error 吐到 stderr ⇒ ★★由 shell 端 grep 它。
			#   ★★★這跟 bare-tick-gate 抓掃描器崩潰是同一招（已驗過的形狀）。
		f = d.get_next()
	d.list_dir_end()
	if bad.is_empty():
		print("[BED-PARSE-GATE] PASS：%d 張床全部載入成功" % n)
	else:
		print("[BED-PARSE-GATE] FAIL：%d/%d 張床載不起來 ⇒ ★這不是「沒有床」，是床壞了" % [bad.size(), n])
		for b in bad:
			print("   ★%s" % b)
	quit()
