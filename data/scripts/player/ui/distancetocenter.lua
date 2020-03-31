
-- namespace DTC
DTC = {}

if onClient() then

MyLabel = {}
function MyLabel:new(container, color, x, y, font_size)
	local o = {}
	setmetatable(o, self)
	self.__index = self

	o.label = container:createLabel(vec2(x,y), '', font_size)

	if color ~= nil then
		o.label.color = color
	end

	o.offset = vec2(x,y)

	function MyLabel:setPosition(pos)
		self.label.position = pos + self.offset
	end

	function MyLabel:resetPosition()
		self.label.position = self.offset
	end

	function MyLabel:setCaption(caption)
		self.label.caption = caption
	end

	function MyLabel:hide()
		self.label:hide()
	end

	function MyLabel:show()
		self.label:show()
	end

	return o
end

function DTC.initialize()
	local player = Player()
	player:registerCallback("onPreRenderHud", "onPreRenderHud")
	player:registerCallback("onMapRenderAfterUI", "onMapRenderAfterUI")

	local sector = Sector()
	local x, y = sector:getCoordinates()
	local distance = math.sqrt(x * x + y * y)
	local hud = Hud()
	local hc = hud:createContainer(Rect())
	local mc = GalaxyMap():createContainer(Rect())

	local grey = ColorARGB(1,0.6,0.6,0.6)
	local white = ColorARGB(1,0.9,0.9,0.9)

	DTC.hud = {}
	DTC.hud.resource_offset = vec2(300, 0)
	DTC.hud.label_key = MyLabel:new(hc, nil, 5, 40, 15)
	DTC.hud.label_value = MyLabel:new(hc, nil, 250, 40, 15)

	DTC.hud.label_key:setCaption(string.format('Distance', distance))
	DTC.hud.label_value:setCaption(string.format('%d', distance))

	DTC.map = {}
	DTC.map.hover = {}
	DTC.map.select = {}

	DTC.map.hover.dist = MyLabel:new(mc, grey, 25, 5, 13)

	DTC.map.hover.diff = MyLabel:new(mc, white, 125, 5, 13)
	DTC.map.hover.diff_coord = MyLabel:new(mc, white, 125, -15, 13)

	DTC.map.select.dist = MyLabel:new(mc, w, 25, 5, 13)
	DTC.map.select.coord = MyLabel:new(mc, w, 25, -15, 13)

	DTC.map.line = mc:createArrowLine()
	DTC.map.line.color = ColorARGB(0.4,1,1,1)
	DTC.map.line.layer = -10
	DTC.map.line.width = 8
end

function DTC.getCoordData()
	local map = GalaxyMap()

	local x, y = map:getHoveredCoordinates()
	local hovered_coord = ivec2(x, y)

	local x, y = map:getSelectedCoordinates()
	local selected_coord = ivec2(x, y)

	local hovered_pos = vec2(map:getCoordinatesScreenPosition(hovered_coord))
	local selected_pos = vec2(map:getCoordinatesScreenPosition(selected_coord))

	local hovered_distance = math.sqrt(hovered_coord.x * hovered_coord.x + hovered_coord.y * hovered_coord.y)
	local selected_distance = math.sqrt(selected_coord.x * selected_coord.x + selected_coord.y * selected_coord.y)

	return {
		hover =
		{
			coord = hovered_coord,
			pos = hovered_pos,
			dist  = hovered_distance
		},
		select =
		{
			coord = selected_coord,
			pos = selected_pos,
			dist  = selected_distance
		},
	}
end

function DTC.stringize(value)
	if value >= 0 then
		return '+' .. tostring(round(value, 0))
	else
		return tostring(round(value, 0))
	end
end

function DTC.onMapRenderAfterUI()

	-- Unwrap some of the ungodly nesting
	local h = DTC.map.hover
	local s = DTC.map.select
	local l = DTC.map.line
	local cd = DTC.getCoordData() 

	s.coord:setPosition(cd.select.pos)
	s.coord:setCaption(string.format('%d : %d', cd.select.coord.x, cd.select.coord.y))

	s.dist:setPosition(cd.select.pos)
	s.dist:setCaption(string.format('(%d)', cd.select.dist))

	h.dist:setPosition(cd.hover.pos)
	h.dist:setCaption(string.format('(%d)', cd.hover.dist))

	h.diff:setPosition(cd.hover.pos)
	h.diff_coord:setPosition(cd.hover.pos)

	if Keyboard():keyPressed(KeyboardKey.LShift) then
		l.to = cd.hover.pos
		l.from = cd.select.pos
		l:show()

		coord_diff = cd.hover.coord - cd.select.coord
		x_str = DTC.stringize(coord_diff.x)
		y_str = DTC.stringize(coord_diff.y)

		h.diff:setCaption(DTC.stringize(cd.hover.dist - cd.select.dist))
		h.diff:show()

		h.diff_coord:setCaption(x_str .. ' ' .. y_str)
		h.diff_coord:show()
	else
		l:hide()
		h.diff:hide()
		h.diff_coord:hide()
	end
end

function DTC.onPreRenderHud()
	local hud = DTC.hud

	if Hud().resourcesVisible then
		hud.label_key:setPosition(DTC.hud.resource_offset)
		hud.label_value:setPosition(DTC.hud.resource_offset)
	else
		hud.label_key:resetPosition()
		hud.label_value:resetPosition()
	end
end

end