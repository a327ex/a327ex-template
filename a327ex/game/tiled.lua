tiled = {}


function tiled.get_polygons(map_name, layer_name)
  local polygons = {}
  local map = require("assets/maps/" .. map_name)

  for _, layer in ipairs(map.layers) do
    if layer.type == 'objectgroup' and layer.name == layer_name then
      for _, object in ipairs(layer.objects) do
        if object.shape == 'polygon' then
          local polygon = {}
          for _, point in ipairs(object.polygon) do
            table.insert(polygon, point.x)
            table.insert(polygon, point.y)
          end
          table.insert(polygons, polygon)
        end
      end
    end
  end

  return polygons
end


function tiled.get_points(map_name, layer_name)
  local points = {}
  local map = require("assets/maps/" .. map_name)

  for _, layer in ipairs(map.layers) do
    if layer.type == 'objectgroup' and layer.name == layer_name then
      for _, object in ipairs(layer.objects) do
        if object.shape == 'point' then
          table.insert(points, {x = object.x, y = object.y})
        end
      end
    end
  end

  return points
end
