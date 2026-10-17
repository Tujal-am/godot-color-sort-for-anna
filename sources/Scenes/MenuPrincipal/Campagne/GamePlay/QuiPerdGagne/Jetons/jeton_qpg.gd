extends "res://Scenes/MenuPrincipal/Campagne/GamePlay/Plateau/Pile/Jeton/jeton.gd"
## Adaptateur de présentation uniquement. Aucun état métier réécrit.

const TEXTURES: Array[Texture2D] = [
    preload("res://Art/UI/Gameplay/QuiPerdGagne/Jetons/01_diablotin_256.png"),
    preload("res://Art/UI/Gameplay/QuiPerdGagne/Jetons/02_trident_256.png"),
    preload("res://Art/UI/Gameplay/QuiPerdGagne/Jetons/03_flamme_256.png"),
    preload("res://Art/UI/Gameplay/QuiPerdGagne/Jetons/04_eclair_256.png"),
    preload("res://Art/UI/Gameplay/QuiPerdGagne/Jetons/05_bombe_256.png"),
    preload("res://Art/UI/Gameplay/QuiPerdGagne/Jetons/06_bonnet_256.png"),
    preload("res://Art/UI/Gameplay/QuiPerdGagne/Jetons/07_queue_256.png"),
    preload("res://Art/UI/Gameplay/QuiPerdGagne/Jetons/08_chauve_souris_256.png"),
    preload("res://Art/UI/Gameplay/QuiPerdGagne/Jetons/09_crane_256.png"),
    preload("res://Art/UI/Gameplay/QuiPerdGagne/Jetons/10_lune_256.png")
]
const COULEURS_UI: Array[Color] = [Color("#02a2fc"), Color("#fb0394"), Color("#fd6301"), Color("#fdc603"), Color("#6903ee"), Color("#5fea12"), Color("#fb040e"), Color("#04ad4e"), Color("#0055fc"), Color("#a836fb")]
var _visible_ui := true
@onready var _visuel_qpg: TextureRect = $Carre/VisuelQPG

func _ready() -> void:
    super._ready()
    _appliquer_visuel()

func choisir_jeton(indice: int, redimensionner: bool = false) -> void:
    super.choisir_jeton(indice, redimensionner)
    _appliquer_visuel()

func _possede_texture() -> bool:
    return indice_jeton >= 0 and indice_jeton < TEXTURES.size()

func _appliquer_visuel() -> void:
    if not is_instance_valid(_visuel_qpg):
        return
    if _possede_texture():
        _visuel_qpg.texture = TEXTURES[indice_jeton]
        _visuel_qpg.visible = _visible_ui
        $Carre.color = Color.TRANSPARENT
        $Nom.hide()
        var teinte: Color = COULEURS_UI[indice_jeton]
        $SoudureHaute.color = teinte.darkened(0.3)
        $SoudureBasse.color = teinte.darkened(0.3)
        $Selection.color = teinte.darkened(0.3) if teinte.get_luminance() > 0.5 else teinte.lightened(0.3)
    else:
        # Cases vides et K–Z : présentation native distincte, aucun modulo.
        _visuel_qpg.texture = null
        _visuel_qpg.hide()
        $Carre.color = _couleur
        $Nom.visible = _visible_ui

func hide() -> void:
    _visible_ui = false
    super.hide()
    _visuel_qpg.hide()

func show() -> void:
    _visible_ui = true
    super.show()
    _appliquer_visuel()
