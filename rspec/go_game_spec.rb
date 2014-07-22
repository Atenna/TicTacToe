# a game is over when all fields are taken
# a game is over when all fields in a column are taken by a player
# a game is over when all fields in a row are taken by a player
# a game is over when all fields in a diagonal are taken by a player
# a player can take a field if not already taken
# players take turns taking fields until the game is over


require 'rspec'
class Game < Struct.new(:state, :plan)

  def initialize(plan)
    @state = false
    plan.each do |a|
     # puts a.inspect
      @state = true if a.include?(0)
    end

    #@state = plan.include?(0)
    @plan = plan
  end

  def take_field(player, x, y)
    if @plan[x][y] == 0
      @plan[x][y] = player
      Game.new(@plan)
    else
      raise ArgumentError, "Field is already taken"
    end
  end

  def is_full?
    !@state
  end

  def has_triple?
    @plan.each do |a|
      return true if a.uniq.size == 1 && !a.include?(0)
    end

    @plan.transpose.each do |a|
      return true if a.uniq.size == 1 && !a.include?(0)
    end

    a = []
    3.times do |i|
      a[i] = @plan[i][i]
    end
    return true if a.uniq.size == 1 && !a.include?(0)

    a = []
    3.times do |i|
      a[i] = @plan.transpose[i][i]
    end
    return true if a.uniq.size == 1 && !a.include?(0)

    return false
  end

  def is_over?
    return true if is_full? || has_triple?
    return false
  end

end

describe 'Game_over' do
  it 'game not over when one field is taken' do
    g = Game.new([[0, 0, 0], [0, 0, 0], [0, 0, 0]])
    g = g.take_field(:player1, 1, 1)
    expect(g.is_over?).to eq(false)
  end

  it 'game over when all fields are taken' do
    g = Game.new([[0, 0, 0], [0, 0, 0], [0, 0, 0]])
    # g = g.take_field(p, 1, 1)

    3.times do |i|
      3.times do |j|
        g = g.take_field(:player1, i, j)
      end
    end
    expect(g.is_over?).to eq(true)
  end

  it 'game over when whole column is taken by one player' do
    g = Game.new([[0, 0, 0], [0, 0, 0], [0, 0, 0]])
    3.times do |j|
      g = g.take_field(:player1, 0, j)
    end
    expect(g.is_over?).to eq(true)
  end

  it 'game over when whole row is taken by one player' do
    g = Game.new([[0, 0, 0], [0, 0, 0], [0, 0, 0]])
    3.times do |j|
      g = g.take_field(:player1, j, 0)
    end
    expect(g.is_over?).to eq(true)
  end

  it 'game over when a diagonal is taken by one player' do
    g = Game.new([[0, 0, 0], [0, 0, 0], [0, 0, 0]])
    3.times do |j|
      g = g.take_field(:player1, j, j)
    end
    expect(g.is_over?).to eq(true)
  end

  it 'a player can take a field if not already taken' do
    g = Game.new([[0, 0, 0], [0, 0, 0], [0, 0, 0]])
    g = g.take_field(:player1, 1, 1)
    expect{g.take_field(:player1, 1, 1)}.to raise_error(ArgumentError)
  end

end
