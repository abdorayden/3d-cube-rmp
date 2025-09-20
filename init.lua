--
--	copyright (C) 2025 by rayden
--
-- 	Permission is hereby granted, free of charge, to any person obtaining a copy
-- 	of this software and associated documentation files (the "Software"), to deal
-- 	in the Software without restriction, including without limitation the rights
-- 	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- 	copies of the Software, and to permit persons to whom the Software is
-- 	furnished to do so, subject to the following conditions:
-- 	
-- 	The above copyright notice and this permission notice shall be included in
-- 	all copies or substantial portions of the Software.
-- 	
-- 	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- 	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- 	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- 	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- 	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- 	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
-- 	THE SOFTWARE.
--
--
-- name: 3d-cube-rmp
-- author : rayden
-- type : animation
-- LICENCE: check licence above

local api = require("rmp.rmp")

local A, B, C = 0.0, 0.0, 0.0  

return function(x, y, xx, yy)
	local h, w = (yy - y), (xx - x)
	local distanceFromCam = 100     
	local horizontalOffset = 0      
	local K1 = h                   
	local incrementSpeed = 0.07     

	
	local zBuffer = {}  
	local buffer = {}   
	local backgroundASCIICode = ' ' 

	
	for i = 1, w * h do
		zBuffer[i] = 0
		buffer[i] = backgroundASCIICode
	end

	
	local function calculateX(i, j, k)
		return j * math.sin(A) * math.sin(B) * math.cos(C) - k * math.cos(A) * math.sin(B) * math.cos(C) +
		j * math.cos(A) * math.sin(C) + k * math.sin(A) * math.sin(C) + i * math.cos(B) * math.cos(C)
	end

	
	local function calculateY(i, j, k)
		return j * math.cos(A) * math.cos(C) + k * math.sin(A) * math.cos(C) -
		j * math.sin(A) * math.sin(B) * math.sin(C) + k * math.cos(A) * math.sin(B) * math.sin(C) -
		i * math.cos(B) * math.sin(C)
	end

	
	local function calculateZ(i, j, k)
		return k * math.cos(A) * math.cos(B) - j * math.sin(A) * math.cos(B) + i * math.sin(B)
	end

	
	local function calculateForSurface(cubeX, cubeY, cubeZ, ch)
		local x_val = calculateX(cubeX, cubeY, cubeZ)
		local y_val = calculateY(cubeX, cubeY, cubeZ)
		local z_val = calculateZ(cubeX, cubeY, cubeZ) + distanceFromCam

		if z_val == 0 then
			z_val = 1e-6  
		end

		local ooz = 1 / z_val

		local xp = math.floor(w / 2 + horizontalOffset + K1 * ooz * x_val * 2)
		local yp = math.floor(h / 2 + K1 * ooz * y_val)

		local idx = xp + yp * w
		if idx >= 1 and idx <= w * h then
			if ooz > zBuffer[idx] then
				zBuffer[idx] = ooz
				buffer[idx] = ch
			end
		end
	end
	local vt = api.VirtualTerminal.new()

	
	for i = 1, w * h do
		zBuffer[i] = 0
		buffer[i] = backgroundASCIICode
	end

	
	A = A + incrementSpeed
	B = B + incrementSpeed
	C = C + 0.01

	
	for cubeX = -20, 20, 0.5 do
		for cubeY = -20, 20, 0.5 do
			calculateForSurface(cubeX, cubeY, -20, '@')
			calculateForSurface(20, cubeY, cubeX, '$')
			calculateForSurface(-20, cubeY, -cubeX, '~')
			calculateForSurface(-cubeX, cubeY, 20, '#')
			calculateForSurface(cubeX, -20, -cubeY, ';')
			calculateForSurface(cubeX, 20, cubeY, '+')
		end
	end

	
	for row = 1, h - 1 do
		local line = ""
		for col = 1, w do
			local idx = col + (row - 1) * w
			line = line .. (buffer[idx] or backgroundASCIICode)
		end
		vt:writeText(x, y + row - 1, line, api.FGColors.Brights.White, api.BGColors.NoBrights.Black)
	end

	return vt
end
