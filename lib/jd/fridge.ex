defmodule JD.Fridge do
  require Record

  @fields for k <- [:name, :calories, :price, :group], do: {k, :_}

  Record.defrecord :food, @fields

  def init do
    :ets.new(:fridge, [:named_table, :public, keypos: food(:name) + 1])
    :ets.new(:fridge_group_idx, [:named_table, :public, :bag, keypos: food(:group) + 1])
    :lists.foreach(&put/1, [
      food(name: :salmon,   calories: 88,  price: 4.00, group: :meat),
      food(name: :cereals,  calories: 178, price: 2.79, group: :bread),
      food(name: :milk,     calories: 150, price: 3.23, group: :dairy),
      food(name: :cake,     calories: 650, price: 7.21, group: :delicious),
      food(name: :bacon,    calories: 800, price: 6.32, group: :meat),
      food(name: :sandwich, calories: 550, price: 5.78, group: :whatever)
    ])
  end

  def put(food) do
    :ets.insert(:fridge, food)
    :ets.insert(:fridge_group_idx, food)
  end

  def get(name) do
    case :ets.lookup(:fridge, name) do
      [food] ->
        food
      [] ->
        nil
    end
  end

  def of_group(group) do
    :ets.lookup(:fridge_group_idx, group)
  end

  def high_calorie() do
    match_head = food(calories: :'$1')
    match_guard = {:>, :'$1', 100}
    match_result = :'$_'
    match_fun = {match_head, [match_guard], [match_result]}
    :ets.select(:fridge, [match_fun])
  end
end
