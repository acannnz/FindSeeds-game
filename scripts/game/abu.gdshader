shader_type canvas_item;
// Benda kosong yang sudah dicoba: gambar jadi abu-abu (tanpa warna) dan sedikit pudar.

void fragment() {
	vec4 warna = texture(TEXTURE, UV) * COLOR;
	float terang = dot(warna.rgb, vec3(0.299, 0.587, 0.114));
	COLOR = vec4(vec3(terang * 0.75 + 0.15), warna.a);
}
