defmodule JD.FridgeTest do
  use ExUnit.Case
  doctest JD.Fridge

  setup do
    JD.Fridge.init
  end

  test "put/1" do
    assert JD.Fridge.put(name: :ice_creaem, calories: 750, price: 5.5, group: :dairy)
  end

  test "get/1" do
    food = JD.Fridge.get(:cake)

    name = Keyword.get(food, :name)
    assert :cake == name

    group = Keyword.get(food, :group)
    assert :delicious == group
  end

  test "of_group/1" do
    assert([
      [name: :salmon, calories: 88, price: 4.00, group: :meat],
      [name: :bacon, calories: 800, price: 6.32, group: :meat]
    ] == JD.Fridge.of_group(:meat))
  end

  test "high_calorie/0" do
    assert length(JD.Fridge.high_calorie()) > 0
  end
end
