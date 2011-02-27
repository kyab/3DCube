# 3DView.rb
# 3DCube
#
# Created by koji on 11/02/08.
# Copyright 2011 __MyCompanyName__. All rights reserved.

#左手座標系を使う。

module Rotator
	extend Math
	module_function
	def rotateX(theta, x,y,z)
		newX = x
		newY = y * cos(theta)  + z *sin(theta)
		newZ = - y * sin(theta) +  z *cos(theta)
		
		return newX, newY, newZ
	end
	
	def rotateY(theta, x, y, z)
		newX = x*cos(theta) - z*sin(theta)
		newY = y
		newZ = x*sin(theta) + z*cos(theta)
		return newX, newY, newZ
	end
	
	def rotateZ(theta, x, y, z)
		newX = x*cos(theta) - y*sin(theta)
		newY = x*sin(theta) + y*cos(theta)
		newZ = z
		return newX, newY, newZ
	end
	
	def shiftX(shift_x, x,y,z)
		[x+shift_x, y, z]
	end
	
	def shiftY(shift_y, x, y, z)
		[x, y+shift_y,z]
	end
	
end

class Array
	def addZ(val)
		[self[0], self[1], self[2] + val]
	end
	
	def scale(scale)
		[self[0]*scale, self[1]*scale, self[2]*scale]
	end
	
	def toNSPoint
		NSMakePoint(self[0], self[1])
	end
	
	def rotateX(theta)
		Rotator.rotateX(theta, self[0], self[1], self[2])
	end
	
	def rotateY(theta)
		Rotator.rotateY(theta, self[0], self[1], self[2])
	end
	
	def rotateZ(theta)
		Rotator.rotateZ(theta, self[0], self[1], self[2])
	end
	
	def shiftY(shift_y)
		shift(0,shift_y,0)
	end
	def shiftX(shift_x)
		shift(shift_x,0,0)
	end
	def shiftZ(shift_z)
		shift(0,0,shift_z)
	end
	
	def shift(sx,sy,sz)
		[self[0] + sx, self[1] +sy, self[2] + sz]
	end
	
	#scale,shift,rotateがあればOK.
	#3dTrandformクラスとかがあると尚良し
	def with_transform()
		#とかできると良いなぁ！この中では変換が適用されるとか。
	end
	
	def toCamera(d1,d2)
		x = self[0]
		y = self[1]
		z = self[2]
		
		cameraX = x * d1 / (d2 + z)
		cameraY = y * d1 / (d2 + z)
		return cameraX, cameraY
	end
	
end

class Fixnum
	def degree
		2 * Math::PI / 360 * self
	end
end

def rotate_to_world
	#ワールド座標系の回転
end

def to_camera
	#ワールド座標系からカメラ座標へ。
end
class The3DView < NSView
	
	attr_accessor :rotateY	#degree
	attr_accessor :rotateX 
	include Rotator
	include Math
	def initWithFrame(rect)
		super
		@rotateY = -10
		@rotateX = 20
		self
	end
	
	def rotateY=(newDegree)
		@rotateY = newDegree
		self.setNeedsDisplay(true)
		puts "rotateY=#{newDegree}"
	end
	
	def setRotateY(val)
		self.rotateY = val
	end
	
	def rotateX=(newDegree)
		@rotateX = newDegree
		self.setNeedsDisplay(true)
		puts "roteteX=#{newDegree}"
	end
	def setRotateX(val)
		self.rotateX = val
	end
	
	def toCamera(point3d, d1,d2)
		x = point3d[0]
		y = point3d[1]
		z = point3d[2]
		
		cameraX = x * d1 / (d2+z)
		cameraY = y * d1 / (d2+z)
		return cameraX, cameraY
	end	
	
	#convert point[in camera] to point in this view
	def toScreen(point2d)
		camera_size = NSSize.new
		camera_size.width = 200
		camera_size.height = 200
		
		bounds = self.bounds
		
		#shift, then scale
		x ,y = point2d[0], point2d[1]
		x = x + camera_size.width/2.0
		y = y + camera_size.height/2.0
		
		#scale
		x = x * bounds.size.width/camera_size.width
		y = y * bounds.size.height/camera_size.width
		
		[x,y]
	end
	
	#degree to radian
	def degree(degree)
		2 * PI / 360 * degree
	end
	
	def drawRect(dirtyRect)
		NSColor.blackColor.set
		NSRectFill(self.bounds)
		#self.setBounds(NSMakeRect(-100,-100, 200,200))
				
		NSBezierPath.defaultLineWidth = 2.0
				
		#draw x,y, and z axis
		NSColor.whiteColor.set
		xaxis = [[-80,0,0],[80,0,0]]
		xaxis.map! do |axisPoint|
			axisPoint.rotateY(degree(@rotateY)).rotateX(degree(@rotateX))
		end
		from = toScreen(xaxis[0]).toNSPoint
		to = toScreen(xaxis[1]).toNSPoint
		NSBezierPath.strokeLineFromPoint(from, toPoint:to)
		
		NSColor.greenColor.set
		xaxis = [[0, -80,0],[0,80,0]]
		xaxis.map! do |axisPoint|
			axisPoint.rotateY(degree(@rotateY)).rotateX(degree(@rotateX))
		end
		from = toScreen(xaxis[0]).toNSPoint
		to = toScreen(xaxis[1]).toNSPoint
		NSBezierPath.strokeLineFromPoint(from, toPoint:to)
		
		NSColor.blueColor.set
		xaxis = [[0, 0, -80],[0,0,80]]
		xaxis.map! do |axisPoint|
			axisPoint.rotateY(degree(@rotateY)).rotateX(degree(@rotateX))#.toCamera(50,200)
		end
		from = toScreen(xaxis[0]).toNSPoint
		to = toScreen(xaxis[1]).toNSPoint
		NSBezierPath.strokeLineFromPoint(from, toPoint:to)
		
		#the cube
		points3D = Array.new(8,[0,0,0])
		points3D[0] = [30,30,0]
		points3D[1] = [130,30,0]
		points3D[2] = [130, 130,0]
		points3D[3] = [30, 130, 0]
		
		points3D[4] = points3D[0].addZ(500)
		points3D[5] = points3D[1].addZ(500)
		points3D[6] = points3D[2].addZ(500)
		points3D[7] = points3D[3].addZ(500)
		
		points3D.map! do |point3D| 
			point3D.scale(0.8).
								rotateX(-20.degree).
								shiftY(20).
								rotateY(degree(@rotateY)).rotateX(degree(@rotateX))
		end
		
		points = points3D.map do |p|
			toScreen(toCamera(p, 100,600))
		end
		
		pathNear = NSBezierPath.bezierPath
		pathNear.moveToPoint( points[0].toNSPoint )
		pathNear.lineToPoint( points[1].toNSPoint )
		pathNear.lineToPoint( points[2].toNSPoint )
		pathNear.lineToPoint( points[3].toNSPoint )
		pathNear.lineToPoint( points[0].toNSPoint )
		
		pathFar = NSBezierPath.bezierPath
		pathFar.moveToPoint( points[4].toNSPoint )
		pathFar.lineToPoint( points[5].toNSPoint )
		pathFar.lineToPoint( points[6].toNSPoint )
		pathFar.lineToPoint( points[7].toNSPoint )
		pathFar.lineToPoint( points[4].toNSPoint )
		NSColor.orangeColor().set
		pathFar.stroke
		NSColor.cyanColor.set
		pathNear.stroke

		NSColor.grayColor().set
		[0,1,2,3].each do |index|
			NSBezierPath.strokeLineFromPoint(points[index].toNSPoint, toPoint: points[index+4].toNSPoint)
		end
		
		#
		drawText("x", [80,0,0])
		drawText("y", [0,80,0])
		drawText("z", [0,0,80])
	
	end
	
	#draw text centerized on point3D
	def drawText(text, point3D)	
	
		
		attributes = {
			NSFontAttributeName => NSFont.fontWithName("Monaco", size:12),
			NSForegroundColorAttributeName => NSColor.whiteColor
		}
		point = point3D.rotateY(degree(@rotateY)).rotateX(degree(@rotateX)).toNSPoint
		point = toScreen(point)
		at_text = NSAttributedString.new.initWithString(text, attributes:attributes)
		
		size = NSSize.new
		size.width = 200
		size.height = 200
		rect = at_text.boundingRectWithSize(size, options:NSStringDrawingUsesLineFragmentOrigin)
		#p rect
		rect.origin.x = point[0] - rect.size.width/2
		rect.origin.y = point[1]+3
		#p at_text.size
		
		at_text.drawInRect(rect)
	end

end