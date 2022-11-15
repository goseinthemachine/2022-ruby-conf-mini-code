GRID_SIZE = 20

def handle_input args
end

def update args
end

def render_grid args
  x_axis = args.grid.w / GRID_SIZE                                                                                                                                                                                                                                     
  y_axis = args.grid.h / GRID_SIZE                                                                                                                                                                                                                                     
  x_axis.each_with_index do |x|                                                                                                                                                                                                                                        
    args.outputs.lines <<
        {
          x: x * GRID_SIZE, 
          y: 0, 
          x2: x * GRID_SIZE, 
          y2: args.grid.h
        }
  end

  y_axis.each_with_index do |y|
    args.outputs.lines <<
      {
        x: 0, 
        y: y * GRID_SIZE, 
        x2: args.grid.w, 
        y2: y * GRID_SIZE
      }
  end
end

def render_snake args
  args.outputs.solids << args.state.head
end

def render args
  render_grid args
  render_snake args
end

def defaults args
  args.state.head ||=
  {
    x: args.grid.w / 2,
    y: args.grid.h / 2,
    w: GRID_SIZE,
    h: GRID_SIZE,
    r: 23,
    g: 245,
    b: 23,
  }
end

def tick args
  defaults args
  handle_input args
  update args
  render args
end
