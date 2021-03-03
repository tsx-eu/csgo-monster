tick <- -1
end <- 0

function tsx_Think()
{
	if( tick == -1 ) {		
		tick <- self.GetTeam()
		end <- self.GetMaxHealth()
		
		if( end > 0 )
			DoEntFire( "!self", "LightOff", "", 0, self, self )
	}
	
	if( end > 0 ) {
		// self
		tick++
		
		if( tick == end-5 )
			DoEntFire( "!self", "LightOn", "", 0, self, self )
		
		if( tick >= end )
			DoEntFire( "!self", "LightOff", "", 0, self, self )
		
		if( tick >= end )
			tick = 1
	}
	
}