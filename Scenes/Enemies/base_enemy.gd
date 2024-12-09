extends CharacterBody2D

var _health: int = 5
var _stun_health: int = 0
var _damage: int = 1
const ExplosionEffect = preload("res://Scenes/Effects/medium_explosion.tscn")
var _hit_SFX: AudioStream = preload("res://Sound/BusterShotHit.wav")


var _player

@onready var _flash_timer: Timer = $FlashTimer
@onready var _stun_timer: Timer = $StunTimer
@onready var _sprite = $Sprite
@onready var _hurt_box: HurtBox = $HurtBox
@onready var _health_component: HealthComponent = $HealthComponent
@onready var _state_label: Label = $Label
@onready var _effect_audio_player: EffectAudioPlayer = $EffectAudioPlayer
var _tween: Tween

var tempStunState: bool = false

func _ready():
	_player = get_tree().get_first_node_in_group("Player")
	_health_component.connect("health_change", _update_health)
	_health_component.connect("die", die)
	_health_component.connect("stun_break", _stun_break)
	_health_component.connect("restore_stun", _restore_state)
	$AspectRatioContainer/Health.max_value = _health_component._max_health
	$AspectRatioContainer/StunHealth.max_value = _health_component._max_stun_health
	$AspectRatioContainer/Health.value = _health
	$AspectRatioContainer/StunHealth.value = _stun_health
	_state_label.text = "normal"

func _physics_process(delta):
	move_and_slide()


func _hit_flash():
	_sprite.material.set_shader_parameter("active", true)
	_flash_timer.start(0.1)

func _hit_push(direction: Vector2, power: int) -> void:
	power *= 10
	var push_vector = direction * power
	velocity = push_vector
	create_tween().tween_property(self, "velocity", Vector2.ZERO, 0.3)

func _reset_sprite_flash() -> void:
	_sprite.material.set_shader_parameter("active", false)

func _on_flash_timer_timeout():
	if tempStunState == false:
		_reset_sprite_flash()

func _update_health(h: int, s: int) -> void:
	if _health != h:
		_hit_flash()
	_health = h
	_stun_health = s
	$AspectRatioContainer/Health.value = h
	$AspectRatioContainer/StunHealth.value = s
	_effect_audio_player.play_sound(_hit_SFX)
	

func _stun_break() -> void:
	_stun_timer.start(5.0)
	tempStunState = true
	_state_label.text = "stun"
	_sprite.material.set_shader_parameter("active", true)
	_sprite.material.set_shader_parameter("stun", true)
	_tween = create_tween()
	_tween.set_loops()
	_tween.tween_method(func(value): _sprite.material.set_shader_parameter("mix_factor", value), 0.4, 0.8, 1)
	_tween.chain().tween_method(func(value): _sprite.material.set_shader_parameter("mix_factor", value), 0.8, 0.4, 1)

func _restore_state(direction: Vector2, power: int) -> void:
	tempStunState = false
	if power != 0:
		_hit_push(direction, power)
	_sprite.material.set_shader_parameter("stun", false)
	_state_label.text = "normal"
	_tween.kill()
	_reset_sprite_flash()

func die():
	var ExplosionInstance = ExplosionEffect.instantiate()
	get_parent().add_child(ExplosionInstance)
	ExplosionInstance.position = global_position
	queue_free()


func _on_stun_timer_timeout():
	_restore_state(Vector2.ZERO, 0)
	_health_component._reset_stun_health()
