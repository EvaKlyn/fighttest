extends Projectile3D

var speed = 1200
var g = Vector3.DOWN * 4.4
var velocity = Vector3.ZERO

func _on_body_entered(body):
	if is_multiplayer_authority():
		if body is StaticBody3D:
			queue_free()

func behavior(delta: float):
	velocity = -transform.basis.z * speed * delta
	velocity += g * delta
	look_at(transform.origin + velocity.normalized(), Vector3.UP)
	transform.origin += velocity * delta
	pass
