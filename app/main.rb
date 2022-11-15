GRID_SIZE = 20
SPEED = 10

def handle_input args
  inputs = args.inputs
  if args.state.game_state == :game_over
    if inputs.keyboard.key_down.escape
      $gtk.reset_next_tick
    end
  else 
    head = args.state.head
    if args.tick_count.mod_zero? SPEED
      head.previous_direction = head.direction
      if inputs.left && head.previous_direction != :right
        head.direction = :left
      elsif inputs.right && head.previous_direction != :left
        head.direction = :right
      elsif inputs.up && head.previous_direction != :down
        head.direction = :up
      elsif inputs.down && head.previous_direction != :up
        head.direction = :down
      end
    end
  end
end

def move_snake args
  snake = [args.state.head, *args.state.body]
  snake.each_with_index do |segment, index|
    segment.previous_direction = segment.direction unless index == 0
    segment.direction = snake[index - 1].previous_direction unless index == 0
    vector = { x: 0, y: 0 }
    case segment.direction
    when :right
      vector.x = 1
    when :left
      vector.x = -1
    when :down
      vector.y = -1
    when :up
      vector.y = 1
    end
    segment.x += GRID_SIZE * vector.x
    segment.y += GRID_SIZE * vector.y
  end
end

def handle_boundary_collision args
  walls = args.state.walls
  head = args.state.head
  if [walls.left, walls.right, walls.top, walls.bottom].any_intersect_rect?  args.state.head 
    # head.x = head.x.clamp(walls.left.right, walls.right.left - GRID_SIZE)
    # head.y = head.y.clamp(walls.bottom.top, walls.top.bottom - GRID_SIZE)
    args.state.game_state = :game_over
  end
end

def handle_body_collision args
  if args.state.body.any_intersect_rect? args.state.head
    # p "COLLIDED WITH BODY"
    args.state.game_state = :game_over
  end
end

def grow_body args
  segment = args.state.body.any? ? args.state.body.last.clone 
    args.state.head.clone
  vector = { x: 0, y: 0 }
  if segment.direction == :right
    vector.x = -1
  elsif segment.direction == :left
    vector.x = 1
  elsif segment.direction == :down
    vector.y = 1
  elsif segment.direction == :up
    vector.y = -1
  end

  segment.x += (GRID_SIZE * vector.x)
  segment.y += (GRID_SIZE * vector.y)
  args.state.body << segment
end

def handle_collectable_collision args
  return if args.state.collectable.nil?
  if args.state.collectable.intersect_rect? args.state.head
    args.state.collectable = nil
    args.state.score += 1
    args.outputs.sounds << "sounds/collect.wav"
    grow_body args 
  end
end

def spawn_collectable args
  if args.state.collectable.nil?
    x_rand = ((args.grid.w / GRID_SIZE) - 1).randomize(:ratio).ceil 
    y_rand = ((args.grid.h / GRID_SIZE) - 1).randomize(:ratio).ceil 
    args.state.collectable = {
      x: x_rand * GRID_SIZE,
      y: y_rand * GRID_SIZE,
      h: GRID_SIZE,
      w: GRID_SIZE,
      r: 233,
      g: 23,
      b: 23
    }
  end
end

def update args
  return if args.state.game_state == :game_over
  if args.tick_count.mod_zero? SPEED
    move_snake args
    handle_boundary_collision args
    handle_collectable_collision args
    handle_body_collision args
    spawn_collectable args
  end
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
  args.outputs.solids << [args.state.head, *args.state.body]
end

def render_walls args
  walls = args.state.walls
  args.outputs.solids << [walls.left, walls.right, walls.top, walls.bottom]
end

def render_collectable args
  args.outputs.solids << args.state.collectable
end

def render_score args
  args.outputs.labels << { x: args.grid.left.shift_right(2 * GRID_SIZE), y: args.grid.top.shift_down(2 * GRID_SIZE), text: "Score: #{args.state.score}"}
end

def render_game_over args
  args.outputs.labels << {
    x: args.grid.w / 2, 
    y: (args.grid.h / 2).shift_up(16), 
    text: "GAME OVER!", 
    size_enum: 10, 
    alignment_enum: 1 
  }
  args.outputs.labels << {
    x: args.grid.w / 2,
    y: (args.grid.h / 2).shift_down(24),
    text: "Final Score was #{args.state.score} points!",
    size_enum: 1,
    alignment_enum: 1 
  }
  args.outputs.labels << {
    x: args.grid.w / 2,
    y: (args.grid.h / 2).shift_down(48),
    text: "Press Escape to try again",
    size_enum: 0,
    alignment_enum: 1
  }
end

def render args
  if args.state.game_state == :game_over
    render_game_over args
  else 
    render_grid args
    render_snake args
    render_walls args
    render_collectable args
    render_score args
  end
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

  args.state.walls.left ||= {
    x: args.grid.left, 
    y: args.grid.bottom, 
    h: args.grid.h, 
    w: GRID_SIZE, 
    r: 12, g: 33, b: 245 
  }
  args.state.walls.right ||= {
    x: args.grid.right - GRID_SIZE, 
    y: args.grid.bottom, 
    h: args.grid.h, 
    w: GRID_SIZE, 
    r: 12, g: 33, b: 245 
  }
  args.state.walls.top ||= {
    x: args.grid.left, 
    y: args.grid.top - GRID_SIZE, 
    h: GRID_SIZE, 
    w: args.grid.w, 
    r: 12, g: 33, b: 245 
  }
  args.state.walls.bottom ||= {
    x: args.grid.left, 
    y: args.grid.bottom, 
    h: GRID_SIZE, 
    w: args.grid.w, 
    r: 12, g: 33, b: 245 
  }

  args.state.score ||= 0
  args.state.body ||= []
  args.state.game_state ||= :in_play
end

def tick args
  defaults args
  handle_input args
  update args
  render args
end
