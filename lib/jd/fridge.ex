defmodule JD.Fridge do
  require Record

  @fields [:name, :calories, :price, :group]
  @fields_with_defaults for k <- @fields, do: {k, :_}

  Record.defrecordp :food, @fields_with_defaults

  def init do
    :ets.new(:fridge, [:named_table, :public, keypos: food(:name) + 1])
    :ets.new(:fridge_group_idx, [:named_table, :public, :bag])
    :lists.foreach(&put_record/1, [
      food(name: :salmon,   calories: 88,  price: 4.00, group: :meat),
      food(name: :cereals,  calories: 178, price: 2.79, group: :bread),
      food(name: :milk,     calories: 150, price: 3.23, group: :dairy),
      food(name: :cake,     calories: 650, price: 7.21, group: :delicious),
      food(name: :bacon,    calories: 800, price: 6.32, group: :meat),
      food(name: :sandwich, calories: 550, price: 5.78, group: :whatever)
    ])
  end

  def put(food) do
    food
    |> keywords2record
    |> put_record
  end

  def put_record(food(name: name, group: group) = record) do
    :ets.insert(:fridge, record)
    :ets.insert(:fridge_group_idx, {group, name})
  end

  def get(name) do
    case :ets.lookup(:fridge, name) do
      [record] ->
        food(record)
      [] ->
        nil
    end
  end

  def of_group(group) do
    :ets.lookup(:fridge_group_idx, group)
    |> Enum.flat_map(fn {^group, name} -> :ets.lookup(:fridge, name) end)
    |> convert_records
  end

  def high_calorie() do
    match_head = food(calories: :'$1')
    match_guard = {:>, :'$1', 100}
    match_result = :'$_'
    match_fun = {match_head, [match_guard], [match_result]}
    :ets.select(:fridge, [match_fun])
    |> convert_records
  end

  defp keywords2record(keywords) do
    values = for k <- @fields, do: Keyword.get(keywords, k)
    List.to_tuple([:food | values])
  end

  defp convert_records(records) do
    for r <- records, do: food(r)
  end
end
