class_name PixelCounter
extends Node
signal kanji_chosen(kanji : Texture2D)
signal total_score_in_percent01(percent01:float)
signal total_score_in_percent100(percent100:float)
signal total_score_in_percent_string(percent:String) 
signal	total_score_richard_percent01_valid(percent01 : float)
signal	total_score_richard_percent100_valid_string(percent : String)
signal	total_score_richard_percent01_fail(percent01 : float)
signal	total_score_richard_percent100_fail_string(percent : String)
@export var liste_kanji : Array[Texture2D] = []
@export var sprite2d : Sprite2D
@export var result_at_ready : Dictionary
@export var result_given : Dictionary

static var sprite2d_static : Sprite2D
var kanji : Texture2D


func override_texture_to_use(new_kanji : Texture2D):
	kanji = new_kanji
	sprite2d.texture = new_kanji
	
func push_in_texture_to_analyze(texture2D: Texture2D):
	result_given = analyze_layer_pixels(texture2D)
		
		

@export var points_for_kanji_cut_in_percent : float
@export var bonus_point_based_on_alpha : float
@export var total_score_in_percent : float
@export var remaining_pixels_in_pourcent : float
@export var bonus_point_alpha : float
var mon_calque : Texture2D
var end_pixel_alpha : int
var end_pixel_black : int
var origin_pixel_alpha : int
var origin_pixel_black : int

@export var load_image_at_ready:bool =true

func _ready() -> void:
	if load_image_at_ready:
		choose_randomly_image_to_use()
	
func choose_randomly_image_to_use() -> void:
	
	sprite2d_static = sprite2d
	if not liste_kanji.is_empty():
		# Sélection aléatoire de la texture dans la liste
		kanji = liste_kanji.pick_random()
		if sprite2d:
			sprite2d.texture = kanji
		mon_calque= kanji
		kanji_chosen.emit(kanji)
	else:
		push_error("PixelCounter: La liste_kanji est vide dans l'inspecteur !")

	if kanji:
		result_at_ready = analyze_layer_pixels(kanji)
	
@export var debug_total_black : int
@export var debug_total_valide : int
@export var final_percent_valid : float
@export var final_percent_fail : float

signal debug_original_texture(texture : Texture2D)
signal debug_given_texture(texture : Texture2D)
func compare_pixel(original_texture : Texture2D, given_texture : Texture2D) :
	debug_original_texture.emit(original_texture)
	debug_given_texture.emit(given_texture)
	var original_image := original_texture.get_image()
	var given_image := given_texture.get_image()
	var width := original_texture.get_width()
	var heigth := original_texture.get_height()
	var original_color_count : int = 0
	var valid_point_count : int = 0
	var original_color_count_fail_zone : int = 0
	var fail_point_count : int = 0
	
	var color_threshold = 0.1
	
	for x in range(width):
		for y in range(heigth):
			var original_color = original_image.get_pixel(x,y)
			var given_color = given_image.get_pixel(x,y)
			if original_color.r <= color_threshold and original_color.g <= color_threshold and original_color.b <= color_threshold and original_color.a > 0.2:
				original_color_count += 1
				if given_color.a > color_threshold:
					valid_point_count += 1
			else:
				original_color_count_fail_zone += 1
				if given_color.a > color_threshold:
					fail_point_count += 1
						
				
	debug_total_black = original_color_count
	debug_total_valide = valid_point_count
	final_percent_valid =  float(valid_point_count)/float(original_color_count)
	final_percent_fail =  float(fail_point_count)/float(original_color_count_fail_zone)
			

func compute_result_from_texture_and_emit(texture:Texture2D):
	result_given = analyze_layer_pixels(texture)
	compare_pixel(mon_calque, texture)
	total_score_richard_percent01_valid.emit(final_percent_valid)
	total_score_richard_percent100_valid_string.emit("%.1f%%" % (final_percent_valid*100.0))
	total_score_richard_percent01_fail.emit(final_percent_fail)
	total_score_richard_percent100_fail_string.emit("%.1f%%" % (final_percent_fail*100.0))
	
	
	


	## YOUR CODE HERE I DONT TOUCH THAT DOWN 
	print("--- Analyse du Calque ---")
	print("Total pixels : ", result_given.total_pixels)
	print("Pixels Invisibles (Alpha) : ", result_given.transparent_pixels)
	print("Pixels Visibles : ", result_given.visible_pixels)
	print("Pixels Noirs détectés : ", result_given.black_pixels)
	
	origin_pixel_alpha = result_at_ready["transparent_pixels"]
	origin_pixel_black = result_at_ready["black_pixels"]
	
	print("Original Pixel Invisible : ", origin_pixel_alpha)
	print("Original Pixel Black :", origin_pixel_black)


	#Calcul pourcentage for pixel colored black and alpha.
	end_pixel_alpha = result_given["transparent_pixels"]
	end_pixel_black = result_given["black_pixels"]
	
	bonus_point_alpha = (float(origin_pixel_alpha)/float(end_pixel_alpha))*100 
	remaining_pixels_in_pourcent = (float(end_pixel_black)/float(origin_pixel_black))*100
	
	points_for_kanji_cut_in_percent = 100 - remaining_pixels_in_pourcent
	bonus_point_based_on_alpha = bonus_point_alpha
	total_score_in_percent = (bonus_point_based_on_alpha + points_for_kanji_cut_in_percent)/2
	#(terminer la fonction en calculant le % de reussite 100 - offset,... et ensuite addition des deux et mise
	
	total_score_in_percent = int(total_score_in_percent)
	
	## YOUR CODE HERE I DONT TOUCH THAT UP
	
	
	total_score_in_percent01.emit(total_score_in_percent*100.0)
	total_score_in_percent100.emit(total_score_in_percent)
	total_score_in_percent_string.emit("%.1f%%" % total_score_in_percent)
	
		
		
static func analyze_layer_pixels(texture: Texture2D, alpha_threshold: float = 0.05, black_threshold: float = 0.05) -> Dictionary:	
	var result = {
		"total_pixels": 0,
		"transparent_pixels": 0,
		"visible_pixels": 0,
		"black_pixels": 0,
		"other_pixels": 0
	}
	
	if not texture:
		push_error("PixelCounter: La texture fournie est vide (null).")
		return result
		
	var original_image : Image = texture.get_image()
	if original_image.is_empty():
		return result
	
	var img : Image = original_image.duplicate()
	img.decompress()
	
	var width = img.get_width()
	var height = img.get_height()
	result["total_pixels"] = width * height
	
	# Parcours de tous les pixels de l'image
	for y in range(height):
		for x in range(width):
			var pixel_color: Color = img.get_pixel(x, y)
			
			# 1. Vérification de l'Alpha (Transparence)
			if pixel_color.a <= alpha_threshold:
				result["transparent_pixels"] += 1
			else:
				result["visible_pixels"] += 1
				
				# 2. Vérification du Noir (proche de 0,0,0 sans compter l'alpha)
				# On utilise une tolérance (threshold) au cas où le noir n'est pas parfait (ex: 0.01)
				if pixel_color.r <= black_threshold and pixel_color.g <= black_threshold and pixel_color.b <= black_threshold:
					result["black_pixels"] += 1
				else:
					result["other_pixels"] += 1
					
	return result
