Pi <- 3.14159265

function AngleBetween(v1, v2) {
	local aZ = atan2((v1.y - v2.y), (v1.x - v2.x))+Pi;	
	local aY = atan2((v1.z - v2.z), (v1 - v2).Length2D())+Pi;
	
	return Vector(aY, aZ,0.0);
}
function rad2deg(r) {
	return r * (180.0 / Pi)
}


function Think_XY() {
	player <- Entities.FindByClassnameNearest( "player", self.GetOrigin(), 4096.0*4096.0)
	if( player && player.IsValid() ) {
		vec <- player.EyePosition() - self.GetOrigin()
		vec.Norm()
		self.SetForwardVector(Vector(vec.x, vec.y, 0))	
	}
}



function Think() {
	origin <- self.GetOrigin()
	
	player <- Entities.FindByClassnameNearest( "player", origin, 4096.0*4096.0)
	if( player && player.IsValid() ) {
		ang <- AngleBetween(origin, player.EyePosition())
		self.SetAngles(180 - (rad2deg(ang.x) + 90), 180, 0)
	}
}