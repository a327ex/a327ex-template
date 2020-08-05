tiled = {}


function tiled.get_polygons(path)
  local polygons = {}
  local map = require(path)

  for _, layer in ipairs(map.layers) do
    if layer.type == 'objectgroup' then
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
