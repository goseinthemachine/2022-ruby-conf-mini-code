GRID_SIZE = 20

def handle_input args
end

def update args
end

def render_grid args
  x_axis = args.grid.w / GRID_SIZE
  x_axis.each_with_index do |x|
        args.outputs.lines <<
        {x: x * GRID_SIZE, y: 0, x2: x * GRID_SIZE, y2: args.grid.h}
  end
end

def render args
  render_grid args
end

def tick args
  handle_input args
  update args
  render args
end
