# a game is over when all fields are taken
# a game is over when all fields in a column are taken by a player
# a game is over when all fields in a row are taken by a player
# a game is over when all fields in a diagonal are taken by a player
# a player can take a field if not already taken
# players take turns taking fields until the game is over


require 'rspec'
class Game < Struct.new(:state, :plan)

  def initialize(plan)
#    puts plan
    @state = plan.include?(0)
    @plan = plan
  end

  def take_field(player, x, y)
    @plan[x][y] = player
    Game.new(@plan)
  end

  def is_full?
    !@state
  end

  def is_over?
    is_full?
  end


end



describe 'Game_over' do
  it 'game over when all fields are taken' do
    g = Game.new([[0, 0, 0], [0, 0, 0], [0, 0, 0]])
    g = g.take_field(p, 1, 1)

    expect(g.is_over?).to eq(false)
    3.times do |i|
      3.times do |j|
        puts i
        puts j
        g = g.take_field(:player1, i, j)

      end
    end

    expect(g.is_over?).to eq(true)
  end
end
